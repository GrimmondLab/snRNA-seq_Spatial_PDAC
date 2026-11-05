# Stage 2: Seurat processing + Simspec integration

R 4.3 · Bioconductor 3.17 · conda env `snrnaseq` · master script `run_stage2.R`

`run_stage2.R` renders two R Markdown files in order:

1. `Seurat_sample_based.Rmd`: converts the post-QC object to Seurat, runs SCTransform (v2), PCA, UMAP and clustering, assigns `cell_class`, and writes `sts.seurat.RDS`.
2. `PDAC_STS_simspec_integration.Rmd`: runs SCTransform per sample, integrates the samples with Cluster Similarity Spectrum (CSS, simspec), clusters at resolution 1.1, assigns `simspec_cell_class`, and writes `sts.simspec_css.sample.sct.RDS`. Stage 3 reads this file.

## Input

The original post-QC object deposited with the manuscript ([10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322)): `qc.dbl.fltrd.sts.sce.RDS`, 26,788 genes × 115,221 cells. Stage 2 starts from this object rather than from a Stage 1 rerun (see the top-level `README.md`).

## Environment

Conda env `snrnaseq` (shared with Stage 1; `../../envs/snrnaseq.yml`, locked in `envs/snrnaseq-linux-64.lock`): R 4.3, Bioconductor 3.17 (scuttle 1.10.1, SingleCellExperiment 1.22.0, glmGamPoi 1.12.2), Seurat 4.3.0 (SeuratObject 4.1.3, sctransform 0.3.5), simspec from GitHub `quadbio/simspec` at commit `f4c87bfb18522d7df0110eb63843972a29415985` (installed by `envs/post_install.R`).

Differences from the original run (`sessionInfo/`):

| | Original | Now | Why |
|---|---|---|---|
| R | 4.4.0 | 4.3 | one R version for all stages; Bioconductor 3.17 is built for R 4.3 |
| Matrix | 1.7-5 | 1.5-4.1 (as Stage 1) | Matrix 1.7 needs R 4.4 |
| glmGamPoi | 1.12.1 | 1.12.2 | patch release; bioconda has no 1.12.1 |
| xgboost, digest, cli, hexbin, labeling | as recorded | nearest R 4.3 build | not used directly by this stage |

All other packages recorded in `sessionInfo/` are pinned to their original versions.

These can shift PCA, UMAP and clustering slightly; see **Known gaps** below.

## Files

| File | Purpose |
|---|---|
| `run_stage2.R` | Master script; `Rscript run_stage2.R [config.yml]` |
| `Seurat_sample_based.Rmd`, `PDAC_STS_simspec_integration.Rmd` | Analysis steps |
| `config.yml` | Input path, output folder, seed and number of workers (container paths) |
| `sessionInfo/` | Session information of the original analysis, plus glmGamPoi and simspec details (see the note inside) |

## Running

| Container path | Mount | Mode |
|---|---|---|
| `/data/input` | folder containing `qc.dbl.fltrd.sts.sce.RDS` | read-only |
| `/output` | where results go | read-write |

```bash
docker run --rm --cpus 28 --memory 128g \
  -v /path/to/input:/data/input:ro \
  -v /path/to/output:/output \
  pdac-snrnaseq:1.0 stage2
```

Results are written to `/output/Seurat_sample_based/` and `/output/PDAC_STS_simspec_integration/` (HTML reports and `.RDS` objects).

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

## Changes needed to render the original code

This stopped the file from rendering from start to end. No analysis step was changed.

| File | Change |
|---|---|
| `PDAC_STS_simspec_integration.Rmd` | Commented out the block that adds `Patient_ID` to `sts.seurat`. By then `sts.seurat` is a list of per-sample objects, so `FetchData()` fails. Nothing reads it afterwards, and the integrated object already has `Patient_ID` from `Seurat_sample_based.Rmd` |
