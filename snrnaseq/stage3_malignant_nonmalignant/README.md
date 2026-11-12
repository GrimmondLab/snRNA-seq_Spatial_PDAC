# Stage 3: malignant and non-malignant analysis

R 4.3 · Bioconductor 3.17 · Seurat 4.3.0 · ggplot2 3.5.2 · conda env `downstream` · master script `run_stage3.R`

`run_stage3.R` renders two R Markdown files. Both start from the deposited final annotated object and do not depend on each other.

1. `STS_Malignant.Rmd`
   - **Malignant cells** (`simspec_cell_class == "PDAC"`, excluding the rare-histology patients 1959, 1971, 2153 and 2185, and 84 cells of sample 2215 listed in the file): SCTransform per sample, simspec (CSS) integration, clustering at resolution 0.1, pseudobulk differential expression per cluster with edgeR (using the original clusters, `stage3_malignant_SCT_snn_res.0.1`), Hallmark over-representation analysis.
   - **Rare malignancies** (patients 1959, 1971, 2153, 2185, 2207): SCTransform, clustering, markers per tumour, Hallmark over-representation analysis.
2. `STS_nonMalignant_TuftADM.Rmd`
   - **Non-malignant cells** (all classes except PDAC, malignant acinar and PDA_OLGC; excluding patients 1959 and 2185): SCTransform, clustering at resolution 0.7, level-1 annotation (`Lv.1.Anno`, from `stage3_Lv.1.Anno`).
   - **Tuft cells**: reclustering, KRAS mutation status per cell, and level-2 annotation (`Lv.2.Anno`, from `stage3_Lv.2.Anno`), including acinar-ductal, MUC5B+ ductal and the tuft cells with copy-number changes in patient 2221 (`Tuft.persistent`).
   - **ADM samples** (patients 2156, 2215, 2221, 2285): pseudobulk differential expression between acinar, acinar-ductal, ductal, MUC5B+ ductal and tuft cells with edgeR, and marker dot plots.

The 84 cells of sample 2215 are listed in `STS_Malignant.Rmd`. They showed no copy-number changes in inferCNV (see `../supplementary_infercnv/README.md`). They are excluded from the malignant analysis and, like all cells annotated PDAC, from the non-malignant analysis. They are included in the ADM dot plots.

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
| `sts.simspec_css.sample.sct_final.RDS` | Final annotated object (deposited, [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322)): the integrated Stage 2 object, with `simspec_cell_class`, that the original code read as `sts.simspec_css.sample.sct.Aug24.RDS`, with the Stage 3 and 4 labels added. Its data are unchanged |
| `tuft.snv.df.csv` | KRAS mutation calls per tuft cell (deposited, [10.5281/zenodo.23933322](https://doi.org/10.5281/zenodo.23933322)) |
| `sample_map.csv` | `shared/sample_map.csv`, included in the image at `/pipeline/shared/`. Adds ICGC donor IDs to the figures |
| `label_checks.R` | `shared/label_checks.R`, included in the image at `/pipeline/shared/`. Reads labels from the deposited object and compares them with the rerun (see below) |

## Environment

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

## Files

| File | Purpose |
|---|---|
| `run_stage3.R` | Master script; `Rscript run_stage3.R [config.yml]` |
| `STS_Malignant.Rmd`, `STS_nonMalignant_TuftADM.Rmd` | The analysis |
| `config.yml` | Input paths and output folder (container paths) |
| `sessionInfo/` | Session information of the original runs |

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
| | `sts.nonmalignant.RDS` | Non-malignant object with `Lv.1.Anno` and `Lv.2.Anno` (from the deposited object), and `Lv.1.Anno_by_cluster` and `Lv.2.Anno_by_cluster` (the original mapping applied to the rerun). Stage 4 doesn't read it |
| | `label_agreement.tsv` | Agreement of the rerun with `Lv.1.Anno`, `Lv.2.Anno` and `Tuft.persistent` |
| | `SupplementaryTable3_adm_pseudobulk.csv` | Supplementary Table 3 (originally saved as `Final_adm.cellnames.pseudobulk.removed.tuft.malig_revisedFDR.csv`) |

## Notes

- **Labels come from the deposited object** (see "Labels read from the deposited object" below). The original code assigned `Lv.1.Anno` to resolution-0.7 clusters by number, `Tuft.persistent` to tuft clusters 2 and 3 at resolution 0.9, `Ductal_MUC5B+` to clusters 5 and 18 at resolution 0.7, and ran the malignant pseudobulk on the resolution-0.1 clusters. The rerun clusters are compared with these, and the rerun cluster numbers are kept as `rerun_SCT_snn_res.0.1` in the malignant object.
- **The malignant contrasts expect 6 clusters.** The edgeR contrasts in `STS_Malignant.Rmd` are written for the 6 original clusters at resolution 0.1. A check stops the run if there are not 6.
- **Extended Data Fig. 4G is a rerun UMAP.** The tuft UMAP is computed again, so its layout may differ from the published one; the cells and their KRAS calls are the same.
- **`sts.nonmalignant.RDS` is saved once,** after `Lv.2.Anno` is added. The original code also saved it earlier, with `Lv.1.Anno` only, under the same name.

## Labels read from the deposited object

Clustering and UMAP can change with small differences in software or hardware, so a rerun is not guaranteed to give the original cluster numbers. The original code assigned labels to clusters by number, so in a different environment the same code could give the right clusters the wrong labels. The labels are therefore read from the deposited final object, matched by cell ID, as Stage 2 does for `cell_class`. They were copied there from the original objects by `../stage4_reclustering/add_labels_to_final_object.R`. The clustering still runs, and each original mapping of cluster numbers to labels is still applied to the rerun clusters (columns ending in `_by_cluster`) and compared with the deposited labels using the functions in `../../shared/label_checks.R`. Each comparison is shown in the HTML report and saved in `label_agreement.tsv`:

- rerun clusters against deposited labels: adjusted Rand index (ARI), a heatmap of each cluster's share of cells per label, and the majority label of each cluster
- labels from the original mapping against deposited labels: % of cells with the same label, ARI, and the label pairs that differ

A run stops if any cell selected for an analysis has no deposited label, which would mean the cell selection differs from the original.
