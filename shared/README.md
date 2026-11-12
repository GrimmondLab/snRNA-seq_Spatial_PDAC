# Shared files

Tables and functions used by more than one stage.

| File | What it is | Used by |
|---|---|---|
| `sample_map.csv` | The 30 analysed samples: position in the analysis (`orig.ident`, the `1_`, `2_`, … prefix of cell IDs), ICGC donor ID, and sample name | Stages 3 and 4 (add ICGC IDs to figures); Stage 0 documents it |
| `label_checks.R` | R functions that read cell labels and stored UMAPs from the deposited final object by cell ID, and report how a rerun's clusters and original cluster mappings agree with those labels (ARI, % same label, heatmap) | Stages 3 and 4 |

The project image copies this folder to `/pipeline/shared/`; stage configs refer to files there by that path.
