# Original inferCNV code

`InferCNV_original.Rmd` is the R Markdown file used for the manuscript analysis, kept unchanged as the record. It runs inferCNV separately for each of the 30 samples, with one code section per sample.

`../InferCNV.Rmd` runs the same analysis as a single loop over `../infercnv_samples.csv`. That table was extracted from this file and holds, for each sample:

- the cells included (`subset_by` and `cell_classes`)
- the reference groups (`ref_groups`)
- the Leiden resolution (`leiden_resolution`)
- `up_to_step`, where it was set (left empty for 2215, which the author confirmed was run in full)
- the original output folder and annotation file names

All other `infercnv::run()` settings are the same for every sample in this file and are set once in the loop.

Differences between this file and `../InferCNV.Rmd`:

- Paths come from `../config.yml` instead of home-folder paths.
- The `gtf_to_position_file.py` command (an R chunk here, which stops knitting) is documented in `../README.md` instead of run. `gene_positions.txt` is provided as an input file.
- Sample 2992 reloads the same object and reads `gene_positions.txt` from another folder (`data/` instead of `inferCNV_old_Jun24/`). `../InferCNV.Rmd` uses one `gene_positions.txt` for all samples.

Neither file sets a random seed, so the Leiden subclustering and the MCMC step vary between runs (see `../README.md`).
