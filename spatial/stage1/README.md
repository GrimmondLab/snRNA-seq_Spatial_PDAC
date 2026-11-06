# Stage 1: from raw Xenium data to annotated objects

This stage takes the raw Xenium output for 16 samples (8 patients from the PURPLE registry, each with a 314-gene and a 480-gene panel) to the final annotated objects used by Stage 2. This is a different cohort from the snRNA-seq samples.

## Summary

All 16 annotated objects were regenerated from the raw Xenium output in two independent runs, reading the saved PCA, UMAP, clusters and kept cells from the original objects. Cell labels, gene-set scores and Nhood z-scores matched the original objects exactly. When PCA and clustering were recalculated, cell labels and Nhood results stayed stable.

## Why the saved PCA, UMAP and kept cells are reused

- **Cells are annotated by gene-set scoring.** Each cell is scored for curated gene sets on the normalised data and given its highest-scoring label above a threshold. PCA and UMAP are not inputs to the scoring.
- **PCA, clustering and UMAP were used mainly to find outliers,** such as cells from neighbouring samples and artefacts in non-tissue areas. Outlier clusters were removed in six samples. In four, the cluster-based annotation was also used to change some labels (see [Label changes after scoring](#label-changes-after-scoring)). Seven samples used scoring alone.
- **PCA and UMAP do not reproduce exactly.** Recalculating PCA gave small numerical differences, and UMAP did not reproduce.
- **So the notebooks read the saved PCA, UMAP, clusters and kept cells,** and recompute everything else from the raw data: QC, normalisation, gene-set scores, labels and Nhood enrichment. This keeps the same cells and labels, which the Nhood enrichment here and the niche analysis in Stage 2 depend on.

## Labels with recalculated PCA

As a separate check, PCA and clustering were recalculated in the nine samples with cluster-based steps, and the same steps were repeated. Clusters changed, but labels and Nhood results changed little:

| Measure | Result, 9 samples |
|---|---|
| Leiden clusters, agreement with the original | ARI 0.60–0.83 |
| Kept cells, overlap with the original (6 samples with cluster removal) | Jaccard 0.93–1.00 |
| Cells with the same `cell_class_threshold` label | 96.58–100.00% |
| Labels present | Same labels in both results |
| Nhood z-score correlation | 0.9990–0.9999 |

Where cells were removed, the test removes a recalculated cluster if at least half its cells were originally removed, so it tests stability rather than being an independent reanalysis. Results for each sample are under [Robustness](#robustness).

**Rare cells: Tuft cells.** Tuft cells are rare, so they show whether a small population is still found when PCA is recalculated. In the samples with Tuft cells and a recalculated PCA test:

| Sample | Tuft cells, original | Tuft cells, test | Original Tuft cells still in the test | Same label | Jaccard |
|---|---|---|---|---|---|
| MH065_314 | 61 | 61 | 61 | 100.0% | 1.000 |
| MH074_314 | 1,446 | 1,446 | 1,446 | 100.0% | 1.000 |
| MH097_314 | 20 | 20 | 20 | 100.0% | 1.000 |
| MH099_480 | 92 | 97 | 83 | 98.8% | 0.854 |
| MH106_480 | 101 | 101 | 101 | 100.0% | 1.000 |

In MH099_480, 9 original Tuft cells were in clusters removed by the test, and 1 of the remaining 83 became Malignant cells.

## What was done

1. **Audit:** we went through the original notebook for each sample and recorded its settings: crop region, genes removed, QC filters, Leiden resolution, gene sets, score quantile and seeds.
2. **First rerun:** each sample was rerun from the raw Xenium output in the current `xenium.squidpy` environment (scanpy 1.9.5, squidpy 1.3.1; see `../environment/`), then compared step by step with the saved object. The original objects were made in this environment before anndata was updated from 0.10.3 to 0.10.8 in January 2026. Raw counts, normalised data, `cell_class_threshold` labels, gene-set scores and Nhood z-scores were identical in all 16 samples.
3. **Recalculated PCA:** the separate check above, for the nine samples with cluster-based steps.
4. **Final notebooks:** we wrote one clean notebook per sample, from raw data to the final object, with all settings in one parameter cell. A second run with these notebooks matched the saved objects and the first rerun in all 16 samples, as well as the labels in the per-cell label tables.
5. **Outputs:** the 16 final objects (2,931,027 cells) are the only input to Stage 2. Stage 1 and Stage 2 are run separately. The [summary of checks](#summary-of-checks), `stage1_executive_summary.tsv`, `stage1_supplementary_table.tsv` and `stage1_robustness_table.tsv` record the checks.

## Workflow

1. **Input:** raw Xenium output for each sample.
2. **Quality control:** crop the tissue region where needed, remove specified genes and filter low-quality cells.
3. **Normalisation:** normalise and log-transform the counts.
4. **Outlier review:** use PCA, Leiden clustering and UMAP to find outlier populations, such as cells from neighbouring samples and artefacts in non-tissue areas.
5. **Annotation:** score curated gene sets on the normalised data and give each cell its highest-scoring label if it passes a sample-specific threshold. This gives `cell_class_threshold`.
6. **Spatial analysis:** calculate neighbourhood enrichment (Nhood) from these labels, using a 50 µm radius.
7. **Output:** the final objects, which are the input for Stage 2.

## Summary of checks

This summarises how far the final objects can be reproduced from raw data across all 16 samples. Each sample's own checks are in its `stage1_check.tsv` and `robustness_summary.tsv`.

**Rerun from raw data**

| Check | Result | Detail |
|---|---|---|
| Cells | MATCH | 16/16 samples; 2,931,027 cells in total |
| Cell order | MATCH | 16/16 samples; identical |
| Genes | MATCH | 16/16 samples; 314-gene and 480-gene panels |
| Raw counts | MATCH | 16/16 samples; max difference=0 |
| Normalised data | MATCH | 16/16 samples; max difference=0 |
| Saved PCA | MATCH | 16/16 samples; read from the saved object; max difference=0; used for review and clustering |
| PCA recalculated from raw | DIFFERS | 16/16 samples; max difference=0.00041–0.0059; not used for labels |
| UMAP recalculated | DIFFERS | 16/16 samples; max difference=6.89–15.2; display only, the final notebooks load the saved UMAP |
| Leiden clusters | MATCH | 16/16 samples; read from the saved object; 100.0000% of cells identical |
| `cell_class_threshold` | MATCH | 16/16 samples; 100.0000% of cells identical |
| Gene-set scores | MATCH | 16/16 samples; 23–39 sets per sample; max difference=0 |
| Nhood z-scores | MATCH | 16/16 samples; 23–40 labels per sample; max difference=0 |

**Second run with the final notebooks**

| Check | Result | Detail |
|---|---|---|
| cell_class_threshold, gene-set scores and Nhood z-scores | MATCH | 16/16 samples; identical to the saved object and to the first rerun |
| Labels in the per-cell label tables | MATCH | 16/16 samples; 100.0000% of cells identical |

**Recalculated PCA test**

| Check | Result | Detail |
|---|---|---|
| Leiden clusters | DIFFERS | 9/9 samples; ARI=0.60–0.83; clusters are used only for review |
| Kept cells | SIMILAR | 6/6 samples with cluster removal; Jaccard=0.9302–1.0000; 2–4,697 cells now removed, 4–5,785 now kept |
| `cell_class_threshold` | SIMILAR | 9/9 samples; 96.58–100.00% of cells identical (lowest MH099_480) |
| Labels present | MATCH | 9/9 samples; no label found in only one result |
| Nhood z-scores | SIMILAR | 9/9 samples; correlation=0.9990–0.9999 |
| Same results in both runs | MATCH | 9/9 samples; identical in the first rerun and the final notebooks |

## Robustness

All 16 samples were rerun from raw data and compared with the saved analysis objects. `cell_class_threshold`, gene-set scores and Nhood z-scores were reproduced exactly in all 16.

Scoring-only samples don't use PCA in labelling. For the other nine, PCA was recalculated, the cluster-based steps were repeated and the results were compared with the originals. Between 96.58% and 100.00% of cells kept the same label, and Nhood z-score correlation was at least 0.9990.

| Sample | Panel | Same `cell_class_threshold` label | Nhood z-score correlation | How tested |
|---|---|---|---|---|
| MH065 | 314 | 99.12% | 0.9991 | Recalculated PCA |
| MH074 | 314 | 98.55% | 0.9999 | Recalculated PCA |
| MH096 | 314 | 100% | 1.0000 | Scoring only, no PCA used |
| MH097 | 314 | 97.77% | 0.9993 | Recalculated PCA |
| MH099 | 314 | 99.93% | 0.9997 | Recalculated PCA |
| MH104 | 314 | 99.86% | 0.9998 | Recalculated PCA |
| MH106 | 314 | 100.00% | 0.9996 | Recalculated PCA |
| MH107 | 314 | 98.32% | 0.9999 | Recalculated PCA |
| MH065 | 480 | 100% | 1.0000 | Scoring only, no PCA used |
| MH074 | 480 | 100% | 1.0000 | Scoring only, no PCA used |
| MH096 | 480 | 100% | 1.0000 | Scoring only, no PCA used |
| MH097 | 480 | 100% | 1.0000 | Scoring only, no PCA used |
| MH099 | 480 | 96.58% | 0.9990 | Recalculated PCA |
| MH104 | 480 | 100% | 1.0000 | Scoring only, no PCA used |
| MH106 | 480 | 99.99% | 0.9998 | Recalculated PCA |
| MH107 | 480 | 100% | 1.0000 | Scoring only, no PCA used |

For scoring-only samples, the values come from the direct rerun comparison. The correlation of 1.0000 reflects a maximum z-score difference of 0.

Each rerun was compared with the saved object for that sample.

## Supplementary table

`stage1_supplementary_table.tsv` has one row per sample. It combines two independent runs from raw data: the earlier full reruns (`previous`) and the final notebooks in this folder (`stage1_run`). Both runs gave the same values for every measure they share, in all 16 samples.

| Columns | Meaning |
|---|---|
| `how_tested` | The test used for the sample |
| `cells` | Cells in the final object |
| `*_same_label`, `*_gene_score_max_difference`, `*_nhood_z_max_difference`, `stage1_run_nhood_z_correlation` | Each run compared with the saved object: identical `cell_class_threshold` labels, gene-set scores and Nhood z-scores |
| `stage1_run_same_label_as_label_table` | Labels compared with the per-cell label table |
| `gene_sets_compared`, `nhood_labels_compared` | Gene sets and labels included in the comparison |
| `recalculated_*_same_label`, `recalculated_*_nhood_z_correlation` | The recalculated PCA test in each run; where cells were removed, same label is among cells kept in both results |
| `recalculated_labels_only_in_one_result` | Labels found in only one of the two results |
| `recalculated_cells_kept_original`, `recalculated_cells_kept`, `recalculated_kept_cells_now_removed`, `recalculated_removed_cells_now_kept`, `recalculated_kept_cells_jaccard` | Kept cells in the original analysis and in the test, and the overlap between them, from the previous reruns |
| `previous_and_stage1_run_agree` | Whether the two runs agree on every shared measure |

`NA` means the measure doesn't apply: scoring-only samples have no recalculated PCA test, and cell counts apply only to samples where clusters were removed.

## Sample settings

| Sample | Crop | Genes removed | Minimum counts | Leiden resolution | Score quantile | Cluster-based steps |
|---|---|---|---|---|---|---|
| MH065_314 | None | None | 10 | 2.0 | 0.75 | Clusters 25 removed; Label changes |
| MH074_314 | None | None | 10 | 2.5 | 0.7 | Label changes |
| MH096_314 | None | None | 30 | 1.0 | 0.5 | Scoring only |
| MH097_314 | x 0–8400, y 0–6000 | None | 15 | 1.0 | 0.6 | Clusters 8 removed |
| MH099_314 | x 0–8000, y 0–5000 | None | 10 | 2.0 | 0.6 | Clusters 0, 3, 12 removed; Label changes |
| MH104_314 | x 0–8000, y 350–5600 | None | 15 | 2.5 | 0.7 | Label changes |
| MH106_314 | x 0–8000, y 0–6000 | None | 15 | 2.0 | 0.65 | Clusters 26 removed |
| MH107_314 | x 0–8300, y 350–5000 | None | 20 | 3.0 | 0.55 | Label changes |
| MH065_480 | None | LGALS3 | 10 | 2.0 | 0.75 | Scoring only |
| MH074_480 | None | LGALS3 | 10 | 1.0 | 0.5 | Scoring only |
| MH096_480 | None | None | 10 | 1.5 | 0.65 | Scoring only |
| MH097_480 | x 450–10700, y 235–6000 | None | 15 | 1.4 | 0.75 | Scoring only |
| MH099_480 | None | LGALS3 | 10 | 1.5 | 0.55 | Clusters 1, 3, 8, 12 removed |
| MH104_480 | None | None | 10 | 1.5 | 0.7 | Scoring only |
| MH106_480 | None | None | 15 | 2.0 | 0.62 | Clusters 21 removed |
| MH107_480 | None | LGALS3 | 15 | 1.5 | 0.7 | Scoring only |

All samples use `MIN_CELLS = 5`, 15 neighbours and a 50 µm Nhood radius. The seeds are in each notebook's parameters cell.

## Label changes after scoring

In five samples, labels were changed after scoring in the original analysis. The notebooks repeat these changes in `apply_label_changes`. Where they use the cluster-based annotation (`anno`), it is read from the saved object.

| Sample | Change |
|---|---|
| MH065_314 | Cells labelled SMCs take the cluster-based annotation: SMCs if `vSMCs`, CAFs_MYO if `CAFs_MYO`, otherwise SMCs |
| MH074_314 | Unclassified cells in `Ductal MUC5B`, `Ductal REG+` or `Malignant cells` take that label. Then the SMC change as in MH065_314 |
| MH099_314 | All Unclassified cells become Malignant cells |
| MH104_314 | Cells labelled SMCs: SMCs if `vSMCs`, otherwise CAFs_MYO |
| MH107_314 | Unclassified cells take a label from the cluster-based annotation: `vSMCs` to SMCs, `TAMs_SPP1_OLR1` to TAMs_SPP1, and `CAFs_MYO`, `Malignant cells`, `CAFs_CXCL14` or `Endothelial` to the same label. Other cells stay Unclassified |

In four samples, label names were also changed to match the original objects (`LABEL_RENAMES`): `Ductal ` to `Ductal` in MH065_480, and `Acinar_REG` to `Acinar_REG+` in MH096_314, MH097_314 and MH099_314.

## Files

| File | Purpose |
|---|---|
| `<sample>_stage1.ipynb` | One notebook per sample, from raw data to the final object |
| `stage1_robustness_summary.ipynb` | Collects each sample's results into the table above |
| `stage1_robustness_table.tsv` | The table above, with full precision |
| `stage1_executive_summary.tsv` | The summary of checks above |
| `stage1_supplementary_table.tsv` | Supplementary details for all 16 samples, from both runs |

## Running a notebook

Set the four folders at the top of the parameters cell, then run all cells with the `xenium.squidpy` kernel:

| Setting | Folder |
|---|---|
| `RAW_DATA_DIR` | Raw Xenium output, one subfolder per sample (`<sample>/cell_feature_matrix.h5` and `<sample>/cells.csv`) |
| `SAVED_OBJECT_DIR` | The saved objects (`<sample>.h5ad`): the archived inputs and the objects to check against. Only read |
| `LABEL_TABLE_DIR` | Per-cell label tables (`<sample>.csv`). Optional: if a sample's table is missing, that comparison is skipped |
| `OUTPUT_ROOT` | Where results go, one subfolder per sample |

The paths in the notebooks were replaced with these placeholders after they were run.

Each notebook writes these files to `OUTPUT_DIR`:

- `<sample>.h5ad`: the final object
- `<sample>.csv`: per-cell metadata and log-normalised expression
- `stage1_check.tsv`: the comparison with the saved object
- `robustness_summary.tsv`: the recalculated PCA test, for the nine samples that have one
- `recalculated_labels.csv.gz`: per-cell labels and coordinates from that test, for the same nine samples
- `software_versions.tsv`: the package versions used
