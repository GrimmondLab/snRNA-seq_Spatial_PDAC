# Supplementary: inferCNV check of the malignant cell annotation

Malignant cells were identified by cell annotation in Stage 2 (clustering and marker genes, `simspec_cell_class`). inferCNV was run afterwards as a check: the annotated malignant cells show copy-number changes relative to the reference (non-malignant) cells. It is not part of the main pipeline. Its outputs are not used by any later stage and are not deposited.

This folder records what was run, and provides a container for anyone who wants to run it. **A rerun is not expected to reproduce the original output exactly**, because inferCNV involves random steps and no seed was set (see [Randomness](#randomness)).

R 4.4.0 · Bioconductor 3.19 (infercnv 1.20.0) · master script `run_infercnv.R`, which renders `InferCNV.Rmd`. `InferCNV.Rmd` runs inferCNV separately for each sample listed in `infercnv_samples.csv`.

## Randomness

The original runs did not set a random seed, and inferCNV 1.20.0 does not set one internally. Two steps are random:

- **Leiden subclustering** (igraph) of each sample's cells
- **Bayesian filtering of the HMM calls** (MCMC sampling with rjags/JAGS)

The code here also sets no seed, so it runs exactly as the original did. Each run, including the original, therefore gives somewhat different subclusters and CNV calls. A rerun should show the same overall copy-number patterns in the malignant cells (for example the same chromosome-arm gains and losses) and none in the reference cells, but subcluster boundaries and individual calls can differ.

## What was run

Every sample used the same inferCNV settings:

| Setting | Value |
|---|---|
| `cutoff` | 0.1 |
| `analysis_mode` | `subclusters` |
| `cluster_by_groups` | TRUE |
| `denoise` | TRUE |
| `HMM` | TRUE |
| `noise_logistic` | TRUE |
| `sd_amplifier` | 3 |
| `BayesMaxPNormal` | 0.3 |
| `tumor_subcluster_pval` | 0.05 |

The settings that differ between samples are in `infercnv_samples.csv`, one row per sample:

| Column | Meaning |
|---|---|
| `sample` | sample name (`Sample`), or patient (`Patient_ID`) for 1959 and 1971 |
| `subset_by` | which metadata column `sample` refers to |
| `cell_classes` | `simspec_cell_class` values included (separated by `;`) |
| `ref_groups` | reference (normal) groups, a subset of `cell_classes` |
| `leiden_resolution` | per-sample resolution for subclustering |
| `up_to_step` | stop after this step; empty means all steps (empty for every sample) |
| `out_name`, `annotation_file` | output folder and annotation file names |
| `note` | remarks from the original code |

The original code, with one section per sample, is kept unchanged in `original/InferCNV_original.Rmd`. The table was extracted from it and checked against it: all 30 runs match. There is one deliberate change. The original code for sample 2215 still had `up_to_step = 15` switched on, which stops before the HMM step, but 2215 was run in full, so the table runs all steps. `original/README.md` lists the other differences, which only concern paths and file handling.

## Input

| File | Source |
|---|---|
| `sts.simspec_css.sample.sct.RDS` | annotated integrated object from Stage 2, with `simspec_cell_class` (deposited, **DOI_TBD**); mounted at run time |
| `gene_positions.txt` | gene positions (36,590 genes), included in this folder and in the image |

`gene_positions.txt` was made once from the 10x Genomics GRCh38 reference GTF (`refdata-gex-GRCh38-2020-A`, `genes.gtf`) with inferCNV's [`gtf_to_position_file.py`](https://github.com/broadinstitute/infercnv/blob/master/scripts/gtf_to_position_file.py):

```bash
python gtf_to_position_file.py --attribute_name gene_name genes.gtf gene_positions.txt
```

## Environment

| | Version |
|---|---|
| R | 4.4.0 (`rocker/r-ver:4.4.0`, Ubuntu 22.04, linux/amd64) |
| Bioconductor | 3.19 (infercnv 1.20.0, SingleCellExperiment 1.26.0), with edgeR 4.2.0, limma 3.60.3 and GenomicRanges 1.56.1 from the 3.19 archive |
| CRAN | Posit Package Manager snapshot from 2024-07-10 (SeuratObject 5.0.2, dplyr 1.1.4, igraph 2.0.3, rjags 4-15, ggplot2 3.5.1) |
| JAGS | 4.3 from Ubuntu 22.04 (needed by rjags) |

This is a newer environment than Stages 1–2 (Bioconductor 3.17, Seurat 4). Versions follow `sessionInfo/sessionInfo_inferCNV.txt`, the session information of the original runs. `install_packages.R` checks about 45 package versions at the end of the build and stops if any differ. It then saves the image's own `sessionInfo()`, with the JAGS version, to `/pipeline/sessionInfo_container.txt`.

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | Image definition |
| `install_packages.R` | Installs and checks R packages (runs during build) |
| `run_infercnv.R` | Master script; `Rscript run_infercnv.R [config.yml]` |
| `InferCNV.Rmd` | Runs inferCNV for each row of `infercnv_samples.csv` |
| `infercnv_samples.csv` | Per-sample settings |
| `gene_positions.txt` | Gene positions for inferCNV |
| `config.yml` | Input path, output folder, samples to run (container paths) |
| `original/` | The original R Markdown file, unchanged, with a note on how this code differs |
| `sessionInfo/` | Session information of the original runs |

## Running

Build:

```bash
docker build -t pdac-infercnv:1.0 .
```

Mount the folder containing `sts.simspec_css.sample.sct.RDS` at `/data/input` (read-only) and an output folder at `/output`:

```bash
docker run --rm \
  --cpus 4 --memory 64g \
  -v /path/to/input:/data/input:ro \
  -v /path/to/output:/output \
  pdac-infercnv:1.0
```

With Apptainer/Singularity, convert the Docker image first:

```bash
docker save pdac-infercnv:1.0 -o pdac-infercnv_1.0.tar
```

```bash
apptainer build pdac-infercnv_1.0.sif docker-archive://pdac-infercnv_1.0.tar
```

```bash
apptainer run --pwd /pipeline \
  --bind /path/to/input:/data/input \
  --bind /path/to/output:/output \
  pdac-infercnv_1.0.sif
```

To copy the image's session information out without running anything:

```bash
docker run --rm --entrypoint cat pdac-infercnv:1.0 /pipeline/sessionInfo_container.txt > sessionInfo_container.txt
```

**Resources.** Each sample takes a long time. inferCNV uses 4 threads, and each run converts the full count matrix (about 27k genes × 115k cells) to a dense matrix, as in the original code, which needs about 25 GB of memory on top of the object; 64 GB per job is a reasonable start. To run one sample per HPC job, set `samples` in `config.yml` to a list of sample names (the default `all` runs every row).

**Outputs** in `/output/InferCNV/`: `annotations/` (the cell annotation file given to inferCNV for each sample), one standard inferCNV output folder per sample (`P1993.out`, `P2215-section-2.out`, …), and `InferCNV.html` (report with the sample table and session information).
