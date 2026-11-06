# Spatial proteomics (MIBI)

This folder is a record of the code used to generate the MIBI figures in the manuscript. The analysis was done by collaborators at WEHI. The scripts are kept as received. They have not been rerun in this repository.

## Docker

This part has no Docker container and is not in the project image or `run.sh`. A Docker container is planned for the upstream image processing and QC, which are not in this folder.

## Manuscript outputs

| Output | Script |
|---|---|
| Fig. 2E: heatmap of cell types per cell neighbourhood | `Fig2_efg_CellNeighbourhood.R` |
| Fig. 2F: cell neighbourhood composition per patient | `Fig2_efg_CellNeighbourhood.R` |
| Fig. 2G: cell neighbourhoods across all FOVs | `Fig2_efg_CellNeighbourhood.R` |
| Extended Data Fig. 6F: distance between cell types, within a 50 µm radius | `ExtFig6f_boxplots_cell_distance.R` |

## Files

| File | Purpose |
|---|---|
| `create_spatial_clusters.R` | Functions that find each cell's nearest neighbours and cluster cells by neighbour composition. Sourced by `Fig2_efg_CellNeighbourhood.R` |
| `Fig2_efg_CellNeighbourhood.R` | Defines 9 cell neighbourhoods with k-means (10 nearest neighbours, up to 50 µm apart) and plots Fig. 2E–G |
| `ExtFig6f_boxplots_cell_distance.R` | Computes distances to epithelial cells and to MHCII+ macrophages, and plots Extended Data Fig. 6F |

## Input

Input and processed files will be deposited on Zenodo (**DOI_TBD**). Both scripts read the processed object `rdata/spe.rds`, a `SpatialExperiment` of the MIBI cells.

## R packages

ggplot2, patchwork, gridExtra, pheatmap, RColorBrewer, dplyr, tidyr, SpatialExperiment, imcRtools, BiocParallel, RANN.
