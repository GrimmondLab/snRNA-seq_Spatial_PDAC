# Spatial proteomics: OPAL

OPAL multiplex immunofluorescence was done in collaboration with a team at WEHI. Two panels were used, and they were processed differently. Panel 1 was analysed largely by hand with Phenochart 2.2.0, inForm 3.0.0 and QuPath 0.6.0 (see [Panel 1 workflow](#panel-1-workflow)). Panel 2 was processed computationally: stitched and tiled, segmented with `sp_segment` (Cellpose-SAM) and classified with `sp-classify` (see [Panel 2 workflow](#panel-2-workflow)).

| Panel | Markers | Samples analysed | Use in the manuscript |
|---|---|---|---|
| 1 | DAPI, CK, PVR, POU2F3 | 30 | Fig. 3H: representative images from 3 patients with POU2F3+ PVR+ tuft cells. Text: tuft cells co-express PVR in 27 of 30 samples (see [Panel 1 counts](#panel-1-counts)) |
| 2 | DAPI, CK19, CCL19, CXCL12, MS4A1, PDGFRA, PLA2G2A | 31 | Fig. 6H and Extended Data Fig. 9J: representative images, showing lymphoid stromal cells in TLS. The cell-level analysis (target cells per patient, and their position relative to B cells) is on Zenodo (below); it is provided for completeness and is not reported in the manuscript |

## Images, workflow and containers

Panel 2 is on Zenodo, [10.5281/zenodo.24356840](https://doi.org/10.5281/zenodo.24356840):

| File | Contents |
|---|---|
| `opal_inform_stitch.sif` | Apptainer container: stitching of the inForm component images and channel naming |
| `export_multiplex_image_tiles.sif` | Apptainer container: tiling (QuPath 0.6.0) |
| `opal_pipeline_source.zip` | Nextflow pipeline: marker classification of segmented cells, target-cell counts, retraining from labels, spatial analysis |
| `sp-classify_0.3.7.sif`, `opal-python.sif` | Apptainer containers for the pipeline |
| `opal_record.zip` | Sample sheet (214 image tiles), saved marker classifiers, training labels, per-cell marker calls, one example tile with its cells, expected outputs |
| `opal_example_crop_P10.ome.tif` | Example image: 2,000 × 2,000 pixel crop of the example tile, all 8 channels |
| `opal_spatial_analysis.zip` | Spatial analysis of target cells (CCL19+ CK19− CXCL12+) and B cells (MS4A1+): scripts, per-patient tables, figures. Not reported in the manuscript |

Versions and settings: see [Panel 2 workflow](#panel-2-workflow). Patients in the record are identified as P01–P31. The full images and the segmented cells of all tiles (113 GB) are too large to deposit and are available on request. The slides were stained and imaged in three batches; in Batches 2 and 3 CCL19 staining was too weak to identify CCL19+ cells reliably, so the Panel 2 per-patient results are informative for Batch 1 (9 patients) only.

## Panel 2 workflow

From the WEHI team's methods. Segmentation runs each step in a container (Docker, Singularity or [Apptainer](https://doi.org/10.1371/journal.pone.0177459)); the other steps use the containers above.

| Step | Software | Settings |
|---|---|---|
| 1. Imaging and unmixing | Vectra Polaris; inForm spectral unmixing with a synthetic Opal library and an autofluorescence component | Channels: DAPI, CCL19 (Opal 480), MS4A1 (Opal 520), CXCL12 (Opal 570), PDGFRA (Opal 620), PLA2G2A (Opal 690), CK19 (Opal 780), autofluorescence |
| 2. Stitching | `opal_inform_stitch.sif` ([opal_inform_stitch](https://github.com/BioimageAnalysisCoreWEHI/opal_inform_stitch), commit `9cb902b`) | inForm component images stitched; channels named |
| 3. Tiling | `export_multiplex_image_tiles.sif` (QuPath 0.6.0; [export_multiplex_image_tiles](https://github.com/BioimageAnalysisCoreWEHI/export_multiplex_image_tiles), commit `30e14b7`) | Tiles of 20,000 × 20,000 pixels, 0.4964 µm per pixel, partial tiles at the edges kept. Three batches were scanned; the Batch 3 scans of three slides duplicated their Batch 2 scans and were left out. 214 tiles from 31 patients |
| 4. Segmentation | [`sp_segment`](https://github.com/WEHI-SODA-Hub/sp_segment) [Nextflow](https://doi.org/10.1038/nbt.3820) pipeline ([nf-core](https://doi.org/10.1038/s41587-020-0439-x) template; `Dev` branch, commit `5db50b0`): [Cellpose-SAM](https://doi.org/10.1101/2025.04.28.651001) (Cellpose 4.2.1.1, model `cpsam_v2`) through [sopa](https://doi.org/10.1038/s41467-024-48981-z) 2.2.6 | Nuclear input: DAPI. Whole-cell input: pixel-wise maximum of MS4A1 and CK19. Diameter 30 pixels, flow threshold 0.4, cell probability threshold 0, minimum area 60 pixels (14.8 µm²). Patches of 3,000 × 3,000 pixels with 250 pixels of overlap; cells in overlaps resolved by sopa. Result: 35,133,888 cells |
| 5. Measurements | [cellmeasurement-py](https://github.com/WEHI-SODA-Hub/cellmeasurement-py) 0.2.0 (in `sp_segment`); imported into [QuPath](https://doi.org/10.1038/s41598-017-17204-5) 0.7.0 with [import_large_geojson](https://github.com/BioimageAnalysisCoreWEHI/import_large_geojson) (branch `qupath-0.7-support`, commit `c387e92`) | Cell area, circularity, length, maximum and minimum diameter and solidity. For each of the 8 channels: mean, median, minimum, maximum, standard deviation and the 70th, 80th, 90th, 95th and 99th percentiles in the whole cell and the membrane; mean, median, minimum, maximum and standard deviation in a 20 µm environment around the cell; mean and median in 5 erosion and 5 expansion bins. 366 measurements per cell (350 or 334 for cells too small for the inner erosion bins) |
| 6. Marker classification | [sp-classify](https://github.com/mikemcka/qupath-extension-sp-classify) QuPath extension: v0.3.6 for classifiers trained in the user interface, v0.3.7 for those trained by script (same training and prediction code) | One binary classifier per marker, labelled by hand until predictions were accurate across the cohort. Each classifier pairs [XGBoost](https://doi.org/10.1145/2939672.2939785) 2.1.4 (learning rate 0.1) and [LightGBM](https://papers.nips.cc/paper_files/paper/2017/hash/6449f44a102fde848669bdd9eb6b76fa-Abstract.html) 4.6.0 (learning rate 0.05): tree depth 6, row and column subsampling 0.8, at most 500 rounds, set by early stopping (patience 20) in 5-fold cross-validation on 80% of the training cells (class-weighted log-loss). Classes balanced with [SMOTE](https://doi.org/10.1613/jair.953) then [Tomek-link](https://doi.org/10.1109/TSMC.1976.4309452) removal. Raw measurements; no batch correction. The six calls are combined into a composite class per cell |
| 7. Target cells | `opal_pipeline_source.zip` | CCL19+ CK19− CXCL12+, in 8 classes by MS4A1, PDGFRA and PLA2G2A. Target cells whose 10 nearest cells in the same tile are on average more than 50 µm away are counted separately as isolated objects. 29,042 target cells, 28,379 without isolated objects; 97% in Batch 1 |

Container checksums (sha256):

| File | sha256 |
|---|---|
| `opal_inform_stitch.sif` | `03d17d3a8e110dc192f98292a5cc8741b7c8d3c4c1a0ac85cbab5d9a146ea924` |
| `export_multiplex_image_tiles.sif` | `685911247fb8efb9366651e64666cee7048709e717f031c0843aacf5a921055d` |
| `opal_pipeline_source.zip` | `cb21896e47e633c1e9d35179153b6005374de3befd4f90a1f89525ad8ae8a3cb` |
| `sp-classify_0.3.7.sif` | `020c5f07c44860b6b76c9ad18bc26602fa1d42c17630c8b85cc370f3a9680550` |
| `opal-python.sif` | `882632f3bfa975c730789653b7f038ca2f6985133442f694c4ebf3f1c33f42ea` |

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
