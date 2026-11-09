# Stage 1: Doublet removal + fixed QC thresholds

R 4.3 · Bioconductor 3.17 · conda env `snrnaseq` · master script `run_stage1.R`

`run_stage1.R` renders two R Markdown files in order:

1. `Preprocessing_DoubleDetection.Rmd`: reads the CellBender `.h5` files, removes very low-quality cells, normalises, clusters, and removes doublets with scDblFinder.
2. `Preprocessing_QC.Rmd`: applies fixed QC thresholds to cells and genes, and writes `qc.dbl.fltrd.sts.sce.RDS`.

The analyses from Stage 2 onward start from the original post-QC object deposited with the manuscript, not from this stage's output (see the top-level `README.md`).

Per-sample QC metrics for the nuclei that passed these filters are in `../supplementary_qc/`.

## Environment

Conda env `snrnaseq` (`../../envs/snrnaseq.yml`, locked in `envs/snrnaseq-linux-64.lock`): R 4.3, Bioconductor 3.17 (scDblFinder 1.14.0, scater 1.28.0, scran 1.28.1, scuttle 1.10.1, DropletUtils 1.20.0), Seurat 4.3.0, dplyr 1.1.2, ggplot2 3.4.2. All packages recorded in `sessionInfo/` are pinned to their original versions, except xgboost (used by scDblFinder: 1.7.5.1 → 1.7.6, the nearest conda build), digest, cli, hexbin and labeling (no R 4.3 build of the original version). Build and general run instructions are in the top-level `README.md`.

## Files

| File | Purpose |
|---|---|
| `run_stage1.R` | Master script; `Rscript run_stage1.R [config.yml]` |
| `Preprocessing_DoubleDetection.Rmd`, `Preprocessing_QC.Rmd` | Analysis steps |
| `config.yml` | Settings for **GEO input**, with container paths (default) |
| `config_local.yml` | Settings for the **original CellBender folders**, with container paths |
| `config_hpc.yml` | Original settings with HPC paths (record only) |
| `geo_samples.csv` | Links each GEO entry to the sample name used in the analysis, and sets the loading order |
| `geo_input.R` | Prepares the GEO files for loading (used in GEO mode) |
| `SG_sample_meta.csv` | Sample metadata; also in the image, but the configs read it from the `/data/meta` mount |
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

## Running

Mounts:

| Container path | Mount | Mode |
|---|---|---|
| `/data/geo` (GEO mode) or `/data/cellbender` (local mode) | input files | read-only |
| `/data/meta` | folder containing `SG_sample_meta.csv` | read-only |
| `/output` | where results go | read-write |

```bash
# GEO input (default config.yml)
docker run --rm --cpus 12 --memory 64g \
  -v /path/to/geo_files:/data/geo:ro \
  -v /path/to/meta:/data/meta:ro \
  -v /path/to/output:/output \
  pdac-snrnaseq:1.0 stage1

# Original CellBender folders
docker run --rm --cpus 12 --memory 64g \
  -v /path/to/cellBender/samples:/data/cellbender:ro \
  -v /path/to/meta:/data/meta:ro \
  -v /path/to/output:/output \
  pdac-snrnaseq:1.0 stage1 config_local.yml
```

Results are written to `/output/Preprocessing_DoubleDetection/` and `/output/Preprocessing_QC/` (HTML reports and `.RDS` objects).

## Resources

- `workers: 12` in `config.yml`. Give the job at least that many CPUs, or lower the value.
- Around 140k cells × 36k genes: request plenty of memory (64 GB is a safe start).
- `denoisePCA` alone took about 1.5 h on the original machine.
- `dbl_workers: 4` is deliberate. With 12 workers scDblFinder failed, and with `RNGseed` + 4 workers the results were reproducible.

## Expected results (sanity checks)

- 30 samples loaded (the run stops otherwise).
From a run in the project image (Apptainer, November 2026):

- scDblFinder: 129,134 singlets / 6,848 doublets.
- Final object after QC: 26,774 genes × 115,301 cells, the same size as the August 2024 rerun.

An earlier rerun outside the image (October 2026) gave 129,115 singlets / 6,867 doublets and 26,757 genes × 115,293 cells.

Small numerical differences are possible against the original runs: the packages come from conda (xgboost 1.7.6, conda-forge BLAS) on a Debian base rather than Ubuntu 20.04. The original analysis did not pass a seed to the parallel workers, so this stage reproduces it closely but not exactly. The deposited post-QC object used from Stage 2 onward is 26,788 genes × 115,221 cells.
