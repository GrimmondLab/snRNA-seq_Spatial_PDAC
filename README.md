# PDAC snRNA-seq and spatial analysis: reproducible environment

Code and environment definitions for the analyses in the manuscript. The repository has two parts:

| Folder | Language | Contents |
|---|---|---|
| `snrnaseq/` | R | snRNA-seq analysis, Stages 0–5 |
| `spatial/` | Python | Spatial (Xenium) analysis, being added (see `spatial/README.md`) |

Everything runs from **one Docker image** that holds one conda env per group of stages. The envs are built from bioconda and conda-forge only, from the lock files in `envs/`. `run.sh` runs a stage inside its env. Data and analysis objects are not stored in this repository; they are on GEO and Zenodo (see below).

## Environments

| Env | Definition | Lock file | Contents | Stages |
|---|---|---|---|---|
| `snrnaseq` | `envs/snrnaseq.yml` | `envs/snrnaseq-linux-64.lock` | R 4.3, Bioconductor 3.17, Seurat 4.3.0, simspec (GitHub, pinned commit) | 1, 2 |
| `downstream` | `envs/downstream.yml` | `envs/downstream-linux-64.lock` | R 4.3, Bioconductor 3.17, Seurat 4.3.0, ggplot2 3.5.2, edgeR, clusterProfiler, simspec + treeio (GitHub, pinned commits), UCell, SingleR, EnhancedVolcano, ReactomePA | 3, 4 |
| `cellchat` | `envs/cellchat.yml` | `envs/cellchat-linux-64.lock` | R 4.3, Bioconductor 3.17, Seurat 4.3.0, CellChat 2.1.2 (GitHub), dplyr 1.2.1 and NMF 0.27 (CRAN source) | 5 |
| `infercnv` | `envs/infercnv.yml` | `envs/infercnv-linux-64.lock` | R 4.3, infercnv 1.20.0, Seurat 5.1.0 | Supplementary inferCNV |

All stages use R 4.3. Every R package recorded in a stage's `sessionInfo/` is pinned to its original version where conda has an R 4.3 build. Each stage README lists the exceptions. The build saves each env's `sessionInfo()` to `/pipeline/sessionInfo/<env>.txt` inside the image.

## snRNA-seq stages

| Stage | Folder | Env | Input | Status |
|---|---|---|---|---|
| 0. Cell Ranger + CellBender | `snrnaseq/stage0_cellranger_cellbender/` | — (documentation only) | FASTQ | Record only |
| 1. Doublet removal + fixed QC thresholds | `snrnaseq/stage1_doublet_qc/` | `snrnaseq` | CellBender output: from GEO ([GSE282918](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282918)), or the original local folders for the reproducibility test | Ready |
| 2. Seurat processing + Simspec integration | `snrnaseq/stage2_seurat_simspec/` | `snrnaseq` | Deposited post-QC object (**DOI_TBD**) | Ready |
| 3. Malignant vs non-malignant (incl. rare malignancies, tuft, ADM) | `snrnaseq/stage3_malignant_nonmalignant/` | `downstream` | Annotated integrated object from Stage 2 (`sts.simspec_css.sample.sct.RDS`) + `tuft.snv.df.csv` (**DOI_TBD**) | Ready |
| 4. Reclustering (lymphoid, myeloid, stromal) + final annotation and plots | `snrnaseq/stage4_reclustering/` | `downstream` | `sts.nonmalignant.RDS` from Stage 3, Stage 2 annotated object, `endo.RDS` | Waiting for `endo.RDS` |
| 5. CellChat | `snrnaseq/stage5_cellchat/` | `cellchat` | `sts.simspec_css.sample.sct_final.RDS` from Stage 4 | CellChat commit to confirm |

**Supplementary: inferCNV** (`snrnaseq/supplementary_infercnv/`, env `infercnv`, `run.sh infercnv`). A check that the cells annotated as malignant in Stage 2 show copy-number changes. Its outputs feed no later stage and are not deposited. Input: the Stage 2 annotated object + `gene_positions.txt` (included).

### The break between Stage 1 and Stage 2

Stage 1 can be rerun from the raw CellBender output, but it doesn't reproduce the original object exactly. The original run set `set.seed()` but did not pass a seed to the parallel workers (`BPPARAM` `RNGseed`), so parallel steps such as scDblFinder gave slightly different results. The rerun gives 26,757 genes × 115,293 cells, while the original object has 26,788 genes × 115,221 cells.

All later stages therefore start from the **original post-QC object**, deposited at **DOI_TBD**. This keeps every manuscript figure exactly reproducible, while Stage 1 documents how that object was made.

## Data

| Data | Where |
|---|---|
| snRNA-seq CellBender output (`<sample>_cellbender_filtered.h5` and 10x matrix files) | GEO [GSE282918](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282918) |
| Analysis objects that later stages start from (post-QC object, annotated Stage 2 object, Stage 3 non-malignant object, endothelial object, final annotated object) | Zenodo, **DOI_TBD** |
| Spatial data | To be added |

## Build

```bash
docker build --platform linux/amd64 -t pdac-snrnaseq:1.0 .
```

The image is linux/amd64 only, because bioconda's R 4.3 builds are only available for linux-64. On an Apple Silicon Mac it builds and runs under emulation, which is slower.

### Prebuilt image (GitHub Actions)

`.github/workflows/docker.yaml` runs only when a version tag `vX.Y.Z` is pushed. It builds the image, checks the key package versions recorded in it, uploads its `sessionInfo/*.txt` as a run artifact, and pushes:

- the Docker image, as `ghcr.io/grimmondlab/snrna-seq_spatial_pdac:X.Y.Z`
- an Apptainer `.sif` converted from the same build and smoke-tested, to the same package as `:X.Y.Z-sif`

To publish a release:

```bash
git tag v1.0.0 && git push origin v1.0.0
```

Then pull it with:

```bash
docker pull ghcr.io/grimmondlab/snrna-seq_spatial_pdac:1.0.0
apptainer pull pdac-snrnaseq.sif oras://ghcr.io/grimmondlab/snrna-seq_spatial_pdac:1.0.0-sif
```

## Run

```bash
docker run --rm -v <input>:/data/...:ro -v <output>:/output pdac-snrnaseq:1.0 <stage> [config.yml]
```

- `<stage>` is `stage1`, `stage2`, `stage3`, `stage4`, `stage5` or `infercnv`.
- `[config.yml]` defaults to the stage's own `config.yml`. You can also give the name of another config in the stage folder (e.g. `config_local.yml`), or the path of a config you have mounted into the container.
- Each stage README lists the mounts it needs and gives a full example.

To copy the recorded session information out of the image:

```bash
docker run --rm --entrypoint cat pdac-snrnaseq:1.0 /pipeline/sessionInfo/snrnaseq.txt
```

### Apptainer/Singularity (HPC)

Pull the `.sif` that CI publishes for a release, then run a stage:

```bash
apptainer pull pdac-snrnaseq.sif oras://ghcr.io/grimmondlab/snrna-seq_spatial_pdac:1.0.0-sif
apptainer run --bind /path/to/input:/data/input --bind /path/to/output:/output \
  pdac-snrnaseq.sif stage2
```

While the package is private, log in first with a GitHub PAT that has `read:packages`: `apptainer registry login -u <github-user> oras://ghcr.io`.

`run.sh` doesn't need to write inside the image, so the read-only `.sif` works as is.

To convert a locally built image instead:

```bash
docker save pdac-snrnaseq:1.0 -o pdac-snrnaseq_1.0.tar
apptainer build pdac-snrnaseq.sif docker-archive://pdac-snrnaseq_1.0.tar
```

### Interactive shell (debugging)

The image's entrypoint is `run.sh`, so override it to get a shell. Mount the same folders as for a real run:

```bash
docker run --rm -it --entrypoint bash \
  -v <input>:/data/...:ro -v <output>:/output \
  pdac-snrnaseq:1.0
```

The shell starts in `/pipeline`, which holds `run.sh`, `snrnaseq/`, `envs/` and `sessionInfo/`. No env is active. Put one first on `PATH`, the same way `run.sh` does:

```bash
export PATH=/opt/conda/envs/snrnaseq/bin:$PATH   # or downstream (Stages 3, 4), cellchat (Stage 5), infercnv
R                                                # interactive R in that env
./run.sh stage1                                  # or run a whole stage from the shell
```

To open a second shell in a container that is already running (e.g. to watch a stage while it runs), use `docker ps` to find its name, then run `docker exec -it <name> bash`.

Under Apptainer, `apptainer shell` runs `/bin/sh`, so use `exec bash`. Apptainer passes the host environment through by default; `--cleanenv` stops host settings such as `R_LIBS` from leaking into the container:

```bash
apptainer exec --cleanenv --bind /path/to/input:/data/input --bind /path/to/output:/output \
  pdac-snrnaseq.sif bash
export PATH=/opt/conda/envs/snrnaseq/bin:$PATH
cd /pipeline
```

The `.sif` is read-only, so `/pipeline` can't be edited there. To try a code change, edit it on the host and bind that folder over the image's copy, e.g. `--bind $PWD/snrnaseq:/pipeline/snrnaseq` (Docker: `-v $PWD/snrnaseq:/pipeline/snrnaseq`).

## Updating an env

Edit `envs/<env>.yml`, then regenerate its lock file and rebuild the image:

```bash
cd envs
conda-lock lock -f <env>.yml -p linux-64 --kind explicit --filename-template '<env>-{platform}.lock'
```
