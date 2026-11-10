# Stage 3: malignant cells, TILs and Tuft cells

Three notebooks, all following the original analysis exactly:

- `stage3_malignant_TIL.ipynb`: malignant cells near and far from TILs (sections below up to Notes).
- `stage3_TIL_regions.ipynb`: the TIL regions themselves (see [TIL regions](#til-regions)).
- `stage3_tuft.ipynb`: Tuft cells across all samples, and three re-analysed Tuft regions (see [Tuft cells](#tuft-cells)).

The TLS analysis is still to be added.

`stage3_malignant_TIL.ipynb` compares malignant cells next to a TIL-rich area (`wTIL`) with malignant cells away from it (`noTIL`), in three 480-gene samples: MH065_480, MH106_480 and MH107_480. It starts from the final Stage 1 objects.

## Workflow

1. **Regions:** for each sample, two fixed boxes in µm, taken from the original notebooks:

   | Sample | `noTIL` (x, y) | `wTIL` (x, y) |
   |---|---|---|
   | MH065_480 | 6400–7400, 2200–3000 | 8800–10000, 1200–3200 |
   | MH106_480 | 2200–3400, 3000–3900 | 5500–5950, 1800–3000 |
   | MH107_480 | 6400–7000, 1600–2800 | 8600–9400, 800–2900 |

2. **Malignant cells:** cells in either box whose `cell_class_threshold` and `anno` (the saved cluster-based annotation from Stage 1) are both "Malignant cells".
3. **DE:** the raw counts of these cells are normalised and log-transformed again, then `wTIL` and `noTIL` are compared with a Wilcoxon test.
4. **Pathway scores:** `sc.tl.score_genes` for 15 gene sets (`ctrl_size = 20`, `random_state = 22`).
5. **Paired comparison:** the mean hypoxia, IL6 and OXPHOS scores per sample and region, compared between `wTIL` and `noTIL` with a paired t-test across the three samples.

PCA, UMAP and Leiden clustering are not used.

## Reproducibility

Compared with the original analysis:

| Check | Result |
|---|---|
| Malignant cells per region | Identical cells and regions: 3,126 (MH065_480), 2,271 (MH106_480), 1,720 (MH107_480) |
| DE, `wTIL` vs `noTIL` | Identical: same top 10 genes in each region, log fold-change max difference 0 |
| Paired t-tests | Same p-values: hypoxia 0.0031, IL6 0.1545, OXPHOS 0.1303 |
| Mean pathway scores | Within 5 × 10⁻⁷ of the original |

An earlier DE analysis of MH106_314 is not part of the final analysis and has been removed from the notebook. The outputs saved in the notebook come from a run that still included MH106_314, so two outputs still mention it. The code for the three 480-gene samples is unchanged, so their results are the same.

## Figures

| Figure | File | Contents |
|---|---|---|
| Fig. 5H | `heatmap_Fig5_MH107_TIL_topDE.pdf` | Top DE genes in MH107_480, `wTIL` vs `noTIL` |
| Fig. 5I | `Hypoxia_score_TIL.pdf`, `IL6_score_TIL.pdf`, `OXPHOS_score_TIL.pdf` | Mean hypoxia, IL6–STAT3 and OXPHOS scores per sample and region, with the paired t-test |
| Extended Data Fig. 7F | `heatmap_MH065_topDE.pdf` | Top DE genes in MH065_480, `wTIL` vs `noTIL` |
| Extended Data Fig. 7G | `MH065_signalling_scatter.pdf` | IL6, IFNG, OXPHOS and hypoxia scores of MH065_480 in space (z-scores) |

## Notes

- **Saved clusters:** the malignant cells depend on `anno`, the cluster-based annotation saved in the Stage 1 objects, as well as on `cell_class_threshold`.
- **Three samples:** each paired t-test compares three samples.
- **TGFB gene set:** it lists `AVCR1B`, a typo for `ACVR1B`, so that gene is not scored. The original had the same typo, and TGFB is not plotted.

## TIL regions

`stage3_TIL_regions.ipynb` looks at four regions with a high local density of T cells, one per sample: MH065_480, MH106_480, MH107_480 and MH106_314.

1. **Crop:** each region is cropped from the **raw Xenium output**, not from the Stage 1 objects:

   | Sample | Region (x, y, µm) | Minimum counts | Score quantile |
   |---|---|---|---|
   | MH065_480 | 8500–10000, 1800–3600 | 8 | 0.75 |
   | MH107_480 | 8000–10000, 280–3200 | 10 | 0.75 |
   | MH106_480 | 5200–6400, 1800–3600 | 8 | 0.75 |
   | MH106_314 | 1500–4500, 3000–5500 | 15 | 0.70 |

2. **QC and normalisation within the region:** cells below the minimum counts and genes in fewer than 5 cells are removed, then counts are normalised and log-transformed.
3. **Labels within the region:** each cell gets its highest-scoring label from a region-specific set of gene sets, or "Unclassified" below the threshold. These region-level labels are stored as `TIL_cell_class_threshold`, to keep them apart from the Stage 1 `cell_class_threshold`, and are used only in this notebook.
4. **TIL composition:** the share of each label in each region, for labels found in at least 3 of the 4 regions.
5. **Distance to T cells:** for each malignant-cell region from `stage3_malignant_TIL.ipynb`, the median distance from each malignant cell to its nearest T cell (CD4, CD4 Tfh, CD4 Treg, CD8 or CD8 TRM). Distances are in µm. Only T cells inside the cropped TIL region are counted, so the `noTIL` distances (1,440–2,392 µm) are in effect distances to the TIL region.

PCA, UMAP and Leiden clustering are not used.

**Reproducibility.** Compared with the original region objects and values:

| Check | Result |
|---|---|
| Cells per region | Identical: 10,928 (MH065_480), 21,695 (MH107_480), 9,081 (MH106_480), 39,875 (MH106_314) |
| Region-level labels (`TIL_cell_class_threshold`) | 100% of cells identical to the original region labels in all four regions |
| Median distance to the nearest T cell (`noTIL` / `wTIL`) | Same as the original: MH106_480 2,392.3 / 98.7 µm, MH107_480 1,440.3 / 82.6 µm, MH065_480 1,552.1 / 53.9 µm |

| Figure | File | Contents |
|---|---|---|
| Extended Data Fig. 7C | `TIL_comp.pdf` | Composition of each TIL region |
| To add | `dotplot_Marker_Immunregulatory.pdf` | Immune markers in T cells and malignant cells of the MH107_480 TIL region |

The T cell counts are saved as `TIL_cell_counts.tsv`, and the distances as `malignant_to_TIL_distance.tsv`.

## Tuft cells

`stage3_tuft.ipynb` has two parts.

**Tuft cells across all samples**, from the final Stage 1 objects and their `cell_class_threshold` labels:

1. **Counts:** Tuft cells per sample, with and without MH074_314, which has most of them.
2. **Neighbour composition:** for each Tuft cell, the share of each label among cells within 50 µm (Tuft, "Unclassified" and "Unassigned" left out), averaged per sample, in the 8 samples with Tuft cells.
3. **Distances:** for each Tuft cell, the distance to the nearest cell of each label within 50 µm, then the median per sample for five epithelial labels.
4. **Nhood enrichment:** the Stage 1 z-scores of Tuft against each other label, min–max scaled within each sample, then the median across samples, for labels found in at least 3 samples.
5. **MH074_314 niche:** the Tuft cells of MH074_314 and the labels around them, in space and by marker expression.

**Three re-analysed regions**, each cropped from the **raw Xenium output**, as for the TIL regions:

| Sample | Region (x, y, µm) | Minimum counts | Score quantile |
|---|---|---|---|
| MH096_480 | 5200–6600, 0–2100 | 10 | 0.75 |
| MH099_480 | 7000–7500, 4000–4300 | 10 | 0.50 |
| MH106_480 | 7400–8500, 3600–4250 | 15 | 0.65 |

Within each region, cells below the minimum counts and genes in fewer than 5 cells are removed, counts are normalised and log-transformed, and each cell gets its highest-scoring label from a region-specific set of gene sets (`predicted_cell_type_threshold`), or "Unclassified" below the threshold. Two adjustments follow the original:

- **MH099_480:** "Unclassified" cells are labelled "Malignant cells".
- **MH096_480:** 103 cells scored as Endocrine but outside the Endocrine cluster are relabelled "Ductal MUC5B" if their cluster was Ductal MUC5B+, otherwise "Unclassified". The clusters come from the region's Leiden clustering, which doesn't reproduce exactly, so they are read from the original region object.

PCA, UMAP and Leiden clustering are not run. The one UMAP figure (Extended Data Fig. 4B, MH099_480) uses the UMAP saved in the original region object, so it keeps the published layout. The notebook stops if the region's cells differ from the original's. So the original MH096_480 and MH099_480 region objects are needed to run the notebook, not only for the check.

**Reproducibility.** Compared with the original values and region objects:

| Check | Result |
|---|---|
| Tuft cells | Same as the original: 2,122 of 2,931,027 cells (0.0724%), 1,446 of them in MH074_314 |
| Cells per region | Identical: 11,992 (MH096_480), 827 (MH099_480), 4,551 (MH106_480) |
| Region-level labels (`predicted_cell_type_threshold`) | 100% of cells identical to the original region labels in all three regions |

| Figure | File | Contents |
|---|---|---|
| Fig. 3B | `Tuft_neighbours_bar_top12.pdf` | Neighbour composition around Tuft cells, per sample |
| Fig. 3C | `Persample_median_distant_Tuft_neighbours.pdf` | Median distance from Tuft cells to the nearest epithelial cells, per sample |
| Fig. 3D | `EnrichmentAnalysisTuft_bar.pdf` | Labels most enriched around Tuft cells (median of min–max scaled Nhood z-scores) |
| Fig. 3G | `stacked_violin_MH096_PVR_tuftexpression.pdf`, `stacked_violin_MH099_PVR_tuftexpression.pdf`, `stacked_violin_MH106_PVR_tuftexpression.pdf` | Tuft markers, PVR, MDK and IL17RB in the epithelial cells of MH096_480, MH099_480 and MH106_480 |
| Extended Data Fig. 4B | `umapMH099_480_rep_tuft_niche_umap.pdf`, `MH099_480_rep_tuft_niche_all.pdf`, `MH099_480_rep_tuft_niche.pdf` | MH099_480 region on the saved UMAP (labels, RGS13, AVIL and BMX), and in space with all labels and with epithelial labels only |
| Extended Data Fig. 4C | `dotplot_MH096_ADM_markers.pdf` | Acinar, ductal, malignant and Tuft markers in the epithelial cells of MH096_480 |
| Extended Data Fig. 4D | `MH074_314_rep_tuft_niche.pdf`, `MH074_314_rep_tuft_only.pdf` | The MH074_314 Tuft niche in space, all its labels and Tuft cells only |
| Not used | `dotplot_MH074_314_tuft_niche_expression.pdf` | Marker expression of the MH074_314 niche labels, to check their identity |
| Not used | `MH096_480_rep_tuft_niche.pdf` | Epithelial cells of MH096_480 in space (zoomed) |
| Not used | `MH106_480_rep_tuft_niche.pdf` | MH106_480 region in space (zoomed) |

**Notes.**

- **Plot title:** the neighbour composition plot was titled "Neighborhood composition of Malignant cells ... (Top 6 + Other)" in the original, though it shows Tuft cells and the top 15 labels. It is now titled "Neighborhood composition of Tuft cells across samples (top neighbours)". The data plotted are unchanged.
- **Hash seed:** `PYTHONHASHSEED` is set inside the notebook, which has no effect on a kernel that is already running. The labels still match exactly.

## Running the notebooks

Set the paths in each notebook's parameters cell, then run all cells with the `xenium.squidpy` kernel (see `../environment/`). Run `stage3_malignant_TIL.ipynb` before `stage3_TIL_regions.ipynb`, which reads its malignant-cell regions. `stage3_tuft.ipynb` doesn't depend on the other two. `stage3_malignant_TIL.ipynb`:

| Setting | Path |
|---|---|
| `STAGE1_DIR` | The final Stage 1 objects, one subfolder per sample (`<sample>/<sample>.h5ad`) |
| `OUTPUT_DIR` | Where results go. Figures go to `OUTPUT_DIR/figures` |
| `ARCHIVED_DIR` | The original subset objects, used only for the check. Set to `None` to skip it |

`stage3_TIL_regions.ipynb`:

| Setting | Path |
|---|---|
| `RAW_DATA_DIR` | Raw Xenium output, one subfolder per sample (`<sample>/cell_feature_matrix.h5` and `<sample>/cells.csv`) |
| `MALIGNANT_DIR` | The output folder of `stage3_malignant_TIL.ipynb` |
| `OUTPUT_DIR` | Where results go. Figures go to `OUTPUT_DIR/figures` |
| `ARCHIVED_DIR` | The original region objects, used only for the check. Set to `None` to skip it |

`stage3_tuft.ipynb`:

| Setting | Path |
|---|---|
| `STAGE1_DIR` | The final Stage 1 objects, one subfolder per sample (`<sample>/<sample>.h5ad`) |
| `RAW_DATA_DIR` | Raw Xenium output, one subfolder per sample (`<sample>/cell_feature_matrix.h5` and `<sample>/cells.csv`) |
| `ARCHIVED_DIR` | The original region objects. Required: the MH096_480 clusters and the MH099_480 UMAP are read from them |
| `OUTPUT_DIR` | Where results go. Figures go to `OUTPUT_DIR/figures` |

The paths in the notebooks were replaced with these placeholders after they were run.

## Outputs

| File | Contents |
|---|---|
| `<sample>_malignant_wTIL_vs_noTIL_DE.csv` | DE results for each sample |
| `<sample>_malignant_TIL_regions.h5ad` | The malignant cells of both regions, with DE results and pathway scores |
| `paired_pathway_scores.tsv` | Mean scores per sample and region, with the paired t-test p-values |
| `stage3_malignant_check.tsv` | The check against the original subsets |
| `figures/` | The figures above |

`stage3_TIL_regions.ipynb`: `<sample>_TIL_region.h5ad` (each cropped region with `TIL_cell_class_threshold`), `TIL_cell_counts.tsv`, `TIL_composition.tsv`, `malignant_to_TIL_distance.tsv`, `stage3_TIL_check.tsv` and `figures/`.

`stage3_tuft.ipynb`: `Tuft_counts.tsv`, `Tuft_min_distance_profiling.csv.gz` (distance from each Tuft cell to the nearest cell of each label), `Persample_median_distant_Tuft_neighbours.tsv`, `EnrichmentAnalysisTuft.tsv`, `<sample>_Tuft_region.h5ad` (each cropped region with `predicted_cell_type_threshold`), `stage3_tuft_check.tsv` and `figures/`.
