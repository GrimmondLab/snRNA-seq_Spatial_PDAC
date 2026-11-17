# Shared files

Tables and functions used by more than one stage.

| File | What it is | Used by |
|---|---|---|
| `sample_map.csv` | The 30 analysed samples: position in the analysis (`orig.ident`, the `1_`, `2_`, … prefix of cell IDs), ICGC donor ID, and sample name | Stages 3 and 4 (add ICGC IDs to figures); Stage 0 documents it |
| `label_checks.R` | R functions that read cell labels and stored UMAPs from the deposited final object by cell ID, and report how a rerun's clusters and original cluster mappings agree with those labels (heatmap, % same label) | Stages 3 and 4 |

The project image copies this folder to `/pipeline/shared/`; stage configs refer to files there by that path.

## Labels read from the deposited object

Clustering and UMAP can change with small differences in software or hardware, so a rerun is not guaranteed to give the original cluster numbers. The original code assigned labels to clusters by number, so in a different environment the same code could give the right clusters the wrong labels. Stages 3 and 4 therefore read their labels from the deposited final object, matched by cell ID, as Stage 2 does for `cell_class`. The labels were copied there from the original objects by `../snrnaseq/stage4_reclustering/add_labels_to_final_object.R`.

The clustering still runs, and each original mapping of cluster numbers to labels is still applied to the rerun clusters (columns ending in `_by_cluster`) and compared with the deposited labels using the functions in `label_checks.R`. Each comparison is shown in the stage's HTML report:

- rerun clusters against deposited labels: a heatmap of each cluster's share of cells per label, and the majority label of each cluster
- labels from the original mapping against deposited labels: % of cells with the same label, and the label pairs that differ. This % is also saved in `label_agreement.tsv`

These comparisons are a record, not a measure of reproducibility. A rerun can split or merge clusters differently (more or fewer clusters, shifted boundaries) and number them differently, so a low % same label, or a low summary score such as the adjusted Rand index (not reported for that reason), does not mean that cells no longer group together; the heatmap shows where each rerun cluster's cells fall. The labels, figures and differential expression all use the deposited labels, so they don't depend on these numbers. The stage READMEs report them only where the original mapping reproduces the labels exactly.

A run stops if any cell selected for an analysis has no deposited label, which would mean the cell selection differs from the original.
