# Stage 2: cellular neighbourhoods (niches)

This stage groups the cells of all 16 samples into 15 niches by the cell types around them. It starts from the final Stage 1 objects.

## Summary

The rerun matched the original niche analysis: the neighbour fractions and scaled values were identical, and 99.9994% of cells (all but 18 of 2,930,241) were given the same niche. All 15 clusters matched their original niche names.

## Workflow

1. **Input:** the 16 final Stage 1 objects. Only `cell_class_threshold`, the cell coordinates and the cell IDs are used.
2. **Neighbour fractions:** for each cell, the fraction of each `cell_class_threshold` label among its neighbours within 50 µm, in its own sample. The cell itself is not counted. Cells with no neighbours within 50 µm are left out (786 cells).
3. **Combine samples:** the 16 samples are combined into one matrix. A label that is missing from a sample, for example because it is specific to one gene panel, counts as 0.
4. **Transform:** centred log-ratio (CLR) transform with a pseudocount of 0.001, then centring and scaling of each label.
5. **Niches:** K-means with K = 15 (`random_state = 23`, `n_init = 12`). Each cell is weighted by 1 / (cells in its sample), so that every sample contributes equally.
6. **Names:** each cluster is given a niche name (`niche_name_map`). The run stops if the clusters do not match the names, or, when the original combined object is given, if any cluster's majority original niche differs from its name.
7. **Figures:** every figure is saved to `FIGURE_DIR`.

**Choosing K.** K was chosen from the elbow, centroid stability and held-out error for K = 8–25, using MiniBatchKMeans. K = 15 was chosen; K = 8 had higher centroid stability (0.8635 vs 0.8395 at K = 15). This step takes several hours, so it is switched off (`RUN_K_SELECTION = False`) and does not change the final fit.

## Check against the original

| Check | Result |
|---|---|
| Cells | 2,930,241, the same cells in the same order |
| Cell types | The same |
| Neighbour fractions | Max difference 0 |
| Scaled CLR values | Max difference 0 |
| Same K-means cluster | 99.9994% of cells |
| Same niche | 99.9994% of cells |
| Niche names | All 15 clusters match their original names |

The 18 cells with a different niche come from 11 samples, with at most 4 in one sample (MH104_314). They all moved between stromal, immune and vascular niches: for example 3 from B_Lymphoid_enriched to CAFsNRT_APCs_enriched, and 3 from Vasculature_enriched to Tumour_TAMs_enriched. No cell moved into or out of Tumour_Tuft_enriched, IPMN_enriched or B_FDCs_enriched. Every cell kept its `cell_class_threshold` label. This comparison used the original niche labels for each cell (`stage2_niche_labels_original.csv.gz`).

## Niches

| Cluster | Niche | Cells |
|---|---|---|
| 7 | Tumour_TAMs_CAFs_enriched | 342,100 |
| 13 | AcinarREG_Ductal_enriched | 319,989 |
| 6 | Acinar_Ductal_enriched | 318,035 |
| 10 | Tumour_CAFs_enriched | 280,239 |
| 11 | Tumour_TAMs_enriched | 269,293 |
| 5 | CAFsNRT_APCs_enriched | 255,784 |
| 1 | Vasculature_enriched | 242,283 |
| 9 | B_Lymphoid_enriched | 189,937 |
| 4 | Tumour_DuctalMUC5B_enriched | 183,563 |
| 14 | Endocrine_Ductal_enriched | 161,492 |
| 12 | Schwann_LymphoidStromal_TAMsC1QC_enriched | 142,576 |
| 3 | Tumour_Neutrophils_Lymphoid_enriched | 117,409 |
| 8 | B_FDCs_enriched | 45,844 |
| 2 | Tumour_Tuft_enriched | 39,811 |
| 0 | IPMN_enriched | 21,886 |

## Figures

The notebook plots only the figures used in the manuscript.

| File | Contents | Manuscript panel |
|---|---|---|
| `Niches_mean_fraction.pdf` | Mean fraction of each cell type in each niche | To add |
| `Niches_composition_celltype_v2.pdf` | Enrichment of each cell type across niches (z-score) | To add |
| `Niches_log2FC.pdf` | Enrichment or depletion of each cell type in each niche, against the overall mean | To add |
| `Niches_composition_CLR_reorder.pdf` | Niche composition of each sample | To add |
| `Samplecontributionperniche.pdf` | Share of each niche's cells from each sample | To add |
| `Representative_niches_<sample>.pdf` | Niches in MH097_480, MH096_314, MH106_314 and MH107_480 | To add |
| `PieCharts.pdf` | Top 10 cell types in each niche | To add |
| `<niche>_acrossPatients.pdf` | Cell types of one niche in each sample, for 7 niches | To add |
| `<niche>_top9_pie.pdf` | Top 9 cell types of CAFsNRT_APCs_enriched and Tumour_Neutrophils_Lymphoid_enriched | To add |

## Running the notebook

Set the paths in the parameters cell, then run all cells with the `xenium.squidpy` kernel (see `../environment/`):

| Setting | Path |
|---|---|
| `STAGE1_DIR` | The final Stage 1 objects, one subfolder per sample (`<sample>/<sample>.h5ad`) |
| `OUTPUT_DIR` | Where results go. Figures go to `OUTPUT_DIR/figures` |
| `ORIGINAL_COMBINED` | The original combined object, used only for the check. Set to `None` to skip the check |

The paths in the notebook were replaced with these placeholders after it was run. It needs about 64 GB of memory and no GPU.

## Outputs

| File | Contents |
|---|---|
| `Combined_CLR_transform_global_CN_stage2.h5ad` | All cells with neighbour fractions, scaled CLR values, K-means cluster and niche |
| `stage2_niche_labels.csv.gz` | Sample, cell ID, `cell_class_threshold`, K-means cluster and niche for each cell |
| `stage2_check.tsv` | The check against the original |
| `software_versions.tsv` | The package versions used |
| `figures/` | The figures above |

## Files

| File | Purpose |
|---|---|
| `stage2_niches.ipynb` | The analysis, from the final Stage 1 objects to the niches and figures |
