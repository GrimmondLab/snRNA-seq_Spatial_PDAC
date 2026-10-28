# Stage 1: Doublet removal + fixed QC thresholds

R 4.3.0 · Bioconductor 3.17 · master script `run_stage1.R`

`run_stage1.R` renders two R Markdown files in order:

1. `Preprocessing_DoubleDetection.Rmd`: reads the CellBender `.h5` files, removes very low-quality cells, normalises, clusters, and removes doublets with scDblFinder.
2. `Preprocessing_QC.Rmd`: applies fixed QC thresholds to cells and genes, and writes `qc.dbl.fltrd.sts.sce.RDS`.

The analyses from Stage 2 onward start from the original post-QC object deposited with the manuscript, not from this stage's output (see the top-level `README.md`).

## Environment

| | Version |
|---|---|
| R | 4.3.0 (`rocker/r-ver:4.3.0`, Ubuntu 22.04, linux/amd64) |
| Bioconductor | 3.17 (scDblFinder 1.14.0, scater 1.28.0, scran 1.28.1, scuttle 1.10.1, DropletUtils 1.20.0) |
| CRAN | Posit Package Manager snapshot from 2023-06-15 (dplyr 1.1.2, ggplot2 3.4.2, Seurat 4.3.0), plus uwot 0.1.16, RcppAnnoy 0.0.21 and matrixStats 1.2.0 |

Versions follow `sessionInfo/`. `install_packages.R` checks the key versions at the end and stops the build if any of them differ. It then saves the image's real `sessionInfo()` to `/pipeline/sessionInfo_container.txt`.

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | Image definition |
| `install_packages.R` | Installs and checks R packages (runs during build) |
| `run_stage1.R` | Master script; `Rscript run_stage1.R [config.yml]` |
| `Preprocessing_DoubleDetection.Rmd`, `Preprocessing_QC.Rmd` | Analysis steps |
| `config.yml` | Settings for **GEO input**, with container paths (default) |
| `config_local.yml` | Settings for the **original CellBender folders**, with container paths |
| `config_hpc.yml` | Original settings with HPC paths (record only) |
| `geo_samples.csv` | Links each GEO entry to the sample name used in the analysis, and sets the loading order |
| `geo_input.R` | Prepares the GEO files for loading (used in GEO mode) |
| `SG_sample_meta.csv` | Sample metadata; mounted at run time, not copied into the image |
| `sessionInfo/` | Session information of the original analysis (see the note inside) |

## Input

The input is the CellBender-filtered counts for 30 samples. The stage can read them in two forms. From loading onward, both modes run the same code.

| Mode | Config | Input | Use |
|---|---|---|---|
| `geo` | `config.yml` (default) | GEO processed files, [GSE282918](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282918): `<sample>_cellbender_filtered.h5` per sample (default), or `<sample>_barcodes.tsv.gz`, `<sample>_features.tsv.gz`, `<sample>_matrix.mtx.gz` | Public reproduction |
| `local` | `config_local.yml` | Original CellBender folders (`*_cellbender_filtered.h5`) | Reproducibility test against the original run |

**GEO mode.** Download all processed files for the series into one folder; subfolders and a `GSM…_` prefix on the file names are fine. `geo_samples.csv` links each GEO entry (`geo_title`, `file_prefix`) to the sample name used in the analysis (`sample`). `geo_format` in `config.yml` chooses which files are read: `h5` (default) reads `<file_prefix>_cellbender_filtered.h5`, the same file the original run read; `mtx` reads the three matrix files. All samples use the same format, and only that format needs to be downloaded. The run stops if any sample's file is missing or matches more than one file.

**Local mode.** The files are found by searching `/data/cellbender` recursively, and the sample name comes from the file name. Sample 2302 has two sections with the same name. The second one is identified by its sequencing run ID (`190819_A00130_0114`) in its file path, so the folder layout must keep that run ID.

**Sample order.** `read10xCounts` prefixes each cell ID with the sample's position (`1_…`, `2_…`). Later steps rely on these IDs, so GEO mode must load the samples in the same order as the original run. Each run writes `Preprocessing_DoubleDetection/sample_order.csv`. The `order` column of `geo_samples.csv` is the original run's loading order, taken from its sample map (`orig.ident` 1–30).

## Build

```bash
docker build -t pdac-stage1:1.0 .
```

The first build compiles a lot of Bioconductor code from source. Expect roughly 30–60 minutes.

## Run with Docker

The container expects three mounts:

| Container path | Mount | Mode |
|---|---|---|
| `/data/geo` (GEO mode) or `/data/cellbender` (local mode) | input files | read-only |
| `/data/meta` | folder containing `SG_sample_meta.csv` | read-only |
| `/output` | where results go | read-write |

GEO input (default):

```bash
docker run --rm \
  --cpus 12 --memory 64g \
  -v /path/to/geo_files:/data/geo:ro \
  -v /path/to/meta:/data/meta:ro \
  -v /path/to/output:/output \
  pdac-stage1:1.0
```

Original CellBender folders:

```bash
docker run --rm \
  --cpus 12 --memory 64g \
  -v /path/to/cellBender/samples:/data/cellbender:ro \
  -v /path/to/meta:/data/meta:ro \
  -v /path/to/output:/output \
  pdac-stage1:1.0 config_local.yml
```

Results are written to `/output/Preprocessing_DoubleDetection/` and `/output/Preprocessing_QC/` (HTML reports and `.RDS` objects).

To change settings without rebuilding, mount your own config and pass its path:

```bash
docker run --rm \
  -v /path/to/geo_files:/data/geo:ro \
  -v /path/to/meta:/data/meta:ro \
  -v /path/to/output:/output \
  -v /path/to/my_config.yml:/pipeline/my_config.yml:ro \
  pdac-stage1:1.0 my_config.yml
```

To copy the image's session information out without running the pipeline:

```bash
docker run --rm --entrypoint cat pdac-stage1:1.0 /pipeline/sessionInfo_container.txt > sessionInfo_container.txt
```

## Run with Apptainer/Singularity

Many clusters don't allow Docker, but Apptainer can run the same image:

```bash
docker save pdac-stage1:1.0 -o pdac-stage1_1.0.tar
```

```bash
apptainer build pdac-stage1_1.0.sif docker-archive://pdac-stage1_1.0.tar
```

```bash
apptainer run --pwd /pipeline \
  --bind /path/to/geo_files:/data/geo \
  --bind /path/to/meta:/data/meta \
  --bind /path/to/output:/output \
  pdac-stage1_1.0.sif
```

For the original CellBender folders, bind them to `/data/cellbender` instead and add `config_local.yml` at the end.

## Resources

- `workers: 12` in `config.yml`. Give the job at least that many CPUs, or lower the value.
- Around 140k cells × 36k genes: request plenty of memory (64 GB is a safe start).
- `denoisePCA` alone took about 1.5 h on the original machine.
- `dbl_workers: 4` is deliberate. With 12 workers scDblFinder failed, and with `RNGseed` + 4 workers the results were reproducible.

## Expected results (sanity checks)

- 30 samples loaded (the run stops otherwise).
- scDblFinder: 129,115 singlets / 6,867 doublets.
- Final object after QC: 26,757 genes × 115,293 cells (Oct 26 rerun).

Small numerical differences are possible against the original runs: the base OS is Ubuntu 22.04 (not 20.04) and the BLAS library may differ. The original analysis did not pass a seed to the parallel workers, so this stage reproduces it closely but not exactly. The deposited post-QC object used from Stage 2 onward is 26,788 genes × 115,221 cells.
