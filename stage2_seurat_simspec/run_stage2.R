suppressPackageStartupMessages({library(yaml); library(rmarkdown)})

# Usage: Rscript run_stage2.R [config.yml]
args     <- commandArgs(trailingOnly = TRUE)
cfg_file <- if (length(args) >= 1) args[1] else "config.yml"

cfg      <- yaml::read_yaml(cfg_file)
out_root <- normalizePath(cfg$output_dir, mustWork = FALSE)
steps    <- c("Seurat_sample_based.Rmd", "PDAC_STS_simspec_integration.Rmd")

for (s in steps) {
  step_name <- tools::file_path_sans_ext(s)
  step_dir  <- file.path(out_root, step_name)
  dir.create(step_dir, recursive = TRUE, showWarnings = FALSE)
  message(">>> ", format(Sys.time()), " running ", s)

  # intermediates go to step_dir so the code folder can stay read-only (e.g. Apptainer)
  rmarkdown::render(s,
                    output_dir = step_dir,
                    intermediates_dir = step_dir,
                    params     = list(cfg = cfg, step_dir = step_dir, out_root = out_root),
                    envir      = new.env(),
                    knit_root_dir = getwd())
}
message(">>> done")
