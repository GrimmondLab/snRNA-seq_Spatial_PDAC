# Spatial proteomics: OPAL

OPAL multiplex immunofluorescence was done in collaboration with a team at WEHI, following the team's image analysis workflow. Two panels were used.

| Panel | Markers | Samples analysed | Use in the manuscript |
|---|---|---|---|
| 1 | DAPI, CK, PVR, POU2F3 | 30 | Fig. 3H: representative images from 3 patients with POU2F3+ PVR+ tuft cells. Text: tuft cells co-express PVR in 27 of 30 samples (per-sample values in [`panel1_tuft_PVR_counts.csv`](panel1_tuft_PVR_counts.csv); see [Panel 1 counts](#panel-1-counts)) |
| 2 | DAPI, CK, CCL19, CXCL12, PDGFRA, PLA2G2A | 31 | Fig. 6H and Extended Data Fig. 9J: representative images only, showing lymphoid stromal cells in TLS. No quantification |

## Input data

The OPAL images are on *(repository and accession TBD, deposited by the WEHI team)*:

| Panel | Files | Format | Samples |
|---|---|---|---|
| 1 | *(TBD)* | *(e.g. `.qptiff` whole slide scans and inForm component TIFFs)* | 30 |
| 2 | *(TBD)* | *(TBD)* | 31 |

Images shown in the figures:

| Figure | Panel | Sample | Region |
|---|---|---|---|
| Fig. 3H | 1 | *(TBD)* | *(TBD)* |
| Fig. 3H | 1 | *(TBD)* | *(TBD)* |
| Fig. 3H | 1 | *(TBD)* | *(TBD)* |
| Fig. 6H | 2 | *(TBD)* | *(TBD)* |
| Extended Data Fig. 9J | 2 | *(TBD)* | *(TBD)* |

## Software

| Software | Version | Containerized | Notes |
|---|---|---|---|
| Phenochart | 2.2.0 | No: licensed Windows software (Akoya Biosciences) | Region selection on the whole slide scans. *(OS TBD)* |
| inForm | 3.0.0 | No: licensed Windows software (Akoya Biosciences) | Spectral unmixing *(and cell segmentation / phenotyping: TBD)*. *(OS TBD)* |
| QuPath | 0.6.0 | *(Yes: Zenodo DOI and digest TBD)* | Stitching and cell detection *(TBD)* |

Phenochart and inForm cannot be put in a container. All of their settings are saved in files that can be loaded into the same versions to repeat the analysis; these are deposited with the images:

| File | Software | Contents |
|---|---|---|
| *(TBD)* | Phenochart | Region annotations for each slide |
| *(TBD)* | inForm | Spectral library used for unmixing |
| *(TBD)* | inForm | Project / algorithm file with the unmixing *(segmentation, phenotyping)* settings |
| *(TBD)* | QuPath | Script(s) for stitching and cell detection |

## Workflow and parameters

*(To be filled in from the WEHI team's documentation.)*

| Step | Software | Parameters |
|---|---|---|
| 1. Acquisition | *(scanner TBD)* | objective, filters, exposure times per channel *(TBD)* |
| 2. Region selection | Phenochart 2.2.0 | number and size of regions per slide, how they were chosen *(TBD)* |
| 3. Spectral unmixing | inForm 3.0.0 | spectral library, autofluorescence handling *(TBD)* |
| 4. Stitching | QuPath 0.6.0 *(TBD)* | method and settings *(TBD)* |
| 5. Cell detection | QuPath 0.6.0 *(TBD)* | detection channel, thresholds, cell expansion *(TBD)* |
| 6. Marker positivity (panel 1) | *(TBD)* | POU2F3 and PVR thresholds, and how a cell is called a tuft cell *(TBD)* |
| 7. Display (figures) | *(TBD)* | channel colours and display ranges for the images in the figures *(TBD)* |

## Panel 1 counts

[`panel1_tuft_PVR_counts.csv`](panel1_tuft_PVR_counts.csv) has one row per sample stained (32), taken from the team's panel 1 data sheet. Clinical columns in that sheet (grade, survival) are not included.

| Column | Meaning |
|---|---|
| `sample_id` | Patient sample ID |
| `pou2f3_pos_pct` | POU2F3+ cells, % of cells *(denominator TBD)* |
| `pvr_pos_pct` | PVR+ cells, % of cells |
| `pou2f3_pvr_pos_pct` | POU2F3+ PVR+ cells, % of cells |
| `pou2f3_pvr_pos_present` | `yes` if `pou2f3_pvr_pos_pct` > 0 |
| `status` | `analysed`, or why the sample was not analysed (sample not found, image error) |

30 of the 32 samples were analysed. All 30 have POU2F3+ cells, and 27 have POU2F3+ PVR+ cells (none in 210, 2189 and 2603).
