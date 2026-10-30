# Stage 3 — PDAC snRNA-seq: malignant vs non-malignant analysis (incl. rare malignancies, tuft and ADM)
# R 4.3.0 / Bioconductor 3.17. Built for linux/amd64 to match the original HPC runs.
#
# Build from the repository root, so that shared/sample_map.csv can be copied in:
#   docker build -f snrnaseq/stage3_malignant_nonmalignant/Dockerfile -t pdac-stage3:1.0 .
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

# Match the locale and time zone of the original runs (see sessionInfo/)
ENV TZ=Etc/UTC \
    LANG=en_AU.UTF-8 \
    LC_ALL=en_AU.UTF-8

WORKDIR /pipeline

# R packages (slow step, kept in its own layer so code changes don't trigger a reinstall)
COPY snrnaseq/stage3_malignant_nonmalignant/install_packages.R .
RUN Rscript install_packages.R && rm -rf /tmp/downloaded_packages

# Pipeline code, default config (container paths) and the shared sample map
COPY snrnaseq/stage3_malignant_nonmalignant/run_stage3.R \
     snrnaseq/stage3_malignant_nonmalignant/STS_Malignant.Rmd \
     snrnaseq/stage3_malignant_nonmalignant/STS_nonMalignant_TuftADM.Rmd \
     snrnaseq/stage3_malignant_nonmalignant/config.yml \
     shared/sample_map.csv ./

# Data is mounted at run time, not stored in the image:
#   /data/input   folder containing sts.simspec_css.sample.sct.RDS and tuft.snv.df.csv (read-only)
#   /output       results
VOLUME ["/output"]

ENTRYPOINT ["Rscript", "run_stage3.R"]
CMD ["config.yml"]
