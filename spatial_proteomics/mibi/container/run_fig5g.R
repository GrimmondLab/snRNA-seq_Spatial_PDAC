# Runs the MIBI cell-cell interaction analysis (Fig. 5G) in the container.
#
# Usage: Rscript run_fig5g.R <spe.rds> <output folder> [workers] [seed]
#   spe.rds  the SpatialExperiment from Zenodo 10.5281/zenodo.24360405
#   workers  parallel workers for the permutation test (default 8, as in the original script)
#   seed     optional random seed for the permutation test. The original analysis set none, so the
#            default is none; with a seed, a rerun gives the same result as the previous run with that seed
#
# The analysis script (Fig5g_heatmap_cell_cell_comm.R) is run as it is in the repository, from a working folder
# where rdata/spe.rds points to the input. Only its BiocParallel line is changed, to set the number of workers
# and, if given, the seed. The script's own plot function then makes the heatmap.
#
# Outputs:
#   Fig5g_cell_cell_interactions_exp50.pdf  heatmap of significance values summed across FOVs (Fig. 5G)
#   Fig5g_summed_sigval.csv                 the values in the heatmap
#   testInteractions_exp50_per_FOV.csv      testInteractions result for every FOV and cell-type pair
#   run_info.txt                            input checksum, settings and sessionInfo()

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2 || length(args) > 4) {
  stop("Usage: run_fig5g.R <spe.rds> <output folder> [workers] [seed]", call. = FALSE)
}
spe_path <- normalizePath(args[1], mustWork = TRUE)
out_dir <- args[2]
workers <- if (length(args) >= 3) as.integer(args[3]) else 8L
seed <- if (length(args) >= 4) as.integer(args[4]) else NA_integer_
stopifnot("workers must be a positive integer" = !is.na(workers) && workers >= 1)
if (length(args) >= 4) stopifnot("seed must be an integer" = !is.na(seed))

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
out_dir <- normalizePath(out_dir)

script_path <- "/opt/mibi/Fig5g_heatmap_cell_cell_comm.R"
script <- readLines(script_path, encoding = "UTF-8")
bpp_line <- 'bpp <- SnowParam(workers = 8, type = "SOCK")'
hit <- which(trimws(script) == bpp_line)
if (length(hit) != 1) stop("Expected one line '", bpp_line, "' in ", script_path, call. = FALSE)
script[hit] <- if (is.na(seed)) {
  sprintf('bpp <- SnowParam(workers = %d, type = "SOCK")', workers)
} else {
  sprintf('bpp <- SnowParam(workers = %d, type = "SOCK", RNGseed = %d)', workers, seed)
}

# The script reads rdata/spe.rds relative to its working folder
work_dir <- file.path(tempdir(), "fig5g")
dir.create(file.path(work_dir, "rdata"), recursive = TRUE, showWarnings = FALSE)
file.symlink(spe_path, file.path(work_dir, "rdata", "spe.rds"))
old_wd <- setwd(work_dir)

started <- Sys.time()
analysis <- new.env()
eval(parse(text = script, keep.source = FALSE), envir = analysis)
finished <- Sys.time()
setwd(old_wd)

out <- analysis$out_exp50
summed <- as.data.frame(out) |>
  dplyr::filter(from_label != "Other", to_label != "Other") |>
  dplyr::group_by(from_label, to_label) |>
  dplyr::summarize(sum_sigval = sum(sigval, na.rm = TRUE), .groups = "drop")

write.csv(as.data.frame(out), file.path(out_dir, "testInteractions_exp50_per_FOV.csv"), row.names = FALSE)
write.csv(summed, file.path(out_dir, "Fig5g_summed_sigval.csv"), row.names = FALSE)

heatmap <- analysis$plot_interactions(out, plot_title = "Spatial graph with radius 50")
ggplot2::ggsave(file.path(out_dir, "Fig5g_cell_cell_interactions_exp50.pdf"), heatmap, width = 8, height = 7)

writeLines(c(
  paste("Input:", spe_path),
  paste("Input md5:", unname(tools::md5sum(spe_path)), "(Zenodo 24360405: 598e75d349e9aca23fcb8a5eadbdee6b)"),
  paste("Workers:", workers),
  paste("Seed:", if (is.na(seed)) "none (as in the original analysis)" else seed),
  paste("Run time:", format(round(difftime(finished, started, units = "mins"), 1))),
  paste("Cells:", ncol(analysis$spe), " FOVs:", length(unique(analysis$spe$sample_id))),
  "",
  capture.output(sessionInfo())
), file.path(out_dir, "run_info.txt"))

cat("Done. Outputs in", out_dir, "\n")
