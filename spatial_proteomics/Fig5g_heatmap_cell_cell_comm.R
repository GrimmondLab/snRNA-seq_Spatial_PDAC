library(S4Vectors)
library(SummarizedExperiment)
library(SingleCellExperiment)
library(SpatialExperiment)
library(imcRtools)
library(BiocParallel)
library(dplyr)
library(ggplot2)

bpp <- SnowParam(workers = 8, type = "SOCK")
spe <- readRDS("rdata/spe.rds")

spe <- buildSpatialGraph(spe, img_id = "sample_id", coords = c("Centroid.X.µm", "Centroid.Y.µm"),
                         type = "expansion", threshold = 50, name = "expansion_interaction_graph_50")

spe$CellType_upd <- as.character(spe$CellType)
spe$CellType_upd <- ifelse(spe$GrzB == "GrzB+" & spe$CellType_upd == "CD8 T cells",
                           "CycotoxicCD8T", spe$CellType_upd)

spe$CellType_upd <- ifelse(spe$MHCII == "MHCII+" & spe$CellType_upd == "Macrophages",
                           "MacrophagesMHCII+", spe$CellType_upd)

spe$CellType_upd <- ifelse(spe$MHCII == "MHCII-" & spe$CellType_upd == "Macrophages",
                           "MacrophagesMHCII-", spe$CellType_upd)

spe$consistent_cell_types <- as.character(spe$CellType_upd)
cell_types_to_join <- c("Vim+", "Vim+CD68+")
spe$consistent_cell_types <- gsub("CD68\\+", "", spe$consistent_cell_types)

out_exp50 <- testInteractions(spe,
                        group_by = "sample_id",
                        label = "consistent_cell_types",
                        colPairName = "expansion_interaction_graph_50",
                        #method = "histocat",
                        BPPARAM = bpp)

#saveRDS(out_exp50, file = "rdata/cell_int_out_exp50_Vim_merged.rds")

plot_interactions <- function(out, plot_title){
  # Sum interaction values across all images
  summed_sigvals <- out %>% as_tibble() %>%
    filter(from_label != "Other") %>% 
    filter(to_label != "Other") %>% 
    group_by(from_label, to_label) %>%
    summarize(sum_sigval = sum(sigval, na.rm = TRUE))
  
  # Visualize summed interaction values in form of a heatmap
  ggplot(summed_sigvals) +
    geom_tile(aes(from_label, to_label, fill = sum_sigval)) +
    scale_fill_gradient2(low = muted("blue"),
                         mid = "white",
                         high = muted("red")) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          panel.background = element_blank())+
    ggtitle(label = plot_title)
}

plot_interactions(out_exp50, plot_title="Spatial graph with radius 50")
