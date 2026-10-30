# Stage 3: malignant and non-malignant analysis

R 4.3.0 · Bioconductor 3.17 · Seurat 4.3.0 · ggplot2 3.5.2 · master script `run_stage3.R`

`run_stage3.R` renders two R Markdown files. Both start from the Stage 2 annotated object and do not depend on each other.

1. `STS_Malignant.Rmd`
   - **Malignant cells** (`simspec_cell_class == "PDAC"`, excluding the rare-histology patients 1959, 1971, 2153 and 2185, and 84 cells of sample 2215 listed in the file): SCTransform per sample, simspec (CSS) integration, clustering at resolution 0.1, pseudobulk differential expression per cluster with edgeR, Hallmark over-representation analysis.
   - **Rare malignancies** (patients 1959, 1971, 2153, 2185, 2207): SCTransform, clustering, markers per tumour, Hallmark over-representation analysis.
2. `STS_nonMalignant_TuftADM.Rmd`
   - **Non-malignant cells** (all classes except PDAC, malignant acinar and PDA_OLGC; excluding patients 1959 and 2185): SCTransform, clustering at resolution 0.7, level-1 annotation (`Lv.1.Anno`) by cluster.
   - **Tuft cells**: reclustering, KRAS mutation status per cell, and level-2 annotation (`Lv.2.Anno`), including acinar-ductal, MUC5B+ ductal and the tuft cells with copy-number changes in patient 2221 (`Tuft.persistent`).
   - **ADM samples** (patients 2156, 2215, 2221, 2285): pseudobulk differential expression between acinar, acinar-ductal, ductal, MUC5B+ ductal and tuft cells with edgeR, and marker dot plots.

The 84 cells of sample 2215 are listed in `STS_Malignant.Rmd`. They are excluded from the malignant analysis and, like all cells annotated PDAC, from the non-malignant analysis. They are included in the ADM dot plots.

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
| `sts.simspec_css.sample.sct.RDS` | Annotated integrated object from Stage 2, with `simspec_cell_class` (deposited, **DOI_TBD**). The original code read the same object as `sts.simspec_css.sample.sct.Aug24.RDS` |
| `tuft.snv.df.csv` | KRAS mutation calls per tuft cell (deposited, **DOI_TBD**) |
| `sample_map.csv` | From `shared/`, included in the image. Adds ICGC donor IDs to the figures |

## Environment

| | Version |
|---|---|
| R | 4.3.0 (`rocker/r-ver:4.3.0`, Ubuntu 22.04, linux/amd64) |
| Bioconductor | 3.17, with patch versions matched to `sessionInfo/` (older patches from the 3.17 archive) |
| CRAN | Posit Package Manager snapshot from 2023-06-15 (Seurat 4.3.0, SeuratObject 4.1.3, dplyr 1.1.2), plus 23 newer versions from `sessionInfo/`, including ggplot2 3.5.2, patchwork 1.3.2, scales 1.4.0 and cli 3.6.6 |
| GitHub | simspec at commit `f4c87bf` (as in Stage 2); treeio 1.25.0.001 at commit `7c32644` (a development version, used by clusterProfiler) |

This environment differs from Stages 1–2 in its newer plotting packages (ggplot2 3.5.2 instead of 3.4.2). `sessionInfo/` holds the session information of the original runs of both files; their package versions are identical. `install_packages.R` installs every package recorded there, checks all 197 versions at the end of the build, and stops if any differ. It then saves the image's own `sessionInfo()` to `/pipeline/sessionInfo_container.txt`.

## Files

| File | Purpose |
|---|---|
| `Dockerfile`, `Dockerfile.dockerignore` | Image definition; built from the repository root |
| `install_packages.R` | Installs and checks R packages (runs during build) |
| `run_stage3.R` | Master script; `Rscript run_stage3.R [config.yml]` |
| `STS_Malignant.Rmd`, `STS_nonMalignant_TuftADM.Rmd` | The analysis |
| `config.yml` | Input paths and output folder (container paths) |
| `sessionInfo/` | Session information of the original runs |

## Build

Run from the repository root (not this folder), so that `shared/sample_map.csv` can be copied into the image:

```bash
docker build -f snrnaseq/stage3_malignant_nonmalignant/Dockerfile -t pdac-stage3:1.0 .
```

## Run with Docker

| Container path | Mount | Mode |
|---|---|---|
| `/data/input` | folder containing `sts.simspec_css.sample.sct.RDS` and `tuft.snv.df.csv` | read-only |
| `/output` | where results go | read-write |

```bash
docker run --rm \
  --cpus 8 --memory 128g \
  -v /path/to/input:/data/input:ro \
  -v /path/to/output:/output \
  pdac-stage3:1.0
```

To copy the image's session information out without running the pipeline:

```bash
docker run --rm --entrypoint cat pdac-stage3:1.0 /pipeline/sessionInfo_container.txt > sessionInfo_container.txt
```

## Run with Apptainer/Singularity

```bash
docker save pdac-stage3:1.0 -o pdac-stage3_1.0.tar
```

```bash
apptainer build pdac-stage3_1.0.sif docker-archive://pdac-stage3_1.0.tar
```

```bash
apptainer run --pwd /pipeline \
  --bind /path/to/input:/data/input \
  --bind /path/to/output:/output \
  pdac-stage3_1.0.sif
```

## Outputs

| Folder | File | Contents |
|---|---|---|
| `STS_Malignant/` | `STS_Malignant.html`, figures | Report and Extended Data Fig. 1C–E |
| `STS_nonMalignant_TuftADM/` | `STS_nonMalignant_TuftADM.html`, figures | Report and Extended Data Fig. 4A, 4C, 4G, 4H |
| | `sts.nonmalignant.RDS` | Non-malignant object with `Lv.1.Anno` and `Lv.2.Anno` |
| | `SupplementaryTable3_adm_pseudobulk.csv` | Supplementary Table 3 (originally saved as `Final_adm.cellnames.pseudobulk.removed.tuft.malig_revisedFDR.csv`) |

## Notes

- **Cell labels come from cluster numbers.** `Lv.1.Anno` is assigned to resolution-0.7 clusters by number, and `Tuft.persistent` to tuft clusters 2 and 3 at resolution 0.9. A rerun in this image is expected to give the same clusters, and so the same labels; `sts.nonmalignant.RDS` can be compared with the original object to confirm this.
- **The malignant contrasts expect 6 clusters.** The edgeR contrasts in `STS_Malignant.Rmd` are written for the 6 clusters at resolution 0.1. A check stops the run with a message if a different number of clusters is found.
- **Extended Data Fig. 4G colours (TODO).** The original code coloured the KRAS status with a vector `col` that was defined outside the file. Until it is added (`kras.col` in that chunk), the figure uses ggplot2's default colours.
- **`sts.nonmalignant.RDS` is saved once,** after `Lv.2.Anno` is added. The original code also saved it earlier, with `Lv.1.Anno` only, under the same name.
