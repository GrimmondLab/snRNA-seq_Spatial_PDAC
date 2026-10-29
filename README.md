# PDAC snRNA-seq and spatial analysis: reproducible environment

Code and environment definitions for the analyses in the manuscript. The repository has two parts:

| Folder | Language | Contents |
|---|---|---|
| `snrnaseq/` | R | snRNA-seq analysis, five stages |
| `spatial/` | Python | Spatial (Xenium) analysis, being added (see `spatial/README.md`) |

Everything runs from **one Docker image** that holds one conda env per group of stages. The envs are built from bioconda and conda-forge only, from the lock files in `envs/`. `run.sh` runs a stage inside its env. Data and analysis objects are not stored in this repository; they are on GEO and Zenodo (see below).

## Environments

| Env | Definition | Lock file | Contents | Stages |
|---|---|---|---|---|
| `snrnaseq` | `envs/snrnaseq.yml` | `envs/snrnaseq-linux-64.lock` | R 4.3, Bioconductor 3.17, Seurat 4.3.0, simspec (GitHub, pinned commit) | 1, 2 |
| `infercnv` | `envs/infercnv.yml` | `envs/infercnv-linux-64.lock` | R 4.3, infercnv 1.20.0, Seurat 5.1.0 | 3 |

All stages use R 4.3. Every R package recorded in a stage's `sessionInfo/` is pinned to its original version where conda has an R 4.3 build. Each stage README lists the exceptions. The build saves each env's `sessionInfo()` to `/pipeline/sessionInfo/<env>.txt` inside the image.

## snRNA-seq stages

| Stage | Folder | Env | Input | Status |
|---|---|---|---|---|
| 0. Cell Ranger + CellBender | `snrnaseq/stage0_cellranger_cellbender/` | — (documentation only) | FASTQ | Record only |
| 1. Doublet removal + fixed QC thresholds | `snrnaseq/stage1_doublet_qc/` | `snrnaseq` | CellBender output: from GEO ([GSE282918](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282918)), or the original local folders for the reproducibility test | Ready |
| 2. Seurat processing + Simspec integration | `snrnaseq/stage2_seurat_simspec/` | `snrnaseq` | Deposited post-QC object (**DOI_TBD**) | Ready |
| 3. inferCNV (confirms the malignant calls; not an input to later stages) | `snrnaseq/stage3_infercnv/` | `infercnv` | Annotated integrated object from Stage 2 (`sts.simspec_css.sample.sct.RDS`) + `gene_positions.txt` (included) | Ready |
| 4. Malignant (integrated) vs non-malignant | — | — | Output of Stage 2 | Waiting for files |
| 5. Downstream subclustering + plotting | — | — | Output of Stage 4 | Waiting for files |

### The break between Stage 1 and Stage 2

Stage 1 can be rerun from the raw CellBender output, but it doesn't reproduce the original object exactly. The original run set `set.seed()` but did not pass a seed to the parallel workers (`BPPARAM` `RNGseed`), so parallel steps such as scDblFinder gave slightly different results. The rerun gives 26,757 genes × 115,293 cells, while the original object has 26,788 genes × 115,221 cells.

All later stages therefore start from the **original post-QC object**, deposited at **DOI_TBD**. This keeps every manuscript figure exactly reproducible, while Stage 1 documents how that object was made.

## Data

| Data | Where |
|---|---|
| snRNA-seq CellBender output (`<sample>_cellbender_filtered.h5` and 10x matrix files) | GEO [GSE282918](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282918) |
| Analysis objects that later stages start from (post-QC object, annotated Stage 2 object) | Zenodo, **DOI_TBD** |
| Spatial data | To be added |

## Build

```bash
docker build --platform linux/amd64 -t pdac-snrnaseq:1.0 .
```

The image is linux/amd64 only, because bioconda's R 4.3 builds are only available for linux-64. On an Apple Silicon Mac it builds and runs under emulation, which is slower.

## Run

```bash
docker run --rm -v <input>:/data/...:ro -v <output>:/output pdac-snrnaseq:1.0 <stage> [config.yml]
```

- `<stage>` is `stage1`, `stage2` or `stage3`.
- `[config.yml]` defaults to the stage's own `config.yml`. You can also give the name of another config in the stage folder (e.g. `config_local.yml`), or the path of a config you have mounted into the container.
- Each stage README lists the mounts it needs and gives a full example.

To copy the recorded session information out of the image:

```bash
docker run --rm --entrypoint cat pdac-snrnaseq:1.0 /pipeline/sessionInfo/snrnaseq.txt
```

### Apptainer/Singularity (HPC)

```bash
docker save pdac-snrnaseq:1.0 -o pdac-snrnaseq_1.0.tar
apptainer build pdac-snrnaseq_1.0.sif docker-archive://pdac-snrnaseq_1.0.tar
apptainer run --bind /path/to/input:/data/input --bind /path/to/output:/output \
  pdac-snrnaseq_1.0.sif stage2
```

`run.sh` doesn't need to write inside the image, so the read-only `.sif` works as is.

## Updating an env

Edit `envs/<env>.yml`, then regenerate its lock file and rebuild the image:

```bash
cd envs
conda-lock lock -f <env>.yml -p linux-64 --kind explicit --filename-template '<env>-{platform}.lock'
```
