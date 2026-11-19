# Spatial proteomics: MIBI and OPAL

The MIBI and OPAL analyses were done in collaboration with a team at WEHI, using the team's spatial proteomics pipelines. Neither is in the project image or `run.sh`; their containers are deposited separately by the WEHI team (see each folder's README).

| Folder | Data | Manuscript figures |
|---|---|---|
| [`mibi/`](mibi/README.md) | MIBI, 8 patients, 29 FOVs after QC | Fig. 1F, 2E–G, 5G; Extended Data Fig. 2E, 6F |
| [`opal/`](opal/README.md) | OPAL multiplex immunofluorescence, 2 panels | Fig. 3H, 6H; Extended Data Fig. 9J |

## WEHI pipelines

| Pipeline | What it does | Used for | Version used | Container |
|---|---|---|---|---|
| [`sp_segment`](https://github.com/WEHI-SODA-Hub/sp_segment) | Cell segmentation and per-cell marker measurement (Nextflow, nf-core template) | MIBI *(and OPAL: TBD)* | *(TBD)* | per-step containers via `-profile docker` or `-profile singularity`; *(Zenodo DOI TBD)* |
| [`sp_celltype_train`](https://github.com/WEHI-SODA-Hub/sp_celltype_train) | Trains an XGBoost cell type classifier on labelled cells (Nextflow) | MIBI | *(TBD)* | *(Zenodo DOI TBD)* |
| [`sp_celltype_apply`](https://github.com/WEHI-SODA-Hub/sp_celltype_apply) | Applies the trained classifier to all cells (Nextflow) | MIBI | *(TBD)* | *(Zenodo DOI TBD)* |

The pipelines are general-purpose. The settings used for this manuscript (params and options files, trained model) and the links to the public input data are given in each folder's README.

## Overview

```
MIBI:  raw images ─► sp_segment ─► sp_celltype_train / apply ─► QC ─► spe.rds ─► figure scripts (R, imcRtools)
OPAL:  raw images ─► Phenochart (regions) ─► inForm (unmixing) ─► QuPath (stitching, cell detection) ─► counts / representative images
```

*(OPAL flow to be confirmed by the WEHI team.)*
