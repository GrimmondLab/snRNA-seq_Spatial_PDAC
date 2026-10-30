# CLAUDE.md

Code and environments for the PDAC snRNA-seq + spatial (Xenium) manuscript. Goal: every manuscript figure reproducible from deposited data. Data and analysis objects are not in the repo (GEO GSE282918 + Zenodo, DOI_TBD).

Read first: `README.md` (layout, envs, build/run), `TODO.md` (current state and open work), the stage READMEs under `snrnaseq/stage*/`.

## Layout

- `snrnaseq/stageN_*/`, `snrnaseq/supplementary_*/`: one folder per R stage or supplementary analysis: Rmd(s), `run_stageN.R` (renders them with `params`), `config.yml` (container paths `/data/...`, `/output`), `sessionInfo/` of the **original** runs, and a README listing every version difference from those runs.
- `spatial/`: Python, not added yet.
- `shared/`: tables used by several stages.
- `envs/`: one conda env per group of stages (`snrnaseq`: stages 1–2; `downstream`: stage 3; `infercnv`: supplementary inferCNV), each `<env>.yml` + committed explicit lock `<env>-linux-64.lock`; `post_install*.R` (GitHub-only packages at pinned commits); `session_info.R`.
- `Dockerfile` + `run.sh`: **one** image holding all envs. `run.sh <stage> [config]` maps a stage to its env and folder.

## Conventions

- New stages go into the single image: add an env (or reuse one), a `run.sh` case, and key-version checks in the CI smoke test. No per-stage Dockerfiles or `install_packages.R` scripts.
- Pin R packages to the versions in the stage's original `sessionInfo/`. When conda has no R 4.3 build of that version, pin the nearest and record the difference in the stage README and in the env yml. Watch noarch conda-forge R packages: newer builds can require R ≥ 4.4 even though they aren't tagged `r43`/`r44`.
- bioconda/conda-forge only, `nodefaults`. linux-64 only (bioconda's R 4.3 builds), so the image is linux/amd64.
- `run.sh` puts the env first on `PATH` instead of `micromamba activate`, and stages write only under `/output` (`intermediates_dir` too), so the read-only Apptainer `.sif` works. Keep it that way.
- After editing `envs/<env>.yml`, regenerate its lock (command in `README.md`, "Updating an env") and commit both.
- Cell-type labels are assigned by cluster number in several Rmds. Any change that could renumber clusters needs a per-cell cross-tab against the original object.
- Stage 1 doesn't reproduce the original post-QC object exactly (no worker seeds). Later stages start from the deposited object, not from a Stage 1 rerun.

## CI

`.github/workflows/docker.yaml` runs only on a pushed `vX.Y.Z` tag: build, smoke test (`run.sh` usage + key package versions from `/pipeline/sessionInfo/<env>.txt`), push `ghcr.io/grimmondlab/snrna-seq_spatial_pdac:X.Y.Z`, then convert to a `.sif` and push it with ORAS as `:X.Y.Z-sif`. Nothing builds on branches or PRs. Actions are pinned by SHA.
