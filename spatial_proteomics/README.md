# Spatial proteomics (MIBI)

This folder is a record of the code used to generate the MIBI figures in the manuscript. The analysis was done by collaborators at WEHI. The scripts and reports are kept as received, except that personal names and internal paths were removed (2026-11-16). They have not been rerun in this repository.

## Docker

This part has no Docker container and is not in the project image or `run.sh`. A Docker container is planned for the upstream image processing and QC, which are not in this folder.

## Workflow

| Step | Record | What it does |
|---|---|---|
| 1. QC and cell types | `QC_9.12.2025.pdf` (rendered report, 9 Dec 2025) | Reads the per-cell table from cell phenotyping, corrects one marker call, removes low-quality FOVs, groups cell types and plots marker heatmaps (see [QC](#qc)) |
| 2. `SpatialExperiment` | not in this folder | Builds `spe.rds` (deposited on Zenodo), with the columns made in step 1 (`FOV_by_patient`, `parent_cell_type`) |
| 3. Cell neighbourhoods | `Fig2_efg_CellNeighbourhood.R`, `create_spatial_clusters.R` | Fig. 2E–G |
| 4. Cell–cell interactions | `Fig5g_heatmap_cell_cell_comm.R` | Fig. 5G (see [Cell–cell interactions](#cellcell-interactions)) |
| 5. Cell distances | `ExtFig6f_boxplots_cell_distance.R` | Extended Data Fig. 6F |

## Manuscript outputs

| Output | Script |
|---|---|
| Fig. 1F: cell type composition | `QC_9.12.2025.pdf` (QC report) |
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

## Input

The input files are on Zenodo, [10.5281/zenodo.24360405](https://doi.org/10.5281/zenodo.24360405) ("Spatial MIBI data of pancreatic cancer"):

| File | Contents |
|---|---|
| `spe.rds` | Processed `SpatialExperiment` of the MIBI cells, read by the figure scripts as `rdata/spe.rds` |
| `celltype_classifier_corrected_min_patient_info.csv` | Per-cell table used for plotting, with patient information reduced to the minimum (not read by the scripts here) |

## R versions

| Analysis | R | Packages |
|---|---|---|
| QC report | 4.5.2 | ggplot2 4.0.0, dplyr 1.1.4, tidyr 1.3.1, pheatmap 1.0.13, RColorBrewer 1.1-3, ggalluvial 0.12.5, cowplot 1.2.0, gridExtra 2.3 |
| Cell–cell interactions | 4.5.1 | imcRtools 1.14.0, SpatialExperiment 1.18.1, SingleCellExperiment 1.30.1, SummarizedExperiment 1.38.1, ggplot2 4.0.0, dplyr 1.1.4, tidyr 1.3.1, pheatmap 1.0.13, RColorBrewer 1.1-3, patchwork 1.3.2, gridExtra 2.3 |

Both on Red Hat Enterprise Linux 9.3, with R's reference BLAS. Versions for the cell neighbourhood and distance scripts have not been recorded; they also use RANN and BiocParallel.
