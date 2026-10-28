# Finds the GEO processed files (CellBender output) for each sample and returns paths for read10xCounts.
#
# GEO holds each sample in two forms (a GSM accession in front of the name is allowed, e.g.
# GSM1234567_1971_cellbender_filtered.h5, and files may sit in subfolders):
#   format = "h5"  (default): the CellBender .h5 file, the same file the original run read
#                             1971_cellbender_filtered.h5
#   format = "mtx": the three 10x matrix files
#                   1971_barcodes.tsv.gz, 1971_features.tsv.gz, 1971_matrix.mtx.gz
# For "h5" the file is used as it is. For "mtx", read10xCounts needs one folder per sample with
# unprefixed names, so each sample gets a folder under `stage_dir` with links to its three files
# (input files are not modified). All samples use the same format, so the loaded objects match.
#
# geo_samples.csv links each GEO entry to the sample name used in the analysis. Its `order` column
# sets the loading order, which must match the original run: read10xCounts prefixes cell IDs with
# the sample's position (1_, 2_, ...), and later steps rely on those IDs.

stage_geo_samples <- function(geo.samples, geo_dir, stage_dir, format = c("h5", "mtx")) {
  format <- match.arg(format)
  stopifnot(all(c("order", "file_prefix", "sample") %in% colnames(geo.samples)),
            !anyDuplicated(geo.samples$sample))
  if (anyNA(geo.samples$order)) {
    stop("geo_samples.csv has no sample order yet. Fill the `order` column from ",
         "sample_order.csv written by a local-mode run.")
  }
  geo.samples <- geo.samples[order(geo.samples$order), ]

  all.files  <- list.files(geo_dir, full.names = TRUE, recursive = TRUE)
  base.names <- sub("^GSM[0-9]+_", "", basename(all.files))

  find_one <- function(names) {
    hit <- all.files[base.names %in% names]
    if (length(hit) != 1) {
      stop("Expected one file named ", paste(names, collapse = " or "), " in ", geo_dir,
           ", found ", length(hit))
    }
    hit
  }

  paths <- vapply(seq_len(nrow(geo.samples)), function(i) {
    prefix <- geo.samples$file_prefix[i]

    if (format == "h5") {
      return(normalizePath(find_one(paste0(prefix, "_cellbender_filtered.h5"))))
    }

    dest <- file.path(stage_dir, geo.samples$sample[i])
    dir.create(dest, recursive = TRUE, showWarnings = FALSE)
    for (part in c("barcodes.tsv", "features.tsv", "matrix.mtx")) {
      hit    <- find_one(paste0(prefix, "_", part, c("", ".gz")))
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

  setNames(paths, geo.samples$sample)
}
