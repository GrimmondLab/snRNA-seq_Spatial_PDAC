# TODO

Status on 2026-11-18: every snRNA-seq stage (1–5) and every spatial stage (1–3) has run in the v1.0.0 `.sif` on Spartan, and the results are compared with the manuscript in each stage README. inferCNV has not run in the image. Fixes made during those runs were mounted with `CODE_DIR`/`SHARED_DIR`; they are committed, and the `v1.0.0` tag now points at the commit that has them (70e911d).

Section 0 lists what is left before submission. The other sections keep the history and the items that can wait until review.

## 0. Before submission

Zenodo record 10.5281/zenodo.23933322 (snRNA-seq and Xenium). Add files before publishing: a file added afterwards needs a new version of the record.
- [x] `Xenium_314.tar` uploaded (2026-11-18, md5 25f86f3e61d23400894b8c54c5e3d10b); both archives' MD5s are in the checksum table in `README.md` ("Data"). File names are listed flat, no subfolder, and written into each Stage 1 notebook's `SAVED_OBJECT` line.
- [x] `stage2_niche_labels_original.csv.gz` uploaded (2026-11-18, 27 MB, md5 a327809f642130939941a9bfdb69e8d7), as an optional check against the original niches; MD5 in the checksum table, and the READMEs and `stage2_spartan.slurm` point to it.
- [x] `infercnv_ICGC_0103_P2215.out.tar` uploaded (2026-11-18, md5 69532608c49ddb487ec2a2fb92b4a328), the record behind the 84 excluded cells; size (1.21 GB) and MD5 in the checksum table, DOI in `snrnaseq/supplementary_infercnv/README.md`. `P2221.lv2anno.out` (Extended Data Fig. 4F) not deposited.
- [x] Record published (2026-11-18), files embargoed until 2026-12-04. Checked: 10.5281/zenodo.23933322 is the concept DOI and opens the record (version DOI 10.5281/zenodo.23933323); every snRNA-seq and Xenium link in the repository uses 23933322.
- [x] **MIBI record re-deposited (2026-11-19):** [10.5281/zenodo.24360405](https://doi.org/10.5281/zenodo.24360405), open. Files: `spe.rds` (md5 `598e75d349e9aca23fcb8a5eadbdee6b`) and `celltype_classifier_corrected_min_patient_info.csv` (md5 `54f7797d054457117a1fea48c9223261`). It replaces 10.5281/zenodo.23996821, which Zenodo deleted on 2026-11-11 (reason "personal-data"). Links updated in `README.md`, `spatial_proteomics/mibi/README.md` and `CLAUDE.md`.

Image and code
- [ ] Check the image built from the current `v1.0.0` tag: run one short stage (e.g. `spatial3`, 4 min) without `CODE_DIR`/`SHARED_DIR`, so the committed fixes are tested from the image itself. The `matrixplot_TLS_*` files listed in section 3 should appear.
- [ ] Make the GHCR package public (package settings → visibility); the repo is private, so the package is too. Otherwise reviewers need a PAT with `read:packages`.
- [ ] Cite the image by digest (`ghcr.io/...@sha256:...`) in the README and manuscript, not only `:1.0.0`: the tag has been moved once, a digest cannot be.
- [ ] Copy `sessionInfo/*.txt` out of the final image and commit them next to the originals:
      `docker run --rm --entrypoint cat pdac-snrnaseq:1.0 /pipeline/sessionInfo/snrnaseq.txt`
- [ ] Make the GitHub repo public (or give reviewers access), and archive the release on Zenodo for a citable code DOI. Turn on the GitHub–Zenodo integration first: it archives releases made after it is on.

Data on GEO
- [ ] When GSE282154 is public (30 November 2026), check it has `cell_feature_matrix.h5` and `cells.csv` for all 16 samples.
- [ ] Check the TNBC sections (GSE281886) have `cell_feature_matrix.h5` and `cells.csv` for all four once public.

Manuscript
- [ ] Add the "Container" paragraph to the methods (drafted 2026-11-18: one image, one conda env per group with lock files, Docker or Apptainer, data mounted at run time, `run.sh <stage>`). Note that inferCNV uses Seurat 5.1.0 and Bioconductor 3.18; the other R envs use Seurat 4.3.0 and Bioconductor 3.17.
- [ ] Add the three CSVs to Supplementary Table 1, from the rerun of the tidied file, each with a note on what it covers (see `snrnaseq/supplementary_qc/README.md`).

MIBI (section 3b)
- [x] Permission to publish the team's code, and credit, agreed (2026-11-18). The other open items in section 3b (questions, `sessionInfo()`, their container) are wanted but don't block submission.

Reviewer points 3.1–4: MIBI and OPAL containers and documentation (started 2026-11-20)
- [x] Split `spatial_proteomics/` into `mibi/` (the existing files, moved) and `opal/`, with an overview README linking the WEHI pipelines. Added container, parameter and reproduce sections to `mibi/README.md`, and `opal/README.md` (panels, figures, software, settings) with *(TBD)* slots for the WEHI details. Top-level `README.md` and `CLAUDE.md` updated.
- [x] Added `spatial_proteomics/opal/panel1_tuft_PVR_counts.csv` (2026-11-20) from the team's sheet `Panel 1_data.xlsx`: 32 samples, 30 analysed, percentages only (clinical columns left out).
- [x] Count checked (2026-11-20): 27 of 30 analysed samples have POU2F3+ PVR+ cells (0% in 210, 2189, 2603); 1862 and 2328 not analysed (highlighted in the sheet). Matches the manuscript (27/30).
- [x] Kept `Panel 1_data.xlsx` out of the repository (moved to the folder above it, 2026-11-20): it has survival and grade per patient, an author name in its file properties and a personal name in its notes.
- [ ] Confirm the sample IDs in the CSV match those used in the manuscript, and what the percentages are of (all cells or CK+ cells).
- [ ] From the WEHI team, fill in the *(TBD)* slots:
  - container DOIs and image digests: `sp_segment`, `sp_celltype_train`/`apply`, the MIBI R analysis, QuPath
  - versions (release tag or commit) of the three pipelines used for this manuscript, and the Nextflow version
  - the params file for `sp_segment` and the options file for `sp_celltype_train`, to commit under `mibi/`; the trained model and training table, deposited
  - how `spe.rds` was built (step 2), or a link to their documentation
  - OPAL: acquisition settings, Phenochart annotations, inForm spectral library and project file, stitching and cell detection settings, POU2F3/PVR thresholds, display settings, and which samples are in Fig. 3H, 6H and Ext. Data Fig. 9J
  - accessions for the raw MIBI images and the OPAL images (check headers and file names for patient details before upload)
- [ ] Optional: ask the WEHI team to link this repository from each pipeline README as a worked example with public data (reviewer 3.1).
- [ ] Write the response to points 3.1, 3.2, 3.3 and 4 (draft: `../reviewer_response_spatial_proteomics.md`, outside the repository).

## 1. Build and move the image to the HPC

- [x] Publish a first image: `v0.1.2` built, passed the smoke test and pushed `:0.1.2` and `:0.1.2-sif` (so the org allows Actions to publish packages).
- [x] Push a tag with Stages 4 and 5: `v0.2.0` built, passed the smoke test and pushed `:0.2.0`.
- [x] Publish a `.sif` with Stages 4 and 5: `v0.2.2` pushed `:0.2.2` and `:0.2.2-sif`, and the `.sif` matches the Docker image.
- [x] Publish an image with the `spatial` env: `v0.3.0` (run 43156695593, 53 min) built, passed the smoke test and pushed `:0.3.0` and `:0.3.0-sif`; the `.sif` matches the Docker image. Sizes: Docker 13.7 GB (`v0.2.3`: 11.5 GB), `.sif` 2.7 GB (2.1 GB).
- [ ] Pass a `GITHUB_PAT` to the Docker build as a BuildKit secret. `install_github` runs unauthenticated, so a rebuild can fail on GitHub's rate limit (`v0.2.1` did, and a rerun passed).
- [x] Pull the prebuilt `.sif` on the HPC and check that the runner starts (it should print usage):
      ```bash
      apptainer pull pdac-snrnaseq.sif oras://ghcr.io/grimmondlab/snrna-seq_spatial_pdac:0.3.0-sif
      apptainer run pdac-snrnaseq.sif
      ```
      Private package: run `apptainer registry login -u <github-user> oras://ghcr.io` first, with a PAT that has `read:packages`.
      Or build locally on a linux/amd64 machine: `docker build --platform linux/amd64 -t pdac-snrnaseq:1.0 .`
- [x] Check the read-only `.sif` works for a real stage. On Spartan, Stage 1 ran with `--cleanenv --no-home --env TMPDIR=/output/tmp` until it ran out of memory, with no file or permission errors.
- [x] Tag `v1.0.0` to publish `:1.0.0` and `:1.0.0-sif`. All the Spartan runs below used it; the tag was moved to 70e911d on 2026-11-18 to include their fixes. Digest citation: section 0.

## 1b. Run on AWS Batch (planned, not needed for submission)

The plan is Batch on EC2, with data in S3.

- [ ] Choose the AWS account and region, and check the data-use terms allow it: the data are patient-derived, and the analysis objects are not deposited yet.
- [ ] Run full Stage 1 once on a single EC2 instance (size from the Spartan peak; `r6i.4xlarge` is probably too small, Docker, `aws s3 sync`, `config_local.yml`, mounting `samples/` only). This gives the peak memory and runtime to size the jobs, and tests reproducibility.
- [ ] Create the S3 bucket: encrypted, public access blocked, reached through a VPC endpoint.
- [ ] Mirror the image to ECR in the same region (13.7 GB uncompressed; the GHCR package is private).
- [ ] Add a thin wrapper image: download inputs to `/data`, call `run.sh`, upload `/output` (also on failure). The image has no S3 tools, and the analysis image stays unchanged.
- [ ] Write the CDK stack (TypeScript, as in `nemo-infra`): Batch on memory-optimised x86 EC2 scaling to zero, one job definition per stage, launch template with a large EBS volume. Use on-demand, not Spot: stages have no checkpoints. A 128 GB job won't fit on a 128 GiB instance, so Stages 2–5 probably need `r6i.8xlarge` at least; size them from measured peaks (Spartan: Stage 1 258 GB, Stage 2 108 GB).
- [ ] Keep the `workers` values from each stage's config: parallel settings can change results.

## 2. Rerun each stage and compare with the originals

### Stage 1 (env `snrnaseq`)
- [x] Run on the original CellBender folders (`run.sh stage1 config_local.yml`): Spartan job 34375352, image `0.1.2-sif`, finished.
- [ ] Optional: run on the GEO input (`run.sh stage1`). It reads the same `_cellbender_filtered.h5` files, renamed, so it should match the local-mode run; it checks that the GEO files and `geo_samples.csv` load correctly.
- [x] **Find the real memory need.** On Spartan (`sapphire`, 12 CPUs), OOM killed at 64G and at 192G, in `discard_lowq_cells` and `variance_modelling`. With 400G it finished: peak 258.32 GB, 1h37, about 1.9 cores on average.
- [x] Stage 1 README: memory corrected (300 GB in the examples), and the Spartan run and the comparison with the original added (2026-11-13). The run used image `0.1.2-sif` and the original CellBender `.h5` files (local mode).
- [ ] A coworker's run in RStudio on a 64G instance finished, which doesn't fit the peak above. Only worth chasing if 400G jobs are hard to get, or for AWS sizing: check how it differed (run in pieces, `workers`, swap), whether Transparent Huge Pages is a factor, and whether forked workers inflate Slurm's figure.
- [ ] Recheck the 128 GB figures for Stages 3–5, which have not been tested at full scale. Stage 2 fits (see below).
- [x] 30 samples loaded; scDblFinder in the image (Apptainer): 129,134 singlets / 6,848 doublets (129,115 / 6,867 in the earlier rerun outside the image).
- [x] Final object in the image (Apptainer): 26,774 genes × 115,301 cells, the same size as the August 2024 rerun (original: 26,788 × 115,221). Exact equality is not expected: worker seeds were not set originally, and xgboost is now 1.7.6 (originally 1.7.5.1).

### Stage 2 (env `snrnaseq`): highest risk
Now runs on R 4.3 with Matrix 1.5-4.1, instead of R 4.4.0 with Matrix 1.7-5.
- [x] Run from the deposited post-QC object (`run.sh stage2`): PCA, UMAP and clusters shift slightly, and the cluster numbers no longer match the original label mappings. Finished on Spartan (job 34425917, `stage2_spartan.slurm`, 12 CPUs, 400G): peak 108.23 GB, 1h48, about 1.4 cores on average. Record the image version. About 150G is enough next time.
- [x] Read `cell_class` and `simspec_cell_class` from the deposited annotated object by cell ID (`reference_object` in `config.yml`); the original mappings are kept as a record; `original/` holds the files before this change.
- [x] Rerun Stage 2 with these changes, and check the reports: the original-mapping check in the integration step should be 100%, and the rerun-cluster comparisons (ARI, heatmaps, majority labels) should show the same populations. Run in v1.0.0 on Spartan (job 35178950, 2026-11-17): label mapping works as intended. 2 h, peak 108.27 GB, 11.4% of 12 CPUs; `stage2_spartan.slurm` now asks for 4 CPUs, 160G, 8 h.
- [x] Check both final objects have 115,221 cells (2026-11-17: `sts.seurat.RDS` and `sts.simspec_css.sample.sct.RDS` both 115,221).
- [x] (2026-11-17: rerun layout differs, same populations each form their own group; deposited UMAP identical to the manuscript.) Visually compare the key UMAP figures with the manuscript. The integration report now shows the rerun UMAP next to the deposited one (chunk `umap-rerun-vs-deposited`), both coloured by `simspec_cell_class`; `Seurat_sample_based.Rmd` saves the deposited coordinates in `reference_labels.RDS` for it.
- [x] Fix the Stage 2 README: it says to give the job 28 CPUs, but `workers: 28` has no effect (fixed 2026-11-17). `Seurat_sample_based.Rmd:27` creates `bpp` and neither Rmd uses it. The same line is the only use of `cfg$seed`, and neither Rmd calls `set.seed()`, so results rely on each function's default seed. Decide whether to note this.

### Supplementary inferCNV (env `infercnv`, `run.sh infercnv`)
- [ ] Run one sample first to check time and memory (set `samples:` in a custom config), then all samples, one per HPC job.
- [ ] Same chromosome-arm gains/losses in malignant cells, and none in the reference cells. Subcluster boundaries and HMM calls will differ: no seed is set, as in the original run.

### Stage 3: malignant / non-malignant (env `downstream`, `run.sh stage3`)
- [x] v1.0.0 rerun fixes (2026-11-17): `clustree` after a single resolution commented out (two places); KRAS join in `STS_nonMalignant_TuftADM.Rmd` stopped with `Column chr12_25245351_G is not found`, as the deposited metadata already has the KRAS columns and the join renamed them `.x`/`.y`. Existing KRAS columns are now dropped before the join. Rerun with `CODE_DIR`; committed, and in the commit `v1.0.0` now points at.
- [x] Write a Spartan Slurm script (`stage3_spartan.slurm`; Stage 4 has `stage4_spartan.slurm`), with an optional `CODE_DIR` to run code fixed after v1.0.0.
- [x] Run from the deposited Stage 2 annotated object and `tuft.snv.df.csv`. Completed in v1.0.0 with the fixed Rmds and `shared/` mounted (job 35233975, 2026-11-17): 42 min, peak 84.81 GB, about 1.1 of 4 CPUs. `stage3_spartan.slurm` now asks for 2 CPUs, 128G, 4 h.
- [x] `STS_Malignant.Rmd` should find 6 clusters at resolution 0.1 (it stops otherwise). Passed in the v1.0.0 run (the original clusters are read from the deposited object).
- [x] (Stage 3 done 2026-11-17: non-malignant `Lv.1.Anno` and `Lv.2.Anno` by cluster 100%; malignant rerun clusters ARI 0.544, 39.26%; tuft ARI 0.487. Stage 4 recorded under Stage 4.) After the first run with labels from the deposited object, check `label_agreement.tsv` in both output folders and record the agreement (ARI, % same label) in the "Rerun" column of the Stage 3 and Stage 4 READMEs ("Comparison with the original"), and fill in the Stage 3 "Result" line. Labels no longer depend on cluster numbers; the table shows how closely the rerun clusters reproduce them.
- [x] Compare Extended Data Fig. 1C–E and 4A/C/G/H, and Supplementary Table 3, with the manuscript. (2026-11-17: all match exactly.)

## 3. Spatial (Python): Stage 1 added, Stages 2 and 3 waiting on inputs
- [x] Add the Stage 1 notebooks under `spatial/stage1/` (one per sample, plus the robustness summary).
- [x] Add the Stage 2 notebooks under `spatial/stage2/`.
- [x] Stage 3: add `spatial/stage3/stage3_malignant_TIL.ipynb` (malignant cells near and far from TILs, three 480-gene samples; reproduces the original exactly). MH106_314's earlier DE analysis is not part of the final analysis and was removed.
- [ ] Stage 3: restart and run all of `stage3_malignant_TIL.ipynb`. Its saved outputs come from a run that still included MH106_314, and two cells ran out of order.
- [x] Stage 3: manuscript panels added to `spatial/stage3/README.md` (Fig. 5H, 5I; Extended Data Fig. 7F, 7G).
- [x] Stage 3: add `spatial/stage3/stage3_TIL_regions.ipynb` (four TIL regions, including MH106_314). Cells, labels and distances to T cells match the original exactly.
- [ ] Stage 3: give the manuscript panel for the MH107_480 immune marker dot plot (`dotplot_Marker_Immunregulatory.pdf`).
- [ ] Stage 3: restart and run all of `stage3_TIL_regions.ipynb`. The region-level labels were renamed `TIL_cell_class_threshold` after the run, so the saved outputs come from the code before the rename (results unchanged).
- [x] Stage 3: compare the figures with the published versions by eye (image run, v1.0.0: all match).
- [x] Stage 3: add `spatial/stage3/stage3_tuft.ipynb`. Tuft counts match, and the three re-analysed regions match the original objects (same cells, 100% same labels).
- [x] Stage 3: Tuft figures mapped to manuscript panels in `spatial/stage3/README.md`; three are marked not used.
- [ ] Stage 3: restart and run all of `stage3_tuft.ipynb`. The neighbour composition plot title was corrected after the run, so the saved figure still has the old title (data unchanged).
- [x] `spatial/stage3/tuft_inputs/`: `MH096_480_anno.csv.gz` (11,992 cells) and `MH099_480_umap.csv.gz` (827 cells) added; cell counts match the regions.
- [ ] Run `stage3_tuft.ipynb` once with the two tables, to test the code that reads them (it replaced reading the original objects).
- [x] Original objects used only for the checks are not deposited; the check results are recorded in the READMEs and saved outputs.
- [x] Map the GEO samples to the notebook folders: table in `spatial/README.md` ("Folder layout").
- [x] 480-gene GEO order confirmed: `_480_1` to `_8` are MH074, MH104, MH106, MH107 (slide 0027518), then MH065, MH096, MH097, MH099 (slide 0027721).
- [x] TNBC GSM IDs added (GSM8631780–GSM8631783). The GEO order (Xenium_1 to 4 = subjects 3946, 3962, 4497-1, 4754) is taken from the order of the identifier table; the folders follow the original analysis (`TNBC_1` = 4754, `TNBC_2` = 3946, `TNBC_3` = 4497, `TNBC_4` = 3962, as in the original paths).
- [x] Stage 3: add `stage3_TLS_regions.ipynb` and `stage3_TLS_figures.ipynb`. All 13 regions match the original objects (same cells, 100% same labels, z-scores identical).
- [x] Stage 3: add `stage3_MH097_PanIN.ipynb` (Fig. 4H). Same 3,472 cells, regions and pathway scores as the original subset.
- [ ] Stage 3 PanIN: give the panels, if any, for `MH097_PanIN_signalling.pdf` and `MH097_PanIN_signalling_2.pdf`, and add the one or two remaining plots. The notebook computes a UMAP but saves no UMAP figure.
- [x] Stage 3: TLS notebooks won't be rerun. Text outputs changed to `TRCs`; a note at the top of each says the saved plot images still show `Stromal_CCL19`.
- [ ] Stage 3: give the manuscript panels, if any, for the TLS figures listed as unlabelled in `spatial/stage3/README.md`. Extended Data Fig. 9E is now saved, and the second `Moran_#4.pdf` is now `Moran_#5.pdf`.
- [x] Stage 3 `stage3_TLS_figures.ipynb`: the TLS cytokine matrix plots for TLS_097_480_n3, TLS_096_480_n1 and TNBC_4 were drawn but not saved in the original; `save=` added (2026-11-17), so `matrixplot_TLS_097_480_n3.pdf`, `matrixplot_TLS_096_480_n1.pdf` and `matrixplot_TLS_cytokines_TNBC_4.pdf` are written from the next image build (check: section 0).
- [x] Stage 3: the *assumed* `color_map` and subsets in `stage3_TLS_figures.ipynb` are accepted: the extra regions show the same pattern as the published ones.
- [x] Stage 3: `Stromal_CCL19` renamed `TRCs` in `stage3_TIL_regions.ipynb` too; the check maps the original name. Its saved outputs come from before the rename (the restart-and-run-all item above covers it).
- [x] TNBC raw Xenium output: GEO GSE281886 (check once public: section 0).
- [x] Commit the env records under `spatial/environment/`: `requirements_as_used.txt`, `packages_with_locations.tsv`, `conda_export.yml`, `conda_explicit.txt`, `conda_revisions.txt`, `runtime_info.json`, `system.txt` and `kernels.txt`.
- [x] Decide which env record is correct: `spatial/environment/requirements_as_used.txt`, the versions actually loaded (scanpy 1.9.5 and squidpy 1.3.1, from `~/.local`).
- [x] Check the imported versions of the packages with two copies inside the conda env: 8 of 10 differ from `requirements_as_used.txt`; see the corrections in `spatial/README.md`.
- [x] Searched the code of all spatial notebooks for s3fs, aiobotocore, botocore and `s3://`: none uses them (and there are no helper `.py` files). Leave these three out of `envs/spatial.yml`.
- [x] Write `envs/spatial.yml` (conda-forge/bioconda only) and lock it (`envs/spatial-linux-64.lock`, 403 packages). squidpy 1.3.1 and spatialdata 0.2.5.post0 are not on conda: `envs/post_install_spatial.txt`, installed with `pip install --no-deps`. Nearest versions where the recorded one has no Python 3.9 conda build: pandas 2.2.3 (2.3.3), tqdm 4.67.1 (4.67.3), pooch 1.8.2 (1.9.0), xarray-spatial 0.4.0 (0.5.3). Built in `v0.3.0`.
- [x] The four version differences are recorded in the main `README.md` ("Environments"), with the spatial run instructions.
- [x] Spatial run instructions in `README.md` updated after the one-sample Stage 1 run with the `.sif`.
- [x] Spatial notebooks are papermill-ready: each has one cell tagged `parameters` with only the path settings; derived paths are in the next cell. Stage 1 output placeholder unified as `/path/to/stage1_output`.
- [x] papermill 2.5.0 and ipykernel 6.29.0 added to the spatial env.
- [x] Kernel `xenium.squidpy` registered inside the env in the `Dockerfile`; the CI smoke test checks it.
- [x] Spatial env added to the `Dockerfile` (lock, then `pip install --no-deps -r envs/post_install_spatial.txt`), `.dockerignore`, the CI smoke test and `run.sh` (`spatial1`, `spatial2`, `spatial3`). `spatial/run_notebooks.py` runs the notebooks listed in `spatial/stageN/config.yml` with papermill.
- [x] Build the image with the `spatial` env: `v0.3.0`. The env installed from the lock, squidpy and spatialdata installed with `--no-deps`, every package imported (`envs/session_info.py`), and the kernel `xenium.squidpy` is registered.
- [x] Run `spatial1` on one sample in the image with the read-only `.sif` (`v0.3.0`): MH065_314 reproduced the saved object exactly (labels 100%, gene-set scores and Nhood z-scores max difference 0). The recalculated PCA test gave different numbers from the earlier runs (kept 154,196 vs 154,105; same label 100% vs 99.12%; Nhood correlation 0.9996 vs 0.9991; ARI 0.6995), as expected for that environment-sensitive test. Recorded in `spatial/stage1/README.md`.
- [x] (Rerun with `CODE_DIR`, job 35233126: completed.) The first full `spatial1` run in v1.0.0 (2026-11-17) stopped at MH074_314: `Clusters differ from cluster_anno: ['30']`. Ten notebooks recomputed Leiden from the saved PCA; they now read the saved clusters, like the other six. Rerun with `CODE_DIR` set in `stage1_spartan.slurm`; include in the next image release.
- [x] Run `spatial1` on all 16 samples and the robustness summary in the image (2026-11-17: exact in all 16, 2,931,027 cells: labels 100%, gene-set scores and Nhood z-scores max difference 0; recalculated PCA test 98.32–100%, Nhood correlation ≥ 0.9995, recorded in the Stage 1 README; earlier-run tables kept). Completed in v1.0.0 (job 35233126, 2026-11-17): 46 min, peak 8.36 GB, about 1.1 of 8 CPUs; `stage1_spartan.slurm` now asks for 2 CPUs, 32G, 4 h. Stage 1 README and top-level table updated. Open: the summary tables (`stage1_robustness_table.tsv` and others) come from the earlier runs; decide whether to keep those or report the image run's recalculated PCA values.
- [ ] Optional: run one sample with Docker as well (only the `.sif` has been tested).
- [x] Run `spatial2` in the image (`spatial/stage2/stage2_spartan.slurm`, after Stage 1 with the same `OUTPUT_DIR`). 2026-11-17, v1.0.0, job 35237912: 8 min, peak 9.0 GB, about 1.3 CPUs; the script now asks for 2 CPUs, 32G, 2 h. `stage2_image_check.tsv`: same `cell_class_threshold` for all 2,930,241 cells; same niche as the original for 99.9994% (18 cells differ) and as the earlier rerun for 100%. The label files are git-ignored (`*.csv.gz`), so the script reads them from `REFERENCE_DIR`.
- [ ] Test `spatial/stage2/stage2_spartan.slurm` with `STAGE1_SOURCE=deposited` (Stage 2 from the 16 deposited processed objects, without Stage 1), in a new `OUTPUT_DIR`, with `REFERENCE_DIR` set. Expect the same niches as the run from the Stage 1 output (99.9994% vs the original, 100% vs the earlier rerun). If the object check reports something missing, the deposited objects lack a field the Stage 1 output has.
- [x] Run `spatial3` in the image (`spatial/stage3/stage3_spartan.slurm`, after Stages 1 and 2 with the same `OUTPUT_DIR`). 2026-11-17, v1.0.0, job 35240101: 4 min, peak 5.1 GB, about 1 CPU; the script now asks for 2 CPUs, 16G, 1 h. TNBC sections uploaded to `xenium_raw_tnbc/`. Every listed figure was written, including Extended Data Fig. 9E for the first time, and all match the published panels.
- [ ] Check whether any Stage 3 notebook needs a GPU (torch / scvi-tools are in the env). Stages 1 and 2 do not; Stage 2 runs in 64 GB.
- [x] Stage 2: notebook added under `spatial/stage2/`. Niches match the original for 99.9994% of cells (about 18 of 2,930,241 differ); all 15 names match.
- [ ] Stage 2: restart the kernel and run all cells, so the figures come from the same run as the check (the figure cells ran in a different session).
- [x] Stage 2: the original niche labels and combined object are not deposited; the check result is recorded in `spatial/stage2/README.md`.
- [ ] Stage 2: save the K selection results (K = 8–25) once as a TSV, so the choice of K = 15 has evidence in the repository.
- [ ] Stage 2: the niche figures feed Fig. 2A–D and Extended Data Fig. 3 (now in the README). Add the panel for each file if wanted.
- [x] Stage 2 `stage2_figures.ipynb`: removed the out-of-date "Other" count cell from the Fig. 1D section.
- [ ] Stage 2 `stage2_figures.ipynb`: optionally restart the kernel and run all cells; the last cell (list of saved figures) never ran.
- [x] Stage 2: Extended Data Fig. 2D comes only from `stage2_figures.ipynb`; the niche notebook makes Fig. 2A–D and Extended Data Fig. 3.
- [x] Stage 2 `stage2_neighbourhood_profiling.ipynb`: other tests for Fig. 4E were checked by the analyst; the repeated-measures ANOVA is kept.
- [x] Stage 2 `stage2_neighbourhood_profiling.ipynb`: Fig. 4F reproduces exactly (confirmed by the analyst); no assert added.
- [x] Stage 2 `stage2_neighbourhood_profiling.ipynb`: removed the comment by the SPP1 vs C1QC paired t-test that said the normality assumption holds.
- [x] Stage 2 `stage2_figures.ipynb`: Fig. 4B with `cell_class_threshold` reproduces the original plot (confirmed by the analyst).
- [x] Stage 2 `stage2_figures.ipynb`: figures first made from earlier objects compared with the published panels (by the analyst).

## 3b. Spatial proteomics (MIBI): waiting on the collaborating team (files now in `spatial_proteomics/mibi/`)
- [ ] Get answers to the questions emailed to the team, then update `spatial_proteomics/`. It is unclear whether the Fig. 2E–G clustering used all cells or excluded "Other".
- [x] Added the QC report (`QC_9.12.2025.html`), the cell–cell interaction report and script (Fig. 5G) and the interaction `sessionInfo()` to `spatial_proteomics/`, and described the QC, FOV filtering and interaction test in its README (2026-11-16).
- [ ] Get `sessionInfo()` for the cell neighbourhood (Fig. 2E–G) and distance (Extended Data Fig. 6F) scripts. The QC and interaction versions are in the README.
- [ ] Ask the team how `spe.rds` was built from the QC output: does it hold only the 29 FOVs kept by QC (54,463 cells) and the patient E Vimentin correction? Same question for the per-cell table (`celltype_classifier_corrected_min_patient_info.csv`).
- [x] Removed names from the received MIBI files (2026-11-16): author lines and notes in both HTML reports, the data file names in the QC code, a comment in `Fig2_efg_CellNeighbourhood.R`, and the internal HPC path in both `sessionInfo()` outputs (now `/path/to/R/`). Names inside the plot images were not checked.
- [x] Deposit `spe.rds` and the per-cell table on Zenodo: 10.5281/zenodo.24360405 (replaces the deleted 23996821; see section 0).
- [ ] Add the team's Docker container for upstream image processing and QC, or a link to it (now tracked in section 0, reviewer points 3.1–4).
- [x] Agree how to credit the team, and get permission to publish the code (agreed 2026-11-18).

## 4. Finish moving the downstream commit (d404957) to the single image

Done: `stage3_infercnv/` replaced by `supplementary_infercnv/` (env `infercnv`, no seed, as in the original run); Stage 3 has its own env `downstream` (`envs/downstream.yml` + lock, GitHub packages in `envs/post_install_downstream.R`); both run through `run.sh` and are checked in the CI smoke test; the per-stage Dockerfiles and `install_packages.R` are deleted.

- [x] **Build the image with the `downstream` env.** `v0.1.2`: treeio 1.25.0.001 installed and every package attached, for the Stage 3 package list.
- [x] **Rebuild with the Stage 4 additions.** `v0.2.0`: treeio 1.25.0.001 and the new packages attached, at the expected versions.
- [x] **Keep one `sample_map.csv`.** The Stage 0 copy is removed, and its README points at `shared/`.

- [x] The v1.0.0 run stopped in `STS_Malignant.Rmd` (2026-11-16) at a check that the RNA data slot equals the counts. The deposited object's RNA data slot is log-normalised (checked 2026-11-16), so the check is commented out; the ADM dot plots (Ext. Data Fig. 4A, 4H) use that slot as before.

### Stage 4: reclustering (env `downstream`, `run.sh stage4`)
- [x] Stage 4 ran to completion in v1.0.0 with the fixed Rmds and `shared/` mounted (job 35232665, 2026-11-17): 36 min, peak 42.73 GB, about 1 of 4 CPUs. `stage4_spartan.slurm` now asks for 2 CPUs, 64G, 4 h.
- [x] Include the Stage 3/4 Rmd and `shared/label_checks.R` fixes in the next image release: committed, and in the commit `v1.0.0` now points at.
- [x] The v1.0.0 rerun (job 35232233, 2026-11-17) stopped in `shared/label_checks.R`: `compare_labels()` failed when every cell agreed (100%), as the list of differing cells was empty. Fixed; the slurm scripts take `SHARED_DIR` to mount the fixed `shared/`. Include in the next image release.
- [x] The v1.0.0 run stopped in `STS_Lymphoid_TNK.Rmd` (2026-11-16): `Cannot find object SCT_snn_res.0.7`. The cells read from the final object lack Stage 3's cluster columns. Fixed in the Stage 3 and 4 Rmds (metadata columns removed through `@meta.data`, which skips missing ones); rerun with `CODE_DIR` set in the slurm script, and include the fix in the next image release.
- [x] (Rerun job 35233653, 2026-11-17: completed, 48 min, peak 42.79 GB; `Plotting/label_agreement.tsv` now 100% for both, ARI 1.) `Plotting.Rmd` rebuilds `Lv.2.Anno` with the 84 cells of sample 2215 as `PDAC`; the deposited object (and Stage 5, which drops `unassigned`) has them as `unassigned`, as `Lv.1.Anno` does. Added the `non.malig` line to the `Lv.2.Anno` step (2026-11-17); confirm 100% on the next Stage 4 run.
- [ ] After the first run with labels from the deposited object, check `label_agreement.tsv` in each output folder: `Plotting/` should show 100% for the rebuilt final `Lv.1.Anno` and `Lv.2.Anno` (2026-11-17: `Lv.1.Anno` 100%; `Lv.2.Anno` 99.93%, only the 84 cells of sample 2215 differ; after the fix, both 100%). Record the agreement of the rerun clusters in the Stage 4 README.
- [x] (2026-11-17: identical.) Compare Fig. 1C and Extended Data Fig. 5A–B (now on the stored UMAPs) with the published panels. Each Fig. 1C subset also has a rerun-vs-deposited panel (`fig-1c-*-rerun-vs-deposited`).
- [x] Compare the figures and Supplementary Tables 4–7 with the manuscript. (2026-11-17: Fig. 1B–C; Ext. Data Fig. 1A, 2A, 5A–B, 6A–C, 8A, 8C, 8E–G; Supp. Tables 4–7 all match exactly.)

### Stage 5: CellChat (env `cellchat`, `run.sh stage5`)
- [x] Check the build: `post_install_cellchat.R` compiled in `v0.2.0`, and CellChat 2.1.2, dplyr 1.2.1 and NMF 0.27 attached.
- [x] Run in the v1.0.0 `.sif` on Spartan (2026-11-16): every figure in `Cellchat.html` matches the published panels.
- [x] Resources measured with `seff` (job 35138147): 5 h 46 min, peak 65.7 GB, CPU efficiency 2.3%. `stage5_spartan.slurm` now asks for 96 GB and 12 h; README updated.

### Supplementary QC (`snrnaseq/supplementary_qc/`, record only)
- Moved to section 0 (Supplementary Table 1).

## 5. Deposits and release (open items moved to section 0)
- [x] Post-QC object and `tuft.snv.df.csv` deposited: 10.5281/zenodo.23933322.
- [x] Annotated Stage 2 object (`sts.simspec_css.sample.sct.RDS`) uploaded to 10.5281/zenodo.23933322. The DOI did not resolve on 2026-11-09 (doi.org returned 404); check the record is published.
- [x] Removed `sts.simspec_css.sample.sct.RDS` from the Zenodo record (2026-11-13). Checked on 2026-11-13: the new final object has the same cells, assays, reductions and columns, plus the 14 added ones; only `Lv.2.Anno` differs (the TAM rename). It already had `Lv.1.Anno`, `Lv.2.Anno` and `ICGC_ID`. Stages 2, 3, 4 and inferCNV now read the final object.
- [x] Rerun `snrnaseq/stage4_reclustering/add_labels_to_final_object.R` on the original objects (set the paths at the top) and deposit the object it writes as `sts.simspec_css.sample.sct_final.RDS`. The first run (2026-11-12) checked out (lymphoid 100%, TAM 84.58%, CAF 98.91% the same as the final `Lv.2.Anno`; every difference a renamed label), but showed that the final object says `TAMs_HLA+`, renamed by hand, where the manuscript and the code say `TAMs_MHC_II`. The script now renames it back; check that it prints "Renamed in Lv.2.Anno: 894 cells" and TAM 100%.
- [x] Stages 3 and 4 read their labels from the deposited final object by cell ID (`shared/label_checks.R`), keep each original cluster mapping as a `_by_cluster` column, report agreement in `label_agreement.tsv`, and plot Fig. 1C from the stored UMAPs. Stage 4 now reads the final object instead of `sts.nonmalignant.RDS`. Not run yet (2026-11-13): the image needs rebuilding.
- [x] Uploaded `sts.simspec_css.sample.sct_final.RDS` to 10.5281/zenodo.23933322 (2026-11-13; 8.77 GB, md5 5996b8bfd886974b46dc3d39cb6c5428). The record now holds 5 files, with checksums in `README.md` ("Data"). `sts.nonmalignant.RDS` no longer needs depositing: no stage reads it.
- [x] Extended Data Fig. 1B (sample 2992, PURPLE WGS) and 4F (patient 2221 by `Lv.2.Anno`) recorded in `snrnaseq/supplementary_infercnv/original/InferCNV_extended_data_figures.R`.
- [x] inferCNV heatmaps for 2992, 2215 and 2221 by `Lv.2.Anno` added to `snrnaseq/supplementary_infercnv/figures/` and shown in its README (the WGS plot is left out).
