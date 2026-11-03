# Run once at image build time, inside the cellchat env (see Dockerfile).
# Packages with no R 4.3 conda build at the versions used for the manuscript.
# CellChat is GitHub-only. 2.1.2 covers many commits, including changes to the human database;
# this is the RemoteSha of the original install (2024-09-07).
cellchat_sha <- "6063355ab8c06a55c61add6a07bc35c94cc962a0"

# dplyr 1.2.1 needs rlang >= 1.1.7, vctrs >= 0.7.1 and lifecycle >= 1.0.5, so they are installed first.
# These replace the conda builds of the same packages.
cran <- c(cli = "3.6.6", rlang = "1.3.0", lifecycle = "1.0.5", vctrs = "0.7.3",
          tidyr = "1.3.2", dplyr = "1.2.1", NMF = "0.27")
for (p in names(cran)) {
  remotes::install_version(p, version = cran[[p]], repos = "https://cloud.r-project.org",
                           dependencies = FALSE, upgrade = "never")
}
remotes::install_github(paste0("jinworks/CellChat@", cellchat_sha),
                        dependencies = FALSE, upgrade = "never")

stopifnot(identical(packageDescription("CellChat")$RemoteSha, cellchat_sha),
          packageVersion("CellChat") == "2.1.2")
for (p in names(cran)) stopifnot(packageVersion(p) == cran[[p]])
