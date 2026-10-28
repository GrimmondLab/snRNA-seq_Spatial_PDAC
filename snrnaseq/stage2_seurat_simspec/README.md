# Stage 2: Seurat processing + Simspec integration

R 4.4.0 · Bioconductor 3.17 packages · master script `run_stage2.R`

`run_stage2.R` renders two R Markdown files in order:

1. `Seurat_sample_based.Rmd`: converts the post-QC object to Seurat, runs SCTransform (v2), PCA, UMAP and clustering, assigns `cell_class`, and writes `sts.seurat.RDS`.
2. `PDAC_STS_simspec_integration.Rmd`: runs SCTransform per sample, integrates the samples with Cluster Similarity Spectrum (CSS, simspec), clusters at resolution 1.1, assigns `simspec_cell_class`, and writes `sts.simspec_css.sample.sct.RDS`. Stage 3 reads this file.

## Input

The original post-QC object deposited with the manuscript (**DOI_TBD**): `qc.dbl.fltrd.sts.sce.RDS`, 26,788 genes × 115,221 cells. Stage 2 starts from this object rather than from a Stage 1 rerun (see the top-level `README.md`).

## Environment

| | Version |
|---|---|
| R | 4.4.0 (`rocker/r-ver:4.4.0`, Ubuntu 22.04, linux/amd64) |
| Bioconductor | 3.17 packages (scuttle 1.10.1, SingleCellExperiment 1.22.0, glmGamPoi 1.12.1), installed directly from the 3.17 repository |
| Seurat | 4.3.0 (SeuratObject 4.1.3, sctransform 0.3.5) |
| simspec | GitHub `quadbio/simspec`, commit `f4c87bfb18522d7df0110eb63843972a29415985` |
| CRAN | Posit Package Manager snapshot from 2023-06-15 (dplyr 1.1.2, ggplot2 3.4.2), plus Matrix 1.7-5, uwot 0.1.16, RcppAnnoy 0.0.21, matrixStats 1.2.0, scales 1.3.0, clustree 0.5.1 |

Versions follow `sessionInfo/`. The original environment ran Bioconductor 3.17 packages on R 4.4.0, a combination Bioconductor does not officially support, so `install_packages.R` installs them straight from the 3.17 repository rather than through BiocManager. It checks the key versions and the simspec commit at the end, and stops the build if anything differs. It then saves the image's real `sessionInfo()` to `/pipeline/sessionInfo_container.txt`.

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | Image definition |
| `install_packages.R` | Installs and checks R packages (runs during build) |
| `run_stage2.R` | Master script; `Rscript run_stage2.R [config.yml]` |
| `Seurat_sample_based.Rmd`, `PDAC_STS_simspec_integration.Rmd` | Analysis steps |
| `config.yml` | Input path, output folder, seed and number of workers (container paths) |
| `sessionInfo/` | Session information of the original analysis, plus glmGamPoi and simspec details (see the note inside) |

## Build

```bash
docker build -t pdac-stage2:1.0 .
```

Everything is compiled from source for R 4.4. Expect roughly 45–90 minutes.

## Run with Docker

| Container path | Mount | Mode |
|---|---|---|
| `/data/input` | folder containing `qc.dbl.fltrd.sts.sce.RDS` | read-only |
| `/output` | where results go | read-write |

```bash
docker run --rm \
  --cpus 28 --memory 128g \
  -v /path/to/input:/data/input:ro \
  -v /path/to/output:/output \
  pdac-stage2:1.0
```

Results are written to `/output/Seurat_sample_based/` and `/output/PDAC_STS_simspec_integration/` (HTML reports and `.RDS` objects).

To copy the image's session information out without running the pipeline:

```bash
docker run --rm --entrypoint cat pdac-stage2:1.0 /pipeline/sessionInfo_container.txt > sessionInfo_container.txt
```

## Run with Apptainer/Singularity

```bash
docker save pdac-stage2:1.0 -o pdac-stage2_1.0.tar
```

```bash
apptainer build pdac-stage2_1.0.sif docker-archive://pdac-stage2_1.0.tar
```

```bash
apptainer run --pwd /pipeline \
  --bind /path/to/input:/data/input \
  --bind /path/to/output:/output \
  pdac-stage2_1.0.sif
```

## Resources

- `workers: 28` in `config.yml`. Give the job that many CPUs, or lower the value.
- SCTransform on about 115k cells, and again per sample before integration, needs a lot of memory. 128 GB is a safe start.

## Outputs

| Folder | File | Contents |
|---|---|---|
| `Seurat_sample_based/` | `sts.seurat.clustered.RDS` | Seurat object after clustering |
| | `sts.seurat.RDS` | adds `cell_class`, `Cell_Ids`, `S_CB`, `Patient_ID`; input to the integration step |
| `PDAC_STS_simspec_integration/` | `sts.simspec_css.sample.sct.clustered.RDS` | CSS-integrated object after clustering, before annotation |
| | `sts.simspec_css.sample.sct.RDS` | CSS-integrated object with `simspec_cell_class`; **input to Stage 3** |

## Known gaps (to revisit)

- **Cell-type labels depend on cluster numbers.** `cell_class` and `simspec_cell_class` are assigned by cluster number (e.g. `"41" ~ "Mast"`). If clusters come out numbered differently, the labels would be wrong without any error. Compare the labels with the original annotated object before relying on a rerun.
- **One chunk is switched off** (`eval=FALSE`, marked TODO): the old-vs-new object comparison at the start of `Seurat_sample_based.Rmd`.
