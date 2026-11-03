# Stage 4: reclustering and final annotation

R 4.3 · Bioconductor 3.17 · Seurat 4.3.0 · ggplot2 3.5.2 · conda env `downstream` · master script `run_stage4.R`

`run_stage4.R` renders four R Markdown files. The first three start from the Stage 3 non-malignant object and do not depend on each other. `Plotting.Rmd` reads what they save, so it runs last.

1. `STS_Lymphoid_TNK.Rmd`: lymphoid cells. SCTransform per sample, simspec (CSS) integration, clustering at resolution 1.2, annotation (`Lv.2.Anno`), pseudobulk differential expression between subsets with edgeR.
2. `STS_Myeloid_Mast_DCs.Rmd`
   - **Myeloid and mast cells:** SCTransform without integration, clustering, annotation of DCs, mast and cycling cells.
   - **Macrophages (TAMs):** SCTransform per sample, simspec integration, clustering at resolution 0.2, annotation of four subtypes, pseudobulk differential expression with edgeR, GO and Hallmark over-representation analysis, UCell scores for published TAM signatures.
3. `STS_stromal_CAF_reclustering.Rmd`
   - **Stromal classes:** pseudobulk differential expression between CAFs, FDCs, FRCs, pericytes and Schwann cells.
   - **CAFs:** SCTransform per sample, simspec integration, clustering at resolution 0.1, annotation (`Lv.2.Anno_subset`), pseudobulk differential expression, UCell scores for published CAF programs.
   - **FRCs vs CAFs:** differential expression and Reactome GSEA.
   - **Endothelial cells:** SCTransform per sample, RPCA integration, clustering at resolution 0.4, annotation of subsets including lymphatic endothelial cells (`cell_names`).
4. `Plotting.Rmd`: moves the subset labels onto the integrated object (`Lv.2.Anno`, `Lv.1.Anno`), adds ICGC donor IDs, draws the overview figures and saves the final annotated object.

## Manuscript outputs

Figure names are taken from the chunk labels.

| Output | File | Chunk |
|---|---|---|
| Fig. 1B | `Plotting.Rmd` | `fig1b-snrnaseq-umap`, `fig1b-snrnaseq-cellularcomposition` |
| Fig. 1C | `STS_Lymphoid_TNK.Rmd`, `STS_Myeloid_Mast_DCs.Rmd` | `fig-1c-lymphoid`, `fig-1c-tam` |
| Extended Data Fig. 1A | `Plotting.Rmd` | `ext-data-fig1a-snrnaseq-gex` |
| Extended Data Fig. 1C | `STS_stromal_CAF_reclustering.Rmd` | `ext-data-fig-1c-caf` |
| Extended Data Fig. 2A | `Plotting.Rmd` | `ext-data-fig2a-snrnaseq-gex` |
| Extended Data Fig. 5A | `STS_stromal_CAF_reclustering.Rmd` | `ext-data-fig-5a-Baron`, `ext-data-fig-5a-Elyada`, `ext-data-fig-5a-Hwang` |
| Extended Data Fig. 5B | `STS_stromal_CAF_reclustering.Rmd` | `ext-data-fig-5b` |
| Extended Data Fig. 6A–C | `STS_Myeloid_Mast_DCs.Rmd` | `ext-data-fig-6a-heatmap-tam-subsets`, `ext-data-fig-6b-ORA`, `ext-data-fig-6c-Ucellscore` |
| Extended Data Fig. 8A | `STS_stromal_CAF_reclustering.Rmd` | `ext-data-fig-8a-lymphoid-stromal-gene-expression` |
| Extended Data Fig. 8C | `STS_stromal_CAF_reclustering.Rmd` | `ext-data-fig-8c-volcano-plot` |
| Extended Data Fig. 8E–G | `STS_stromal_CAF_reclustering.Rmd` | `ext-data-fig-8e-icaf-signature`, `ext-data-fig-8f-caf-gene-expression`, `ext-data-fig-8g-caf-programs` |
| Supplementary Table 4 | `STS_stromal_CAF_reclustering.Rmd` | writes `SupplementaryTable4_caf_pseudobulk.csv` |
| Supplementary Table 5 | `STS_Myeloid_Mast_DCs.Rmd` | writes `SupplementaryTable5_tam_pseudobulk.csv` |
| Supplementary Table 6 | `STS_stromal_CAF_reclustering.Rmd` | writes `SupplementaryTable6_stromal_pseudobulk.csv` |
| Supplementary Table 7 | `STS_Lymphoid_TNK.Rmd` | writes `SupplementaryTable7_lymphoid_pseudobulk.csv` |

Figures are shown in each HTML report and also saved as PNG and PDF files, named after their chunk.

## Input

| File | Source |
|---|---|
| `sts.nonmalignant.RDS` | Non-malignant object from Stage 3, with `Lv.1.Anno` and `Lv.2.Anno` (deposited, **DOI_TBD**) |
| `sts.simspec_css.sample.sct.RDS` | Annotated integrated object from Stage 2 (deposited, **DOI_TBD**). Read by `Plotting.Rmd`. The original code read it as `sts.simspec_css.sample.sct_fullworkflow.RDS` |
| `sample_map.csv` | `shared/sample_map.csv`, included in the image at `/pipeline/shared/`. Adds ICGC donor IDs to the figures |

## Environment

Conda env `downstream` in the project image (`../../envs/downstream.yml`, locked in `../../envs/downstream-linux-64.lock`), shared with Stage 3. Every package version recorded in `sessionInfo/` for this stage matches the Stage 3 recording. This stage adds schex 1.14.0, UCell 2.4.0, SingleR 2.2.0, EnhancedVolcano 1.18.0, ReactomePA 1.44.0, reactome.db 1.84.0, SingleCellExperiment 1.22.0 and here 1.0.1, each at its original version.

The differences from the original runs are those in the Stage 3 README ("Environment"), with these additions:

| Package | Original | Here | Why |
|---|---|---|---|
| devtools, usethis, pkgbuild, pkgload, profvis, urlchecker, sessioninfo, loupeR, monocle3, hdf5r, lme4, minqa, nloptr, boot, terra, prettyunits | | not installed | loaded in the original sessions but not used by the code |

`sessionInfo/` holds the session information of the original runs. `STS_stromal_CAF_reclustering.Rmd` has two: the `_v2` file was recorded in the session that ran the Reactome GSEA, so it has packages the first does not. There is no recording for `Plotting.Rmd` (**TODO**).

## Files

| File | Purpose |
|---|---|
| `run_stage4.R` | Master script; `Rscript run_stage4.R [config.yml]` |
| `STS_Lymphoid_TNK.Rmd`, `STS_Myeloid_Mast_DCs.Rmd`, `STS_stromal_CAF_reclustering.Rmd`, `Plotting.Rmd` | The analysis |
| `config.yml` | Input paths and output folder (container paths) |
| `sessionInfo/` | Session information of the original runs |

## Run

Use the project image (see the top-level `README.md` to build or pull it).

| Container path | Mount | Mode |
|---|---|---|
| `/data/input` | folder containing `sts.nonmalignant.RDS` and `sts.simspec_css.sample.sct.RDS` | read-only |
| `/output` | where results go | read-write |

```bash
docker run --rm \
  --cpus 8 --memory 128g \
  -v /path/to/input:/data/input:ro \
  -v /path/to/output:/output \
  pdac-snrnaseq:1.0 stage4
```

With Apptainer/Singularity:

```bash
apptainer run \
  --bind /path/to/input:/data/input \
  --bind /path/to/output:/output \
  pdac-snrnaseq.sif stage4
```

## Outputs

| Folder | File | Contents |
|---|---|---|
| `STS_Lymphoid_TNK/` | `lymphoid.simspec.RDS` | Lymphoid object with `Lv.2.Anno` |
| `STS_Myeloid_Mast_DCs/` | `myeloid.nonintegrated.RDS`, `mac.only.simspec.RDS` | Myeloid and TAM objects with `Lv.2.Anno` |
| `STS_stromal_CAF_reclustering/` | `fib.only.simspec.RDS`, `stromal.subsets.RDS`, `endo.RDS` | CAF object with `Lv.2.Anno_subset`; stromal object with `Lv.3.Anno`; endothelial object with `cell_names` |
| `Plotting/` | `sts.simspec_css.sample.sct_final.RDS` | Final annotated object, with `Lv.1.Anno`, `Lv.2.Anno` and `ICGC_ID`. Input to Stage 5 |

Each folder also holds the HTML report and figures, and the first three hold the Supplementary Tables listed above.

## Notes

- **Cell labels come from cluster numbers.** Lymphoid, TAM, CAF and endothelial subsets are assigned to clusters by number. A rerun in this image is expected to give the same clusters, and so the same labels; the saved objects can be compared with the originals to confirm this.
- **`non.malig` in `Plotting.Rmd`** is the list of 84 cells of sample 2215 from `STS_Malignant.Rmd`. They are labelled `unassigned` in `Lv.1.Anno`.
- **`fib.only.simspec.RDS` is saved three times** under the same name, as in the original code. The last save has the UCell scores.

## Changes needed to render the original code

These stopped the files from rendering from start to end. No analysis step was changed.

| File | Change |
|---|---|
| `STS_Lymphoid_TNK.Rmd`, `STS_Myeloid_Mast_DCs.Rmd`, `STS_stromal_CAF_reclustering.Rmd` | Removed `eval=FALSE` from the chunks that load and prepare the data |
| `STS_Lymphoid_TNK.Rmd` | Moved the `lymphoid.color` definition before its first use |
| `STS_Myeloid_Mast_DCs.Rmd` | `library(t)` is now `library(tibble)`; added a missing comma in a chunk header |
| `STS_stromal_CAF_reclustering.Rmd` | The colours of two MDS check plots were defined outside the file, so they now use a `Set1` palette. Commented out one `clustree` call, which needs at least two resolutions |
| `Plotting.Rmd` | `non.malig` was defined outside the file, so the list is now copied in |
