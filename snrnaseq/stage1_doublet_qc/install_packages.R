# Installs the R packages for the pipeline at fixed versions.
# Run once at image build time (see Dockerfile).
#
# CRAN: Posit Package Manager snapshot of 2023-06-15 (dplyr 1.1.2, ggplot2 3.4.2, Seurat 4.3.0).
# Bioconductor: release 3.17, with patch versions matched to Sessioninfo_*.txt.

cran_snapshot <- "https://packagemanager.posit.co/cran/__linux__/jammy/2023-06-15"
options(repos = c(CRAN = cran_snapshot), Ncpus = max(1L, parallel::detectCores() - 1L))

bioc_archive <- "https://bioconductor.org/packages/3.17/bioc/src/contrib/Archive"

# ---- CRAN ----
install.packages(c("BiocManager", "remotes",
                   "yaml", "rmarkdown", "knitr",
                   "dplyr", "purrr", "patchwork", "RColorBrewer", "ggplot2",
                   "Matrix", "Seurat"))

# Newer than the snapshot date, matched to sessionInfo/
cran_archive <- "https://cloud.r-project.org"
cran_pinned  <- c(matrixStats = "1.2.0",   # used via MatrixGenerics
                  RcppAnnoy   = "0.0.21",  # nearest neighbours for runUMAP
                  uwot        = "0.1.16")  # runUMAP
for (pkg in names(cran_pinned)) {
  remotes::install_version(pkg, version = cran_pinned[[pkg]], repos = cran_archive, upgrade = "never")
}

# ---- Bioconductor 3.17 ----
BiocManager::install(version = "3.17", update = FALSE, ask = FALSE)
BiocManager::install(c("SingleCellExperiment", "DropletUtils", "scuttle", "scater",
                       "scran", "scDblFinder", "BiocParallel"),
                     update = FALSE, ask = FALSE)

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
                 scran              = "1.28.1")
for (pkg in names(bioc_pinned)) {
  if (packageVersion(pkg) != bioc_pinned[[pkg]]) {
    install.packages(sprintf("%s/%s/%s_%s.tar.gz", bioc_archive, pkg, pkg, bioc_pinned[[pkg]]),
                     repos = NULL, type = "source")
  }
}

# ---- Check versions; the build fails if anything differs ----
expected <- c(
  # stated by the user
  dplyr = "1.1.2", ggplot2 = "3.4.2", Seurat = "4.3.0", SeuratObject = "4.1.3",
  # from sessionInfo/sessionInfo_*.txt
  scDblFinder = "1.14.0", scater = "1.28.0", scran = "1.28.1", scuttle = "1.10.1",
  DropletUtils = "1.20.0", SingleCellExperiment = "1.22.0", SummarizedExperiment = "1.30.2",
  BiocParallel = "1.34.2", BiocSingular = "1.16.0", BiocNeighbors = "1.18.0",
  beachmat = "2.16.0", HDF5Array = "1.28.1", rhdf5 = "2.44.0", bluster = "1.10.0",
  MatrixGenerics = "1.12.2", GenomicRanges = "1.52.0", S4Vectors = "0.38.1",
  BiocGenerics = "0.46.0", IRanges = "2.34.1",
  xgboost = "1.7.5.1", irlba = "2.3.5.1", igraph = "1.4.3", rsvd = "1.0.5", uwot = "0.1.16",
  Matrix = "1.5-4.1", matrixStats = "1.2.0", RcppAnnoy = "0.0.21",
  GenomeInfoDb = "1.36.1", S4Arrays = "1.0.4", DelayedArray = "0.26.6", DelayedMatrixStats = "1.22.1"
)
installed <- vapply(names(expected),
                    function(p) tryCatch(as.character(packageVersion(p)), error = function(e) NA_character_),
                    character(1))
# compare as package versions so that "1.5-4.1" equals "1.5.4.1"
ok <- !is.na(installed) &
  mapply(function(i, e) !is.na(i) && package_version(i) == package_version(e), installed, expected)
check <- data.frame(package = names(expected), expected = expected, installed = installed,
                    ok = ok, row.names = NULL)
print(check)
stopifnot(R.version$major == "4", R.version$minor == "3.0")
if (!all(check$ok)) stop("Version mismatch: ", paste(check$package[!check$ok], collapse = ", "))
message("All package versions match.")

# ---- Record the real environment of this image ----
# Attach the packages the Rmds load, then save sessionInfo() as part of the image.
suppressPackageStartupMessages(
  for (p in c("yaml", "rmarkdown", "dplyr", "purrr", "patchwork", "RColorBrewer", "ggplot2",
              "SingleCellExperiment", "DropletUtils", "scuttle", "scater", "scran",
              "scDblFinder", "BiocParallel", "Seurat")) library(p, character.only = TRUE)
)
writeLines(c("Session information recorded while building the Docker image",
             capture.output(sessionInfo())),
           "sessionInfo_container.txt")
