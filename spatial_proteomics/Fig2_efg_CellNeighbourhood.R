
library(ggplot2)
library(patchwork)
library(gridExtra)
library(pheatmap)
library(RColorBrewer)
library(dplyr)
library(tidyr)
library(SpatialExperiment)
library(imcRtools)

## Source the function from Kenta
source("create_spatial_clusters.R")

spe <- readRDS("rdata/spe.rds")
## Merge Vim+ with Vim+CD68+
spe$consistent_cell_types <- as.character(spe$CellType_upd)
cell_types_to_join <- c("Vim+", "Vim+CD68+")
spe$consistent_cell_types <- gsub("CD68\\+", "", spe$consistent_cell_types)

for_cn <- data.frame(Image = spe$FOV_by_patient,
                     Phenotype = as.character(spe$consistent_cell_types),
                     CellType_h1 = spe$parent_cell_type,
                     X = spatialCoords(spe)[,1],
                     Y = spatialCoords(spe)[,2],
                     check.names = F)

dim(for_cn)
for_cn_immune <- for_cn[for_cn$CellType_h1 != "Other",]
for_cn_immune <- droplevels(for_cn_immune)
dim(for_cn_immune)

out <- create_spatial_clusters(for_cn, 
                               image_col = "Image",
                               phenotype_col = "Phenotype",
                               x_coordinates = "X",
                               y_coordinates = "Y",
                               number_clusters_kmeans=9)

set.seed(42)
cntrs <- 9
cluster_objs <- kmeans(out[,-which(colnames(out) %in% 
                                     c("Image", "temp_id", "cluster", "cell.id", "cl3_25"))],
                       centers = cntrs, iter.max = 30, nstart = 25)
out$cl3_25 <- cluster_objs$cluster

cn_res <- for_cn %>% 
  left_join(out, by = "cell.id") %>% 
  mutate(CN.clusters = replace_na(cl3_25, -1))

#saveRDS(cn_res, file = paste0("rdata/out_CN",cntrs,".rds"))

spe$CN9 <- as.character(cn_res$CN.clusters)

# Fig.2G
plotSpatial(spe, 
            node_color_by = "CN9", 
            img_id = "sample_id",
            coords = c("Centroid.X.µm", "Centroid.Y.µm"),
            node_size_fix = 0.5) +
  scale_color_brewer(palette = "Set3")+
  ggtitle("All FOVs, CN9")


for_plot <- prop.table(table(as.character(spe$CN9), spe$consistent_cell_types), margin = 2)

# Fig.2E
pheatmap(for_plot, main = "CN9",
         color = colorRampPalette(c("dark blue", "white", "dark red"))(100), 
         scale = "column")

# Fig.2F
ggplot(colData(spe), aes(x=as.factor(Patient..), fill = CN9)) +
  geom_bar(position = "fill")+
  scale_fill_brewer(palette = "Set3")+
  labs(title = "Cell neighbourhood composition per patient")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))