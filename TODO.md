# TODO

Next steps after the move to one conda-based Docker image (`Dockerfile`, `envs/`, `run.sh`).
`v0.2.2` is published as a Docker image and a `.sif`, with all four envs and Stages 1–5. Stages 1 and 2 have finished full runs on Spartan (exit code 0), but neither output has been checked yet (see section 2). Stage 1 needs far more memory than documented.

## 1. Build and move the image to the HPC

- [x] Publish a first image: `v0.1.2` built, passed the smoke test and pushed `:0.1.2` and `:0.1.2-sif` (so the org allows Actions to publish packages).
- [x] Push a tag with Stages 4 and 5: `v0.2.0` built, passed the smoke test and pushed `:0.2.0`.
- [x] Publish a `.sif` with Stages 4 and 5: `v0.2.2` pushed `:0.2.2` and `:0.2.2-sif`, and the `.sif` matches the Docker image.
- [ ] Pass a `GITHUB_PAT` to the Docker build as a BuildKit secret. `install_github` runs unauthenticated, so a rebuild can fail on GitHub's rate limit (`v0.2.1` did, and a rerun passed).
- [ ] The repo is private, so the package will be private. Make it public (package settings → visibility) before sharing with reviewers, or use a `docker login ghcr.io` with a PAT that has `read:packages` on the HPC.
- [x] Pull the prebuilt `.sif` on the HPC and check that the runner starts (it should print usage):
      ```bash
      apptainer pull pdac-snrnaseq.sif oras://ghcr.io/grimmondlab/snrna-seq_spatial_pdac:0.2.2-sif
      apptainer run pdac-snrnaseq.sif
      ```
      Private package: run `apptainer registry login -u <github-user> oras://ghcr.io` first, with a PAT that has `read:packages`.
      Or build locally on a linux/amd64 machine: `docker build --platform linux/amd64 -t pdac-snrnaseq:1.0 .`
- [x] Check the read-only `.sif` works for a real stage. On Spartan, Stage 1 ran with `--cleanenv --no-home --env TMPDIR=/output/tmp` until it ran out of memory, with no file or permission errors.
- [ ] For the paper: tag a release (`git tag v1.0.0 && git push origin v1.0.0`) to publish `:1.0.0` and `:1.0.0-sif`, and cite the image by digest (`ghcr.io/...@sha256:...`) in the README and manuscript.

## 1b. Run on AWS Batch (planned)

The plan is Batch on EC2, with data in S3.

- [ ] Choose the AWS account and region, and check the data-use terms allow it: the data are patient-derived, and the analysis objects are not deposited yet.
- [ ] Run full Stage 1 once on a single EC2 instance (size from the Spartan peak; `r6i.4xlarge` is probably too small, Docker, `aws s3 sync`, `config_local.yml`, mounting `samples/` only). This gives the peak memory and runtime to size the jobs, and tests reproducibility.
- [ ] Create the S3 bucket: encrypted, public access blocked, reached through a VPC endpoint.
- [ ] Mirror the image to ECR in the same region (10 GB; the GHCR package is private).
- [ ] Add a thin wrapper image: download inputs to `/data`, call `run.sh`, upload `/output` (also on failure). The image has no S3 tools, and the analysis image stays unchanged.
- [ ] Write the CDK stack (TypeScript, as in `nemo-infra`): Batch on memory-optimised x86 EC2 scaling to zero, one job definition per stage, launch template with a large EBS volume. Use on-demand, not Spot: stages have no checkpoints. A 128 GB job won't fit on a 128 GiB instance, so Stages 2–5 probably need `r6i.8xlarge` at least; size them from measured peaks (Spartan: Stage 1 258 GB, Stage 2 108 GB).
- [ ] Keep the `workers` values from each stage's config: parallel settings can change results.

## 2. Rerun each stage and compare with the originals

### Stage 1 (env `snrnaseq`)
- [ ] Run on the GEO input (`run.sh stage1`), and on the original CellBender folders (`run.sh stage1 config_local.yml`). One full run finished on Spartan (job 34375352): record which input it used and the image version, then see whether the other is still needed.
- [x] **Find the real memory need.** On Spartan (`sapphire`, 12 CPUs), OOM killed at 64G and at 192G, in `discard_lowq_cells` and `variance_modelling`. With 400G it finished: peak 258.32 GB, 1h37, about 1.9 cores on average.
- [ ] Correct "64 GB" in the Stage 1 README (lines 59, 66 and 78).
- [ ] A coworker's run in RStudio on a 64G instance finished, which doesn't fit the peak above. Only worth chasing if 400G jobs are hard to get, or for AWS sizing: check how it differed (run in pieces, `workers`, swap), whether Transparent Huge Pages is a factor, and whether forked workers inflate Slurm's figure.
- [ ] Recheck the 128 GB figures for Stages 3–5, which have not been tested at full scale. Stage 2 fits (see below).
- [x] 30 samples loaded; scDblFinder in the image (Apptainer): 129,134 singlets / 6,848 doublets (129,115 / 6,867 in the earlier rerun outside the image).
- [x] Final object in the image (Apptainer): 26,774 genes × 115,301 cells, the same size as the August 2024 rerun (original: 26,788 × 115,221). Exact equality is not expected: worker seeds were not set originally, and xgboost is now 1.7.6 (originally 1.7.5.1).

### Stage 2 (env `snrnaseq`): highest risk
Now runs on R 4.3 with Matrix 1.5-4.1, instead of R 4.4.0 with Matrix 1.7-5.
- [x] Run from the deposited post-QC object (`run.sh stage2`): PCA, UMAP and clusters shift slightly, and the cluster numbers no longer match the original label mappings. Finished on Spartan (job 34425917, `stage2_spartan.slurm`, 12 CPUs, 400G): peak 108.23 GB, 1h48, about 1.4 cores on average. Record the image version. About 150G is enough next time.
- [x] Read `cell_class` and `simspec_cell_class` from the deposited annotated object by cell ID (`reference_object` in `config.yml`); the original mappings are kept as a record; `original/` holds the files before this change.
- [ ] Rerun Stage 2 with these changes, and check the reports: the original-mapping check in the integration step should be 100%, and the rerun-cluster comparisons (ARI, heatmaps, majority labels) should show the same populations.
- [ ] Check both final objects have 115,221 cells.
- [ ] Visually compare the key UMAP figures with the manuscript.
- [ ] Fix the Stage 2 README: it says to give the job 28 CPUs, but `workers: 28` has no effect. `Seurat_sample_based.Rmd:27` creates `bpp` and neither Rmd uses it. The same line is the only use of `cfg$seed`, and neither Rmd calls `set.seed()`, so results rely on each function's default seed. Decide whether to note this.

### Supplementary inferCNV (env `infercnv`, `run.sh infercnv`)
- [ ] Run one sample first to check time and memory (set `samples:` in a custom config), then all samples, one per HPC job.
- [ ] Same chromosome-arm gains/losses in malignant cells, and none in the reference cells. Subcluster boundaries and HMM calls will differ: no seed is set, as in the original run.

### Stage 3: malignant / non-malignant (env `downstream`, `run.sh stage3`)
- [ ] Write a Spartan Slurm script, based on `snrnaseq/stage2_seurat_simspec/stage2_spartan.slurm`.
- [ ] Run from the deposited Stage 2 annotated object and `tuft.snv.df.csv`. This doesn't depend on the Stage 2 rerun, so it can start alongside those checks.
- [ ] `STS_Malignant.Rmd` should find 6 clusters at resolution 0.1 (it stops otherwise).
- [ ] Cross-tabulate `Lv.1.Anno`, `Lv.2.Anno` and `Tuft.persistent` in `sts.nonmalignant.RDS` against the original object per cell. They are assigned by cluster number, so renumbered clusters would mislabel cells.
- [ ] Compare Extended Data Fig. 1C–E and 4A/C/G/H, and Supplementary Table 3, with the manuscript.

## 3. Spatial (Python): Stage 1 added, Stages 2 and 3 waiting on inputs
- [x] Add the Stage 1 notebooks under `spatial/stage1/` (one per sample, plus the robustness summary).
- [ ] Add the Stage 2 and Stage 3 notebooks and any helper `.py` files under `spatial/`.
- [x] Commit the env records under `spatial/environment/`: `requirements_as_used.txt`, `packages_with_locations.tsv`, `conda_export.yml`, `conda_explicit.txt`, `conda_revisions.txt`, `runtime_info.json`, `system.txt` and `kernels.txt`.
- [x] Decide which env record is correct: `spatial/environment/requirements_as_used.txt`, the versions actually loaded (scanpy 1.9.5 and squidpy 1.3.1, from `~/.local`).
- [x] Check the imported versions of the packages with two copies inside the conda env: 8 of 10 differ from `requirements_as_used.txt`; see the corrections in `spatial/README.md`.
- [ ] When the Stage 3 notebooks arrive, search them and their helper files for s3fs, aiobotocore, botocore and `s3://`. The Stage 1 and Stage 2 notebooks' code has none (Stage 2 has no helper files), and the analyst does not recall using Amazon S3. If nothing needs them, leave these three out: they probably conflict with the imported fsspec 2023.10.0 and urllib3 2.1.0, so the env may not solve with them.
- [ ] Deposit the 16 processed `.h5ad` files (they also hold the PCA results that Stage 1 reads), and record their DOI.
- [ ] Write `envs/spatial.yml`, using conda-forge/bioconda only (no `defaults`):
  - pin the analysis packages (scanpy, squidpy, anndata, …) to `requirements_as_used.txt` with the corrections in `spatial/README.md`, leaving out muon and mofapy2 (not used);
  - leave low-level libraries unpinned;
  - add pip-only packages under `pip:`.
- [ ] Lock it with `conda-lock` (see README, "Updating an env"), and add it to the `Dockerfile`, `.dockerignore` (an allowlist) and a `spatial` entry in `run.sh` (papermill or `jupyter nbconvert --execute`).
- [ ] Check whether any Stage 3 notebook needs a GPU (torch / scvi-tools are in the env). Stages 1 and 2 do not; Stage 2 runs in 64 GB.
- [x] Stage 2: notebook added under `spatial/stage2/`. Niches match the original for 99.9994% of cells (about 18 of 2,930,241 differ); all 15 names match.
- [ ] Stage 2: restart the kernel and run all cells, so the figures come from the same run as the check (the figure cells ran in a different session).
- [ ] Stage 2: deposit the original niche labels (sample, cell ID, label, niche) so reviewers can run the check, and point `ORIGINAL_COMBINED` (or a smaller labels file) at it.
- [ ] Stage 2: save the K selection results (K = 8–25) once as a TSV, so the choice of K = 15 has evidence in the repository.
- [ ] Stage 2: fill in the manuscript panel for each figure in `spatial/stage2/README.md`.

## 3b. Spatial proteomics (MIBI): record only, waiting on the collaborating team
- [ ] Get answers to the questions emailed to the team, then update `spatial_proteomics/`. `Fig2_efg_CellNeighbourhood.R` does not run as written: it joins on a `cell.id` column that is not there, and it is unclear whether clustering used all cells or excluded "Other". `ExtFig6f_boxplots_cell_distance.R` does not load dplyr or ggplot2 and does not define `output_folder`.
- [ ] Get `sessionInfo()` for the scripts and add the versions to the README.
- [x] Deposit `spe.rds` and `celltype_classifier_corrected.csv` on Zenodo: 10.5281/zenodo.23996821.
- [ ] Add the team's Docker container for upstream image processing and QC, or a link to it.
- [ ] Agree how to credit the team, and get permission to publish the code.

## 4. Finish moving the downstream commit (d404957) to the single image

Done: `stage3_infercnv/` replaced by `supplementary_infercnv/` (env `infercnv`, no seed, as in the original run); Stage 3 has its own env `downstream` (`envs/downstream.yml` + lock, GitHub packages in `envs/post_install_downstream.R`); both run through `run.sh` and are checked in the CI smoke test; the per-stage Dockerfiles and `install_packages.R` are deleted.

- [x] **Build the image with the `downstream` env.** `v0.1.2`: treeio 1.25.0.001 installed and every package attached, for the Stage 3 package list.
- [x] **Rebuild with the Stage 4 additions.** `v0.2.0`: treeio 1.25.0.001 and the new packages attached, at the expected versions.
- [x] **Keep one `sample_map.csv`.** The Stage 0 copy is removed, and its README points at `shared/`.

### Stage 4: reclustering (env `downstream`, `run.sh stage4`)
- [ ] Cross-tabulate `Lv.2.Anno` in each saved object against the original objects per cell. They are assigned by cluster number.
- [ ] Compare the figures and Supplementary Tables 4–7 with the manuscript.

### Stage 5: CellChat (env `cellchat`, `run.sh stage5`)
- [x] Check the build: `post_install_cellchat.R` compiled in `v0.2.0`, and CellChat 2.1.2, dplyr 1.2.1 and NMF 0.27 attached.

### Supplementary QC (`snrnaseq/supplementary_qc/`, record only)
- [ ] Add the three CSVs to Supplementary Table 1, from the rerun of the tidied file, each with a note on what it covers (see the folder README).

## 5. Before submission
- [x] Post-QC object and `tuft.snv.df.csv` deposited: 10.5281/zenodo.23933322.
- [ ] Deposit on Zenodo, and replace every remaining **DOI_TBD**: the annotated Stage 2 object, `sts.nonmalignant.RDS` (Stage 3 output, input to Stage 4) and `sts.simspec_css.sample.sct_final.RDS` (Stage 4 output, input to Stage 5).
- [ ] Tag a release (e.g. `v1.0`) and archive the repo on Zenodo for a citable DOI.
- [ ] Copy `sessionInfo/*.txt` out of the final image and commit them next to the originals:
      `docker run --rm --entrypoint cat pdac-snrnaseq:1.0 /pipeline/sessionInfo/snrnaseq.txt`
- [ ] Add a short "Reproducibility" paragraph to the methods: one image, conda lock files, R 4.3, the known version differences (listed in each stage README).
