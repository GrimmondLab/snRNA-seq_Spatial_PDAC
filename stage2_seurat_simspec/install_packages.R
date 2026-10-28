# Installs the R packages for Stage 2 at fixed versions.
# Run once at image build time (see Dockerfile).
#
# The original environment (sessionInfo/) was R 4.4.0 with Bioconductor 3.17 packages, Seurat 4.3.0
# and Matrix 1.7-5. Bioconductor 3.17 is officially for R 4.3, so BiocManager would refuse it on
# R 4.4; the packages are installed straight from the Bioconductor 3.17 repository instead.
#
# CRAN: Posit Package Manager snapshot of 2023-06-15 (Seurat 4.3.0, dplyr 1.1.2, ggplot2 3.4.2),
# plus the newer versions listed below.

cran_snapshot <- "https://packagemanager.posit.co/cran/__linux__/jammy/2023-06-15"
cran_archive  <- "https://cloud.r-project.org"
bioc_317      <- "https://bioconductor.org/packages/3.17"
bioc_archive  <- paste0(bioc_317, "/bioc/src/contrib/Archive")

options(repos = c(CRAN      = cran_snapshot,
                  BioCsoft  = paste0(bioc_317, "/bioc"),
                  BioCann   = paste0(bioc_317, "/data/annotation"),
                  BioCexp   = paste0(bioc_317, "/data/experiment")),
        Ncpus = max(1L, parallel::detectCores() - 1L))

install_archive <- function(url) install.packages(url, repos = NULL, type = "source")

# ---- Matrix first, so everything else is compiled against it ----
install_archive(paste0(cran_archive, "/src/contrib/Archive/Matrix/Matrix_1.7-5.tar.gz"))

# ---- CRAN + Bioconductor 3.17 ----
install.packages(c("remotes", "yaml", "rmarkdown", "knitr",
                   "Seurat", "SeuratObject", "sctransform",
                   "tidyverse", "dplyr", "ggplot2", "patchwork", "pheatmap", "dichromat",
                   "RColorBrewer", "clustree", "ggraph",
                   "mixtools", "RANN", "irlba", "igraph",          # simspec dependencies
                   "SingleCellExperiment", "scuttle", "BiocSingular", "BiocParallel",
                   "bluster", "glmGamPoi"))

# ---- Newer than the snapshot date, matched to sessionInfo/ ----
cran_pinned <- c(matrixStats = "1.2.0",   # used via MatrixGenerics
                 RcppAnnoy   = "0.0.21",  # nearest neighbours for FindNeighbors and RunUMAP
                 uwot        = "0.1.16",  # RunUMAP
                 scales      = "1.3.0",
                 clustree    = "0.5.1",
                 rmarkdown   = "2.23")
for (pkg in names(cran_pinned)) {
  remotes::install_version(pkg, version = cran_pinned[[pkg]], repos = cran_archive, upgrade = "never")
}

# Bioconductor only serves the latest patch of a release; older patches come from its archive.
# Order matters: dependencies first.
bioc_pinned <- c(S4Vectors          = "0.38.1",
                 GenomeInfoDb       = "1.36.1",
                 GenomicRanges      = "1.52.0",
                 MatrixGenerics     = "1.12.2",
                 S4Arrays           = "1.0.4",
                 DelayedArray       = "0.26.6",
                 DelayedMatrixStats = "1.22.1",
                 scuttle            = "1.10.1",
                 glmGamPoi          = "1.12.1")
for (pkg in names(bioc_pinned)) {
  if (packageVersion(pkg) != bioc_pinned[[pkg]]) {
    install_archive(sprintf("%s/%s/%s_%s.tar.gz", bioc_archive, pkg, pkg, bioc_pinned[[pkg]]))
  }
}

# ---- simspec from GitHub, at the commit used for the manuscript ----
simspec_sha <- "f4c87bfb18522d7df0110eb63843972a29415985"
remotes::install_github(paste0("quadbio/simspec@", simspec_sha), upgrade = "never")

# ---- Check versions; the build fails if anything differs ----
expected <- c(
  Seurat = "4.3.0", SeuratObject = "4.1.3", ggplot2 = "3.4.2", dplyr = "1.1.2",
  Matrix = "1.7-5", sctransform = "0.3.5", glmGamPoi = "1.12.1",
  uwot = "0.1.16", RcppAnnoy = "0.0.21", irlba = "2.3.5.1", igraph = "1.4.3", leiden = "0.4.3",
  Rcpp = "1.0.10", matrixStats = "1.2.0", clustree = "0.5.1", scales = "1.3.0",
  patchwork = "1.1.2", pheatmap = "1.0.12",
  SingleCellExperiment = "1.22.0", SummarizedExperiment = "1.30.2", scuttle = "1.10.1",
  S4Vectors = "0.38.1", GenomeInfoDb = "1.36.1", GenomicRanges = "1.52.0", IRanges = "2.34.1",
  BiocGenerics = "0.46.0", MatrixGenerics = "1.12.2", S4Arrays = "1.0.4", DelayedArray = "0.26.6",
  DelayedMatrixStats = "1.22.1", BiocParallel = "1.34.2", BiocSingular = "1.16.0",
  BiocNeighbors = "1.18.0", beachmat = "2.16.0", bluster = "1.10.0"
)
installed <- vapply(names(expected),
                    function(p) tryCatch(as.character(packageVersion(p)), error = function(e) NA_character_),
                    character(1))
# compare as package versions so that "1.7-5" equals "1.7.5"
ok <- !is.na(installed) &
  mapply(function(i, e) !is.na(i) && package_version(i) == package_version(e), installed, expected)
check <- data.frame(package = names(expected), expected = expected, installed = installed,
                    ok = ok, row.names = NULL)
print(check)
stopifnot(R.version$major == "4", R.version$minor == "4.0")
stopifnot(identical(packageDescription("simspec")$RemoteSha, simspec_sha))
if (!all(check$ok)) stop("Version mismatch: ", paste(check$package[!check$ok], collapse = ", "))
message("All package versions match.")

# ---- Record the real environment of this image ----
# Attach the packages the Rmds load, then save sessionInfo() as part of the image.
suppressPackageStartupMessages(
  for (p in c("yaml", "rmarkdown", "Seurat", "tidyverse", "patchwork", "BiocSingular",
              "BiocParallel", "pheatmap", "bluster", "dichromat", "RColorBrewer", "clustree",
              "scuttle", "simspec", "glmGamPoi")) library(p, character.only = TRUE)
)
writeLines(c("Session information recorded while building the Docker image",
             capture.output(sessionInfo())),
           "sessionInfo_container.txt")
