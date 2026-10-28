# Stage 1 — PDAC snRNA-seq preprocessing: doublet detection (scDblFinder) + fixed-threshold QC
# R 4.3.0 / Bioconductor 3.17. Built for linux/amd64 to match the original HPC runs.
FROM --platform=linux/amd64 rocker/r-ver:4.3.0

# System libraries needed to compile Bioconductor / Seurat dependencies, plus pandoc for rmarkdown
RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake \
        libbz2-dev \
        libcurl4-openssl-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libfribidi-dev \
        libglpk-dev \
        libgmp-dev \
        libharfbuzz-dev \
        libjpeg-dev \
        liblzma-dev \
        libpng-dev \
        libssl-dev \
        libtiff-dev \
        libxml2-dev \
        locales \
        zlib1g-dev \
    && sed -i 's/^# *en_AU.UTF-8/en_AU.UTF-8/' /etc/locale.gen && locale-gen \
    && /rocker_scripts/install_pandoc.sh \
    && rm -rf /var/lib/apt/lists/*

# Match the locale and time zone of the original runs (see Sessioninfo_*.txt)
ENV TZ=Etc/UTC \
    LANG=en_AU.UTF-8 \
    LC_ALL=en_AU.UTF-8

WORKDIR /pipeline

# R packages (slow step, kept in its own layer so code changes don't trigger a reinstall)
COPY install_packages.R .
RUN Rscript install_packages.R && rm -rf /tmp/downloaded_packages

# Pipeline code and default config (container paths)
COPY run_stage1.R Preprocessing_DoubleDetection.Rmd Preprocessing_QC.Rmd geo_input.R \
     geo_samples.csv config.yml config_local.yml ./

# Data is mounted at run time, not stored in the image:
#   /data/geo          GEO processed files (config.yml), or
#   /data/cellbender   original CellBender output folders (config_local.yml)
#   /data/meta         folder containing SG_sample_meta.csv (read-only)
#   /output            results
VOLUME ["/output"]

ENTRYPOINT ["Rscript", "run_stage1.R"]
CMD ["config.yml"]
