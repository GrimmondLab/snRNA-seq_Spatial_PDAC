# Usage: Rscript session_info.R <out_file> <pkg> [<pkg> ...]
# Attaches the packages the Rmds load and saves sessionInfo() as a record of the image.
args <- commandArgs(trailingOnly = TRUE)
suppressPackageStartupMessages(for (p in args[-1]) library(p, character.only = TRUE))
writeLines(c("Session information recorded while building the Docker image",
             capture.output(sessionInfo())),
           args[1])
