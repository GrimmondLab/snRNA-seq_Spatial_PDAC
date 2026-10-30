# Installs the R packages for Stage 3 at fixed versions.
# Run once at image build time (see Dockerfile).
#
# The original environment (sessionInfo/) was R 4.3.0 with Bioconductor 3.17, Seurat 4.3.0,
# dplyr 1.1.2 and ggplot2 3.5.2. Every package recorded there is installed and checked here.
#
# CRAN: Posit Package Manager snapshot of 2023-06-15, plus the newer versions listed below.
# Bioconductor: release 3.17, with patch versions matched to sessionInfo/.

cran_snapshot <- "https://packagemanager.posit.co/cran/__linux__/jammy/2023-06-15"
cran_archive  <- "https://cloud.r-project.org"
bioc_archive  <- "https://bioconductor.org/packages/3.17/bioc/src/contrib/Archive"

options(repos = c(CRAN = cran_snapshot), Ncpus = max(1L, parallel::detectCores() - 1L))

install_archive <- function(url) install.packages(url, repos = NULL, type = "source")

# ---- CRAN: every CRAN package in sessionInfo/ ----
cran_pkgs <- c(
  "BiocManager", "DBI", "KernSmooth", "MASS", "Matrix", "R6",
  "RANN", "RColorBrewer", "RCurl", "ROCR", "RSQLite", "Rcpp",
  "RcppAnnoy", "Rtsne", "Seurat", "SeuratObject", "abind", "ape",
  "aplot", "babelgene", "backports", "beeswarm", "bit", "bit64",
  "bitops", "blob", "cachem", "callr", "checkmate", "cli",
  "cluster", "clustree", "codetools", "colorspace", "cowplot", "crayon",
  "data.table", "deldir", "dichromat", "digest", "downloader", "dplyr",
  "ellipsis", "evaluate", "fansi", "farver", "fastmap", "fastmatch",
  "fitdistrplus", "fs", "future", "future.apply", "generics", "getPass",
  "ggbeeswarm", "ggforce", "ggfun", "ggplot2", "ggplotify", "ggraph",
  "ggrastr", "ggrepel", "ggridges", "git2r", "globals", "glue",
  "goftest", "graphlayouts", "gridExtra", "gridGraphics", "gson", "gtable",
  "hms", "htmltools", "htmlwidgets", "httpuv", "httr", "ica",
  "igraph", "irlba", "jsonlite", "knitr", "labeling", "later",
  "lattice", "lazyeval", "leiden", "lifecycle", "listenv", "lmtest",
  "locfit", "magrittr", "matrixStats", "memoise", "mime", "miniUI",
  "msigdbr", "nlme", "openxlsx", "parallelly", "patchwork", "pbapply",
  "pheatmap", "pillar", "pkgconfig", "plotly", "plyr", "png",
  "polyclip", "processx", "progressr", "promises", "ps", "purrr",
  "readr", "renv", "reshape2", "reticulate", "rlang", "rmarkdown",
  "rprojroot", "rstudioapi", "scales", "scattermore", "scatterpie", "sctransform",
  "shadowtext", "shiny", "sp", "spatstat.data", "spatstat.explore", "spatstat.geom",
  "spatstat.random", "spatstat.sparse", "spatstat.utils", "stringi", "stringr", "survival",
  "tensor", "tibble", "tidygraph", "tidyr", "tidyselect", "tidytree",
  "tweenr", "tzdb", "utf8", "uwot", "vctrs", "vipor",
  "viridis", "viridisLite", "vroom", "whisker", "withr", "workflowr",
  "xfun", "xtable", "yaml", "yulab.utils", "zip", "zoo"
)
install.packages(c("remotes", cran_pkgs))   # remotes is only used here, to install fixed versions

# ---- Newer than the snapshot date, matched to sessionInfo/ ----
# Order matters: dependencies first.
cran_pinned <- c(Rcpp            = "1.0.14",
                 rlang           = "1.3.0",
                 cli             = "3.6.6",
                 lifecycle       = "1.0.5",
                 vctrs           = "0.7.3",
                 digest          = "0.6.32",
                 jsonlite        = "1.8.7",
                 processx        = "3.8.2",
                 tidyselect      = "1.2.1",
                 tidyr           = "1.3.2",
                 gtable          = "0.3.6",
                 S7              = "0.2.2",
                 scales          = "1.4.0",
                 ggplot2         = "3.5.2",
                 ggrepel         = "0.9.8",
                 cowplot         = "1.2.0",
                 patchwork       = "1.3.2",
                 cluster         = "2.1.8.2",
                 matrixStats     = "1.2.0",
                 RcppAnnoy       = "0.0.21",
                 uwot            = "0.1.16",
                 spatstat.utils  = "3.1-0",
                 rmarkdown       = "2.23")
for (pkg in names(cran_pinned)) {
  remotes::install_version(pkg, version = cran_pinned[[pkg]], repos = cran_archive, upgrade = "never")
}

# ---- Bioconductor 3.17: every Bioconductor package in sessionInfo/ ----
BiocManager::install(version = "3.17", update = FALSE, ask = FALSE)
bioc_pkgs <- c(
  "AnnotationDbi", "Biobase", "BiocGenerics", "BiocParallel", "Biostrings", "DOSE",
  "DelayedArray", "DelayedMatrixStats", "GO.db", "GOSemSim", "GenomeInfoDb", "GenomeInfoDbData",
  "GenomicRanges", "HDO.db", "IRanges", "KEGGREST", "MatrixGenerics", "S4Arrays",
  "S4Vectors", "SummarizedExperiment", "XVector", "clusterProfiler", "edgeR", "enrichplot",
  "fgsea", "ggtree", "glmGamPoi", "limma", "org.Hs.eg.db", "qvalue",
  "sparseMatrixStats", "treeio", "zlibbioc"
)
BiocManager::install(setdiff(bioc_pkgs, "treeio"), update = FALSE, ask = FALSE)

# Bioconductor only serves the latest patch of a release; older patches come from its archive.
# Order matters: dependencies first.
bioc_pinned <- c(S4Vectors          = "0.38.1",
                 GenomeInfoDb       = "1.36.1",
                 GenomicRanges      = "1.52.0",
                 MatrixGenerics     = "1.12.2",
                 S4Arrays           = "1.0.4",
                 DelayedArray       = "0.26.6",
                 DelayedMatrixStats = "1.22.1",
                 KEGGREST           = "1.40.0",
                 AnnotationDbi      = "1.62.1",
                 GOSemSim           = "2.26.0",
                 DOSE               = "3.26.1",
                 glmGamPoi          = "1.12.1")
for (pkg in names(bioc_pinned)) {
  if (packageVersion(pkg) != bioc_pinned[[pkg]]) {
    install_archive(sprintf("%s/%s/%s_%s.tar.gz", bioc_archive, pkg, pkg, bioc_pinned[[pkg]]))
  }
}

# ---- GitHub ----
# treeio 1.25.0.001 is a development version (Bioconductor 3.17 has 1.24.x). The only commit with
# this version number is 7c32644 (2023-05-31).
treeio_sha  <- "7c3264453901861da9b564b15b7b4e8377f8a8ee"
remotes::install_github(paste0("YuLab-SMU/treeio@", treeio_sha), upgrade = "never")
# simspec, at the same commit as Stage 2
simspec_sha <- "f4c87bfb18522d7df0110eb63843972a29415985"
remotes::install_github(paste0("quadbio/simspec@", simspec_sha), upgrade = "never")

# Packages that depend on treeio, at their sessionInfo/ versions (after treeio)
for (pv in c("ggtree_3.8.0", "enrichplot_1.20.0", "clusterProfiler_4.8.1")) {
  pkg <- sub("_.*", "", pv)
  install_archive(sprintf("%s/%s/%s.tar.gz", bioc_archive, pkg, pv))
}

# ---- Check versions; the build fails if anything differs ----
# Every package in sessionInfo/ apart from base R
expected <- c(
  AnnotationDbi = "1.62.1", Biobase = "2.60.0", BiocGenerics = "0.46.0", BiocManager = "1.30.21",
  BiocParallel = "1.34.2", Biostrings = "2.68.1", DBI = "1.1.3", DOSE = "3.26.1",
  DelayedArray = "0.26.6", DelayedMatrixStats = "1.22.1", `GO.db` = "3.17.0", GOSemSim = "2.26.0",
  GenomeInfoDb = "1.36.1", GenomeInfoDbData = "1.2.10", GenomicRanges = "1.52.0", `HDO.db` = "0.99.1",
  IRanges = "2.34.1", KEGGREST = "1.40.0", KernSmooth = "2.23-21", MASS = "7.3-60",
  Matrix = "1.5-4.1", MatrixGenerics = "1.12.2", R6 = "2.5.1", RANN = "2.6.1",
  RColorBrewer = "1.1-3", RCurl = "1.98-1.12", ROCR = "1.0-11", RSQLite = "2.3.1",
  Rcpp = "1.0.14", RcppAnnoy = "0.0.21", Rtsne = "0.16", S4Arrays = "1.0.4",
  S4Vectors = "0.38.1", S7 = "0.2.2", Seurat = "4.3.0", SeuratObject = "4.1.3",
  SummarizedExperiment = "1.30.2", XVector = "0.40.0", abind = "1.4-5", ape = "5.7-1",
  aplot = "0.1.10", babelgene = "22.9", backports = "1.4.1", beeswarm = "0.4.0",
  bit = "4.0.5", bit64 = "4.0.5", bitops = "1.0-7", blob = "1.2.4",
  cachem = "1.0.8", callr = "3.7.3", checkmate = "2.2.0", cli = "3.6.6",
  cluster = "2.1.8.2", clusterProfiler = "4.8.1", clustree = "0.5.0", codetools = "0.2-19",
  colorspace = "2.1-0", cowplot = "1.2.0", crayon = "1.5.2", `data.table` = "1.14.8",
  deldir = "1.0-9", dichromat = "2.0-0.1", digest = "0.6.32", downloader = "0.4",
  dplyr = "1.1.2", edgeR = "3.42.4", ellipsis = "0.3.2", enrichplot = "1.20.0",
  evaluate = "0.21", fansi = "1.0.4", farver = "2.1.1", fastmap = "1.1.1",
  fastmatch = "1.1-3", fgsea = "1.26.0", fitdistrplus = "1.1-11", fs = "1.6.2",
  future = "1.32.0", `future.apply` = "1.11.0", generics = "0.1.3", getPass = "0.2-2",
  ggbeeswarm = "0.7.2", ggforce = "0.4.1", ggfun = "0.0.9", ggplot2 = "3.5.2",
  ggplotify = "0.1.0", ggraph = "2.1.0", ggrastr = "1.0.2", ggrepel = "0.9.8",
  ggridges = "0.5.4", ggtree = "3.8.0", git2r = "0.32.0", glmGamPoi = "1.12.1",
  globals = "0.16.2", glue = "1.6.2", goftest = "1.2-3", graphlayouts = "1.0.0",
  gridExtra = "2.3", gridGraphics = "0.5-1", gson = "0.1.0", gtable = "0.3.6",
  hms = "1.1.3", htmltools = "0.5.5", htmlwidgets = "1.6.2", httpuv = "1.6.11",
  httr = "1.4.6", ica = "1.0-3", igraph = "1.4.3", irlba = "2.3.5.1",
  jsonlite = "1.8.7", knitr = "1.43", labeling = "0.4.2", later = "1.3.1",
  lattice = "0.21-8", lazyeval = "0.2.2", leiden = "0.4.3", lifecycle = "1.0.5",
  limma = "3.56.2", listenv = "0.9.0", lmtest = "0.9-40", locfit = "1.5-9.8",
  magrittr = "2.0.3", matrixStats = "1.2.0", memoise = "2.0.1", mime = "0.12",
  miniUI = "0.1.1.1", msigdbr = "7.5.1", nlme = "3.1-162", openxlsx = "4.2.5.2",
  `org.Hs.eg.db` = "3.17.0", parallelly = "1.36.0", patchwork = "1.3.2", pbapply = "1.7-0",
  pheatmap = "1.0.12", pillar = "1.9.0", pkgconfig = "2.0.3", plotly = "4.10.2",
  plyr = "1.8.8", png = "0.1-8", polyclip = "1.10-4", processx = "3.8.2",
  progressr = "0.13.0", promises = "1.2.0.1", ps = "1.7.5", purrr = "1.0.1",
  qvalue = "2.32.0", readr = "2.1.4", renv = "0.17.3", reshape2 = "1.4.4",
  reticulate = "1.30", rlang = "1.3.0", rmarkdown = "2.23", rprojroot = "2.0.3",
  rstudioapi = "0.14", scales = "1.4.0", scattermore = "1.2", scatterpie = "0.2.1",
  sctransform = "0.3.5", shadowtext = "0.1.2", shiny = "1.7.4", simspec = "0.0.0.9000",
  sp = "1.6-1", sparseMatrixStats = "1.12.2", `spatstat.data` = "3.0-1", `spatstat.explore` = "3.2-1",
  `spatstat.geom` = "3.2-1", `spatstat.random` = "3.1-5", `spatstat.sparse` = "3.0-1", `spatstat.utils` = "3.1-0",
  stringi = "1.7.12", stringr = "1.5.0", survival = "3.5-5", tensor = "1.5",
  tibble = "3.2.1", tidygraph = "1.2.3", tidyr = "1.3.2", tidyselect = "1.2.1",
  tidytree = "0.4.2", treeio = "1.25.0.001", tweenr = "2.0.2", tzdb = "0.4.0",
  utf8 = "1.2.3", uwot = "0.1.16", vctrs = "0.7.3", vipor = "0.4.5",
  viridis = "0.6.3", viridisLite = "0.4.2", vroom = "1.6.3", whisker = "0.4.1",
  withr = "2.5.0", workflowr = "1.7.0", xfun = "0.39", xtable = "1.8-4",
  yaml = "2.3.7", `yulab.utils` = "0.0.6", zip = "2.3.0", zlibbioc = "1.46.0",
  zoo = "1.8-12"
)
installed <- vapply(names(expected),
                    function(p) tryCatch(as.character(packageVersion(p)), error = function(e) NA_character_),
                    character(1))
# compare as package versions so that "1.5-4.1" equals "1.5.4.1"
ok <- !is.na(installed) &
  mapply(function(i, e) !is.na(i) && package_version(i) == package_version(e), installed, expected)
check <- data.frame(package = names(expected), expected = expected, installed = installed,
                    ok = ok, row.names = NULL)
print(check[!check$ok, ])
stopifnot(R.version$major == "4", R.version$minor == "3.0")
stopifnot(identical(packageDescription("simspec")$RemoteSha, simspec_sha),
          identical(packageDescription("treeio")$RemoteSha, treeio_sha))
if (!all(check$ok)) stop("Version mismatch: ", paste(check$package[!check$ok], collapse = ", "))
message("All ", nrow(check), " package versions match.")

# ---- Record the real environment of this image ----
# Attach the packages the Rmds load, then save sessionInfo() as part of the image.
suppressPackageStartupMessages(
  for (p in c("yaml", "Seurat", "ggplot2", "dplyr", "patchwork", "rmarkdown", "openxlsx",
              "simspec", "limma", "edgeR", "tibble", "msigdbr", "clusterProfiler",
              "org.Hs.eg.db", "clustree", "readr")) library(p, character.only = TRUE)
)
writeLines(c("Session information recorded while building the Docker image",
             capture.output(sessionInfo())),
           "sessionInfo_container.txt")
