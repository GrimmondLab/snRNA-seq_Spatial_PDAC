# PDAC snRNA-seq analysis: reproducible containers

Code and container definitions for the snRNA-seq analysis in the manuscript. The workflow has five stages. Each stage has its own folder, its own master script, and its own Docker image built for the R version that stage originally ran under.

## Stages

| Stage | Folder | R | Master script | Input | Status |
|---|---|---|---|---|---|
| 1. Doublet removal + fixed QC thresholds | `stage1_doublet_qc/` | 4.3.0 | `run_stage1.R` | CellBender output: from GEO (**GSE_TBD**), or the original local folders for the reproducibility test | Ready to build |
| 2. Seurat processing + Simspec integration | `stage2_seurat_simspec/` | 4.4.0 | `run_stage2.R` | Deposited post-QC object (**DOI_TBD**) | Ready to build (Plotting chunk parked) |
| 3. inferCNV (confirms the malignant calls; not an input to later stages) | `stage3_infercnv/` | 4.4.0 (Bioconductor 3.19) | `run_stage3.R` | Annotated integrated object from Stage 2 (`sts.simspec_css.sample.sct.Aug24.RDS`) + `gene_positions.txt` (included) | Ready to build |
| 4. Malignant (integrated) vs non-malignant | — | 4.3 | — | Output of Stage 2 | Waiting for files |
| 5. Downstream subclustering + plotting | — | 4.3 | — | Output of Stage 4 | Waiting for files |

## The break between Stage 1 and Stage 2

Stage 1 can be rerun from the raw CellBender output, but it doesn't reproduce the original object exactly. The original run set `set.seed()` but did not pass a seed to the parallel workers (`BPPARAM` `RNGseed`), so parallel steps such as scDblFinder gave slightly different results. The rerun gives 26,757 genes × 115,293 cells, while the original object has 26,788 genes × 115,221 cells.

All later stages therefore start from the **original post-QC object**, deposited at **DOI_TBD**. This keeps every manuscript figure exactly reproducible, while Stage 1 documents how that object was made.

## Running

Each stage folder has a `README.md` with build and run commands for Docker and Apptainer/Singularity. The images are built for linux/amd64 and are meant to run on an HPC or Linux server.
