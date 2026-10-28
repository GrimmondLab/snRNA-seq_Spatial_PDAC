# Stage 1 session information

| File | What it records |
|---|---|
| `sessionInfo_DoubletRemoval.txt` | Doublet Removal step (`Preprocessing_DoubleDetection.Rmd`). Provided by the author on 28 October 2026. |
| `sessionInfo_FixedQC.txt` | Fixed-threshold QC step (`Preprocessing_QC.Rmd`). Provided by the author on 28 October 2026. |
| `oct26_rerun/` | Session information from the October 26 rerun, kept as recorded (see the note inside). |

The Docker image pins the key package versions from the two files above (R 4.3.0, Bioconductor 3.17, ggplot2 3.4.2, dplyr 1.1.2; full list in `../install_packages.R`). Packages that are loaded but not used by the Stage 1 code (e.g. workflowr, openxlsx, monocle3, simspec) are not installed.

The build also records the image's own session information in `/pipeline/sessionInfo_container.txt` (see `../README.md`).
