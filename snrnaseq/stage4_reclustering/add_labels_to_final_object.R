# Adds the cell labels and subset UMAPs made in Stages 3 and 4 to the final annotated object before it is deposited.
#
# The final object (sts.simspec_css.sample.sct_final.RDS) already has Lv.1.Anno and Lv.2.Anno for every cell. Stages 3
# and 4 also need labels that are not in it: the malignant clusters, the Stage 3 labels used to pick the Stage 4 subsets,
# the subset labels and the endothelial subtypes. This script copies them from the original intermediate objects,
# matched by cell ID, so Stages 3 and 4 can read every label from the deposited object instead of from cluster numbers.
#
# Run once, on the original objects, in an R with Seurat 4 (e.g. the original analysis environment):
#   Rscript add_labels_to_final_object.R
# Apart from the label renamed back to its original name (RENAME below), existing columns, assays and reductions are not
# changed. The output is written to OUTPUT_DIR, never over the input.

suppressPackageStartupMessages({
  library(Seurat)
  library(dplyr)
})

# Paths: set these before running ---------------------------------------------------------------------------------
FINAL_OBJECT <- "/path/to/sts.simspec_css.sample.sct_final.RDS"   # Stage 4 output, input to Stage 5
ORIGINAL <- list(
  malignant    = "/path/to/malignant_object.RDS",     # STS_Malignant.Rmd: sts.malignant.simspec, with SCT_snn_res.0.1
  nonmalignant = "/path/to/sts.nonmalignant.RDS",     # STS_nonMalignant_TuftADM.Rmd: Lv.1.Anno, Lv.2.Anno
  lymphoid     = "/path/to/lymphoid.simspec.RDS",     # STS_Lymphoid_TNK.Rmd: Lv.2.Anno, umap_css
  myeloid      = "/path/to/myeloid.nonintegrated.RDS",# STS_Myeloid_Mast_DCs.Rmd: Lv.2.Anno (TAMs, DCs, Mast)
  tam          = "/path/to/mac.only.simspec.RDS",     # STS_Myeloid_Mast_DCs.Rmd: Lv.2.Anno (TAM subsets), umap_css
  caf          = "/path/to/fib.only.simspec.RDS",     # STS_stromal_CAF_reclustering.Rmd: Lv.2.Anno_subset, umap_css (last save)
  endothelial  = "/path/to/endo.RDS"                  # STS_stromal_CAF_reclustering.Rmd: cell_names
)
OUTPUT_DIR <- "/path/to/output"

# What to copy: source object, metadata column, new column name in the final object ----------------------------------
LABELS <- tibble::tribble(
  ~source,        ~column,             ~new_column,
  "malignant",    "SCT_snn_res.0.1",   "stage3_malignant_SCT_snn_res.0.1",
  "nonmalignant", "Lv.1.Anno",         "stage3_Lv.1.Anno",
  "nonmalignant", "Lv.2.Anno",         "stage3_Lv.2.Anno",
  "lymphoid",     "Lv.2.Anno",         "stage4_lymphoid_Lv.2.Anno",
  "myeloid",      "Lv.2.Anno",         "stage4_myeloid_Lv.2.Anno",
  "tam",          "Lv.2.Anno",         "stage4_TAM_Lv.2.Anno",
  "caf",          "Lv.2.Anno_subset",  "stage4_CAF_Lv.2.Anno_subset",
  "endothelial",  "cell_names",        "stage4_endothelial_cell_names"
)
# UMAPs plotted in Fig. 1C, stored as two columns each
UMAPS <- tibble::tribble(
  ~source,    ~reduction, ~prefix,
  "lymphoid", "umap_css", "stage4_lymphoid_UMAP",
  "tam",      "umap_css", "stage4_TAM_UMAP",
  "caf",      "umap_css", "stage4_CAF_UMAP"
)

dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)
if (normalizePath(OUTPUT_DIR) == dirname(normalizePath(FINAL_OBJECT))) stop("OUTPUT_DIR must not be the folder of FINAL_OBJECT")

final <- readRDS(FINAL_OBJECT)

# Labels renamed by hand after Plotting.Rmd, before the object was saved. The manuscript and the code (Plotting.Rmd,
# Cellchat.Rmd) use the original names, so they are restored here. Every other column, assay and reduction is unchanged.
RENAME <- c("TAMs_HLA+" = "TAMs_MHC_II")
for (col in colnames(final@meta.data)) {
  x <- final@meta.data[[col]]
  if (!(is.character(x) || is.factor(x)) || !any(as.character(x) %in% names(RENAME))) next
  n <- sum(as.character(x) %in% names(RENAME))
  if (is.factor(x)) {
    levels(x)[levels(x) %in% names(RENAME)] <- RENAME[levels(x)[levels(x) %in% names(RENAME)]]
  } else {
    x[x %in% names(RENAME)] <- RENAME[x[x %in% names(RENAME)]]
  }
  final@meta.data[[col]] <- x
  message("Renamed in ", col, ": ", n, " cells (", paste(names(RENAME), "->", RENAME, collapse = ", "), ")")
}
ids <- Idents(final)
if (any(levels(ids) %in% names(RENAME))) {
  levels(ids)[levels(ids) %in% names(RENAME)] <- RENAME[levels(ids)[levels(ids) %in% names(RENAME)]]
  Idents(final) <- ids
}
stopifnot(!any(unlist(lapply(final@meta.data, function(x) as.character(x) %in% names(RENAME)))))

meta_before <- final@meta.data
stopifnot(!any(c(LABELS$new_column, paste0(UMAPS$prefix, "_", 1:2)) %in% colnames(meta_before)))
if ("Cell_Ids" %in% colnames(meta_before)) stopifnot(identical(as.character(final$Cell_Ids), colnames(final)))

added <- data.frame(Cell_Ids = colnames(final), row.names = colnames(final))
summary_rows <- list()

for (src in names(ORIGINAL)) {
  message(">>> ", src, ": ", ORIGINAL[[src]])
  obj <- readRDS(ORIGINAL[[src]])
  ids <- colnames(obj)
  if ("Cell_Ids" %in% colnames(obj@meta.data)) stopifnot(identical(as.character(obj$Cell_Ids), ids))
  missing <- setdiff(ids, colnames(final))
  if (length(missing) > 0) stop(src, ": ", length(missing), " cells are not in the final object, e.g. ", missing[1])

  for (i in which(LABELS$source == src)) {
    col <- LABELS$column[i]
    if (!col %in% colnames(obj@meta.data)) stop(src, ": no column ", col, " (use the last saved version of this object)")
    added[[LABELS$new_column[i]]] <- NA_character_
    added[ids, LABELS$new_column[i]] <- as.character(obj@meta.data[[col]])
    summary_rows[[length(summary_rows) + 1]] <- data.frame(
      source = src, column = LABELS$new_column[i], cells = length(ids),
      labelled = sum(!is.na(obj@meta.data[[col]])), labels = length(unique(na.omit(obj@meta.data[[col]]))))
  }
  for (i in which(UMAPS$source == src)) {
    emb <- Embeddings(obj, reduction = UMAPS$reduction[i])
    stopifnot(identical(rownames(emb), ids))
    for (k in 1:2) {
      col <- paste0(UMAPS$prefix[i], "_", k)
      added[[col]] <- NA_real_
      added[ids, col] <- emb[, k]
    }
    summary_rows[[length(summary_rows) + 1]] <- data.frame(
      source = src, column = paste0(UMAPS$prefix[i], "_1/_2"), cells = length(ids), labelled = nrow(emb), labels = NA)
  }
  rm(obj); gc()
}

# Check the copied subset labels against the final Lv.2.Anno: they should agree, apart from labels Plotting.Rmd names
# differently ("Vascular smooth muscle" is "vSMC" in the final object). Original run, before RENAME was added:
# lymphoid 100% of 8033 cells; TAM 84.58% of 5797 (all 894 others TAMs_MHC_II vs TAMs_HLA+); CAF 98.91% of 7924
# (all 86 others Vascular smooth muscle vs vSMC). With RENAME, TAM is expected to be 100%.
for (col in c("stage4_lymphoid_Lv.2.Anno", "stage4_TAM_Lv.2.Anno", "stage4_CAF_Lv.2.Anno_subset")) {
  has <- !is.na(added[[col]])
  message(col, ": same as the final Lv.2.Anno for ",
          round(100 * mean(added[[col]][has] == as.character(final$Lv.2.Anno[has])), 2), "% of ", sum(has), " cells")
  print(table(copied = added[[col]][has], final = as.character(final$Lv.2.Anno[has])) %>% as.data.frame() %>%
          dplyr::filter(Freq > 0, as.character(copied) != as.character(final)))
}

final <- AddMetaData(final, metadata = added[, -1, drop = FALSE])

# Existing columns must be unchanged
stopifnot(identical(final@meta.data[, colnames(meta_before)], meta_before))

summary_table <- bind_rows(summary_rows)
print(summary_table)
write.table(summary_table, file.path(OUTPUT_DIR, "added_labels_summary.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.csv(added, gzfile(file.path(OUTPUT_DIR, "added_labels.csv.gz")), row.names = FALSE)
saveRDS(final, file.path(OUTPUT_DIR, basename(FINAL_OBJECT)))
writeLines(capture.output(sessionInfo()), file.path(OUTPUT_DIR, "sessionInfo_add_labels_to_final_object.txt"))
message(">>> done: ", file.path(OUTPUT_DIR, basename(FINAL_OBJECT)))
