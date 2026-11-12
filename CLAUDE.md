# CLAUDE.md

Code and environments for the PDAC snRNA-seq + spatial (Xenium) manuscript. Goal: every manuscript figure reproducible from deposited data. Data and analysis objects are not in the repo (GEO GSE282918 for snRNA-seq, GSE282154 for spatial PDAC, GSE281886 for spatial TNBC (TLS comparison), + Zenodo, 10.5281/zenodo.23933322 (snRNA-seq objects and the 16 processed Xenium objects), 10.5281/zenodo.23996821 (MIBI) and DOI_TBD).

Read first: `README.md` (layout, envs, build/run), `TODO.md` (current state and open work), the READMEs under `snrnaseq/*/`, `spatial/` and `spatial_proteomics/`.

## Layout

- `snrnaseq/stageN_*/`, `snrnaseq/supplementary_*/`: one folder per R stage or supplementary analysis: Rmd(s), `run_stageN.R` (renders them with `params`), `config.yml` (container paths `/data/...`, `/output`), `sessionInfo/` of the **original** runs, and a README listing every version difference from those runs.
- `snrnaseq/stage0_*/`, `snrnaseq/supplementary_qc/`: records only, not in the image (excluded in `.dockerignore`) or `run.sh`.
- `spatial/stageN/`: Python notebooks, organised like the snRNA-seq stages (one folder per stage, README listing inputs, figures and the check against the original). The one difference: **one env for all spatial stages** (`xenium.squidpy`, scanpy 1.9.5, squidpy 1.3.1), not one per group of stages. Xenium data from 16 samples of 8 PURPLE registry patients (a 314-gene and a 480-gene panel each), a different cohort from the snRNA-seq samples, plus 4 TNBC sections for the TLS comparison.
  - `stage1/`: one notebook per sample (`<sample>_stage1.ipynb`), the robustness summary notebook and result tables.
  - `stage2/`: niches, figures and neighbourhood profiling notebooks.
  - `stage3/`: malignant–TIL, Tuft, TIL regions, TLS regions, TLS figures and MH097 PanIN notebooks, run in that order; `tuft_inputs/` holds the two small saved inputs the Tuft notebook needs (MH096 clusters, MH099 UMAP).
  - `environment/`: the env records, including `requirements_as_used.txt` (corrections in `spatial/README.md`).
  - The notebooks have `/path/to/...` placeholders in their parameters cell. `stageN/config.yml` gives the container paths for them and lists the notebooks in run order; `run_notebooks.py` runs them with papermill (`run.sh spatial1|spatial2|spatial3`). Env `spatial` (`envs/spatial.yml` + lock; squidpy and spatialdata from PyPI with `--no-deps`, `envs/post_install_spatial.txt`). `environment/` is not in the image.
- `spatial_proteomics/`: record only (MIBI figure code from collaborators at WEHI, kept as received), not in the image or `run.sh`.
- `shared/`: tables used by several stages.
- `envs/`: one conda env per group of stages (`snrnaseq`: stages 1–2; `downstream`: stages 3–4; `cellchat`: stage 5; `infercnv`: supplementary inferCNV), each `<env>.yml` + committed explicit lock `<env>-linux-64.lock`; `post_install*.R` (GitHub-only packages at pinned commits, plus CRAN source packages for `cellchat`); `session_info.R`.
- `Dockerfile` + `run.sh`: **one** image holding all envs. `run.sh <stage> [config]` maps a stage to its env and folder.
- `snrnaseq/stage2_seurat_simspec/stage2_spartan.slurm`: Slurm job for Spartan, and the template for other stages. It runs the `.sif` with `--cleanenv --no-home --env TMPDIR=/output/tmp`. Measured peaks and job IDs are in `TODO.md`.

## Conventions

- New stages go into the single image: add an env (or reuse one), a `run.sh` case, and key-version checks in the CI smoke test. No per-stage Dockerfiles or `install_packages.R` scripts.
- Pin R packages to the versions in the stage's original `sessionInfo/`. When conda has no R 4.3 build of that version, pin the nearest and record the difference in the stage README and in the env yml. Watch noarch conda-forge R packages: newer builds can require R ≥ 4.4 even though they aren't tagged `r43`/`r44`.
- bioconda/conda-forge only, `nodefaults`. linux-64 only (bioconda's R 4.3 builds), so the image is linux/amd64. One exception: `post_install_cellchat.R` installs dplyr 1.2.1, the packages it needs and NMF from CRAN source, because Stage 5 needs them and conda has no R 4.3 build.
- `run.sh` puts the env first on `PATH` instead of `micromamba activate`, and stages write only under `/output` (`intermediates_dir` too), so the read-only Apptainer `.sif` works. Keep it that way.
- After editing `envs/<env>.yml`, regenerate its lock (command in `README.md`, "Updating an env") and commit both.
- Cell-type labels are read from the deposited final object by cell ID (Stage 2 from `cell_class`/`simspec_cell_class`; Stages 3–4 from the `stage3_*`/`stage4_*` columns, via `shared/label_checks.R`), not from cluster numbers. The original cluster mappings are kept as `_by_cluster` columns and compared in `label_agreement.tsv`. Fig. 1C uses the stored subset UMAPs.
- snRNA-seq Stage 1 doesn't reproduce the original post-QC object exactly (no worker seeds). Later stages start from the deposited object, not from a Stage 1 rerun.
- Spatial Stage 1 reads the saved PCA, UMAP, clusters and kept cells from the 16 processed `.h5ad` files (Zenodo, `Xenium_480.tar` and `Xenium_314.tar`), because PCA and UMAP don't reproduce exactly, and recomputes everything else from raw data. Its 16 final objects are the input to spatial Stages 2 and 3; Stage 3 region analyses also crop from the raw Xenium output.
- Spatial checks against the original objects are optional and skipped when those objects are missing: the originals are not deposited, and the check results are recorded in the stage READMEs. Deposit only what a notebook needs to run.

## CI

`.github/workflows/docker.yaml` runs only on a pushed `vX.Y.Z` tag: build, smoke test (`run.sh` usage + key package versions from `/pipeline/sessionInfo/<env>.txt`), push `ghcr.io/grimmondlab/snrna-seq_spatial_pdac:X.Y.Z`, then build a `.sif` from the pushed image (not the local Docker daemon, which fills the runner's disk), smoke-test it and push it with ORAS as `:X.Y.Z-sif`. Nothing builds on branches or PRs. Actions are pinned by SHA.
