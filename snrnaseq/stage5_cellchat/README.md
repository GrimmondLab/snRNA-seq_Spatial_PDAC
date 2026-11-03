# Stage 5: CellChat

R 4.3 · Bioconductor 3.17 · Seurat 4.3.0 · CellChat 2.1.2 · dplyr 1.2.1 · conda env `cellchat` · master script `run_stage5.R`

`run_stage5.R` renders `Cellchat.Rmd`, which infers cell-cell communication from the final annotated object. Both analyses use the RNA assay, CellChatDB.human, 500 cells per cell type and a truncated mean with `trim = 0.15`.

1. **`Lv.1.Anno` cell types:** PVR signalling across all cell types.
2. **`Lv.2.Anno` cell types:** TAMs to PDAC, CAFs_NRT with TAMs and lymphoid cells (CD80, CD86), and the tertiary lymphoid structure cell types (CCL, CXCL).

## Manuscript outputs

Figure names are taken from the chunk labels.

| Output | Chunk |
|---|---|
| Fig. 3E | `fig3e-pvr` |
| Fig. 3F | `fig3f-pvr-signalling-network` |
| Fig. 4G | `fig4g-LR-analysis` |
| Fig. 5F | `fig5f-LR-analysis-cd80-cd86` |
| Fig. 6G | `fig6g-LR-analysis-ccl19-cxcl12` |

Figures are shown in the HTML report and also saved as PNG and PDF files, named after their chunk.

## Input

| File | Source |
|---|---|
| `sts.simspec_css.sample.sct_final.RDS` | Final annotated object from Stage 4 (deposited, **DOI_TBD**) |

## Environment

Conda env `cellchat` in the project image (`../../envs/cellchat.yml`, locked in `../../envs/cellchat-linux-64.lock`). This is a separate env from Stages 3–4 because the original run used dplyr 1.2.1 and needs the CellChat dependencies. `sessionInfo/` holds the session information of the original run.

`../../envs/post_install_cellchat.R` installs what conda does not have at these versions for R 4.3: CellChat from GitHub, and cli, rlang, lifecycle, vctrs, tidyr, dplyr and NMF from CRAN source, all at their original versions.

**CellChat commit.** Version 2.1.2 covers many commits, including changes to the human database. The script pins `6063355`, the commit of the original install.

Every other package recorded in `sessionInfo/` is pinned to its original version, except:

| Package | Original | Here | Why |
|---|---|---|---|
| R | 4.3.0 | 4.3.3 | conda's R 4.3 builds |
| ggpubr | 1.0.0 | 0.6.1 | no R 4.3 conda build of the original |
| rstatix | 1.0.0 | 0.7.2 | " |
| S7 | 0.2.2 | 0.2.0 | " |
| ggrepel | 0.9.8 | 0.9.6 | " |
| cluster | 2.1.8.2 | 2.1.8.1 | " |
| digest | 0.6.32 | 0.6.33 | " |
| workflowr, git2r, getPass, whisker, renv | | not installed | attached in the original session but not used by the code |

The image build saves the env's own `sessionInfo()` to `/pipeline/sessionInfo/cellchat.txt`.

## Files

| File | Purpose |
|---|---|
| `run_stage5.R` | Master script; `Rscript run_stage5.R [config.yml]` |
| `Cellchat.Rmd` | The analysis |
| `config.yml` | Input path and output folder (container paths) |
| `sessionInfo/` | Session information of the original run |

## Run

Use the project image (see the top-level `README.md` to build or pull it). The code starts 20 parallel workers for the first analysis and 10 for the second.

| Container path | Mount | Mode |
|---|---|---|
| `/data/input` | folder containing `sts.simspec_css.sample.sct_final.RDS` | read-only |
| `/output` | where results go | read-write |

```bash
docker run --rm \
  --cpus 20 --memory 128g \
  -v /path/to/input:/data/input:ro \
  -v /path/to/output:/output \
  pdac-snrnaseq:1.0 stage5
```

With Apptainer/Singularity:

```bash
apptainer run \
  --bind /path/to/input:/data/input \
  --bind /path/to/output:/output \
  pdac-snrnaseq.sif stage5
```

## Outputs

| Folder | File | Contents |
|---|---|---|
| `Cellchat/` | `Cellchat.html`, figures | Report and figures |
| | `cellchat_lv1.RDS`, `cellchat_lv2.RDS` | CellChat objects |
