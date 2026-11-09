# Spatial analysis (Python)

Python analysis of the spatial (Xenium) data, from 16 samples of 8 patients in the PURPLE registry, a different cohort from the snRNA-seq samples. This part is being set up: the Stage 1 notebooks are in `stage1/` (see its README), and Stages 2 and 3 have not been added yet. The data are on GEO: [GSE282154](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282154).

Each stage will follow the same pattern as the snRNA-seq stages in `../snrnaseq/`: its own folder, a master script that runs the notebooks in order (with papermill), and a `config.yml` with container paths. Stage 1 has its own folder but not the rest yet: its notebooks are run one at a time, with the folders set in each parameters cell. The Python env will be added to `../envs/` as a new conda env in the same Docker image, with a `run.sh` entry per stage.

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

## Stages

| Stage | Analysis | Starts from | Status |
|---|---|---|---|
| 1 | Sample processing, cell annotation by gene scoring, neighbourhood enrichment | GEO files, with PCA results or retained cells read from the 16 processed `.h5ad` files | Notebooks in `stage1/` |
| 2 | Niche analysis: clustering cells by neighbourhood composition, using the Stage 1 gene-scoring labels | The 16 processed `.h5ad` files | Planned |
| 3 | Focused analysis of specific regions, such as TLS and Tuft-containing regions | To be confirmed | Planned |

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

- The Stage 2 and 3 notebooks (`.ipynb`) and any helper `.py` files they import
- The run order within those stages, and which notebook's output feeds which
- Where the 16 processed `.h5ad` files are deposited
- Which notebooks produce which manuscript figure panels
- Whether any Stage 2 or 3 step needs a GPU (the environment includes torch and scvi-tools; the Stage 1 notebooks' code uses neither)
