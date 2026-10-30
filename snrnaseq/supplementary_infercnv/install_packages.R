# Installs the R packages for the supplementary inferCNV check at fixed versions.
# Run once at image build time (see Dockerfile).
#
# The original environment (sessionInfo/) was R 4.4.0 with Bioconductor 3.19 (infercnv 1.20.0),
# SeuratObject 5.0.2 and dplyr 1.1.4. This differs from Stages 1-2 (Bioconductor 3.17, Seurat 4).
#
# CRAN: Posit Package Manager snapshot of 2024-07-10, which matches the sessionInfo versions
# (dplyr 1.1.4, SeuratObject 5.0.2, Seurat 5.1.0, igraph 2.0.3, rjags 4-15, ggplot2 3.5.1).

cran_snapshot <- "https://packagemanager.posit.co/cran/__linux__/jammy/2024-07-10"
options(repos = c(CRAN = cran_snapshot), Ncpus = max(1L, parallel::detectCores() - 1L))

bioc_archive <- "https://bioconductor.org/packages/3.19/bioc/src/contrib/Archive"

# ---- CRAN ----
install.packages(c("BiocManager", "yaml", "rmarkdown", "knitr",
                   "dplyr", "SeuratObject", "Seurat", "rjags"))

# ---- Bioconductor 3.19 ----
BiocManager::install(version = "3.19", update = FALSE, ask = FALSE)
BiocManager::install("infercnv", update = FALSE, ask = FALSE)

# Bioconductor only serves the latest patch of a release; older patches come from its archive.
# Order matters: dependencies first.
bioc_pinned <- c(limma         = "3.60.3",
                 edgeR         = "4.2.0",
                 GenomicRanges = "1.56.1")
for (pkg in names(bioc_pinned)) {
  if (packageVersion(pkg) != bioc_pinned[[pkg]]) {
    install.packages(sprintf("%s/%s/%s_%s.tar.gz", bioc_archive, pkg, pkg, bioc_pinned[[pkg]]),
                     repos = NULL, type = "source")
  }
}

# ---- Check versions; the build fails if anything differs ----
expected <- c(
  infercnv = "1.20.0", SeuratObject = "5.0.2", Seurat = "5.1.0", dplyr = "1.1.4",
  ggplot2 = "3.5.1", Matrix = "1.7-0",
  # used by inferCNV for subclustering, the HMM and the Bayesian filter
  igraph = "2.0.3", leiden = "0.4.3.1", rjags = "4-15", coda = "0.19-4.1", RANN = "2.6.1",
  fastcluster = "1.2.6", parallelDist = "0.2.6", phyclust = "0.1-34", ape = "5.8",
  caTools = "1.18.2", fitdistrplus = "1.1-11", gplots = "3.1.3.1", coin = "1.4-3",
  futile.logger = "1.4.3", argparse = "2.2.3", foreach = "1.5.2", doParallel = "1.0.17",
  Rcpp = "1.0.12", RcppParallel = "5.1.8", irlba = "2.3.5.1", matrixStats = "1.3.0",
  edgeR = "4.2.0", limma = "3.60.3",
  SingleCellExperiment = "1.26.0", SummarizedExperiment = "1.34.0", GenomicRanges = "1.56.1",
  S4Vectors = "0.42.1", IRanges = "2.38.1", BiocGenerics = "0.50.0", GenomeInfoDb = "1.40.1",
  DelayedArray = "0.30.1", SparseArray = "1.4.8", S4Arrays = "1.4.1", MatrixGenerics = "1.16.0",
  rmarkdown = "2.27", knitr = "1.48", yaml = "2.3.9"
)
installed <- vapply(names(expected),
                    function(p) tryCatch(as.character(packageVersion(p)), error = function(e) NA_character_),
                    character(1))
# compare as package versions so that "4-15" equals "4.15"
ok <- !is.na(installed) &
  mapply(function(i, e) !is.na(i) && package_version(i) == package_version(e), installed, expected)
check <- data.frame(package = names(expected), expected = expected, installed = installed,
                    ok = ok, row.names = NULL)
print(check)
stopifnot(R.version$major == "4", R.version$minor == "4.0")
if (!all(check$ok)) stop("Version mismatch: ", paste(check$package[!check$ok], collapse = ", "))
message("All package versions match.")

# ---- Record the real environment of this image ----
# Attach the packages the Rmd loads, then save sessionInfo() as part of the image.
suppressPackageStartupMessages(
  for (p in c("yaml", "rmarkdown", "infercnv", "dplyr", "SeuratObject")) library(p, character.only = TRUE)
)
writeLines(c("Session information recorded while building the Docker image",
             paste("JAGS:", tryCatch(as.character(rjags::jags.version()), error = function(e) "unknown")),
             capture.output(sessionInfo())),
           "sessionInfo_container.txt")
