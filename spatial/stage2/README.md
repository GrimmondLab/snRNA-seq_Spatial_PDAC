# Stage 2: cellular neighbourhoods (niches)

Groups the cells of all 16 samples into 15 niches by the cell types around them (`stage2_niches.ipynb`), profiles the neighbours of selected cell types (`stage2_neighbourhood_profiling.ipynb`), and plots the figures drawn from single samples (`stage2_figures.ipynb`). All three notebooks start from the final Stage 1 objects.

Reproduces Fig. 1D, 1F (Xenium panel), 2A–D, 4B–F, 5B–E and Extended Data Fig. 2D, 3, 5C–D, 6D–E and 8H–I.

**Result: near-exact.** Cell labels and K-means input are identical; niche assignment matches for 99.9994% of cells, with 18 borderline cells (of 2,930,241) assigned to a neighbouring niche. All 15 clusters match their original niche names. The run in the project image (v1.0.0) gives the same niche for every cell as the run outside it. The profiling and single-sample figures are computed from the Stage 1 objects, which reproduce exactly, and have no random steps; the Fig. 4E statistics are as in the original (F = 25.0082, p < 0.0001).

## Manuscript outputs

| Output | Notebook | File |
|---|---|---|
| Fig. 2A–D, Extended Data Fig. 3 | `stage2_niches.ipynb` | `figures/` (see Details) |
| Fig. 1F (Xenium panel) | `stage2_niches.ipynb` | `figures/Fig1f_Xenium_broad_cell_class_composition.pdf`, with `Fig1f_Xenium_broad_cell_class_proportions.csv` (broad cell classes per sample; added 2026-11-20, not yet run) |
| Fig. 1D | `stage2_figures.ipynb` | `umap_Fig1d_MH065_314.png`, `Fig1d_MH065_314_scatterplot.png` (MH065_314) |
| Fig. 4B | `stage2_figures.ipynb` | `dotplot_Fig4b_TAMs_CAFs_Tu.pdf` (MH107_480) |
| Fig. 4C | `stage2_neighbourhood_profiling.ipynb` | `Fig4c_Malignant_cells_cross_sample_median.pdf`, with its `.tsv` |
| Fig. 4D | `stage2_figures.ipynb` | `Fig4d-1_MH106_480.pdf`, `Fig4d-2_MH104_480.pdf`, `Fig4d-3_MH096_480.pdf` (MH106_480, MH104_480, MH096_480) |
| Fig. 4E | `stage2_neighbourhood_profiling.ipynb` | `Fig4e_Persample_median_distant_PDAC_neighbours_TAMs_CAFs.pdf`, with `Fig4e_summary.tsv`, `Fig4e_repeated_measures_anova.tsv` and `Fig4e_posthoc_paired_ttests.tsv` |
| Fig. 4F | `stage2_neighbourhood_profiling.ipynb` | `Fig4f_PDAC_top8_over6sample.pdf` |
| Fig. 5B | `stage2_figures.ipynb` | `Fig5b_MH106_480.pdf`, `Fig5b-2_MH107_480.pdf`, `Fig5b-3_MH106_314.pdf` (MH106_480, MH107_480, MH106_314) |
| Fig. 5C | `stage2_neighbourhood_profiling.ipynb` | `Fig5c_CAFs_NRT_cross_sample_median.pdf`, `Fig5c_TAMs_C1QC_cross_sample_median.pdf`, `Fig5c_CD4_T_cross_sample_median.pdf`, `Fig5c_CD8_T_cross_sample_median.pdf`, each with its `.tsv` |
| Fig. 5D | `stage2_neighbourhood_profiling.ipynb` | `Fig5d_NRT_C1QC_nhood_50.pdf` |
| Fig. 5E | `stage2_figures.ipynb` | `stacked_violin_Fig5e_CXCL12_CXCR4_signalling.pdf` (MH107_480) |
| Extended Data Fig. 2D | `stage2_figures.ipynb` | `EDFig2d-1_MH106_G12D.pdf`, `EDFig2d-2_MH106_GNAS_R844H.pdf` (MH106_480) |
| Extended Data Fig. 5C–D | `stage2_figures.ipynb` | `umap_EDFig5c_CAFs_clustering_MH106.png`, `EDFig5d_CAFs_CXCL14rep.png` (MH106_480) |
| Extended Data Fig. 6D | `stage2_neighbourhood_profiling.ipynb` | `EDFig6d_Persample_median_distant_PDAC_neighbours_all.pdf` |
| Extended Data Fig. 6E | `stage2_neighbourhood_profiling.ipynb` | `EDFig6e_PDAC_CAFs_TAM_relative_enrichment.pdf` |
| Extended Data Fig. 8H–I | `stage2_figures.ipynb` | `stacked_violin_LymphoidStromal_geneexpression.png`, `EDFig8i_lymphnode.png` (MH104_480) |

## Run

In the project image: `run.sh spatial2`, after Stage 1 and with the same output folder (see "Running the spatial stages" in the top-level `README.md`). No GPU. In the image (v1.0.0) all three notebooks took 8 min, with a peak of 9.0 GB. On Spartan: `stage2_spartan.slurm` (2 CPUs, 32 GB, 2 h).

**Starting without Stage 1.** Stage 2 can also start from the 16 processed objects deposited on Zenodo (`Xenium_480.tar`, `Xenium_314.tar`) instead of the Stage 1 output: in `stage2_spartan.slurm`, set `STAGE1_SOURCE=deposited` and `DEPOSITED_DIR` to the folder with the extracted `.h5ad` files. The script links each file under the name Stage 2 reads, checks that every object holds the labels, coordinates and Nhood z-scores Stage 2 needs, and then runs the notebooks. In the image, Stage 1 reproduces these objects exactly, so both starts should give the same result; the deposited start has not been run yet.

**Optional: compare with the original niches.** Download `stage2_niche_labels_original.csv.gz` (Zenodo [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322); 27 MB, the original niche of each cell) into a folder and set `REFERENCE_DIR` in `stage2_spartan.slurm` to it. After the run, the script compares each cell's `cell_class_threshold`, K-means cluster and niche with the original and writes `stage2_image_check.tsv`. Stage 2 runs without it.

<details>
<summary>Running the notebooks directly</summary>

Set the paths in each notebook's parameters cell, then run all cells with the `xenium.squidpy` kernel (see `../environment/`). `stage2_niches.ipynb`:

| Setting | Path |
|---|---|
| `STAGE1_DIR` | The final Stage 1 objects, one subfolder per sample (`<sample>/<sample>.h5ad`) |
| `OUTPUT_DIR` | Where results go. Figures go to `OUTPUT_DIR/figures` |
| `ORIGINAL_COMBINED` | The original combined object, not deposited, used only for the check. Set to `None` to skip the check |

`stage2_figures.ipynb` and `stage2_neighbourhood_profiling.ipynb` use the same `STAGE1_DIR`. `stage2_figures.ipynb` saves its figures to `FIGURE_DIR`; `stage2_neighbourhood_profiling.ipynb` saves its tables to `OUTPUT_DIR` and its figures to `OUTPUT_DIR/figures`.

The paths in the notebooks were replaced with these placeholders after they were run. The niche analysis needs about 64 GB of memory and no GPU.

</details>

## Outputs

| File | Contents |
|---|---|
| `Combined_CLR_transform_global_CN_stage2.h5ad` | All cells with neighbour fractions, scaled CLR values, K-means cluster and niche |
| `stage2_niche_labels.csv.gz` | Sample, cell ID, `cell_class_threshold`, K-means cluster and niche for each cell |
| `stage2_check.tsv` | The check against the original |
| `software_versions.tsv` | The package versions used |
| `figures/` | The niche figures |
| `manuscript_figures/` | The figures from single samples (`FIGURE_DIR` in `stage2_figures.ipynb`) |
| `neighbourhood_profiling/` | Neighbourhood profiling tables and figures (`OUTPUT_DIR` in `stage2_neighbourhood_profiling.ipynb`), including the distances for each malignant cell and the combined Nhood z-scores (`.csv.gz`) |

## Comparison with the original

| Check | Result |
|---|---|
| Cells | 2,930,241, the same cells in the same order |
| Cell types | The same |
| Neighbour fractions | Max difference 0 |
| Scaled CLR values | Max difference 0 |
| Same K-means cluster | 99.9994% of cells |
| Same niche | 99.9994% of cells |
| Niche names | All 15 clusters match their original names |

The 18 cells with a different niche all moved between stromal, immune and vascular niches; every cell kept its `cell_class_threshold` label (see Details).

**Run in the project image** (v1.0.0, Spartan, `stage2_spartan.slurm`, `stage2_image_check.tsv`):

| Check | Against the original | Against the run outside the image |
|---|---|---|
| Cells | 2,930,241, all shared | 2,930,241, all shared |
| Same `cell_class_threshold` | 100% | 100% |
| Same K-means cluster | 99.9994% (18 cells differ) | 100% |
| Same niche | 99.9994% (18 cells differ) | 100% |

The image gives exactly the niches of the run outside it, so the same 18 cells differ from the original.

## Details

<details>
<summary>Niche workflow and choice of K</summary>

1. **Input:** the 16 final Stage 1 objects. Only `cell_class_threshold`, the cell coordinates and the cell IDs are used.
2. **Neighbour fractions:** for each cell, the fraction of each `cell_class_threshold` label among its neighbours within 50 µm, in its own sample. The cell itself is not counted. Cells with no neighbours within 50 µm are left out (786 cells).
3. **Combine samples:** the 16 samples are combined into one matrix. A label that is missing from a sample, for example because it is specific to one gene panel, counts as 0.
4. **Transform:** centred log-ratio (CLR) transform with a pseudocount of 0.001, then centring and scaling of each label.
5. **Niches:** K-means with K = 15 (`random_state = 23`, `n_init = 12`). Each cell is weighted by 1 / (cells in its sample), so that every sample contributes equally.
6. **Names:** each cluster is given a niche name (`niche_name_map`). The run stops if the clusters do not match the names, or, when the original combined object is given, if any cluster's majority original niche differs from its name.
7. **Figures:** every figure is saved to `FIGURE_DIR`.

**Choosing K.** K was chosen from the elbow, centroid stability and held-out error for K = 8–25, using MiniBatchKMeans. K = 15 was chosen; K = 8 had higher centroid stability (0.8635 vs 0.8395 at K = 15). This step takes several hours, so it is switched off (`RUN_K_SELECTION = False`) and does not change the final fit.

</details>

<details>
<summary>The 18 cells with a different niche</summary>

The 18 cells with a different niche come from 11 samples, with at most 4 in one sample (MH104_314). They all moved between stromal, immune and vascular niches: for example 3 from B_Lymphoid_enriched to CAFsNRT_APCs_enriched, and 3 from Vasculature_enriched to Tumour_TAMs_enriched. No cell moved into or out of Tumour_Tuft_enriched, IPMN_enriched or B_FDCs_enriched. Every cell kept its `cell_class_threshold` label. This comparison used the original niche labels for each cell (`stage2_niche_labels_original.csv.gz`, deposited on Zenodo [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322)).

</details>

<details>
<summary>Niches and their sizes</summary>

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

</details>

<details>
<summary>Niche figure files (Fig. 2A–D, Extended Data Fig. 3)</summary>

| File | Contents |
|---|---|
| `Niches_mean_fraction.pdf` | Mean fraction of each cell type in each niche |
| `Niches_composition_celltype_v2.pdf` | Enrichment of each cell type across niches (z-score) |
| `Niches_log2FC.pdf` | Enrichment or depletion of each cell type in each niche, against the overall mean |
| `Niches_composition_CLR_reorder.pdf` | Niche composition of each sample |
| `Fig1f_Xenium_broad_cell_class_composition.pdf` | Broad cell class composition of each sample (Fig. 1F, Xenium panel), with the proportions in `Fig1f_Xenium_broad_cell_class_proportions.csv`. Uses `cell_class_threshold` grouped into 20 broad classes, not the niches |
| `Samplecontributionperniche.pdf` | Share of each niche's cells from each sample |
| `Representative_niches_<sample>.pdf` | Niches in MH097_480, MH096_314, MH106_314 and MH107_480 |
| `PieCharts.pdf` | Top 10 cell types in each niche |
| `<niche>_acrossPatients.pdf` | Cell types of one niche in each sample, for 7 niches |
| `<niche>_top9_pie.pdf` | Top 9 cell types of CAFsNRT_APCs_enriched and Tumour_Neutrophils_Lymphoid_enriched |

</details>

<details>
<summary>Figures from single samples</summary>

`stage2_figures.ipynb` plots single samples from their final Stage 1 objects, mostly by `cell_class_threshold`. Fig. 1D uses the broad classes from the cluster-based annotation (`anno`), and Extended Data Fig. 5C uses the Leiden clusters; both are read from the Stage 1 object, as are the UMAP coordinates. Some of these figures were originally made from earlier objects of the same samples (named in the notebook).

</details>

<details>
<summary>Neighbourhood profiling methods</summary>

`stage2_neighbourhood_profiling.ipynb` uses `cell_class_threshold`, the cell coordinates and the Nhood enrichment z-scores from Stage 1 (50 µm radius). It has no random steps.

1. **Nearest-neighbour distances:** for each malignant cell, the distance to the nearest cell of each other type within 50 µm. A type with no cell within 50 µm is left out for that malignant cell, not counted as further away, so all distances are 50 µm or less. 433,949 of the 444,967 malignant cells have at least one neighbour within 50 µm. The median distance per sample is then compared across cell types.
2. **Fig. 4E statistics:** the seven CAF and TAM subtypes are compared with a repeated-measures ANOVA (F = 25.0082, df 6 and 84, p < 0.0001, as in the original analysis), then paired t-tests with Benjamini–Hochberg correction. 15 samples are included. MH096_314 is mostly adjacent normal tissue, with only 170 malignant cells, none of which has a cell of these types within 50 µm. The notebook prints a Shapiro test for each cell type (p = 0.010 for TAMs_C1QC, 0.067–0.987 for the others). Other tests were also checked, and the repeated-measures ANOVA was kept.
3. **Nhood enrichment:** the Stage 1 z-scores, scaled to 0–1 within each sample, then averaged across samples. Neighbour types found in fewer than 3 samples (Extended Data Fig. 6E, Fig. 5D) or 6 samples (Fig. 4F) are left out.
4. **Neighbour composition:** for each cell of a given type, the fraction of each other cell type within 50 µm, excluding cells of the same type and unclassified cells, averaged over the cells of that type in each sample.

</details>

<details>
<summary>Files in this folder</summary>

| File | Purpose |
|---|---|
| `stage2_niches.ipynb` | The niche analysis, from the final Stage 1 objects to the niches and figures |
| `stage2_figures.ipynb` | Manuscript figures plotted from single Stage 1 objects |
| `stage2_neighbourhood_profiling.ipynb` | Distances, Nhood enrichment and neighbour composition around selected cell types |
| `stage2_spartan.slurm` | Slurm script to run this stage in the image on an HPC cluster, after `../stage1/stage1_spartan.slurm` with the same output folder. If `REFERENCE_DIR` holds `stage2_niche_labels_original.csv.gz` (Zenodo, not in the image or this repository), it then compares each cell's niche with it and writes `stage2_image_check.tsv`; `COMPARE_ONLY=yes` runs only that comparison. `STAGE1_SOURCE=deposited` starts from the deposited processed objects instead of the Stage 1 output |

</details>
