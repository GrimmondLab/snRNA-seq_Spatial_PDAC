# Run once at image build time, inside the downstream env (see Dockerfile).
# GitHub-only packages, at the commits used for the manuscript.
# treeio 1.25.0.001 is a development version (Bioconductor 3.17 has 1.24.x); the only commit with
# this version number is 7c32644 (2023-05-31). It replaces the treeio that conda installs as a
# dependency of ggtree / clusterProfiler.
treeio_sha  <- "7c3264453901861da9b564b15b7b4e8377f8a8ee"
# simspec, at the same commit as Stage 2
simspec_sha <- "f4c87bfb18522d7df0110eb63843972a29415985"
remotes::install_github(paste0("YuLab-SMU/treeio@", treeio_sha),
                        dependencies = FALSE, upgrade = "never")
remotes::install_github(paste0("quadbio/simspec@", simspec_sha),
                        dependencies = FALSE, upgrade = "never")
stopifnot(identical(packageDescription("treeio")$RemoteSha, treeio_sha),
          packageVersion("treeio") == "1.25.0.001",  # as.character() would give "1.25.0.1"
          identical(packageDescription("simspec")$RemoteSha, simspec_sha))
