# Helpers for Stages 3 and 4: read cell labels from the deposited final object by cell ID, and report how well a rerun
# agrees with them.
#
# Clustering and UMAP can change with small differences in software or hardware, so the cluster numbers of a rerun are
# not guaranteed to match the original ones. Each stage therefore still reruns its clustering, but takes its labels from
# the deposited object, matched by cell ID. The original mapping of cluster numbers to labels is kept and applied to the
# rerun clusters, and both are compared with the deposited labels:
#   - deposited_labels():   the labels, with a stop if any cell has none
#   - compare_clusters():   rerun clusters vs deposited labels: ARI, heatmap, majority label per cluster
#   - compare_labels():     labels from the original mapping applied to the rerun vs deposited labels: % same, ARI,
#                           and the cells that differ
#   - read_nonmalignant():  Stage 4 input, the Stage 3 non-malignant cells of the final object with their Stage 3 labels
#   - use_deposited_umap(): the stored subset UMAP, for Fig. 1C
# Each comparison is printed in the HTML report and appended to label_agreement.tsv in the stage's output folder.

suppressPackageStartupMessages(library(pheatmap))

# Adjusted Rand index (Hubert and Arabie, 1985) of two labellings of the same cells
adjusted_rand_index <- function(a, b) {
  stopifnot(length(a) == length(b))
  tab <- table(as.character(a), as.character(b))
  pairs <- function(n) n * (n - 1) / 2
  index <- sum(pairs(tab))
  rows <- sum(pairs(rowSums(tab)))
  cols <- sum(pairs(colSums(tab)))
  expected <- rows * cols / pairs(sum(tab))
  maximum <- (rows + cols) / 2
  if (maximum == expected) return(1)
  (index - expected) / (maximum - expected)
}

# Labels of the cells of `object` from metadata column `column`, which was copied into the deposited final object
# (see snrnaseq/stage4_reclustering/add_labels_to_final_object.R). Stops if the column is missing or any cell has no label.
deposited_labels <- function(object, column) {
  if (!column %in% colnames(object@meta.data)) {
    stop("Column ", column, " is not in the object. Use the deposited sts.simspec_css.sample.sct_final.RDS.")
  }
  labels <- object@meta.data[[column]]
  if (anyNA(labels)) stop(sum(is.na(labels)), " of ", length(labels), " cells have no ", column)
  setNames(as.character(labels), colnames(object))
}

record_agreement <- function(step_dir, row) {
  file <- file.path(step_dir, "label_agreement.tsv")
  write.table(row, file, sep = "\t", quote = FALSE, row.names = FALSE,
              append = file.exists(file), col.names = !file.exists(file))
}

# Rerun clusters against deposited labels. Shows a heatmap (share of each cluster's cells per label) and returns one
# row per cluster with its majority label.
compare_clusters <- function(clusters, labels, title, step_dir) {
  clusters <- as.character(clusters)
  labels <- as.character(labels)
  ari <- adjusted_rand_index(clusters, labels)
  counts <- table(cluster = clusters, label = labels)
  counts <- counts[order(suppressWarnings(as.numeric(rownames(counts)))), , drop = FALSE]
  shares <- prop.table(counts, margin = 1)
  pheatmap(unclass(shares), cluster_rows = FALSE, cluster_cols = FALSE,
           color = colorRampPalette(c("white", "darkred"))(50),
           main = sprintf("%s (ARI %.3f)", title, ari))
  record_agreement(step_dir, data.frame(comparison = title, type = "rerun clusters vs deposited labels",
                                        cells = length(labels), ari = round(ari, 4), same_label_pct = NA))
  data.frame(cluster = rownames(shares),
             cells = as.vector(rowSums(counts)),
             majority_label = colnames(shares)[apply(shares, 1, which.max)],
             majority_share_pct = round(100 * apply(shares, 1, max), 1))
}

# Labels from the original cluster mapping applied to the rerun, against deposited labels. NA (a rerun cluster that the
# original mapping doesn't name) counts as a difference. Returns the label pairs that differ, with cell counts.
compare_labels <- function(by_cluster, labels, title, step_dir) {
  by_cluster <- as.character(by_cluster)
  labels <- as.character(labels)
  same <- !is.na(by_cluster) & by_cluster == labels
  ari <- adjusted_rand_index(ifelse(is.na(by_cluster), "<none>", by_cluster), labels)
  message(sprintf("%s: same label for %.2f%% of %d cells (ARI %.3f)", title, 100 * mean(same), length(same), ari))
  record_agreement(step_dir, data.frame(comparison = title, type = "original mapping on rerun vs deposited labels",
                                        cells = length(labels), ari = round(ari, 4),
                                        same_label_pct = round(100 * mean(same), 2)))
  differ <- as.data.frame(table(by_cluster = ifelse(is.na(by_cluster), "<none>", by_cluster)[!same],
                                deposited = labels[!same]), stringsAsFactors = FALSE)
  differ <- differ[differ$Freq > 0, , drop = FALSE]
  differ[order(-differ$Freq), , drop = FALSE]
}

# Stage 4 input: the Stage 3 non-malignant cells of the deposited final object (those with a stage3_Lv.1.Anno), with the
# Stage 3 Lv.1.Anno and Lv.2.Anno. This replaces the Stage 3 output sts.nonmalignant.RDS. Only the RNA assay is kept: it
# is the same as in sts.nonmalignant.RDS, and every Stage 4 analysis of these cells either uses the RNA assay or runs
# SCTransform again. The final object's own Lv.1.Anno and Lv.2.Anno (the final labels) are kept as final_Lv.1.Anno and
# final_Lv.2.Anno.
read_nonmalignant <- function(path) {
  object <- readRDS(path)
  stopifnot("stage3_Lv.1.Anno" %in% colnames(object@meta.data))
  object <- subset(object, cells = colnames(object)[!is.na(object$stage3_Lv.1.Anno)])
  DefaultAssay(object) <- "RNA"
  object <- DietSeurat(object, assays = "RNA", counts = TRUE, data = TRUE)
  object$final_Lv.1.Anno <- object$Lv.1.Anno
  object$final_Lv.2.Anno <- object$Lv.2.Anno
  object$Lv.1.Anno <- deposited_labels(object, "stage3_Lv.1.Anno")
  object$Lv.2.Anno <- deposited_labels(object, "stage3_Lv.2.Anno")
  message("Non-malignant cells from the final object: ", ncol(object))
  object
}

# Replaces the rerun UMAP `reduction` with the original one stored in the final object (columns <prefix>_1, <prefix>_2),
# for the figures. UMAP layouts change with small differences in software, so the published figure is drawn from the
# stored coordinates. The rerun UMAP is kept as <reduction>_rerun.
use_deposited_umap <- function(object, prefix, reduction = "umap_css") {
  coords <- as.matrix(object@meta.data[, paste0(prefix, "_", 1:2)])
  if (anyNA(coords)) stop(sum(rowSums(is.na(coords)) > 0), " cells have no stored ", prefix, " coordinates")
  old <- object[[reduction]]
  key <- Key(old)
  rerun <- Embeddings(old)[, 1:2]
  colnames(rerun) <- paste0("rerun", key, 1:2)
  colnames(coords) <- paste0(key, 1:2)
  object[[reduction]] <- NULL
  object[[paste0(reduction, "_rerun")]] <- CreateDimReducObject(embeddings = rerun, key = paste0("rerun", key),
                                                                assay = DefaultAssay(old))
  object[[reduction]] <- CreateDimReducObject(embeddings = coords, key = key, assay = DefaultAssay(old))
  object
}
