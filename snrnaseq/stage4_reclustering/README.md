# Stage 4: reclustering and final annotation

R 4.3 · Bioconductor 3.17 · Seurat 4.3.0 · ggplot2 3.5.2 · conda env `downstream` · master script `run_stage4.R`

`run_stage4.R` renders four R Markdown files. The first three start from the non-malignant cells of the deposited final object, with their Stage 3 labels, and do not depend on each other. `Plotting.Rmd` reads what they save, so it runs last.

1. `STS_Lymphoid_TNK.Rmd`: lymphoid cells. SCTransform per sample, simspec (CSS) integration, clustering at resolution 1.2, annotation (`Lv.2.Anno`, from `stage4_lymphoid_Lv.2.Anno`), pseudobulk differential expression between subsets with edgeR.
2. `STS_Myeloid_Mast_DCs.Rmd`
   - **Myeloid and mast cells:** SCTransform without integration, clustering, annotation of DCs, mast and cycling cells (`Lv.2.Anno`, from `stage4_myeloid_Lv.2.Anno`).
   - **Macrophages (TAMs):** SCTransform per sample, simspec integration, clustering at resolution 0.2, annotation of four subtypes (from `stage4_TAM_Lv.2.Anno`), pseudobulk differential expression with edgeR, GO and Hallmark over-representation analysis, UCell scores for published TAM signatures.
3. `STS_stromal_CAF_reclustering.Rmd`
   - **Stromal classes:** pseudobulk differential expression between CAFs, FDCs, FRCs, pericytes and Schwann cells.
   - **CAFs:** SCTransform per sample, simspec integration, clustering at resolution 0.1, annotation (`Lv.2.Anno_subset`, from `stage4_CAF_Lv.2.Anno_subset`), pseudobulk differential expression, UCell scores for published CAF programs.
   - **FRCs vs CAFs:** differential expression and Reactome GSEA.
   - **Endothelial cells:** SCTransform per sample, RPCA integration, clustering at resolution 0.4, annotation of subsets including lymphatic endothelial cells (`cell_names`, from `stage4_endothelial_cell_names`).
4. `Plotting.Rmd`: moves the subset labels onto the integrated object (`Lv.2.Anno`, `Lv.1.Anno`), checks them against the deposited ones (expected to match exactly), adds ICGC donor IDs, draws the overview figures and saves the final annotated object.

## Manuscript outputs

Figure names are taken from the chunk labels.

| Output | File | Chunk |
|---|---|---|
| Fig. 1B | `Plotting.Rmd` | `fig1b-snrnaseq-umap`, `fig1b-snrnaseq-cellularcomposition` |
| Fig. 1C | `STS_Lymphoid_TNK.Rmd`, `STS_Myeloid_Mast_DCs.Rmd`, `STS_stromal_CAF_reclustering.Rmd` | `fig-1c-lymphoid`, `fig-1c-tam`, `fig-1c-caf` |
| Extended Data Fig. 1A | `Plotting.Rmd` | `ext-data-fig1a-snrnaseq-gex` |
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
| `sts.simspec_css.sample.sct_final.RDS` | Final annotated object (deposited, [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322)): the integrated Stage 2 object with the labels added. The three reclustering files take its Stage 3 non-malignant cells (those with a `stage3_Lv.1.Anno`), with their Stage 3 `Lv.1.Anno` and `Lv.2.Anno`, the subset labels and the Fig. 1C UMAPs. The original code read the non-malignant cells from the Stage 3 output `sts.nonmalignant.RDS`; only its RNA assay was used, which is the same in the final object. `Plotting.Rmd` reads the whole object, which the original code read as `sts.simspec_css.sample.sct_fullworkflow.RDS` |
| `sample_map.csv` | `shared/sample_map.csv`, included in the image at `/pipeline/shared/`. Adds ICGC donor IDs to the figures |
| `label_checks.R` | `shared/label_checks.R`, included in the image at `/pipeline/shared/`. Reads labels and UMAPs from the deposited object and compares them with the rerun (see the Stage 3 README, "Labels read from the deposited object") |

## Environment

Conda env `downstream` in the project image (`../../envs/downstream.yml`, locked in `../../envs/downstream-linux-64.lock`), shared with Stage 3. Every package version recorded in `sessionInfo/` for this stage matches the Stage 3 recording. This stage adds schex 1.14.0, UCell 2.4.0, SingleR 2.2.0, EnhancedVolcano 1.18.0, ReactomePA 1.44.0, reactome.db 1.84.0, SingleCellExperiment 1.22.0 and here 1.0.1, each at its original version.

The differences from the original runs are those in the Stage 3 README ("Environment"), with these additions:

| Package | Original | Here | Why |
|---|---|---|---|
| devtools, usethis, pkgbuild, pkgload, profvis, urlchecker, sessioninfo, loupeR, monocle3, hdf5r, lme4, minqa, nloptr, boot, terra, prettyunits | | not installed | loaded in the original sessions but not used by the code |

`sessionInfo/` holds the session information of the original runs. `STS_stromal_CAF_reclustering.Rmd` has two: the `_v2` file was recorded in the session that ran the Reactome GSEA, so it has packages the first does not. `sessionInfo_Plotting.txt` was recorded after dplyr was updated to 1.2.1 for CellChat; `Plotting.Rmd` originally ran with the same packages as the other files here, including dplyr 1.1.2, which this env uses.

## Files

| File | Purpose |
|---|---|
| `run_stage4.R` | Master script; `Rscript run_stage4.R [config.yml]` |
| `STS_Lymphoid_TNK.Rmd`, `STS_Myeloid_Mast_DCs.Rmd`, `STS_stromal_CAF_reclustering.Rmd`, `Plotting.Rmd` | The analysis |
| `config.yml` | Input paths and output folder (container paths) |
| `add_labels_to_final_object.R` | Not part of the run. Run once on the original objects before depositing the final object: copies the Stage 3 and 4 labels that are not in it (malignant clusters, Stage 3 `Lv.1.Anno` and `Lv.2.Anno`, subset labels, endothelial subtypes) and the Fig. 1C subset UMAPs into new `stage3_*` and `stage4_*` columns, matched by cell ID. It also restores the label `TAMs_MHC_II`, which had been renamed `TAMs_HLA+` by hand in the final object after `Plotting.Rmd`; the manuscript and the code use `TAMs_MHC_II`. No other existing column is changed |
| `sessionInfo/` | Session information of the original runs |

## Run

Use the project image (see the top-level `README.md` to build or pull it).

| Container path | Mount | Mode |
|---|---|---|
| `/data/input` | folder containing `sts.simspec_css.sample.sct_final.RDS` | read-only |
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
| `STS_Lymphoid_TNK/` | `lymphoid.simspec.RDS` | Lymphoid object with `Lv.2.Anno` and `Lv.2.Anno_by_cluster`; `umap_css` is the stored original UMAP, `umap_css_rerun` the rerun |
| `STS_Myeloid_Mast_DCs/` | `myeloid.nonintegrated.RDS`, `mac.only.simspec.RDS` | Myeloid and TAM objects with `Lv.2.Anno` and `Lv.2.Anno_by_cluster`; in the TAM object, `umap_css` is the stored original UMAP |
| `STS_stromal_CAF_reclustering/` | `fib.only.simspec.RDS`, `stromal.subsets.RDS`, `endo.RDS` | CAF object with `Lv.2.Anno_subset` and `Lv.2.Anno_subset_by_cluster` (`umap_css` is the stored original UMAP); stromal object with `Lv.3.Anno`; endothelial object with `cell_names` and `cell_names_by_cluster` |
| `Plotting/` | `sts.simspec_css.sample.sct_final.RDS` | Final annotated object, with `Lv.1.Anno`, `Lv.2.Anno` and `ICGC_ID`. Input to Stage 5 |

Each folder also holds the HTML report, figures and `label_agreement.tsv` (agreement of the rerun with the deposited labels), and the first three hold the Supplementary Tables listed above.

## Notes

- **Labels and Fig. 1C UMAPs come from the deposited object.** The original code assigned the lymphoid, TAM, CAF and endothelial subsets, and some DC subsets, to clusters by number. The labels are now read from the deposited object and the original mappings are compared with them, as described in the Stage 3 README ("Labels read from the deposited object"). Fig. 1C, Extended Data Fig. 5A and 5B are drawn on the stored original UMAPs. Other UMAPs in these reports (for example the myeloid and endothelial ones) are rerun and may look different from the originals.
- **Fig. 1C (CAFs) is coloured by `Lv.2.Anno_subset`.** The original chunk coloured the cells by their identities, which at that point were the resolution-0.1 cluster numbers, while its colours are named by subtype. It now sets `group.by = "Lv.2.Anno_subset"`.
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
