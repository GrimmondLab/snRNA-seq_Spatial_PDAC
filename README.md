# PDAC snRNA-seq and spatial analysis: reproducible containers

Code and container definitions for the analyses in the manuscript. The repository has two parts:

| Folder | Language | Contents |
|---|---|---|
| `snrnaseq/` | R | snRNA-seq analysis, five stages |
| `spatial/` | Python | Spatial (Xenium) analysis, being added (see `spatial/README.md`) |

Each stage has its own folder, its own master script, and its own Docker image built for the environment that stage originally ran under. Data and analysis objects are not stored in this repository; they are on GEO and Zenodo (see below).

## snRNA-seq stages

| Stage | Folder | R | Master script | Input | Status |
|---|---|---|---|---|---|
| 1. Doublet removal + fixed QC thresholds | `snrnaseq/stage1_doublet_qc/` | 4.3.0 | `run_stage1.R` | CellBender output: from GEO ([GSE282918](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282918)), or the original local folders for the reproducibility test | Ready to build |
| 2. Seurat processing + Simspec integration | `snrnaseq/stage2_seurat_simspec/` | 4.4.0 | `run_stage2.R` | Deposited post-QC object (**DOI_TBD**) | Ready to build |
| 3. inferCNV (confirms the malignant calls; not an input to later stages) | `snrnaseq/stage3_infercnv/` | 4.4.0 (Bioconductor 3.19) | `run_stage3.R` | Annotated integrated object from Stage 2 (`sts.simspec_css.sample.sct.RDS`) + `gene_positions.txt` (included) | Ready to build |
| 4. Malignant (integrated) vs non-malignant | — | 4.3 | — | Output of Stage 2 | Waiting for files |
| 5. Downstream subclustering + plotting | — | 4.3 | — | Output of Stage 4 | Waiting for files |

### The break between Stage 1 and Stage 2

Stage 1 can be rerun from the raw CellBender output, but it doesn't reproduce the original object exactly. The original run set `set.seed()` but did not pass a seed to the parallel workers (`BPPARAM` `RNGseed`), so parallel steps such as scDblFinder gave slightly different results. The rerun gives 26,757 genes × 115,293 cells, while the original object has 26,788 genes × 115,221 cells.

All later stages therefore start from the **original post-QC object**, deposited at **DOI_TBD**. This keeps every manuscript figure exactly reproducible, while Stage 1 documents how that object was made.

## Data

| Data | Where |
|---|---|
| snRNA-seq CellBender output (`<sample>_cellbender_filtered.h5` and 10x matrix files) | GEO [GSE282918](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282918) |
| Analysis objects that later stages start from (post-QC object, annotated Stage 2 object) | Zenodo, **DOI_TBD** |
| Spatial data | To be added |

## Running

Each stage folder has a `README.md` with build and run commands for Docker and Apptainer/Singularity. Build each image from inside its stage folder. The images are built for linux/amd64 and are meant to run on an HPC or Linux server.
