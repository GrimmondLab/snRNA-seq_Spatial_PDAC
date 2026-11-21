# Container: MIBI cell–cell interaction analysis (Fig. 5G)

An Apptainer container that runs `Fig5g_heatmap_cell_cell_comm.R` with the R and package versions of the original analysis (`Cell_cell_interaction_sessioninfo.txt`). It covers only this analysis; the upstream MIBI steps (segmentation, measurement, cell typing) have their own container on Zenodo, [10.5281/zenodo.24356840](https://doi.org/10.5281/zenodo.24356840).

**Status (2026-11-20):** built on Spartan with `apptainer build --fakeroot`; all 21 recorded package versions match. Run on Spartan from the Zenodo `spe.rds` (8 workers, no seed, as in the original): the heatmap matches Fig. 5G.

## Download

The built container, `mibi_interactions.sif`, is on Zenodo, [10.5281/zenodo.24394013](https://doi.org/10.5281/zenodo.24394013) (1.7 GB; md5 `6af775b660a4bfc805fb1de6d6f03557`, as listed on Zenodo). To use it, download it with `spe.rds` and go to [Run](#run); building is only needed to check or change the environment.

Check the download:

```bash
sha256sum mibi_interactions.sif
# expected: c9883cf59287ec1a69d0db6f53bfa5dcd0916a5d6935e1a05283cac37c34afd2
```

## Environment

| | Version | Source |
|---|---|---|
| Base image | `bioconductor/bioconductor_docker:3.21-R-4.5.1`, pinned by digest | Docker Hub |
| R | 4.5.1 | Base image |
| Bioconductor packages | Release 3.21; BiocGenerics 0.54.0 and GenomeInfoDb 1.44.2 from the 3.21 archive (the release has since updated them) | bioconductor.org |
| CRAN packages | Snapshot of 2025-11-01 | Posit Public Package Manager |

All 21 attached packages recorded in the original session (imcRtools 1.14.0, SpatialExperiment 1.18.1, ggplot2 4.0.0 and the others) are installed at the recorded version. The build stops if any differs. The installed versions are in `/opt/mibi/package_versions.tsv` in the container. Differences from the original: Ubuntu 24.04 instead of Red Hat Enterprise Linux 9.3, and the dependencies that were not recorded (they come from the same release and snapshot).

## Files

| File | Purpose |
|---|---|
| `mibi_interactions.def` | Apptainer definition |
| `install_packages.R` | Installs and checks the package versions during the build |
| `run_fig5g.R` | Runs the analysis script and saves the heatmap, its values and the per-FOV results |
| `mibi_interactions_spartan.slurm` | Builds the container and runs the analysis on Spartan |

## Build

From `spatial_proteomics/mibi` (the paths in the definition are relative to it), on Linux with Apptainer:

```bash
cd spatial_proteomics/mibi
apptainer build --fakeroot mibi_interactions.sif container/mibi_interactions.def
```

## Run

With `spe.rds` from Zenodo [10.5281/zenodo.24360404](https://doi.org/10.5281/zenodo.24360404) (md5 `598e75d349e9aca23fcb8a5eadbdee6b`):

```bash
apptainer run --cleanenv --no-home -B <folder with spe.rds>:/data:ro -B <output folder>:/output \
  mibi_interactions.sif /data/spe.rds /output 8
```

Arguments: input, output folder, number of workers (default 8) and, optionally, a random seed.

`run_fig5g.R` runs the analysis script unchanged, except for its BiocParallel line, which sets the number of workers and the seed. Outputs:

| File | Contents |
|---|---|
| `Fig5g_cell_cell_interactions_exp50.pdf` | Heatmap of the significance values summed across FOVs (Fig. 5G) |
| `Fig5g_summed_sigval.csv` | The values in the heatmap |
| `testInteractions_exp50_per_FOV.csv` | `testInteractions` result for every FOV and cell-type pair |
| `run_info.txt` | Input checksum, workers, seed, run time and `sessionInfo()` |

**Random seed.** The original analysis set no seed, so a rerun can differ slightly from Fig. 5G for cell-type pairs near the significance threshold (p = 0.01). Compare the pattern of interactions (red) and avoidances (blue) with Fig. 5G rather than the exact values. With a seed, reruns give identical results.
