# Stage 4: reclustering and final annotation

Reproduces Fig. 1B and 1C, Extended Data Fig. 1A, 2A, 5A–B, 6A–C, 8A, 8C and 8E–G, and Supplementary Tables 4–7, from the deposited final object, and rebuilds the final annotated object used by Stage 5.

**Result: reproduced.** Run in the project image (v1.0.0, on Spartan, 2026-11-17), with fixes needed to render made after the image was built (see [Details](#details)). Fig. 1B–C, Extended Data Fig. 1A, 2A, 5A–B, 6A–C, 8A, 8C and 8E–G, and Supplementary Tables 4–7 match the manuscript exactly, and the rebuilt final `Lv.1.Anno` and `Lv.2.Anno` are 100% the same as the deposited object (see [Comparison with the original](#comparison-with-the-original)).

R 4.3 · Seurat 4.3.0 · conda env `downstream` · master script `run_stage4.R`

## What it does

`run_stage4.R` renders four R Markdown files. The first three start from the non-malignant cells of the deposited final object and do not depend on each other. `Plotting.Rmd` reads what they save, so it runs last.

1. `STS_Lymphoid_TNK.Rmd`: lymphoid cells. Integration, clustering, annotation and pseudobulk differential expression between subsets (edgeR).
2. `STS_Myeloid_Mast_DCs.Rmd`
   - **Myeloid and mast cells:** clustering and annotation of DCs, mast and cycling cells.
   - **Macrophages (TAMs):** integration, clustering, annotation of four subtypes, pseudobulk differential expression, GO and Hallmark over-representation analysis, and UCell scores for published TAM signatures.
3. `STS_stromal_CAF_reclustering.Rmd`
   - **Stromal classes:** pseudobulk differential expression between CAFs, FDCs, FRCs, pericytes and Schwann cells.
   - **CAFs:** integration, clustering, annotation, pseudobulk differential expression and UCell scores for published CAF programs.
   - **FRCs vs CAFs:** differential expression and Reactome GSEA.
   - **Endothelial cells:** integration, clustering and annotation of subsets, including lymphatic endothelial cells.
4. `Plotting.Rmd`: moves the subset labels onto the whole object (`Lv.2.Anno`, `Lv.1.Anno`), checks them against the deposited ones, adds ICGC donor IDs, draws the overview figures and saves the final annotated object.

Cell labels are read from the deposited object by cell ID, not from cluster numbers, so a rerun in another environment keeps the original labels. The rerun clusters are still computed and compared with them (see [`shared/README.md`](../../shared/README.md#labels-read-from-the-deposited-object)). The Fig. 1C UMAPs, and those of Extended Data Fig. 5A and 5B, are drawn from the original coordinates stored in the deposited object, so they match the published figures.

A few fixes were needed for the original code to render from start to end; no analysis step was changed (see [Details](#details)).

## Manuscript outputs

| Output | File | Chunk |
|---|---|---|
| Fig. 1B | `Plotting.Rmd` | `fig1b-snrnaseq-umap`, `fig1b-snrnaseq-cellularcomposition` |
| Fig. 1C | `STS_Lymphoid_TNK.Rmd`, `STS_Myeloid_Mast_DCs.Rmd`, `STS_stromal_CAF_reclustering.Rmd` | `fig-1c-lymphoid`, `fig-1c-tam`, `fig-1c-caf` (stored UMAPs); `fig-1c-*-rerun-vs-deposited` (rerun UMAP next to the stored one) |
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
| `sts.simspec_css.sample.sct_final.RDS` | Final annotated object, [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322) |
| `sample_map.csv`, `label_checks.R` | In the image at `/pipeline/shared/` (see [`shared/README.md`](../../shared/README.md)) |

## Run

Use the project image (see the top-level `README.md` to build or pull it).

| Container path | Mount | Mode |
|---|---|---|
| `/data/input` | folder containing `sts.simspec_css.sample.sct_final.RDS` | read-only |
| `/output` | where results go | read-write |

```bash
docker run --rm \
  --cpus 2 --memory 64g \
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

On Spartan: edit the three paths at the top of `stage4_spartan.slurm`, then `sbatch stage4_spartan.slurm`. It asks for 2 CPUs (no file runs in parallel), 64 GB and 4 hours. The v1.0.0 runs took 36–48 min with a peak of 42.8 GB.

## Outputs

| Folder | File | Contents |
|---|---|---|
| `STS_Lymphoid_TNK/` | `lymphoid.simspec.RDS` | Lymphoid object |
| `STS_Myeloid_Mast_DCs/` | `myeloid.nonintegrated.RDS`, `mac.only.simspec.RDS` | Myeloid and TAM objects |
| `STS_stromal_CAF_reclustering/` | `fib.only.simspec.RDS`, `stromal.subsets.RDS`, `endo.RDS` | CAF, stromal and endothelial objects |
| `Plotting/` | `sts.simspec_css.sample.sct_final.RDS` | Final annotated object, with `Lv.1.Anno`, `Lv.2.Anno` and `ICGC_ID`. Input to Stage 5 |

Each folder also holds the HTML report, figures and `label_agreement.tsv` (agreement of the rerun with the deposited labels), and the first three hold the Supplementary Tables listed above.

## Comparison with the original

| What | Expected | Rerun |
|---|---|---|
| Subset labels (lymphoid, myeloid, TAM, CAF, endothelial) | Identical: read from the deposited object | Identical (read by cell ID; v1.0.0 run, 2026-11-17) |
| Rerun clusters vs original labels | Recorded in the reports and `label_agreement.tsv`, not a reproducibility measure (see [`shared/README.md`](../../shared/README.md#labels-read-from-the-deposited-object)) | **Myeloid** (6,290 cells) and **TAM** (5,797 cells): the original mapping applied to the rerun clusters gives the deposited `Lv.2.Anno` for every cell. Likewise for **CAF** subsets (7,924 cells). **Endothelial** (1,134 cells): 98.94% (12 cells differ). **Lymphoid:** the rerun clusters differ from the original ones. The labels, Fig. 1C and the pseudobulk use the deposited labels, so they are unaffected |
| Rebuilt `Lv.1.Anno` and `Lv.2.Anno` (`Plotting.Rmd`) vs deposited | 100% the same | Both 100%. The first run gave 99.93% for `Lv.2.Anno`: the 84 cells of sample 2215 were `PDAC` in the rebuild and `unassigned` in the deposited object. Fixed (see Details) |
| Fig. 1C, Extended Data Fig. 5A–B | Identical: drawn on the stored UMAPs | Identical to the manuscript |
| Other manuscript figures (Fig. 1B, Extended Data Fig. 1A, 2A, 6A–C, 8A, 8C, 8E–G) | Same cells and labels | Match the manuscript exactly |
| Pseudobulk differential expression, enrichment and UCell scores (Supplementary Tables 4–7) | Same cells and groups as the original | Supplementary Tables 4–7 match the manuscript exactly |

## Details

<details>
<summary>Cell selection and clustering</summary>

The three reclustering files take the Stage 3 non-malignant cells of the deposited object (those with a `stage3_Lv.1.Anno`), with their Stage 3 `Lv.1.Anno` and `Lv.2.Anno`. The original code read them from the Stage 3 output `sts.nonmalignant.RDS`; only its RNA assay was used, which is the same in the final object. `Plotting.Rmd` reads the whole object, which the original code read as `sts.simspec_css.sample.sct_fullworkflow.RDS`.

| Subset | Method | Resolution | Label column (deposited) |
|---|---|---|---|
| Lymphoid | SCTransform per sample, simspec (CSS) integration | 1.2 | `stage4_lymphoid_Lv.2.Anno` |
| Myeloid and mast | SCTransform without integration | | `stage4_myeloid_Lv.2.Anno` |
| TAMs | SCTransform per sample, simspec integration | 0.2 | `stage4_TAM_Lv.2.Anno` |
| CAFs | SCTransform per sample, simspec integration | 0.1 | `stage4_CAF_Lv.2.Anno_subset` |
| Endothelial | SCTransform per sample, RPCA integration | 0.4 | `stage4_endothelial_cell_names` |

</details>

<details>
<summary>Original cluster-to-label mappings and stored UMAPs</summary>

The original code assigned the lymphoid, TAM, CAF and endothelial subsets, and some DC subsets, to clusters by number. These mappings are applied to the rerun clusters (columns ending in `_by_cluster`) and compared with the deposited labels.

In the saved lymphoid, TAM and CAF objects, `umap_css` is the stored original UMAP and `umap_css_rerun` the rerun.

Fig. 1C (CAFs) is coloured by `Lv.2.Anno_subset`. The original chunk coloured the cells by their identities, which at that point were the resolution-0.1 cluster numbers, while its colours are named by subtype; it now sets `group.by = "Lv.2.Anno_subset"`.

`non.malig` in `Plotting.Rmd` is the list of 84 cells of sample 2215 from `STS_Malignant.Rmd`. They are labelled `unassigned` in `Lv.1.Anno`.

`fib.only.simspec.RDS` is saved three times under the same name, as in the original code. The last save has the UCell scores.

</details>

<details>
<summary>Changes needed to render the original code</summary>

These stopped the files from rendering from start to end. No analysis step was changed.

| File | Change |
|---|---|
| `STS_Lymphoid_TNK.Rmd`, `STS_Myeloid_Mast_DCs.Rmd`, `STS_stromal_CAF_reclustering.Rmd` | Removed `eval=FALSE` from the chunks that load and prepare the data |
| `STS_Lymphoid_TNK.Rmd` | Moved the `lymphoid.color` definition before its first use |
| `STS_Myeloid_Mast_DCs.Rmd` | `library(t)` is now `library(tibble)`; added a missing comma in a chunk header |
| `STS_stromal_CAF_reclustering.Rmd` | The colours of two MDS check plots were defined outside the file, so they now use a `Set1` palette. Commented out one `clustree` call, which needs at least two resolutions |
| `Plotting.Rmd` | `non.malig` was defined outside the file, so the list is now copied in |
| `Plotting.Rmd` | The `Lv.2.Anno` step now sets the 84 cells of sample 2215 (`non.malig`) to `unassigned`, as the `Lv.1.Anno` step does. Without it they became `PDAC`; the deposited `Lv.2.Anno` has them as `unassigned`, which Stage 5 relies on to leave them out |
| `STS_Lymphoid_TNK.Rmd`, `STS_Myeloid_Mast_DCs.Rmd`, `STS_stromal_CAF_reclustering.Rmd` | Metadata columns are removed with `x@meta.data[["col"]] <- NULL` instead of `x[["col"]] <- NULL`. The original input, Stage 3's `sts.nonmalignant.RDS`, had Stage 3's cluster columns (such as `SCT_snn_res.0.7`); the cells read from the final object don't, and SeuratObject stops when asked to remove a column that isn't there. The new form removes the same columns when they exist |

</details>

<details>
<summary>Environment and package versions</summary>

Conda env `downstream` in the project image (`../../envs/downstream.yml`, locked in `../../envs/downstream-linux-64.lock`), shared with Stage 3. Every package version recorded in `sessionInfo/` for this stage matches the Stage 3 recording. This stage adds schex 1.14.0, UCell 2.4.0, SingleR 2.2.0, EnhancedVolcano 1.18.0, ReactomePA 1.44.0, reactome.db 1.84.0, SingleCellExperiment 1.22.0 and here 1.0.1, each at its original version.

The differences from the original runs are those in the Stage 3 README ("Environment and package versions", under "Details"), with these additions:

| Package | Original | Here | Why |
|---|---|---|---|
| devtools, usethis, pkgbuild, pkgload, profvis, urlchecker, sessioninfo, loupeR, monocle3, hdf5r, lme4, minqa, nloptr, boot, terra, prettyunits | | not installed | loaded in the original sessions but not used by the code |

`sessionInfo/` holds the session information of the original runs. `STS_stromal_CAF_reclustering.Rmd` has two: the `_v2` file was recorded in the session that ran the Reactome GSEA, so it has packages the first does not. `sessionInfo_Plotting.txt` was recorded after dplyr was updated to 1.2.1 for CellChat; `Plotting.Rmd` originally ran with the same packages as the other files here, including dplyr 1.1.2, which this env uses.

</details>

<details>
<summary>Files in this folder</summary>

| File | Purpose |
|---|---|
| `run_stage4.R` | Master script; `Rscript run_stage4.R [config.yml]` |
| `STS_Lymphoid_TNK.Rmd`, `STS_Myeloid_Mast_DCs.Rmd`, `STS_stromal_CAF_reclustering.Rmd`, `Plotting.Rmd` | The analysis |
| `config.yml` | Input paths and output folder (container paths) |
| `stage4_spartan.slurm` | Slurm script to run this stage from the `.sif` on Spartan |
| `add_labels_to_final_object.R` | Not part of the run. Run once on the original objects before depositing the final object: copies the Stage 3 and 4 labels that are not in it (malignant clusters, Stage 3 `Lv.1.Anno` and `Lv.2.Anno`, subset labels, endothelial subtypes) and the Fig. 1C subset UMAPs into new `stage3_*` and `stage4_*` columns, matched by cell ID. It also restores the label `TAMs_MHC_II`, which had been renamed `TAMs_HLA+` by hand in the final object after `Plotting.Rmd`; the manuscript and the code use `TAMs_MHC_II`. No other existing column is changed |
| `sessionInfo/` | Session information of the original runs |

</details>
