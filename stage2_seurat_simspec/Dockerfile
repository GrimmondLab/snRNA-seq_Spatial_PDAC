# Stage 2 — PDAC snRNA-seq: Seurat processing + Simspec (CSS) integration
# R 4.4.0 on Ubuntu 22.04 with Bioconductor 3.17 packages, as in the original runs (see sessionInfo/).
# Built for linux/amd64 to match the original machine.
FROM --platform=linux/amd64 rocker/r-ver:4.4.0

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

# Match the locale and time zone of the original runs (see sessionInfo/)
ENV TZ=Etc/UTC \
    LANG=en_AU.UTF-8 \
    LC_ALL=en_AU.UTF-8

WORKDIR /pipeline

# R packages (slow step, kept in its own layer so code changes don't trigger a reinstall)
COPY install_packages.R .
RUN Rscript install_packages.R && rm -rf /tmp/downloaded_packages

# Pipeline code and default config (container paths)
COPY run_stage2.R Seurat_sample_based.Rmd PDAC_STS_simspec_integration.Rmd config.yml ./

# Data is mounted at run time, not stored in the image:
#   /data/input   folder containing qc.dbl.fltrd.sts.sce.RDS (read-only)
#   /output       results
VOLUME ["/output"]

ENTRYPOINT ["Rscript", "run_stage2.R"]
CMD ["config.yml"]
