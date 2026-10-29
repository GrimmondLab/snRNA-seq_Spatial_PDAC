# Session information from the October 26 rerun

These two files are kept unchanged as recorded:

- `Sessioninfo_Preprocessing_DoubletRemoval.txt`: Doublet Removal step
- `Sessioninfo_QC.txt`: fixed-threshold QC step

They come from a rerun of these steps on October 26, not from the session that produced the manuscript figures. Packages on the analysis machine had been updated before this rerun, so these files list ggplot2 3.5.2 and dplyr 1.2.1. The original analysis used ggplot2 3.4.2 and dplyr 1.1.2.

The conda env `snrnaseq` uses the original versions (except xgboost 1.7.6 and a few minor dependencies; see `../../README.md`), as recorded in `../sessionInfo_DoubletRemoval.txt` and `../sessionInfo_FixedQC.txt`.
