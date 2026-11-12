# Analysis code, environments and reproducibility checks

For the manuscript "Single-cell spatial profiling identifies recurrent spatial niches in pancreatic cancer microenvironment" (link to be added on publication).

This repository holds:

- **Code for every analysis in the manuscript:** snRNA-seq, inferCNV, spatial transcriptomics (Xenium) and spatial proteomics (MIBI).
- **A container to rerun the snRNA-seq and Xenium analyses:** one Docker image (also as an Apptainer `.sif`) with pinned conda environments.
- **Checks against the original analysis:** each stage README compares the rerun with the original objects and explains any difference.
- **A map from figures to code:** the stage READMEs list which notebook or Rmd makes each manuscript panel.
- **Records of steps that are not rerun here:** Cell Ranger and CellBender (snRNA-seq Stage 0), the MIBI figure code, and saved values used where a step doesn't reproduce exactly (for example the Xenium PCA and UMAP).

| Folder | Language | Contents |
|---|---|---|
| `snrnaseq/` | R | snRNA-seq analysis, Stages 0–5, and the supplementary inferCNV analysis |
| `spatial/` | Python | Spatial (Xenium) analysis, Stages 1–3 (see `spatial/README.md`) |
| `spatial_proteomics/` | R | Record of the code for the MIBI figures; no Docker container (see `spatial_proteomics/README.md`) |

The snRNA-seq analysis uses one conda env per group of stages, and the Xenium analysis one env for all its stages. All envs go in **one Docker image**, built from bioconda and conda-forge only, from the lock files in `envs/`. `run.sh` runs a stage inside its env. The Xenium env (`spatial`) is in the image from `v0.3.0`, but no notebook has been run in the image yet: the Xenium results so far come from the original `xenium.squidpy` env (see `spatial/README.md`). Data and analysis objects are not stored in this repository; they are on GEO and Zenodo (see [Data](#data)).

## Environments

| Env | Definition | Lock file | Contents | Stages |
|---|---|---|---|---|
| `snrnaseq` | `envs/snrnaseq.yml` | `envs/snrnaseq-linux-64.lock` | R 4.3, Bioconductor 3.17, Seurat 4.3.0, simspec (GitHub, pinned commit) | 1, 2 |
| `downstream` | `envs/downstream.yml` | `envs/downstream-linux-64.lock` | R 4.3, Bioconductor 3.17, Seurat 4.3.0, ggplot2 3.5.2, edgeR, clusterProfiler, simspec + treeio (GitHub, pinned commits), UCell, SingleR, EnhancedVolcano, ReactomePA | 3, 4 |
| `cellchat` | `envs/cellchat.yml` | `envs/cellchat-linux-64.lock` | R 4.3, Bioconductor 3.17, Seurat 4.3.0, CellChat 2.1.2 (GitHub), dplyr 1.2.1 and NMF 0.27 (CRAN source) | 5 |
| `infercnv` | `envs/infercnv.yml` | `envs/infercnv-linux-64.lock` | R 4.3, infercnv 1.20.0, Seurat 5.1.0 | Supplementary inferCNV |
| `spatial` | `envs/spatial.yml` | `envs/spatial-linux-64.lock` | Python 3.9, scanpy 1.9.5, squidpy 1.3.1 and spatialdata 0.2.5.post0 (PyPI, `envs/post_install_spatial.txt`), papermill | Spatial 1, 2, 3 |

All snRNA-seq stages use R 4.3. Every R package recorded in a stage's `sessionInfo/` is pinned to its original version where conda has an R 4.3 build. Each stage README lists the exceptions. The build saves each env's `sessionInfo()` to `/pipeline/sessionInfo/<env>.txt` inside the image.

The `spatial` env uses Python 3.9. The packages the notebooks import, and the scanpy, squidpy and spatialdata dependencies, are pinned to the versions loaded in the original env (`spatial/environment/requirements_as_used.txt`, with the corrections in `spatial/README.md`). Four have no Python 3.9 conda build of that version and use the nearest one: pandas 2.2.3 (originally 2.3.3), tqdm 4.67.1 (4.67.3), pooch 1.8.2 (1.9.0) and xarray-spatial 0.4.0 (0.5.3). The build saves the installed versions to `/pipeline/sessionInfo/spatial.txt`.

## snRNA-seq stages

| Stage | Folder | Env | Input | Status |
|---|---|---|---|---|
| 0. Cell Ranger + CellBender | `snrnaseq/stage0_cellranger_cellbender/` | — (documentation only) | FASTQ | Record only |
| 1. Doublet removal + fixed QC thresholds | `snrnaseq/stage1_doublet_qc/` | `snrnaseq` | CellBender output: from GEO ([GSE282918](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282918)), or the original local folders for the reproducibility test | Ready |
| 2. Seurat processing + Simspec integration | `snrnaseq/stage2_seurat_simspec/` | `snrnaseq` | Deposited post-QC object ([10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322)); cell labels from the deposited final annotated object | Ready |
| 3. Malignant vs non-malignant (incl. rare malignancies, tuft, ADM) | `snrnaseq/stage3_malignant_nonmalignant/` | `downstream` | Deposited final annotated object (`sts.simspec_css.sample.sct_final.RDS`) + `tuft.snv.df.csv` ([10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322)) | Ready |
| 4. Reclustering (lymphoid, myeloid, stromal) + final annotation and plots | `snrnaseq/stage4_reclustering/` | `downstream` Deposited final annotated object | Ready |
| 5. CellChat | `snrnaseq/stage5_cellchat/` | `cellchat` | Deposited final annotated object (`sts.simspec_css.sample.sct_final.RDS`), as made by Stage 4 | Ready |

**Supplementary: inferCNV** (`snrnaseq/supplementary_infercnv/`, env `infercnv`, `run.sh infercnv`). A check that the cells annotated as malignant in Stage 2 show copy-number changes. It also identified the 84 cells of sample 2215 that Stage 3 excludes from the malignant analysis; their IDs are written into the code, so no later stage reruns inferCNV. Input: the deposited final annotated object + `gene_positions.txt` (included).

**Supplementary: per-sample QC** (`snrnaseq/supplementary_qc/`, documentation only). How the per-sample QC tables and plots requested in review were made, from the annotated object and the Cell Ranger output. It adds to Stages 0 and 1.

### The break between Stage 1 and Stage 2

Stage 1 can be rerun from the raw CellBender output, but it doesn't reproduce the original object exactly. The original run set `set.seed()` but did not pass a seed to the parallel workers (`BPPARAM` `RNGseed`), so parallel steps such as scDblFinder gave slightly different results. A rerun in the project image gives 26,774 genes × 115,301 cells, while the original object has 26,788 genes × 115,221 cells.

All later stages therefore start from the **original post-QC object**, deposited at [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322). This keeps every manuscript figure exactly reproducible, while Stage 1 documents how that object was made.

## Spatial (Xenium) stages

| Stage | Folder | `run.sh` stage | Input | Notebooks |
|---|---|---|---|---|
| 1. Sample processing, cell annotation, neighbourhood enrichment | `spatial/stage1/` | `spatial1` | Raw Xenium output of the 16 samples (GEO [GSE282154](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282154)) and the 16 processed `.h5ad` files ([10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322)) | One per sample, then the robustness summary |
| 2. Niches, figures, neighbourhood profiling | `spatial/stage2/` | `spatial2` | Stage 1 output | 3 |
| 3. Malignant–TIL, Tuft, TIL regions, TLS, MH097 PanIN | `spatial/stage3/` | `spatial3` | Stage 1 and Stage 2 output, raw Xenium output of the 16 samples and of the four TNBC sections (GEO [GSE281886](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE281886)) | 6 |

All three use the env `spatial`. Each stage folder has a `config.yml` with the container paths and the notebooks in run order; `spatial/run_notebooks.py` runs them with papermill. See [Running the spatial stages](#running-the-spatial-stages).

## Data

| Data | Where |
|---|---|
| snRNA-seq CellBender output (`<sample>_cellbender_filtered.h5` and 10x matrix files) | GEO [GSE282918](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282918) |
| Post-QC object (`qc.dbl.fltrd.sts.sce.RDS`), final annotated object (`sts.simspec_css.sample.sct_final.RDS`) and KRAS calls per tuft cell (`tuft.snv.df.csv`) | Zenodo, [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322) |
| Spatial (Xenium) data, PDAC | GEO [GSE282154](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282154) |
| Spatial (Xenium) data, TNBC (TLS comparison in Stage 3) | GEO [GSE281886](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE281886) |
| Spatial (Xenium) processed objects, 16 PDAC samples (`Xenium_480.tar`, `Xenium_314.tar`) | Zenodo, [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322) |
| Spatial proteomics (MIBI) processed object (`spe.rds`) and per-cell table for plotting (`celltype_classifier_corrected.csv`) | Zenodo, [10.5281/zenodo.23996821](https://doi.org/10.5281/zenodo.23996821) |

Files in the Zenodo record [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322), with the MD5 checksums Zenodo shows. Check a download with `md5sum <file>` (Linux) or `md5 <file>` (macOS).

| File | Size | MD5 | Used by |
|---|---|---|---|
| `qc.dbl.fltrd.sts.sce.RDS` | 511.87 MB | `ed3332de67d0bab32d9cd2d9c4d773fb` | snRNA-seq Stage 2 |
| `sts.simspec_css.sample.sct_final.RDS` | 8.77 GB | `5996b8bfd886974b46dc3d39cb6c5428` | snRNA-seq Stages 2–5, inferCNV |
| `tuft.snv.df.csv` | 2.11 MB | `e0217adfd5bb07c3bc1b2ecb72ccf327` | snRNA-seq Stage 3 |
| `Xenium_480.tar` | 9.37 GB | `a50f0c7960b6c8c6bdfecaeba23154df` | Spatial Stage 1 |
| `Xenium_314.tar` | 5.16 GB | `25f86f3e61d23400894b8c54c5e3d10b` | Spatial Stage 1 |

## Build

```bash
docker build --platform linux/amd64 -t pdac-snrnaseq:1.0 .
```

The image is linux/amd64 only, because bioconda's R 4.3 builds are only available for linux-64. On an Apple Silicon Mac it builds and runs under emulation, which is slower. `v0.3.0` is 13.7 GB as a Docker image and 2.7 GB as a `.sif`.

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

- `<stage>` is `stage1`, `stage2`, `stage3`, `stage4`, `stage5` or `infercnv` (snRNA-seq), or `spatial1`, `spatial2` or `spatial3` (Xenium).
- `[config.yml]` defaults to the stage's own `config.yml`. You can also give the name of another config in the stage folder (e.g. `config_local.yml`), or the path of a config you have mounted into the container.
- Each stage README lists the mounts it needs and gives a full example.

To copy the recorded session information out of the image:

```bash
docker run --rm --entrypoint cat pdac-snrnaseq:1.0 /pipeline/sessionInfo/snrnaseq.txt
```

### Running the spatial stages

The `spatial` env is in the image from `v0.3.0`: it builds, and scanpy, squidpy and the other packages import. No notebook has been run in the image yet, so the commands below are untested.

Put the inputs in one folder, laid out as below, and mount it at `/data/input`. The sample folder names are in `spatial/README.md` ("Folder layout").

```
<input>/
  xenium_raw/<sample>/            cell_feature_matrix.h5 and cells.csv, for each of the 16 samples (e.g. MH107_314)
  xenium_raw_tnbc/TNBC_<1-4>/     the same two files for the four TNBC sections (Stage 3 only)
  xenium_saved_objects/           the 16 .h5ad files from Xenium_480.tar and Xenium_314.tar (Stage 1 only)
```

Run the stages in order, with the same output folder: Stages 2 and 3 read the Stage 1 output from `/output/spatial/stage1`, and Stage 3 also reads the combined object that Stage 2 writes.

```bash
docker run --rm -v <input>:/data/input:ro -v <output>:/output pdac-snrnaseq:1.0 spatial1
docker run --rm -v <input>:/data/input:ro -v <output>:/output pdac-snrnaseq:1.0 spatial2
docker run --rm -v <input>:/data/input:ro -v <output>:/output pdac-snrnaseq:1.0 spatial3
```

With Apptainer:

```bash
apptainer run --cleanenv --no-home --bind <input>:/data/input --bind <output>:/output \
  pdac-snrnaseq.sif spatial1
```

Each stage writes to `/output/spatial/stage<N>/`: the results and figures of each notebook, and the executed notebooks in `notebooks/`.

- **Some samples or notebooks only.** Copy the stage's `config.yml`, shorten its `notebooks` list, mount the copy and give its path. For example, for one Stage 1 sample:

  ```bash
  docker run --rm -v <input>:/data/input:ro -v <output>:/output \
    -v $PWD/my_config.yml:/config/my_config.yml:ro \
    pdac-snrnaseq:1.0 spatial1 /config/my_config.yml
  ```

  The Stage 1 robustness summary needs all 16 samples, and in Stage 3 the TIL regions notebook needs the malignant–TIL output and the TLS figures notebook the TLS regions.
- **Other paths.** The `parameters` in the config are the values for each notebook's `parameters` cell; change them in a copy of the config.
- **Checks against the original objects** are skipped: those objects are not deposited. The results of the checks are in the stage READMEs.

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

The shell starts in `/pipeline`, which holds `run.sh`, `snrnaseq/`, `spatial/`, `envs/` and `sessionInfo/`. No env is active. Put one first on `PATH`, the same way `run.sh` does:

```bash
export PATH=/opt/conda/envs/snrnaseq/bin:$PATH   # or downstream (Stages 3, 4), cellchat (Stage 5), infercnv, spatial
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

An explicit lock holds conda packages only. The two PyPI packages of the `spatial` env are pinned in `envs/post_install_spatial.txt` and installed with `pip install --no-deps` in the `Dockerfile`.
