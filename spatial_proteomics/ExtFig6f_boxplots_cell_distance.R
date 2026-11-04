library(imcRtools)
library(SpatialExperiment)
library(BiocParallel)

args = commandArgs(trailingOnly=TRUE)
id_task <- as.integer(args[1])
print(paste0('id task ', id_task))


multicoreParam <- MulticoreParam(workers = 10, progressbar = T, RNGseed = 42)

spe <- readRDS("rdata/spe.rds")

spe$CellType_upd <- as.character(spe$CellType)
spe$CellType_upd <- ifelse(spe$GrzB == "GrzB+" & spe$CellType_upd == "CD8 T cells",
                           "CycotoxicCD8T", spe$CellType_upd)

spe$CellType_upd <- ifelse(spe$MHCII == "MHCII+" & spe$CellType_upd == "Macrophages",
                           "MacrophagesMHCII+", spe$CellType_upd)

spe$CellType_upd <- ifelse(spe$MHCII == "MHCII-" & spe$CellType_upd == "Macrophages",
                           "MacrophagesMHCII-", spe$CellType_upd)

ref_cells <- c("Epithelial cells",
               "MacrophagesMHCII+")
ref <- ref_cells[id_task]

col_name = paste0("distTo", gsub("\\+", "Pos", ref))
col_name <- gsub("\\-", "Neg", col_name)
col_name <- gsub(" ", "_", col_name)
col_name <- gsub("cells", "", col_name)

spe <- minDistToCells(spe, name = col_name, return_neg = T,
                      x_cells = colData(spe)$CellType_upd == ref,
                      coords = c("Centroid.X.µm", "Centroid.Y.µm"),
                      img_id = "sample_id", BPPARAM = multicoreParam)

saveRDS(spe[[col_name]],
        file = paste0("rdata/",col_name,".rds"))

distToTumor <- readRDS("rdata/distToEpithelial_.rds")
distToMacroMHC2Pos <- readRDS("rdata/distToMacrophagesMHCIIPos.rds")

cell_info <- data.frame(CellType = spe$consistent_cell_types,
                        CellType_h2 = spe$parent_cell_type,
                        distToTumor = distToTumor,
                        distToMacroMHC2Pos = distToMacroMHC2Pos)
cell_info_filt <- cell_info %>% filter(CellType != "Other")
cell_info_filt <- droplevels(cell_info_filt)


distance_boxplot <- function(cell_info_filt, distance, radius, cols){
  cell_info_filt[[distance]][cell_info_filt[[distance]] < 0] <- 0
  p <- cell_info_filt %>% 
    filter(., #CellType_h2 %in% c("Lymphoid", "Myeloid", "Tumor", "CAF") &
           .data[[distance]] < radius) %>% 
    ggplot(., aes(x=reorder(CellType, .data[[distance]], FUN = median), 
                  y=.data[[distance]], fill = CellType)) + 
    geom_boxplot()+#geom_violin()+
    scale_fill_manual(values=cols)+
    #stat_compare_means(label = "p.signif", paired = T)+
    labs(title = paste0("cell types within radius ", radius),
         #subtitle = sub_title,
         x = "")+
    scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
    theme_bw()
  
  full_filename <- file.path(output_folder, paste0("Boxplot_", distance,"_r",radius,".png"))
  ggsave(full_filename, p)
  return(p)
}


r <- 50

color_set2 <- c(
  "B cells" = "#ff7f0e",
  "CD4 T cells" = "#7d87b9",
  "Epithelial cells" = "#8c564b",
  "CD56+epi" = "#bf8d85",
  "CD8 T cells "= "#023fa5",
  "Dendritic cells" = "#888D07",
  "EndoMT" = "#d5eae7",
  "EndomyCAF" = "#d5eae7",
  "Endothelial cells" = "#d62728",
  "Mast cells" = "#000035",
  "myCAF" = "#FFE5A7",
  "NK cells" = "#00025E",
  "Other Myeloid" = "#b903aa",
  "Other T cells" = "#bdd7e7",
  "Treg cells" = "#536CC7", 
  "Vim+" = "#B4584D",
  "CycotoxicCD8T" = "#b903aa",
  "MacrophagesMHCII+" = "#5E21E3",
  "MacrophagesMHCII-" = "#17becf"
)

distTo <- "distToMacroMHC2Pos"
distance_boxplot(cell_info_filt, distance = distTo, radius=r, cols = color_set2)

distTo <- "distToTumor"
distance_boxplot(cell_info_filt, distance = distTo, radius=r, cols = color_set2)