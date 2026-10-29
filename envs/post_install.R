# Run once at image build time, inside the snrnaseq env (see Dockerfile).
# simspec is not on conda: install it from GitHub at the commit used for the manuscript.
simspec_sha <- "f4c87bfb18522d7df0110eb63843972a29415985"
remotes::install_github(paste0("quadbio/simspec@", simspec_sha),
                        dependencies = FALSE, upgrade = "never")
stopifnot(identical(packageDescription("simspec")$RemoteSha, simspec_sha))
