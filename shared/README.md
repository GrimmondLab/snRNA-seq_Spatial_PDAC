# Shared files

Tables used by more than one stage.

| File | What it is | Used by |
|---|---|---|
| `sample_map.csv` | The 30 analysed samples: position in the analysis (`orig.ident`, the `1_`, `2_`, … prefix of cell IDs), ICGC donor ID, and sample name | Stage 3 (adds ICGC IDs to figures); Stage 0 documents it |

Stage images that need a shared file are built from the repository root so that the file is copied into the image (see each stage's README).
