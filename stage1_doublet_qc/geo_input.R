# Prepares the GEO processed files (CellBender output as 10x matrix files) for read10xCounts.
#
# GEO stores each sample as three prefixed files, e.g.
#   2302-section-2_barcodes.tsv.gz, 2302-section-2_features.tsv.gz, 2302-section-2_matrix.mtx.gz
# (optionally with a GSM accession in front: GSM1234567_2302-section-2_barcodes.tsv.gz).
# read10xCounts needs one folder per sample with unprefixed names, so each sample gets a folder
# under `stage_dir` with links to its three files (input files are not modified).
#
# geo_samples.csv links each GEO entry to the sample name used in the analysis. Its `order` column
# sets the loading order, which must match the original run: read10xCounts prefixes cell IDs with
# the sample's position (1_, 2_, ...), and later steps rely on those IDs.

stage_geo_samples <- function(geo.samples, geo_dir, stage_dir) {
  stopifnot(all(c("order", "file_prefix", "sample") %in% colnames(geo.samples)),
            !anyDuplicated(geo.samples$sample))
  if (anyNA(geo.samples$order)) {
    stop("geo_samples.csv has no sample order yet. Fill the `order` column from ",
         "sample_order.csv written by a local-mode run.")
  }
  geo.samples <- geo.samples[order(geo.samples$order), ]

  all.files  <- list.files(geo_dir, full.names = TRUE, recursive = TRUE)
  base.names <- sub("^GSM[0-9]+_", "", basename(all.files))

  dirs <- vapply(seq_len(nrow(geo.samples)), function(i) {
    prefix <- geo.samples$file_prefix[i]
    dest   <- file.path(stage_dir, geo.samples$sample[i])
    dir.create(dest, recursive = TRUE, showWarnings = FALSE)

    for (part in c("barcodes.tsv", "features.tsv", "matrix.mtx")) {
      hit <- all.files[base.names %in% paste0(prefix, "_", part, c("", ".gz"))]
      if (length(hit) != 1) {
        stop("Expected one file for ", prefix, "_", part, "(.gz) in ", geo_dir,
             ", found ", length(hit))
      }
      target <- file.path(dest, paste0(part, ".gz"))
      if (file.exists(target)) file.remove(target)
      if (grepl("\\.gz$", hit)) {
        file.symlink(normalizePath(hit), target)
      } else {
        R.utils::gzip(hit, destname = target, remove = FALSE)
      }
    }
    dest
  }, character(1))

  setNames(dirs, geo.samples$sample)
}
