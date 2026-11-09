# Stage 3: malignant cells near and far from TILs

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

## Running the notebook

Set the paths in the parameters cell, then run all cells with the `xenium.squidpy` kernel (see `../environment/`):

| Setting | Path |
|---|---|
| `STAGE1_DIR` | The final Stage 1 objects, one subfolder per sample (`<sample>/<sample>.h5ad`) |
| `OUTPUT_DIR` | Where results go. Figures go to `OUTPUT_DIR/figures` |
| `ARCHIVED_DIR` | The original subset objects, used only for the check. Set to `None` to skip it |

The paths in the notebook were replaced with these placeholders after it was run.

## Outputs

| File | Contents |
|---|---|
| `<sample>_malignant_wTIL_vs_noTIL_DE.csv` | DE results for each sample |
| `<sample>_malignant_TIL_regions.h5ad` | The malignant cells of both regions, with DE results and pathway scores |
| `paired_pathway_scores.tsv` | Mean scores per sample and region, with the paired t-test p-values |
| `stage3_malignant_check.tsv` | The check against the original subsets |
| `figures/` | The figures above |
