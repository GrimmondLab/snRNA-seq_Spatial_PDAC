# PDAC snRNA-seq analysis: one image, one conda env per group of stages.
#   snrnaseq  R 4.3, Bioconductor 3.17, Seurat 4     stages 1, 2
#   downstream R 4.3, Bioconductor 3.17, Seurat 4,   stages 3, 4
#              ggplot2 3.5.2, edgeR, clusterProfiler
#   cellchat  R 4.3, Bioconductor 3.17, Seurat 4,    stage 5
#              CellChat 2.1.2, dplyr 1.2.1
#   infercnv  R 4.3, inferCNV 1.20.0, Seurat 5       supplementary inferCNV
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
RUN micromamba create -y -n downstream -f envs/downstream-linux-64.lock \
    && micromamba run -n downstream Rscript envs/post_install_downstream.R \
    && micromamba clean -a -y
RUN micromamba create -y -n cellchat -f envs/cellchat-linux-64.lock \
    && micromamba run -n cellchat Rscript envs/post_install_cellchat.R \
    && micromamba clean -a -y
RUN micromamba create -y -n infercnv -f envs/infercnv-linux-64.lock \
    && micromamba clean -a -y

# Record the real environment of each env
RUN mkdir -p sessionInfo \
    && micromamba run -n snrnaseq Rscript envs/session_info.R sessionInfo/snrnaseq.txt \
         yaml rmarkdown dplyr purrr patchwork RColorBrewer ggplot2 SingleCellExperiment \
         DropletUtils scuttle scater scran scDblFinder BiocParallel Seurat tidyverse \
         BiocSingular pheatmap bluster dichromat clustree simspec glmGamPoi \
    && micromamba run -n downstream Rscript envs/session_info.R sessionInfo/downstream.txt \
         yaml rmarkdown Seurat ggplot2 dplyr patchwork openxlsx simspec limma edgeR tibble \
         msigdbr clusterProfiler org.Hs.eg.db clustree readr treeio schex shiny here pheatmap \
         viridis viridisLite UCell SingleR EnhancedVolcano ReactomePA enrichplot tidyr \
    && micromamba run -n cellchat Rscript envs/session_info.R sessionInfo/cellchat.txt \
         yaml rmarkdown CellChat dplyr patchwork Seurat presto NMF \
    && micromamba run -n infercnv Rscript envs/session_info.R sessionInfo/infercnv.txt \
         yaml rmarkdown infercnv dplyr SeuratObject rjags

# Pipeline code (data is mounted at run time: /data/... read-only, /output read-write)
COPY --chown=$MAMBA_USER:$MAMBA_USER run.sh ./
COPY --chown=$MAMBA_USER:$MAMBA_USER shared/ shared/
COPY --chown=$MAMBA_USER:$MAMBA_USER snrnaseq/ snrnaseq/

ENTRYPOINT ["/pipeline/run.sh"]
