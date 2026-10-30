# Shared files

Tables used by more than one stage.

| File | What it is | Used by |
|---|---|---|
| `sample_map.csv` | The 30 analysed samples: position in the analysis (`orig.ident`, the `1_`, `2_`, … prefix of cell IDs), ICGC donor ID, and sample name | Stage 3 (adds ICGC IDs to figures); Stage 0 documents it |

The project image copies this folder to `/pipeline/shared/`; stage configs refer to files there by that path.
