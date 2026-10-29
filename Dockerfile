# PDAC snRNA-seq analysis: one image, one conda env per group of stages.
#   snrnaseq  R 4.3, Bioconductor 3.17, Seurat 4     stages 1, 2
#   infercnv  R 4.3, inferCNV 1.20.0, Seurat 5       stage 3
# Envs are built from the explicit lock files in envs/ (bioconda + conda-forge only).
# Bioconda's R 4.3 builds are linux-64 only, hence linux/amd64.
FROM --platform=linux/amd64 mambaorg/micromamba:1.5.10

# Match the locale and time zone of the original runs (see snrnaseq/stage*/sessionInfo/)
USER root
RUN apt-get update && apt-get install -y --no-install-recommends locales \
    && sed -i 's/^# *en_AU.UTF-8/en_AU.UTF-8/' /etc/locale.gen && locale-gen \
    && rm -rf /var/lib/apt/lists/*
ENV TZ=Etc/UTC \
    LANG=en_AU.UTF-8 \
    LC_ALL=en_AU.UTF-8
USER $MAMBA_USER

WORKDIR /pipeline

# Envs (slow step, kept in their own layers so code changes don't trigger a rebuild)
COPY --chown=$MAMBA_USER:$MAMBA_USER envs/ envs/
RUN micromamba create -y -n snrnaseq -f envs/snrnaseq-linux-64.lock \
    && micromamba run -n snrnaseq Rscript envs/post_install.R \
    && micromamba clean -a -y
RUN micromamba create -y -n infercnv -f envs/infercnv-linux-64.lock \
    && micromamba clean -a -y

# Record the real environment of each env
RUN mkdir -p sessionInfo \
    && micromamba run -n snrnaseq Rscript envs/session_info.R sessionInfo/snrnaseq.txt \
         yaml rmarkdown dplyr purrr patchwork RColorBrewer ggplot2 SingleCellExperiment \
         DropletUtils scuttle scater scran scDblFinder BiocParallel Seurat tidyverse \
         BiocSingular pheatmap bluster dichromat clustree simspec glmGamPoi \
    && micromamba run -n infercnv Rscript envs/session_info.R sessionInfo/infercnv.txt \
         yaml rmarkdown infercnv dplyr SeuratObject rjags

# Pipeline code (data is mounted at run time: /data/... read-only, /output read-write)
COPY --chown=$MAMBA_USER:$MAMBA_USER run.sh ./
COPY --chown=$MAMBA_USER:$MAMBA_USER snrnaseq/ snrnaseq/

ENTRYPOINT ["/pipeline/run.sh"]
