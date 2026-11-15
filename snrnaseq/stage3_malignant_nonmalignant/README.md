# Stage 3: malignant and non-malignant analysis

Reproduces Extended Data Fig. 1C–E, Extended Data Fig. 4A, 4C, 4G and 4H, and Supplementary Table 3, from the deposited final object.

**Result:** not yet run in the project image. The agreement with the original analysis will be added here after the run (see [Comparison with the original](#comparison-with-the-original)).

R 4.3 · Seurat 4.3.0 · conda env `downstream` · master script `run_stage3.R`

## What it does

`run_stage3.R` renders two R Markdown files. Both start from the deposited final object and do not depend on each other.

1. `STS_Malignant.Rmd`
   - **Malignant cells:** integration, clustering, pseudobulk differential expression per cluster (edgeR) and Hallmark over-representation analysis.
   - **Rare malignancies** (patients 1959, 1971, 2153, 2185, 2207): clustering, markers per tumour and Hallmark over-representation analysis.
2. `STS_nonMalignant_TuftADM.Rmd`
   - **Non-malignant cells:** clustering and level-1 annotation (`Lv.1.Anno`).
   - **Tuft cells:** reclustering, KRAS mutation status per cell, and level-2 annotation (`Lv.2.Anno`).
   - **ADM samples** (patients 2156, 2215, 2221, 2285): pseudobulk differential expression between acinar, acinar-ductal, ductal, MUC5B+ ductal and tuft cells (edgeR), and marker dot plots.

Cell labels are read from the deposited object by cell ID, not from cluster numbers, so a rerun in another environment keeps the original labels. The rerun clusters are still computed and compared with them (see [`shared/README.md`](../../shared/README.md#labels-read-from-the-deposited-object)).

## Manuscript outputs

| Output | File | Chunk |
|---|---|---|
| Extended Data Fig. 1C | `STS_Malignant.Rmd` | `ext-data-fig-1c` |
| Extended Data Fig. 1D | `STS_Malignant.Rmd` | `ext-data-fig-1d` |
| Extended Data Fig. 1E | `STS_Malignant.Rmd` | `ext-data-fig-1e` |
| Extended Data Fig. 4A | `STS_nonMalignant_TuftADM.Rmd` | `ext-data-fig-4a` |
| Extended Data Fig. 4C | `STS_nonMalignant_TuftADM.Rmd` | `ext-data-fig-4c` |
| Extended Data Fig. 4G | `STS_nonMalignant_TuftADM.Rmd` | `ext-data-fig-4g` |
| Extended Data Fig. 4H | `STS_nonMalignant_TuftADM.Rmd` | `ext-data-fig-4h` |
| Supplementary Table 3 | `STS_nonMalignant_TuftADM.Rmd` | writes `SupplementaryTable3_adm_pseudobulk.csv` |

Figures are shown in each HTML report and also saved as PNG and PDF files, named after their chunk.

## Input

| File | Source |
|---|---|
| `sts.simspec_css.sample.sct_final.RDS` | Final annotated object, [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322) |
| `tuft.snv.df.csv` | KRAS mutation calls per tuft cell, [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322) |
| `sample_map.csv`, `label_checks.R` | In the image at `/pipeline/shared/` (see [`shared/README.md`](../../shared/README.md)) |

## Run

Use the project image (see the top-level `README.md` to build or pull it).

| Container path | Mount | Mode |
|---|---|---|
| `/data/input` | folder containing `sts.simspec_css.sample.sct_final.RDS` and `tuft.snv.df.csv` | read-only |
| `/output` | where results go | read-write |

```bash
docker run --rm \
  --cpus 8 --memory 128g \
  -v /path/to/input:/data/input:ro \
  -v /path/to/output:/output \
  pdac-snrnaseq:1.0 stage3
```

With Apptainer/Singularity:

```bash
apptainer run \
  --bind /path/to/input:/data/input \
  --bind /path/to/output:/output \
  pdac-snrnaseq.sif stage3
```

## Outputs

| Folder | File | Contents |
|---|---|---|
| `STS_Malignant/` | `STS_Malignant.html`, figures | Report and Extended Data Fig. 1C–E |
| | `label_agreement.tsv` | Agreement of the rerun malignant clusters with the original ones |
| `STS_nonMalignant_TuftADM/` | `STS_nonMalignant_TuftADM.html`, figures | Report and Extended Data Fig. 4A, 4C, 4G, 4H |
| | `sts.nonmalignant.RDS` | Non-malignant object with the deposited labels. Stage 4 doesn't read it |
| | `label_agreement.tsv` | Agreement of the rerun with `Lv.1.Anno`, `Lv.2.Anno` and `Tuft.persistent` |
| | `SupplementaryTable3_adm_pseudobulk.csv` | Supplementary Table 3 |

## Comparison with the original

| What | Expected | Rerun |
|---|---|---|
| Cell labels (`Lv.1.Anno`, `Lv.2.Anno`, `Tuft.persistent`, malignant clusters) | Identical: read from the deposited object | to be added |
| Rerun clusters vs original labels | Close (ARI and % same label in `label_agreement.tsv`) | to be added |
| Pseudobulk differential expression and Hallmark analysis | Same cells and groups as the original | to be added |
| Extended Data Fig. 4G (tuft UMAP) | Same cells and KRAS calls; layout may differ, as the UMAP is recomputed | to be added |

The malignant edgeR contrasts are written for the 6 original clusters; the run stops if there are not 6.

## Details

<details>
<summary>Cell selection</summary>

- **Malignant cells:** `simspec_cell_class == "PDAC"`, excluding the rare-histology patients 1959, 1971, 2153 and 2185, and 84 cells of sample 2215 listed in `STS_Malignant.Rmd`. SCTransform per sample, simspec (CSS) integration, clustering at resolution 0.1. The pseudobulk uses the original clusters (`stage3_malignant_SCT_snn_res.0.1`); the rerun clusters are kept as `rerun_SCT_snn_res.0.1`.
- **Non-malignant cells:** all classes except PDAC, malignant acinar and PDA_OLGC, excluding patients 1959 and 2185. SCTransform, clustering at resolution 0.7.
- **The 84 cells of sample 2215** showed no copy-number changes in inferCNV (see `../supplementary_infercnv/README.md`). They are excluded from the malignant analysis and, like all cells annotated PDAC, from the non-malignant analysis. They are included in the ADM dot plots.
- **`Lv.2.Anno`** includes acinar-ductal, MUC5B+ ductal and the tuft cells with copy-number changes in patient 2221 (`Tuft.persistent`).

</details>

<details>
<summary>Original cluster-to-label mappings</summary>

The original code assigned `Lv.1.Anno` to resolution-0.7 clusters by number, `Tuft.persistent` to tuft clusters 2 and 3 at resolution 0.9, `Ductal_MUC5B+` to clusters 5 and 18 at resolution 0.7, and ran the malignant pseudobulk on the resolution-0.1 clusters. These mappings are applied to the rerun clusters (columns ending in `_by_cluster`) and compared with the deposited labels.

The original code saved `sts.nonmalignant.RDS` twice under the same name, first with `Lv.1.Anno` only; here it is saved once, after `Lv.2.Anno` is added. Supplementary Table 3 was originally saved as `Final_adm.cellnames.pseudobulk.removed.tuft.malig_revisedFDR.csv`.

</details>

<details>
<summary>Environment and package versions</summary>

Conda env `downstream` in the project image (`../../envs/downstream.yml`, locked in `../../envs/downstream-linux-64.lock`): R 4.3, Bioconductor 3.17, Seurat 4.3.0, SeuratObject 4.1.3, dplyr 1.1.2, ggplot2 3.5.2, patchwork 1.3.2, scales 1.4.0, edgeR 3.42.4, limma 3.56.2, clusterProfiler 4.8.1, msigdbr 7.5.1, org.Hs.eg.db 3.17.0. `../../envs/post_install_downstream.R` adds two GitHub packages at fixed commits: simspec `f4c87bf` (as in Stage 2) and treeio 1.25.0.001 at `7c32644` (a development version, used by clusterProfiler; it replaces the conda treeio 1.24.1).

This is a separate env from Stages 1–2 because of its newer plotting packages (ggplot2 3.5.2 instead of 3.4.2). `sessionInfo/` holds the session information of the original runs of both files; their package versions are identical. Every package recorded there is pinned to its original version, except:

| Package | Original | Here | Why |
|---|---|---|---|
| R | 4.3.0 | 4.3.3 | conda's R 4.3 builds |
| cli | 3.6.6 | 3.6.5 | no R 4.3 conda build of the original |
| rlang | 1.3.0 | 1.1.6 | " |
| vctrs | 0.7.3 | 0.6.5 | " |
| lifecycle | 1.0.5 | 1.0.4 | " (1.0.5 needs R ≥ 4.4) |
| tidyr | 1.3.2 | 1.3.1 | " |
| S7 | 0.2.2 | 0.2.0 | " |
| ggrepel | 0.9.8 | 0.9.6 | " |
| cluster | 2.1.8.2 | 2.1.8.1 | " |
| digest | 0.6.32 | 0.6.33 | " |
| AnnotationDbi | 1.62.1 | 1.62.2 | " |
| glmGamPoi | 1.12.1 | 1.12.2 | " |
| workflowr, git2r, getPass, whisker, renv, BiocManager | | not installed | attached in the original session but not used by the code |

The image build saves the env's own `sessionInfo()` to `/pipeline/sessionInfo/downstream.txt`.

</details>

<details>
<summary>Files in this folder</summary>

| File | Purpose |
|---|---|
| `run_stage3.R` | Master script; `Rscript run_stage3.R [config.yml]` |
| `STS_Malignant.Rmd`, `STS_nonMalignant_TuftADM.Rmd` | The analysis |
| `config.yml` | Input paths and output folder (container paths) |
| `sessionInfo/` | Session information of the original runs |

</details>
