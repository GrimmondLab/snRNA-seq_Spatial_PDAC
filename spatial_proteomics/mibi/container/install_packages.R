# Installs the packages for the MIBI cell-cell interaction analysis, at the versions recorded in
# Cell_cell_interaction_sessioninfo.txt (R 4.5.1, Bioconductor 3.21). Run during the container build.
#
# - Bioconductor packages come from release 3.21. Two had a bug-fix update after the analysis
#   (BiocGenerics 0.54.1, GenomeInfoDb 1.44.3), so the recorded versions are installed from the 3.21 archive.
# - CRAN packages come from a dated snapshot (2025-11-01), which has every recorded CRAN version
#   (ggplot2 4.0.0 was replaced by 4.0.1 on 2025-11-14).
# The script stops if any installed version differs from the record.

stopifnot(
  "R 4.5.1 is required" = identical(paste(R.version$major, R.version$minor, sep = "."), "4.5.1"),
  "Bioconductor 3.21 is required" = identical(as.character(BiocManager::version()), "3.21")
)

cran_snapshot <- "https://p3m.dev/cran/__linux__/noble/2025-11-01"
options(repos = c(CRAN = cran_snapshot), Ncpus = max(1L, parallel::detectCores() - 1L))

bioc_pkgs <- c("imcRtools", "SpatialExperiment", "SingleCellExperiment", "SummarizedExperiment",
               "Biobase", "GenomicRanges", "GenomeInfoDb", "IRanges", "S4Vectors", "BiocGenerics",
               "MatrixGenerics", "BiocParallel")
cran_pkgs <- c("generics", "matrixStats", "tidyr", "dplyr", "RColorBrewer", "pheatmap", "gridExtra",
               "patchwork", "ggplot2", "scales", "knitr")

BiocManager::install(c(bioc_pkgs, cran_pkgs), update = FALSE, ask = FALSE)

# Recorded patch versions that Bioconductor 3.21 has since updated
archive <- "https://bioconductor.org/packages/3.21/bioc/src/contrib/Archive"
pinned <- c(BiocGenerics = "0.54.0", GenomeInfoDb = "1.44.2")
for (p in names(pinned)) {
  install.packages(sprintf("%s/%s/%s_%s.tar.gz", archive, p, p, pinned[[p]]), repos = NULL, type = "source")
}

# "Other attached packages" in Cell_cell_interaction_sessioninfo.txt
recorded <- c(
  imcRtools = "1.14.0", SpatialExperiment = "1.18.1", SingleCellExperiment = "1.30.1",
  SummarizedExperiment = "1.38.1", Biobase = "2.68.0", GenomicRanges = "1.60.0", GenomeInfoDb = "1.44.2",
  IRanges = "2.42.0", S4Vectors = "0.46.0", BiocGenerics = "0.54.0", generics = "0.1.4",
  MatrixGenerics = "1.20.0", matrixStats = "1.5.0", tidyr = "1.3.1", dplyr = "1.1.4",
  RColorBrewer = "1.1-3", pheatmap = "1.0.13", gridExtra = "2.3", patchwork = "1.3.2", ggplot2 = "4.0.0",
  knitr = "1.50"
)
installed <- vapply(names(recorded), function(p) as.character(packageVersion(p)), character(1))
same <- mapply(function(a, b) package_version(a) == package_version(b), installed, recorded)

# Not attached in the original session (no version recorded); listed for reference
extra <- c("BiocParallel", "scales")
versions <- data.frame(
  package = c(names(recorded), extra),
  recorded = c(recorded, rep(NA, length(extra))),
  installed = c(installed, vapply(extra, function(p) as.character(packageVersion(p)), character(1))),
  same = c(same, rep(NA, length(extra)))
)
write.table(versions, "/opt/mibi/package_versions.tsv", sep = "\t", quote = FALSE, row.names = FALSE, na = "")
print(versions, row.names = FALSE)

if (!all(same)) {
  stop("Installed versions differ from the record: ",
       paste(sprintf("%s %s (recorded %s)", names(recorded)[!same], installed[!same], recorded[!same]),
             collapse = ", "))
}
cat("All", length(recorded), "recorded package versions match.\n")
