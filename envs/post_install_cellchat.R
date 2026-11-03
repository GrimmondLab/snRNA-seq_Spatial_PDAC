# Run once at image build time, inside the cellchat env (see Dockerfile).
# Packages with no R 4.3 conda build at the versions used for the manuscript.
# CellChat is GitHub-only. 2.1.2 covers many commits (2024-02 to 2025-03, including changes to the
# human database). PROVISIONAL: this is the last of them; replace it with the RemoteSha of the original
# install, packageDescription("CellChat")$RemoteSha.
cellchat_sha <- "2aab4d2bbfb9e2e107066aad640304266d9e091a"

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
