# Stage 0: Cell Ranger and CellBender

This stage documents how the count matrices were produced. It is provided for transparency, not for rerunning: it is not part of the Docker image or `run.sh`. The outputs are deposited on GEO ([GSE282918](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE282918)), and Stage 1 starts from the CellBender output there.

Single-nucleus RNA sequencing (snRNA-seq) samples were processed in four batches, one per sequencing run. For each batch, Cell Ranger was run first, then CellBender was run on each sample to remove ambient RNA. The scripts in this folder are the SLURM scripts used on the HPC cluster, unchanged, including their original cluster paths.

**Note on reproducibility.** These steps were run several years ago on an HPC cluster whose software environment has since changed, so running the same scripts today may not give identical results. CellBender in particular trains a model and gives slightly different results between runs. This is why the processed outputs are deposited and the analysis starts from them.

## Software

| Step | Software | Settings |
|---|---|---|
| Alignment and counting | Cell Ranger 6.1.1, `cellranger count` | Reference `refdata-gex-GRCh38-2020-A` (10x Genomics), `--include-introns` (single-nucleus data) |
| Ambient RNA removal | CellBender 0.2.0, `cellbender remove-background`, run on CPU | `--expected-cells` and `--total-droplets-included` set per sample (table below); all other settings at that version's defaults |

## Files

| File | What it is |
|---|---|
| `Cellranger/<run>_cellranger_count.slurm` | Cell Ranger job for one sequencing run. Reads the list of FASTQ folders from `run_sample_details.txt` and runs `cellranger count` on each; the sample ID is the FASTQ folder name |
| `Cellbender/cellbender_<run>.slurm` | CellBender job for one sequencing run. Runs `cellbender remove-background` on each sample's `raw_feature_bc_matrix`, with that sample's settings from the matching `_sample_cellbender_args.csv` |
| `Cellbender/<run>_sample_cellbender_args.csv` | Per-sample CellBender settings as used, without a header: sample ID, `--expected-cells`, `--total-droplets-included`. These lists include samples that were processed but are not part of the 30 analysed (for example 2179, 2210, 2911) |
| `samples_cellranger_cellbender.csv` | The 30 analysed samples, each linked to its sequencing run, Cell Ranger/CellBender ID, CellBender settings and GEO file (see below) |
| `../../shared/sample_map.csv` | Sample order (`orig.ident`) and ICGC donor ID for the 30 analysed samples |

## The 30 analysed samples

`samples_cellranger_cellbender.csv` has one row per analysed sample:

| Column | Meaning |
|---|---|
| `orig_ident` | Sample position in the analysis (the `1_`, `2_`, … prefix of cell IDs) |
| `sample` | Sample name used in the analysis |
| `icgc_id` | ICGC donor ID. Some donors have two samples (two sections, or two specimens) |
| `sequencing_run` | Sequencing run, which is also the batch name in the script and settings file names |
| `cellranger_id` | Sample ID in Cell Ranger and CellBender (the FASTQ folder name) |
| `expected_cells`, `total_droplets_included` | CellBender settings for that sample |
| `geo_file` | The CellBender output for that sample on GEO |

CellBender was run with `--output <id>_cellbender.h5`. It writes several files from that name; `<id>_cellbender_filtered.h5` (cell-containing droplets only) is the one deposited on GEO and read by Stage 1.

**Naming differences between Stage 0 and the analysis:**

- Samples from run `200317_A00130_0132_AH2KMMDSXY_run_bc` have a `-GEX` suffix in Cell Ranger, CellBender and on GEO (for example `1993-GEX`). Stage 1 removes it, so the analysis name is `1993`.
- Sample 2302 was sequenced twice, in runs `190322_A00130_0097…` and `190819_A00130_0114…`, with the same ID `2302` both times. The second is the second section: Stage 1 renames it `2302-section-2` using its run ID, and it is deposited on GEO as `2302-section-2_cellbender_filtered.h5`.

The per-sample sequencing metrics from the Cell Ranger output (reads per nucleus, sequencing saturation) are in `../supplementary_qc/`.
