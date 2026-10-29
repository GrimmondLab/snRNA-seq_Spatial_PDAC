# TODO

Next steps after the move to one conda-based Docker image (`Dockerfile`, `envs/`, `run.sh`).
The image builds, and every package the Rmds load attaches in both envs. Nothing has been run on real data yet.

## 1. Build and move the image to the HPC

- [ ] Build on a linux/amd64 machine (faster than emulation on a Mac):
      `docker build --platform linux/amd64 -t pdac-snrnaseq:1.0 .`
- [ ] Convert to Apptainer and check that the runner starts (it should print usage):
      ```bash
      docker save pdac-snrnaseq:1.0 -o pdac-snrnaseq_1.0.tar
      apptainer build pdac-snrnaseq_1.0.sif docker-archive://pdac-snrnaseq_1.0.tar
      apptainer run pdac-snrnaseq_1.0.sif
      ```
- [ ] Check the read-only `.sif` works for a real stage. If R complains about a non-writable `HOME` or temp dir, add `--env TMPDIR=/output/tmp` or bind a writable `HOME`.
- [ ] Optional: push the image to a registry (e.g. GHCR or Docker Hub) and reference it by digest in the README and manuscript.

## 2. Rerun each stage and compare with the originals

### Stage 1 (env `snrnaseq`)
- [ ] Run on the GEO input (`run.sh stage1`), and on the original CellBender folders (`run.sh stage1 config_local.yml`).
- [ ] 30 samples loaded; scDblFinder ≈ 129,115 singlets / 6,867 doublets.
- [ ] Final object ≈ 26,757 genes × 115,293 cells (the Oct 26 rerun). Exact equality is not expected: worker seeds were not set originally, and xgboost is now 1.7.6 (originally 1.7.5.1).

### Stage 2 (env `snrnaseq`): highest risk
Now runs on R 4.3 with Matrix 1.5-4.1, instead of R 4.4.0 with Matrix 1.7-5.
- [ ] Run from the deposited post-QC object (`run.sh stage2`).
- [ ] Compare cluster sizes (`seurat_clusters`) at each resolution with the original objects.
- [ ] **Check cell-type labels.** `cell_class` and `simspec_cell_class` are assigned by cluster number. Cross-tabulate the new labels against the original annotated object per cell (`table(new, old)`). Any off-diagonal block means clusters were renumbered and the label mapping is wrong.
- [ ] Visually compare the key UMAP figures with the manuscript.
- [ ] If clusters differ materially: keep the deposited annotated object as the starting point for Stages 3+, and describe the Stage 2 rerun as documentation (as already done for Stage 1).

### Stage 3 (env `infercnv`)
- [ ] Run one sample first to check time and memory (set `samples:` in a custom config), then all samples, one per HPC job.
- [ ] Same chromosome-arm gains/losses in malignant cells, and none in the reference cells. Subcluster boundaries may differ (no original seed).

## 3. Spatial (Python): blocked on inputs
- [ ] Add the notebooks (`.ipynb`) and any helper `.py` files under `spatial/`.
- [ ] Decide which env record is correct: `environment_full.yml` or `requirements_pip.txt` (they disagree on 19 versions, including scanpy and squidpy).
- [ ] Write `envs/spatial.yml`, using conda-forge/bioconda only (no `defaults`):
  - pin the analysis packages (scanpy, squidpy, anndata, muon, mofapy2, …) to the chosen record;
  - leave low-level libraries unpinned;
  - add pip-only packages under `pip:`.
- [ ] Lock it with `conda-lock` (see README, "Updating an env"), and add it to the `Dockerfile` and a `spatial` entry in `run.sh` (papermill or `jupyter nbconvert --execute`).
- [ ] Check whether any notebook needs a GPU (torch / scvi-tools are in the env). If so, decide on a CPU fallback or a separate GPU image.

## 4. Stages 4 and 5
- [ ] Add the Rmds when available. Check their `sessionInfo` against the `snrnaseq` env (R 4.3, Bioc 3.17). If they used other versions, add pins or a new env.
- [ ] Add `run_stage4.R` / `run_stage5.R` (copy the pattern of `run_stage2.R`) and entries in `run.sh`.

## 5. Before submission
- [ ] Deposit the post-QC and annotated Stage 2 objects on Zenodo, and replace every **DOI_TBD**.
- [ ] Tag a release (e.g. `v1.0`) and archive the repo on Zenodo for a citable DOI.
- [ ] Copy `sessionInfo/*.txt` out of the final image and commit them next to the originals:
      `docker run --rm --entrypoint cat pdac-snrnaseq:1.0 /pipeline/sessionInfo/snrnaseq.txt`
- [ ] Add a short "Reproducibility" paragraph to the methods: one image, conda lock files, R 4.3, the known version differences (listed in each stage README).
