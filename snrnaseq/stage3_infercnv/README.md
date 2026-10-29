# Stage 3: inferCNV

R 4.3 · infercnv 1.20.0 · conda env `infercnv` · master script `run_stage3.R`

`run_stage3.R` renders `InferCNV.Rmd`, which runs inferCNV separately for each sample listed in `infercnv_samples.csv`.

**Role in the workflow:** malignant cells were identified by clustering and marker genes in Stage 2 (`simspec_cell_class`). inferCNV was used to **confirm** those calls by showing copy-number changes in the malignant clusters relative to the reference cells. Its outputs do not feed later stages: Stage 4 continues from the Stage 2 object.

## How the per-sample runs are defined

Every sample uses the same inferCNV settings:

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

Only these differ between samples, one row per sample in `infercnv_samples.csv`:

| Column | Meaning |
|---|---|
| `sample` | sample name (`Sample`), or patient (`Patient_ID`) for 1959 and 1971 |
| `subset_by` | which metadata column `sample` refers to |
| `cell_classes` | `simspec_cell_class` values included (separated by `;`) |
| `ref_groups` | reference (normal) groups, a subset of `cell_classes` |
| `leiden_resolution` | per-sample resolution for subclustering |
| `up_to_step` | stop after this step; empty means all steps (empty for every sample) |
| `out_name`, `annotation_file` | output folder and annotation file names, as in the original run |
| `note` | remarks from the original code |

The table was extracted from the original code (`original/InferCNV_original.Rmd`, kept unchanged) and checked against it: all 30 runs match. There is one deliberate change. The original code for sample 2215 still had `up_to_step = 15` switched on, which stops before the HMM step. The author confirmed that 2215 was run in full, so the table runs all steps. Cells in its subcluster `PDAC_s4` were then extracted and relabelled as non-malignant downstream.

## Environment

Conda env `infercnv` (`../../envs/infercnv.yml`, locked in `envs/infercnv-linux-64.lock`): R 4.3, infercnv 1.20.0, Seurat 5.1.0, SeuratObject 5.0.2, dplyr 1.1.4, igraph 2.0.3, rjags 4-15, ggplot2 3.5.1, JAGS 4.3.2. This is a separate env from Stages 1–2 (which use Bioconductor 3.17 and Seurat 4).

Differences from the original run (`sessionInfo/sessionInfo_inferCNV.txt`): R 4.4.0 → 4.3. bioconda built infercnv 1.20.0 for R 4.3 against Bioconductor 3.18 infrastructure, so its Bioconductor dependencies are one release older (e.g. SingleCellExperiment 1.24.0, limma 3.58.1, edgeR 4.0.16, GenomicRanges 1.54.1; originally 1.26.0, 3.60.3, 4.2.0, 1.56.1). inferCNV itself is the same version. All other recorded packages are pinned to their original versions, except base-R recommended packages whose recorded versions need R 4.4 (cluster, KernSmooth, MASS, Matrix 1.7-0 → 1.6-5, survival) and RcppParallel, spatstat.explore, stringi.

## Input

| File | Source |
|---|---|
| `sts.simspec_css.sample.sct.RDS` | annotated integrated object from Stage 2, with `simspec_cell_class` (deposited, **DOI_TBD**); mounted at run time |
| `gene_positions.txt` | gene positions (36,590 genes), included in this folder and in the image |

`gene_positions.txt` was made once from the 10x Genomics GRCh38 reference GTF (`refdata-gex-GRCh38-2020-A`, `genes.gtf`) with inferCNV's [`gtf_to_position_file.py`](https://github.com/broadinstitute/infercnv/blob/master/scripts/gtf_to_position_file.py):

```bash
python gtf_to_position_file.py --attribute_name gene_name genes.gtf gene_positions.txt
```

## Files

| File | Purpose |
|---|---|
| `run_stage3.R` | Master script; `Rscript run_stage3.R [config.yml]` |
| `InferCNV.Rmd` | Runs inferCNV for each row of `infercnv_samples.csv` |
| `infercnv_samples.csv` | Per-sample settings |
| `gene_positions.txt` | Gene positions for inferCNV |
| `config.yml` | Input path, output folder, seed, samples to run (container paths) |
| `original/` | The original R Markdown file, unchanged, with a note on how the pipeline differs |
| `sessionInfo/` | Session information of the original inferCNV runs |

## Running

| Container path | Mount | Mode |
|---|---|---|
| `/data/input` | folder containing `sts.simspec_css.sample.sct.RDS` | read-only |
| `/output` | where results go | read-write |

```bash
docker run --rm --cpus 4 --memory 64g \
  -v /path/to/input:/data/input:ro \
  -v /path/to/output:/output \
  pdac-snrnaseq:1.0 stage3
```

## Running only some samples

Each sample takes a long time, so on an HPC it can help to run one sample per job. Set `samples` in `config.yml` to a list of sample names (the default `all` runs every row). inferCNV also resumes from its saved intermediate files if a run is restarted with the same output folder.

## Reproducibility

The original code did not set a random seed, and inferCNV 1.20.0 does not set one internally. Two steps involve randomness: the Leiden subclustering (igraph) and the Bayesian MCMC filtering (rjags). Rerunning inferCNV therefore gives similar but not identical subclusters and CNV calls. The pipeline calls `set.seed()` before each sample, so its own reruns are repeatable for the Leiden step, but it cannot recreate the original draws.

Because inferCNV is a confirmation step, this is expected to be enough: a rerun should show the same overall copy-number patterns in the malignant cells (e.g. the same chromosome-arm gains and losses) and none in the reference cells. Exact subcluster boundaries may differ. The inferCNV outputs are not deposited.

## Resources

inferCNV uses 4 threads by default. Each run converts the full count matrix (about 27k genes × 115k cells) to a dense matrix, as in the original code. That needs about 25 GB of memory on top of the object itself. 64 GB per job is a reasonable start.

## Outputs

`/output/InferCNV/`:
- `annotations/`: the cell annotation file given to inferCNV for each sample
- one folder per sample (`P1993.out`, `P2215-section-2.out`, …): the standard inferCNV output
- `InferCNV.html`: report with the sample table and session information
