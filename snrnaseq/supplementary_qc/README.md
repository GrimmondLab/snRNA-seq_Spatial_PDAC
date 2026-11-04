# Supplementary: per-sample QC metrics

This folder records how the per-sample QC tables and plots were made for the manuscript's revision, in response to a reviewer's request for QC results per single-cell experiment. It adds to Stage 0 (Cell Ranger) and Stage 1 (QC filtering).

It is provided for transparency, not for rerunning: it is not part of the Docker image or `run.sh`. `QC_checks.Rmd` is a tidied version of the original analysis, and it keeps the original cluster paths. The metrics are calculated in the same way. Exploratory repeats were removed, chunks were put in running order, and the mean reads plot was corrected (see below). The original file is in the Git history (`snrnaseq/QC_checks.Rmd`).

## What it reports

| Metric | Source | Output |
|---|---|---|
| Genes detected per nucleus (`nFeature_RNA`), counts per nucleus (`nCount_RNA`) | Annotated object | `Supp_Table_QC_per_sample.csv`, `Supp_Fig_QC_per_sample.pdf` |
| Proportion of counts from mitochondrial (`subsets_mito_percent`) and ribosomal (`subsets_ribo_percent`) genes | Annotated object; calculated in Stage 1 | Same |
| MALAT1 expression (`malat1_expr`, normalised) | Annotated object | Same |
| Mean and median reads per nucleus, sequencing saturation, for the nuclei in the final object | Cell Ranger `molecule_info.h5` | `Supp_Table_seq_metrics.csv` |
| Valid barcodes, mean reads per cell, reads mapped to the transcriptome, reads in cells, sequencing saturation, for the whole library | Cell Ranger `metrics_summary.csv` | `cellranger_metrics_all_samples.csv`, plots |

The first three rows describe the nuclei that passed QC, not the nuclei before filtering. Stage 1 shows the metrics before filtering and the thresholds applied.

**The two sets of sequencing metrics differ by design.** `Supp_Table_seq_metrics.csv` uses only the molecules from nuclei in the final object, and saturation is calculated as 1 − (molecules / reads). `cellranger_metrics_all_samples.csv` gives Cell Ranger's own values for the whole library.

**Correction to the mean reads plot.** The original code also drew `Mean Reads per Cell` multiplied by 100, with a line at 75 carried over from the percentage plots. Both are removed. The tidied file has one mean reads plot, on the original scale.

## In the manuscript

| Output | Where |
|---|---|
| `Supp_Fig_QC_per_sample.pdf` | Rebuttal figure. Samples are labelled by `orig.ident`; `Supp_Table_QC_per_sample.csv` links these to ICGC donor IDs |
| `Supp_Table_QC_per_sample.csv`, `Supp_Table_seq_metrics.csv`, `cellranger_metrics_all_samples.csv` | Supplementary Table 1 |

## Inputs

| File | Source |
|---|---|
| `sts.simspec.final.RDS` | Annotated integrated object (read from the original analysis folder) |
| `molecule_info.h5`, `metrics_summary.csv` | `cellranger count` output for each of the 30 samples (Stage 0) |

## Environment

`sessionInfo/sessionInfo_QC_checks.txt` holds the session information of a rerun of the tidied file: R 4.3.0, Seurat 4.3.0, DropletUtils 1.20.0, readr 2.1.4, ggplot2 3.5.2, dplyr 1.2.1.
