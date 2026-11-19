# Spatial proteomics: OPAL

OPAL multiplex immunofluorescence was done in collaboration with a team at WEHI, following the team's image analysis workflow (Phenochart 2.2.0, inForm 3.0.0, QuPath 0.6.0). Two panels were used.

| Panel | Markers | Samples analysed | Use in the manuscript |
|---|---|---|---|
| 1 | DAPI, CK, PVR, POU2F3 | 30 | Fig. 3H: representative images from 3 patients with POU2F3+ PVR+ tuft cells. Text: tuft cells co-express PVR in 27 of 30 samples (see [Panel 1 counts](#panel-1-counts)) |
| 2 | DAPI, CK, CCL19, CXCL12, PDGFRA, PLA2G2A | 31 | Fig. 6H and Extended Data Fig. 9J: representative images only, showing lymphoid stromal cells in TLS. No quantification |

## Images, workflow and containers

The OPAL images, the workflow with all its settings, and the containers are deposited and documented by the WEHI team: *(link TBD)*.

## Panel 1 counts

[`panel1_tuft_PVR_counts.csv`](panel1_tuft_PVR_counts.csv) has one row per sample stained (32), taken from the team's panel 1 data sheet. Clinical columns in that sheet (grade, survival) are not included.

| Column | Meaning |
|---|---|
| `sample_id` | Patient sample ID |
| `pou2f3_pos_pct` | POU2F3+ cells, % of CK+ cells |
| `pvr_pos_pct` | PVR+ cells, % of CK+ cells |
| `pou2f3_pvr_pos_pct` | POU2F3+ PVR+ cells, % of CK+ cells |
| `pou2f3_pvr_pos_present` | `yes` if `pou2f3_pvr_pos_pct` > 0 |
| `status` | `analysed`, or why the sample was not analysed (sample not found, image error) |

30 of the 32 samples were analysed. All 30 have POU2F3+ cells, and 27 have POU2F3+ PVR+ cells (none in 210, 2189 and 2603).
