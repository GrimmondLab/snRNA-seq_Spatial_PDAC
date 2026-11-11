# Spatial analysis (Python)

Python analysis of the spatial (Xenium) data, from 16 samples of 8 patients in the PURPLE registry, a different cohort from the snRNA-seq samples. This part is being set up: the notebooks are in `stage1/`, `stage2/` and `stage3/`, each with its own README. The data are on GEO: [GSE282154](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282154).

Each stage follows the same pattern as the snRNA-seq stages in `../snrnaseq/`: its own folder, with a README listing inputs, figures and the check against the original. Still to add: a master script per stage that runs the notebooks in order with papermill, a `config.yml` with container paths, one conda env for all spatial stages in `../envs/` (in the same Docker image), and a `run.sh` entry per stage.

**Running with papermill.** In every notebook, the folders and input files are in one cell tagged `parameters`, holding only plain path settings. The paths built from them (per-sample folders, `FIGURE_DIR` and so on) are in the next cell, so values papermill injects carry through. For example:

```bash
papermill stage3_malignant_TIL.ipynb out.ipynb -k xenium.squidpy \
  -p STAGE1_DIR /output/spatial/stage1 -p OUTPUT_DIR /output/spatial/stage3/malignant_TIL -p ARCHIVED_DIR None
```

`stage3_tuft.ipynb` reads `TUFT_INPUT_DIR = "tuft_inputs"`, relative to `stage3/`: run it with `--cwd` set to `stage3/`, or pass an absolute path.

## Input data

All raw data are on GEO: [GSE282154](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282154). Downstream analyses import two Xenium output files per sample:

| File | Contents |
|---|---|
| `cell_feature_matrix.h5` | Counts per cell and gene |
| `cells.csv` | Per-cell table, including the centroids `x_centroid` and `y_centroid` |

They are loaded as follows:

```python
adata = sc.read_10x_h5("cell_feature_matrix.h5")
df = pd.read_csv("cells.csv")
df.set_index(adata.obs_names, inplace=True)
adata.obs = df.copy()
adata.obsm["spatial"] = adata.obs[["x_centroid", "y_centroid"]].copy().to_numpy()
```

**Folder layout.** The notebooks expect the two files of each sample in a folder named after the sample, under `RAW_DATA_DIR` (for example `RAW_DATA_DIR/MH107_314/cell_feature_matrix.h5`). The table maps each GEO sample to its folder. The sample names use `MH`; some records use `MHP` for the same patient (e.g. MHP099).

| GEO sample | GEO title | Xenium slide and region | Patient | Folder (sample name in the notebooks) |
|---|---|---|---|---|
| GSM8636953 | PDAC_untreated_Xenium_1 | 0010614_Region_1 | MH065 | `MH065_314` |
| GSM8636954 | PDAC_untreated_Xenium_2 | 0010614_Region_2 | MH099 | `MH099_314` |
| GSM8636955 | PDAC_untreated_Xenium_3 | 0010614_Region_3 | MH097 | `MH097_314` |
| GSM8636956 | PDAC_untreated_Xenium_4 | 0010614_Region_4 | MH096 | `MH096_314` |
| GSM8636957 | PDAC_untreated_Xenium_5 | 0010617_Region_1 | MH104 | `MH104_314` |
| GSM8636958 | PDAC_untreated_Xenium_6 | 0010617_Region_2 | MH107 | `MH107_314` |
| GSM8636959 | PDAC_untreated_Xenium_7 | 0010617_Region_3 | MH106 | `MH106_314` |
| GSM8636960 | PDAC_untreated_Xenium_8 | 0010617_Region_4 | MH074 | `MH074_314` |
| GSM9285470 | PDAC_untreated_Xenium_480_1 | 0027518 | MH074 | `MH074_480` |
| GSM9285471 | PDAC_untreated_Xenium_480_2 | 0027518 | MH104 | `MH104_480` |
| GSM9285472 | PDAC_untreated_Xenium_480_3 | 0027518 | MH106 | `MH106_480` |
| GSM9285473 | PDAC_untreated_Xenium_480_4 | 0027518 | MH107 | `MH107_480` |
| GSM9285474 | PDAC_untreated_Xenium_480_5 | 0027721 | MH065 | `MH065_480` |
| GSM9285475 | PDAC_untreated_Xenium_480_6 | 0027721 | MH096 | `MH096_480` |
| GSM9285476 | PDAC_untreated_Xenium_480_7 | 0027721 | MH097 | `MH097_480` |
| GSM9285477 | PDAC_untreated_Xenium_480_8 | 0027721 | MH099 | `MH099_480` |

For the 480-gene panel, the slide is the Xenium slide in the raw output folder name (`output-XETG00115__<slide>__<slide>-<patient>__20250117__002027`).

The four TNBC sections (GEO [GSE281886](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE281886)) go under `TNBC_RAW_DIR`. The notebook folder numbers come from the original analysis and differ from the GEO numbers:

| GEO sample | GEO title | Xenium slide and section | Subject ID | Folder (name in the notebooks) |
|---|---|---|---|---|
| GSM8631780 | Breast_TNBC_untreated_Xenium_1 | 0010466, bottom | 3946 | `TNBC_2` |
| GSM8631781 | Breast_TNBC_untreated_Xenium_2 | 0010544, bottom | 3962 | `TNBC_4` |
| GSM8631782 | Breast_TNBC_untreated_Xenium_3 | 0010544, top | 4497-1 | `TNBC_3` |
| GSM8631783 | Breast_TNBC_untreated_Xenium_4 | 0010466, top | 4754 | `TNBC_1` |

## Deposits

Besides the GEO files, the notebooks need only the files below.

| Files | Used by | Where |
|---|---|---|
| `cell_feature_matrix.h5` and `cells.csv`, for each of the 16 samples | Stage 1; Stage 3 TIL, Tuft and TLS regions | GEO [GSE282154](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282154) |
| Raw Xenium output (`cell_feature_matrix.h5` and `cells.csv`) of the four TNBC sections | `stage3/stage3_TLS_regions.ipynb`: the TNBC TLS | GEO [GSE281886](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE281886) |
| The 16 processed `.h5ad` files, in two archives: `Xenium_480.tar` and `Xenium_314.tar` | Stage 1: saved PCA, UMAP and kept cells. Extract both into `SAVED_OBJECT_DIR` and keep the file names: each Stage 1 notebook reads its file by the name in the archive | Zenodo [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322) |
| `MH096_480_anno.csv.gz` and `MH099_480_umap.csv.gz` | `stage3/stage3_tuft.ipynb`: the saved MH096_480 clusters and MH099_480 UMAP | This repository, `stage3/tuft_inputs/` |

Stages 2 and 3 otherwise start from the Stage 1 outputs, which reproduce exactly.

**Original objects used for the checks are not deposited.** Each notebook ends with a check against the original objects (the Stage 1 label tables, the original combined niche object, and the original Stage 3 subset and region objects). These checks were run, and their results are recorded in the stage READMEs and the saved notebook outputs: all matched. Without the original objects, the checks are skipped and the notebooks still run.

## Stages

| Stage | Analysis | Starts from | Status |
|---|---|---|---|
| 1 | Sample processing, cell annotation by gene scoring, neighbourhood enrichment | GEO files, with PCA results or retained cells read from the 16 processed `.h5ad` files | Notebooks in `stage1/` |
| 2 | Niche analysis across all 16 samples together: K-means (K = 15) of cells by the composition of their neighbours within 50 µm, using the Stage 1 labels (`cell_class_threshold`). See `stage2/README.md` | The 16 final Stage 1 objects | Notebook in `stage2/` |
| 3 | Malignant cells next to and away from TIL-rich areas, the TIL regions themselves, Tuft cells, TLS in PDAC and TNBC, and malignant cells in a PanIN-like and a PDAC region of MH097_480. See `stage3/README.md` | The final Stage 1 objects; the TIL, Tuft and TLS regions are cropped from the raw Xenium output | Notebooks in `stage3/` |

The workflow was rerun with the archived PCA results or retained cells because the environment has changed since the original objects were made. Most analyses do not use PCA or clustering; some filter cells by cluster.

## Environment

`environment/` holds the records of the conda environment the analysis ran in (`xenium.squidpy`, Python 3.9.18, Ubuntu 22.04).

**Current environment, captured from the active kernel:**

| File | What it is |
|---|---|
| `requirements_as_used.txt` | The 395 Python packages in use, with exact versions. **The Docker image will be pinned to this file, with the corrections below** |
| `packages_with_locations.tsv` | Every installed copy of each package, where it is installed, and which copy is used |
| `conda_export.yml`, `conda_explicit.txt` | The conda environment as exported, by version and by download URL |
| `conda_revisions.txt` | History of conda changes to the environment since December 2023 |
| `runtime_info.json`, `system.txt`, `kernels.txt` | Python path, thread and BLAS settings, operating system, CPU, and Jupyter kernels |

**Earlier records:**

| File | What it is |
|---|---|
| `environment.yml` | The packages requested when the environment was created (no versions, except `plotly_express==0.4.0`) |
| `environment_full.yml` | `conda env export`. Shows some packages at versions that were not the ones used (see below) |
| `requirements_pip.txt` | `pip freeze`. 73 lines point to local build paths (`@ file:///...`) and cannot be installed as written |

**Two install locations.** The environment loads packages from `~/.local/lib/python3.9/site-packages` (130 of the 395) as well as from the conda env, and `~/.local` comes first on the Python path. Where a package is in both, the `~/.local` copy is used and `conda_export.yml` and `environment_full.yml` still show the conda copy. This is why those files list scanpy 1.9.6 and squidpy 1.2.2, while the analyses used scanpy 1.9.5 and squidpy 1.3.1 (confirmed by the analyst), and it accounts for all 19 version differences between the two earlier records. The image has no `~/.local`, so the versions in `requirements_as_used.txt` will be installed together in one env.

**Corrections to `requirements_as_used.txt`.** Some packages have two sets of version metadata inside the conda env, so the file can list a version that is not the one imported. These were checked by importing each package and reading its `__version__`:

| Package | Listed | Imported (pinned in the image) |
|---|---|---|
| scikit-image | 0.20.0 | 0.22.0 |
| imageio | 2.33.0 | 2.31.5 |
| fsspec | 2022.11.0 | 2023.10.0 |
| psutil | 5.9.6 | 5.9.5 |
| PyWavelets | 1.5.0 | 1.4.1 |
| urllib3 | 1.26.18 | 2.1.0 |
| tblib | 3.0.0 | 2.0.0 |
| typing_extensions | 4.8.0 | 4.13.0 |

numpy (1.24.4) and tifffile (2023.8.12) were listed correctly. typing_extensions has no `__version__`: the imported module has `TypeIs`, added in 4.10, which rules out 4.8.0 and leaves the other installed copy, 4.13.0. The files in this folder are left as captured, so `packages_with_locations.tsv` also shows the listed versions above as used.

**Not included:** muon and mofapy2. They are installed in the environment but were not used in these analyses.

**To confirm when the Stage 2 and 3 notebooks are added:** s3fs, aiobotocore and botocore (Amazon S3 access). The Stage 1 notebooks' code does not use them, the analyst does not recall using them, and they probably conflict with the imported fsspec 2023.10.0 and urllib3 2.1.0. Leave them out if no notebook needs them.

**Differences from the original runs.** These records describe the environment as it is now, not as it was when the input objects were made. The notebooks will start from fixed, deposited input objects, so the earlier steps do not need to be rerun in this environment. `conda_revisions.txt` shows the conda changes made on 2026-01-06: anndata 0.10.3 to 0.10.8, array-api-compat 1.4 to 1.11.2, and the addition of muon, mudata, protobuf and mofapy2. Changes to `~/.local` are not recorded there.

**Channel problem:** the conda records come from an env built partly from Anaconda's `defaults` channel (84 of the packages in `conda_explicit.txt`). Many of those exact pins (e.g. `glib=2.69.1`, `mkl`, `mysql=5.7.24`, `ld_impl_linux-64=2.38`) exist only there, so they do not solve on conda-forge/bioconda. The new env should pin the analysis packages from `requirements_as_used.txt`, take low-level libraries from conda-forge, and be locked with conda-lock like the R envs.

## Still needed

- The DOIs of the deposits above
