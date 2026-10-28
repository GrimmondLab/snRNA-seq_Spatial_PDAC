# Spatial analysis (Python)

Python analysis of the spatial (Xenium) data. This part is being set up: the notebooks have not been added yet.

Each stage will follow the same pattern as the snRNA-seq stages in `../snrnaseq/`: its own folder, a master script that runs the notebooks in order (with papermill), a `config.yml` with container paths, a pinned environment, and a Dockerfile.

## Environment

`environment/` holds the records of the conda environment the analysis ran in (`xenium.squidpy`, Python 3.9.18):

| File | What it is |
|---|---|
| `environment.yml` | The packages requested when the environment was created (no versions, except `plotly_express==0.4.0`) |
| `environment_full.yml` | `conda env export` of the environment: every conda and pip package with its exact version |
| `requirements_pip.txt` | `pip freeze` output. 73 lines point to local build paths (`@ file:///...`) and cannot be installed as written |

**Open question:** the two full records disagree on 19 package versions, including scanpy (1.9.6 in `environment_full.yml`, 1.9.5 in `requirements_pip.txt`) and squidpy (1.2.2 vs 1.3.1). They may have been exported at different times or from different environments. The Docker image will be pinned to whichever one matches the environment the notebooks actually ran in.

## Still needed

- The notebooks (`.ipynb`) and any helper `.py` files they import
- The run order, and which notebook's output feeds which
- The input data (Xenium output) and where it is deposited
- Which notebooks produce which manuscript figure panels
- Whether any step needs a GPU (the environment includes torch and scvi-tools)
