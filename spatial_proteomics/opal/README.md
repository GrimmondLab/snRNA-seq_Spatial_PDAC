# Spatial proteomics: OPAL

OPAL multiplex immunofluorescence was done in collaboration with a team at WEHI. Panel 1 was analysed with Phenochart 2.2.0, inForm 3.0.0 and QuPath 0.6.0 (see [Panel 1 workflow](#panel-1-workflow)). Panel 2 was segmented with `sp_segment` (Cellpose-SAM) and classified with `sp-classify` (see [Images, workflow and containers](#images-workflow-and-containers)). Two panels were used.

| Panel | Markers | Samples analysed | Use in the manuscript |
|---|---|---|---|
| 1 | DAPI, CK, PVR, POU2F3 | 30 | Fig. 3H: representative images from 3 patients with POU2F3+ PVR+ tuft cells. Text: tuft cells co-express PVR in 27 of 30 samples (see [Panel 1 counts](#panel-1-counts)) |
| 2 | DAPI, CK19, CCL19, CXCL12, MS4A1, PDGFRA, PLA2G2A | 31 | Fig. 6H and Extended Data Fig. 9J: representative images, showing lymphoid stromal cells in TLS. The cell-level analysis (target cells per patient, and their position relative to B cells) is on Zenodo (below) |

## Images, workflow and containers

Panel 2 is on Zenodo, [10.5281/zenodo.24356840](https://doi.org/10.5281/zenodo.24356840):

| File | Contents |
|---|---|
| `opal_pipeline_source.zip` | Nextflow pipeline: marker classification of segmented cells, target-cell counts, retraining from labels, spatial analysis |
| `sp-classify_0.3.7.sif`, `opal-python.sif` | Apptainer containers for the pipeline |
| `opal_record.zip` | Sample sheet (214 image tiles), saved marker classifiers, training labels, per-cell marker calls, one example tile with its cells, expected outputs |
| `opal_example_crop_P10.ome.tif` | Example image: 2,000 × 2,000 pixel crop of the example tile, all 8 channels |
| `opal_spatial_analysis.zip` | Spatial analysis of target cells (CCL19+ CK19− CXCL12+) and B cells (MS4A1+): scripts, per-patient tables, figures |

The record's README gives the segmentation settings. Patients in the record are identified as P01–P31. The full images and the segmented cells of all tiles (113 GB) are too large to deposit and are available on request. The slides were stained and imaged in three batches; in Batches 2 and 3 CCL19 staining was too weak to identify CCL19+ cells reliably, so the Panel 2 per-patient results are informative for Batch 1 (9 patients) only.

## Panel 1 workflow

Phenochart and inForm (Akoya Biosciences) are licensed Windows applications and cannot be put in a container; QuPath is free and open source.

| Step | Software | Settings |
|---|---|---|
| 1. Annotation, pre-processing and stitching | Phenochart 2.2.0, inForm 3.0.0, QuPath 0.6.0 | Scanned images annotated, pre-processed and stitched |
| 2. Cell detection | QuPath 0.6.0, cell detection tool | Across the stitched images; DAPI intensity threshold 5 |
| 3. Cell classification | QuPath 0.6.0, one object classifier per image channel | Thresholds: CK 2.0, PVR 2.84, POU2F3 0.5 |
| 4. Quantification | From the classified cells | Percentage of POU2F3+, PVR+ and POU2F3+ PVR+ cells among CK+ cells, per patient (see [Panel 1 counts](#panel-1-counts)) |

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
