# Stage 2 session information

| File | What it records |
|---|---|
| `sessionInfo_SeuratSampleProcessing.txt` | `Seurat_sample_based.Rmd` |
| `sessionInfo_SimspecIntegration.txt` | `PDAC_STS_simspec_integration.Rmd` |

Both show R 4.4.0 on Ubuntu 22.04 with Bioconductor 3.17 packages, Seurat 4.3.0, SeuratObject 4.1.3, ggplot2 3.4.2, dplyr 1.1.2 and Matrix 1.7-5. The conda env now runs this stage on R 4.3 with Matrix 1.5-4.1 (see `../README.md`).

SCTransform (`method = "glmGamPoi"`) uses glmGamPoi, which does not appear in either file. The author checked its version in the same R 4.4 environment on 28 October 2026: **glmGamPoi 1.12.1**.

simspec was installed from GitHub, so its version number (`0.0.0.9000`) does not identify the code. The installed commit, read from the same environment with `packageDescription("simspec")$RemoteSha`, is **`f4c87bfb18522d7df0110eb63843972a29415985`** (github.com/quadbio/simspec, 6 March 2024; the repository has moved from `quadbiolab/simspec`).
