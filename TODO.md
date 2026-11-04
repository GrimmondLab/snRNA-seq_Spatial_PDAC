# TODO

Next steps after the move to one conda-based Docker image (`Dockerfile`, `envs/`, `run.sh`).
The image built with the `snrnaseq` and `infercnv` envs, and every package the Rmds load attached in both. The `downstream` (Stages 3–4) and `cellchat` (Stage 5) envs are locked but have not been built into the image yet. Nothing has been run on real data yet.

## 1. Build and move the image to the HPC

- [ ] Push a tag (e.g. `git tag v0.1.0 && git push origin v0.1.0`) so that `.github/workflows/docker.yaml` builds and publishes `ghcr.io/grimmondlab/snrna-seq_spatial_pdac:0.1.0` and the Apptainer `:0.1.0-sif`. Check the run passes, and download its `sessionInfo` artifact.
- [ ] Check the org allows Actions to publish packages: **Settings → Actions → General → Workflow permissions**, and org **Packages** settings.
- [ ] The repo is private, so the package will be private. Make it public (package settings → visibility) before sharing with reviewers, or use a `docker login ghcr.io` with a PAT that has `read:packages` on the HPC.
- [ ] Pull the prebuilt `.sif` on the HPC and check that the runner starts (it should print usage):
      ```bash
      apptainer pull pdac-snrnaseq.sif oras://ghcr.io/grimmondlab/snrna-seq_spatial_pdac:0.1.0-sif
      apptainer run pdac-snrnaseq.sif
      ```
      Private package: run `apptainer registry login -u <github-user> oras://ghcr.io` first, with a PAT that has `read:packages`.
      Or build locally on a linux/amd64 machine: `docker build --platform linux/amd64 -t pdac-snrnaseq:1.0 .`
- [ ] Check the read-only `.sif` works for a real stage. If R complains about a non-writable `HOME` or temp dir, add `--env TMPDIR=/output/tmp` or bind a writable `HOME`.
- [ ] For the paper: tag a release (`git tag v1.0.0 && git push origin v1.0.0`) to publish `:1.0.0` and `:1.0.0-sif`, and cite the image by digest (`ghcr.io/...@sha256:...`) in the README and manuscript.

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

### Supplementary inferCNV (env `infercnv`, `run.sh infercnv`)
- [ ] Run one sample first to check time and memory (set `samples:` in a custom config), then all samples, one per HPC job.
- [ ] Same chromosome-arm gains/losses in malignant cells, and none in the reference cells. Subcluster boundaries and HMM calls will differ: no seed is set, as in the original run.

### Stage 3: malignant / non-malignant (env `downstream`, `run.sh stage3`)
- [ ] Run from the deposited Stage 2 annotated object and `tuft.snv.df.csv`.
- [ ] `STS_Malignant.Rmd` should find 6 clusters at resolution 0.1 (it stops otherwise).
- [ ] Cross-tabulate `Lv.1.Anno`, `Lv.2.Anno` and `Tuft.persistent` in `sts.nonmalignant.RDS` against the original object per cell. They are assigned by cluster number, so renumbered clusters would mislabel cells.
- [ ] Compare Extended Data Fig. 1C–E and 4A/C/G/H, and Supplementary Table 3, with the manuscript.

## 3. Spatial (Python): blocked on inputs
- [ ] Add the notebooks (`.ipynb`) and any helper `.py` files under `spatial/`.
- [x] Decide which env record is correct: `spatial/environment/requirements_as_used.txt`, the versions actually loaded (scanpy 1.9.5 and squidpy 1.3.1, from `~/.local`).
- [x] Check the imported versions of the packages with two copies inside the conda env: 8 of 10 differ from `requirements_as_used.txt`; see the corrections in `spatial/README.md`.
- [ ] When the notebooks arrive, search them and their helper files for s3fs, aiobotocore, botocore and `s3://`. The analyst does not recall using Amazon S3. If nothing needs them, leave these three out: they probably conflict with the imported fsspec 2023.10.0 and urllib3 2.1.0, so the env may not solve with them.
- [ ] Deposit the 16 processed `.h5ad` files (they also hold the PCA results that Stage 1 reads), and record their DOI.
- [ ] Write `envs/spatial.yml`, using conda-forge/bioconda only (no `defaults`):
  - pin the analysis packages (scanpy, squidpy, anndata, …) to `requirements_as_used.txt` with the corrections in `spatial/README.md`, leaving out muon and mofapy2 (not used);
  - leave low-level libraries unpinned;
  - add pip-only packages under `pip:`.
- [ ] Lock it with `conda-lock` (see README, "Updating an env"), and add it to the `Dockerfile` and a `spatial` entry in `run.sh` (papermill or `jupyter nbconvert --execute`).
- [ ] Check whether any notebook needs a GPU (torch / scvi-tools are in the env). If so, decide on a CPU fallback or a separate GPU image.

## 4. Finish moving the downstream commit (d404957) to the single image

Done: `stage3_infercnv/` replaced by `supplementary_infercnv/` (env `infercnv`, no seed, as in the original run); Stage 3 has its own env `downstream` (`envs/downstream.yml` + lock, GitHub packages in `envs/post_install_downstream.R`); both run through `run.sh` and are checked in the CI smoke test; the per-stage Dockerfiles and `install_packages.R` are deleted.

- [ ] **Build the image with the `downstream` env** (locally or by pushing a tag) and check the build log: `post_install_downstream.R` must install treeio 1.25.0.001 over the conda treeio 1.24.1, and every package in `sessionInfo/downstream.txt` must attach. If the GitHub treeio clashes with the conda builds of ggtree / enrichplot / clusterProfiler, fall back to conda's treeio 1.24.1 and record the difference.
- [ ] **Keep one `sample_map.csv`.** `shared/sample_map.csv` is identical to `snrnaseq/stage0_cellranger_cellbender/sample_map.csv`; keep `shared/` and point the Stage 0 README at it.

### Stage 4: reclustering (env `downstream`, `run.sh stage4`)
- [ ] Cross-tabulate `Lv.2.Anno` in each saved object against the original objects per cell. They are assigned by cluster number.
- [ ] Compare the figures and Supplementary Tables 4–7 with the manuscript.

### Stage 5: CellChat (env `cellchat`, `run.sh stage5`)
- [ ] Check the build log: `post_install_cellchat.R` compiles CRAN and GitHub packages inside the env, which no other env does with compiled code.

### Supplementary QC (`snrnaseq/supplementary_qc/`, record only)
- [ ] Add the three CSVs to Supplementary Table 1, from the rerun of the tidied file, each with a note on what it covers (see the folder README).

## 5. Before submission
- [x] Post-QC object and `tuft.snv.df.csv` deposited: 10.5281/zenodo.23933322.
- [ ] Deposit on Zenodo, and replace every remaining **DOI_TBD**: the annotated Stage 2 object, `sts.nonmalignant.RDS` (Stage 3 output, input to Stage 4) and `sts.simspec_css.sample.sct_final.RDS` (Stage 4 output, input to Stage 5).
- [ ] Tag a release (e.g. `v1.0`) and archive the repo on Zenodo for a citable DOI.
- [ ] Copy `sessionInfo/*.txt` out of the final image and commit them next to the originals:
      `docker run --rm --entrypoint cat pdac-snrnaseq:1.0 /pipeline/sessionInfo/snrnaseq.txt`
- [ ] Add a short "Reproducibility" paragraph to the methods: one image, conda lock files, R 4.3, the known version differences (listed in each stage README).
