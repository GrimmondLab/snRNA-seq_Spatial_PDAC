# Spatial proteomics: MIBI

This folder holds the code used to generate the MIBI figures in the manuscript. The analysis was done by collaborators at WEHI with their spatial proteomics pipelines (see [`../README.md`](../README.md)). The scripts and reports here are kept as received, except that personal names and internal paths were removed (2026-11-16) and `library(scales)` was added to `Fig5g_heatmap_cell_cell_comm.R`, which uses `muted()` from that package (2026-11-20). The cell–cell interaction analysis (Fig. 5G) has been rerun in a container (see [Reproduce the figures](#reproduce-the-figures)); the other scripts have not been rerun in this repository.

## Images, pipelines and containers

The raw MIBI images (33 FOVs), the segmentation and cell typing (steps 0a–0b) with the saved models and expected outputs, and their container (`mibi-pdac-repro.sif`) are on Zenodo, [10.5281/zenodo.24356840](https://doi.org/10.5281/zenodo.24356840). `mibi_README.md` in that record explains how to rerun steps 0a–0b. The `SpatialExperiment` (step 2) is on Zenodo [10.5281/zenodo.24360404](https://doi.org/10.5281/zenodo.24360404) (see [Input](#input)). This analysis is not in the project image or `run.sh`.

## Segmentation and cell typing (steps 0a–0b)

From the WEHI team's methods. The container `mibi-pdac-repro.sif` (sha256 `377bfd1fe4c30c19f09179c76cbe500f5e328c7802338bc6639884ad63ae655f`; [Apptainer](https://doi.org/10.1371/journal.pone.0177459)) holds QuPath 0.3.2, the MIBI extension, the `sp_celltype` pipelines and the original Python environment with these settings. The environment is also the Docker image `ghcr.io/wehi-researchcomputing/mibi:0.1-gpu`.

| Step | Software | Settings |
|---|---|---|
| Segmentation | [Mesmer](https://doi.org/10.1038/s41587-021-01094-0) (DeepCell `MultiplexSegmentation`, version 9), run in [QuPath](https://doi.org/10.1038/s41598-017-17204-5) 0.3.2 through the [MIBI extension](https://github.com/WEHI-SODA-Hub/MIBI_extension) (branch `test-branch`, commit `4c66f79`) | 33 FOVs, mass-corrected images, 0.390625 µm per pixel. Nuclear input: dsDNA. Membrane input: sum of panCK, Na-K-ATPase, CD31, CD45, MHC I and vimentin, each divided by the median of its non-zero pixels. Tiles of 256 × 256 pixels with 96 pixels of padding; both inputs contrast-equalised per tile ([CLAHE](https://doi.org/10.1016/B978-0-12-336156-1.50061-6)) and scaled to 0–1. Nuclei under 35 pixels (5.3 µm²) removed. Each nucleus matched to the whole-cell object with a centroid within 2 pixels and the boundary expanded by 3 pixels (6 pixels from the nucleus when unmatched). Overlaps resolved by keeping the larger cell; cells touching the image edge removed. Cells in a high-background strip along the top edge of 28 FOVs (24–98 pixels), and individual cells flagged on visual inspection, deleted. Result: 56,904 cells |
| Measurements | QuPath 0.3.2 | Area and shape of the nucleus and the cell; for each of the 25 channels, mean, median, minimum, maximum, standard deviation and the 70th, 80th, 90th, 95th–99th, 99.5th and 99.9th percentiles in the nucleus, cytoplasm, membrane and whole cell. 1,513 measurements per cell |
| Cell typing | [`sp_celltype_preprocess`](https://github.com/WEHI-SODA-Hub/sp_celltype_preprocess) (commit `0f078e1`), [`sp_celltype_train`](https://github.com/WEHI-SODA-Hub/sp_celltype_train) (`5372b6d`) and [`sp_celltype_apply`](https://github.com/WEHI-SODA-Hub/sp_celltype_apply) (`d763071`), [Nextflow](https://doi.org/10.1038/nbt.3820) pipelines. Python 3.9, [XGBoost](https://doi.org/10.1145/2939672.2939785) 1.7.4, [scikit-learn](https://jmlr.org/papers/v12/pedregosa11a.html) 1.1.1, scikit-optimize 0.9.0, [imbalanced-learn](https://jmlr.org/papers/v18/16-365.html) 0.9.1 | 10,637 cells annotated in QuPath (9 FOVs, 19 classes), by the localisation and intensity of the markers. Split 80% training, 20% test. Hyperparameters chosen by five-fold stratified cross-validation (`BayesSearchCV`, five iterations, balanced accuracy). Of eight combinations of feature set (with or without pairwise products) and class balancing ([ADASYN](https://doi.org/10.1109/IJCNN.2008.4633969), [SMOTE](https://doi.org/10.1613/jair.953), [SMOTEENN](https://doi.org/10.1145/1007730.1007735), [Tomek links](https://doi.org/10.1109/TSMC.1976.4309452)), pairwise products with ADASYN was selected. Test set (2,128 cells): accuracy 0.786, balanced accuracy 0.767, macro F1 0.768. Applied to all 56,904 cells |
| Review of predictions | QuPath | Two rounds of visual review: Treg predictions in all FOVs (219 cells reassigned), and NK, epithelial and other cells in the FOVs of five patients (1,126 reassigned). 1,343 cells (2.4%) reassigned in total |
| Functional markers | Same pipelines, one binary classifier per marker | MHC II (HLA-DP-DR-DQ; defines MHC-II+ macrophages), CD206, granzyme B, MHC I, Ki67 and vimentin. Annotations from images across the cohort; minimum, maximum and median statistics excluded; hyperparameters chosen by ROC AUC |

In the deposited data the CAF classes are named `Vim+` (CAFs), `Vim+CD68+` (CD68+ CAFs), `myCAF` and `EndomyCAF`; cells annotated as CD56+ or CD56+ Vim+ are in "Other".

## Workflow

| Step | Record | What it does |
|---|---|---|
| 0a. Segmentation | QuPath 0.3.2 with the MIBI extension (Mesmer) | Segments cells in the raw MIBI images and measures marker intensities per cell (see [Segmentation and cell typing](#segmentation-and-cell-typing-steps-0a0b)) |
| 0b. Cell typing | `sp_celltype_preprocess`, `sp_celltype_train`, `sp_celltype_apply` | Trains an XGBoost classifier on labelled cells and applies it to all cells, giving the per-cell table |
| 1. QC and cell types | `QC_9.12.2025.pdf` (rendered report, 9 Dec 2025) | Reads the per-cell table from cell phenotyping, corrects one marker call, removes low-quality FOVs, groups cell types and plots marker heatmaps (see [QC](#qc)) |
| 2. `SpatialExperiment` | WEHI team (see above) | Builds `spe.rds` (deposited on Zenodo), with the columns made in step 1 (`FOV_by_patient`, `parent_cell_type`) |
| 3. Cell neighbourhoods | `Fig2_efg_CellNeighbourhood.R`, `create_spatial_clusters.R` | Fig. 2E–G |
| 4. Cell–cell interactions | `Fig5g_heatmap_cell_cell_comm.R` | Fig. 5G (see [Cell–cell interactions](#cellcell-interactions)) |
| 5. Cell distances | `ExtFig6f_boxplots_cell_distance.R` | Extended Data Fig. 6F |

## Manuscript outputs

| Output | Script |
|---|---|
| Fig. 1F (MIBI panel): cell type composition | `QC_9.12.2025.pdf` (QC report) |
| Extended Data Fig. 2E: cell type composition | `QC_9.12.2025.pdf` (QC report) |
| Fig. 2E: heatmap of cell types per cell neighbourhood | `Fig2_efg_CellNeighbourhood.R` |
| Fig. 2F: cell neighbourhood composition per patient | `Fig2_efg_CellNeighbourhood.R` |
| Fig. 2G: cell neighbourhoods across all FOVs | `Fig2_efg_CellNeighbourhood.R` |
| Fig. 5G: heatmap of cell–cell interactions (summed across FOVs) | `Fig5g_heatmap_cell_cell_comm.R` |
| Extended Data Fig. 6F: distance between cell types, within a 50 µm radius | `ExtFig6f_boxplots_cell_distance.R` |

## Files

| File | Purpose |
|---|---|
| `QC_9.12.2025.pdf` | Rendered QC report, with its code and `sessionInfo()`. Printed from `QC_9.12.2025.html` with all code shown, so it can be read on GitHub. Includes the cell type composition plots for Fig. 1F and Extended Data Fig. 2E |
| `create_spatial_clusters.R` | Functions that find each cell's nearest neighbours and cluster cells by neighbour composition. Sourced by `Fig2_efg_CellNeighbourhood.R` |
| `Fig2_efg_CellNeighbourhood.R` | Defines 9 cell neighbourhoods with k-means (10 nearest neighbours, up to 50 µm apart) and plots Fig. 2E–G |
| `Fig5g_heatmap_cell_cell_comm.R` | Runs the interaction test used for Fig. 5G and plots the heatmap |
| `Cell_cell_interaction_sessioninfo.txt` | `sessionInfo()` of the cell–cell interaction analysis |
| `ExtFig6f_boxplots_cell_distance.R` | Computes distances to epithelial cells and to MHCII+ macrophages, and plots Extended Data Fig. 6F |

## QC

From `QC_9.12.2025.pdf`.

**Cohort.** 8 patients, 33 FOVs and 56,904 cells before filtering. Cell types come from XGBoost phenotyping (19 types, including "Other" for cells without marker staining).

**Marker correction.** For patient E (P074), the Vimentin call was corrected after phenotyping: cells typed `Vim+` or `Vim+CD68+` in that patient's FOVs are set to `Vim+` in the `Vim` column (175 cells changed).

**FOV filtering.** FOVs with fewer than 15 tumour cells were reviewed against histology:

| FOV | Tumour cells | Decision |
|---|---|---|
| 065_7 | 2 | Kept: tumour region on histology |
| 107_12 | 2 | Kept: tumour region on histology |
| 107_13 | 0 | Kept: tumour region on histology |
| 074_2 | 11 | Removed: the MIBI region could not be matched to the H&E |
| 074_5 | 10 | Removed: the MIBI region could not be matched to the H&E |
| 104_18 | 0 | Removed: mostly fat, muscle or blood, not tumour |
| 107_14 | 1 | Removed: mostly fat, muscle or blood, not tumour |

Several of these FOVs came from tissue that was detaching from the slide, which left few regions to choose from. FOVs with a high share of "Other" cells were kept: acinar cells (096_3, 096_5, 097_6, 097_9), probable blood cells (099_3), and weak staining in patient P104, all of which lack markers in the MIBI panel. A 55% "Other" cut-off was considered and not applied.

After filtering, 29 FOVs and 54,463 cells remain:

| Cell group | Before | After |
|---|---|---|
| Tumour (`Epithelial cells`, `CD56+epi`) | 11,727 | 11,705 |
| CAF (`myCAF`, `EndomyCAF`, `Vim+`, `Vim+CD68+`) | 12,426 | 11,632 |
| Endothelial (`Endothelial cells`, `EndoMT`) | 3,034 | 2,883 |
| Lymphoid (CD8, CD4, Treg, other T, NK, B cells) | 4,545 | 4,068 |
| Myeloid (macrophages, dendritic cells, mast cells, other myeloid) | 4,711 | 4,548 |
| Other | 20,461 | 19,627 |
| **Total** | **56,904** | **54,463** |

The report also plots cell type proportions per patient and FOV, CAF, myeloid and T cell subsets, cells in fibrotic areas (collagen I), and heatmaps of mean marker intensity per cell type (`Vim+` and `Vim+CD68+` merged). It saves `celltype_intensities_df.rds`, `meta.rds` and the colour tables to `rdata/`, and the heatmaps to `plots_filt_FOVs/`; none of these are deposited.

## Cell–cell interactions

From `Fig5g_heatmap_cell_cell_comm.R`, and the team's rendered report comparing spatial graphs and normalisations (10 Dec 2025, not in this repository).

- **Cell types.** CD8 T cells that are GrzB+ become `CycotoxicCD8T` (spelling as in the code), and macrophages are split into `MacrophagesMHCII+` and `MacrophagesMHCII-`. `Vim+` and `Vim+CD68+` are merged.
- **Spatial graphs** (`imcRtools::buildSpatialGraph`, per FOV, run on HPC): expansion with a 30 µm and a 50 µm radius, and 20 nearest neighbours.
- **Test** (`imcRtools::testInteractions`, permutation test per FOV): the default ("classic") normalisation, by the number of cells, and the histoCAT normalisation, by the number of interactions. The report compares the 50 µm and 20-neighbour graphs under both.
- **Fig. 5G** uses the 50 µm expansion graph with the classic normalisation. The significance values (`sigval`: +1 interaction, −1 avoidance, 0 neither) are summed across FOVs, with "Other" left out.

## Analysis parameters

| Step | Parameter | Value | Source |
|---|---|---|---|
| Cell neighbourhoods (Fig. 2E–G) | neighbours per cell | 10 nearest, up to 50 µm (`max_dist = 50`) | `create_spatial_clusters.R` |
| | clustering | k-means, 9 centres, `iter.max = 30`, `nstart = 25`, `set.seed(42)` | `Fig2_efg_CellNeighbourhood.R` |
| Spatial graph (Fig. 5G) | `buildSpatialGraph` | `type = "expansion"`, `threshold = 50` (µm), per FOV (`img_id = "sample_id"`) | `Fig5g_heatmap_cell_cell_comm.R` |
| Interaction test (Fig. 5G) | `testInteractions` | classic method, `group_by = "sample_id"`, imcRtools defaults otherwise (`iter = 1000` permutations, `p_threshold = 0.01`) | `Fig5g_heatmap_cell_cell_comm.R` |
| Cell distances (Ext. Data Fig. 6F) | radius | 50 µm | `ExtFig6f_boxplots_cell_distance.R` |

The interaction test sets no random seed, so a rerun gives slightly different p-values near the threshold; the summed `sigval` values in Fig. 5G may differ by a small amount. Segmentation and cell typing parameters: see [Segmentation and cell typing](#segmentation-and-cell-typing-steps-0a0b).

## Input

The processed files, the input to steps 1–5, are on Zenodo, [10.5281/zenodo.24360404](https://doi.org/10.5281/zenodo.24360404) ("Spatial MIBI data of pancreatic cancer"):

| File | Contents |
|---|---|
| `spe.rds` | Processed `SpatialExperiment` of the MIBI cells, read by the figure scripts as `rdata/spe.rds` |
| `celltype_classifier_corrected_min_patient_info.csv` | Per-cell table used for plotting, with patient information reduced to the minimum (not read by the scripts here) |

## Reproduce the figures

From the deposited `spe.rds`, with the R versions below.

**Install.** The cell–cell interaction analysis ran on R 4.5.1 with Bioconductor 3.21. Bioconductor releases are fixed, so installing release 3.21 on R 4.5 gives the same Bioconductor package versions (imcRtools 1.14, SpatialExperiment 1.18), apart from bug-fix updates within the release. CRAN packages install at their current versions; they are used for data handling and plotting only.

```r
install.packages("BiocManager")
BiocManager::install(version = "3.21")
BiocManager::install(c("imcRtools", "SpatialExperiment", "SingleCellExperiment",
                       "SummarizedExperiment", "S4Vectors", "BiocParallel"))
install.packages(c("dplyr", "tidyr", "ggplot2", "scales", "RColorBrewer",
                   "pheatmap", "patchwork", "gridExtra", "RANN"))
```

**Run.**

```bash
mkdir -p rdata
# download spe.rds from Zenodo 10.5281/zenodo.24360404 into rdata/
Rscript Fig2_efg_CellNeighbourhood.R
Rscript Fig5g_heatmap_cell_cell_comm.R
Rscript ExtFig6f_boxplots_cell_distance.R
```

Run from this folder (`Fig2_efg_CellNeighbourhood.R` sources `create_spatial_clusters.R` by relative path). Steps 0a–0b from the raw images: see `mibi_README.md` in Zenodo [10.5281/zenodo.24356840](https://doi.org/10.5281/zenodo.24356840).

**Container for Fig. 5G.** [`container/`](container/README.md) holds an Apptainer definition that runs the cell–cell interaction analysis with the package versions of the original run (R 4.5.1, Bioconductor 3.21, and the CRAN versions from a dated snapshot), and a script to build and run it on Spartan. The built container (`mibi_interactions.sif`) is on Zenodo, [10.5281/zenodo.24394013](https://doi.org/10.5281/zenodo.24394013). Built and run on Spartan (2026-11-20) from the deposited `spe.rds`: all recorded package versions match, and the heatmap matches Fig. 5G.

## R versions

| Analysis | R | Packages |
|---|---|---|
| QC report | 4.5.2 | ggplot2 4.0.0, dplyr 1.1.4, tidyr 1.3.1, pheatmap 1.0.13, RColorBrewer 1.1-3, ggalluvial 0.12.5, cowplot 1.2.0, gridExtra 2.3 |
| Cell–cell interactions | 4.5.1 | imcRtools 1.14.0, SpatialExperiment 1.18.1, SingleCellExperiment 1.30.1, SummarizedExperiment 1.38.1, ggplot2 4.0.0, dplyr 1.1.4, tidyr 1.3.1, pheatmap 1.0.13, RColorBrewer 1.1-3, patchwork 1.3.2, gridExtra 2.3 |

Both on Red Hat Enterprise Linux 9.3, with R's reference BLAS. Versions for the cell neighbourhood and distance scripts have not been recorded; they also use RANN and BiocParallel.
