suppressPackageStartupMessages({library(yaml); library(rmarkdown)})

# Usage: Rscript run_stage4.R [config.yml]
args     <- commandArgs(trailingOnly = TRUE)
cfg_file <- if (length(args) >= 1) args[1] else "config.yml"

cfg      <- yaml::read_yaml(cfg_file)
out_root <- normalizePath(cfg$output_dir, mustWork = FALSE)
# The three reclustering Rmds start from the Stage 3 non-malignant object and do not depend on each other;
# Plotting.Rmd reads what they save, so it runs last
steps    <- c("STS_Lymphoid_TNK.Rmd", "STS_Myeloid_Mast_DCs.Rmd",
              "STS_stromal_CAF_reclustering.Rmd", "Plotting.Rmd")

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
