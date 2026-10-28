# Stage 3 — PDAC snRNA-seq: inferCNV per sample (confirms the malignant calls from Stage 2)
# R 4.4.0 on Ubuntu 22.04 with Bioconductor 3.19 (infercnv 1.20.0), as in the original runs (see sessionInfo/).
# Built for linux/amd64 to match the original machine.
FROM --platform=linux/amd64 rocker/r-ver:4.4.0

# System libraries for Bioconductor / Seurat dependencies, JAGS for inferCNV's Bayesian filter (rjags),
# Python for argparse (an inferCNV dependency), and pandoc for rmarkdown
RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake \
        jags \
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
        pkg-config \
        python3 \
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

# Pipeline code, per-sample table, gene positions and default config (container paths)
COPY run_stage3.R InferCNV.Rmd infercnv_samples.csv gene_positions.txt config.yml ./

# Data is mounted at run time, not stored in the image:
#   /data/input   folder containing sts.simspec_css.sample.sct.Aug24.RDS (read-only)
#   /output       results
VOLUME ["/output"]

ENTRYPOINT ["Rscript", "run_stage3.R"]
CMD ["config.yml"]
