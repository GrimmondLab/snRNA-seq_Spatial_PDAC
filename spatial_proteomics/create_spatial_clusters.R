#' @author Big K
#' 
#' 
#'
#' @param 
#'
#' @return
#' @examples
#' 

library(dplyr)
library(tidyr)



create_spatial_clusters <- function(cell_df, 
                                    image_col,
                                    phenotype_col,
                                    x_coordinates, 
                                    y_coordinates, 
                                    k_closest=10,
                                    max_dist=50, 
                                    number_clusters_kmeans=7,
                                    keep_proportions=TRUE,
                                    random.state = 123){
  
  proportions_df <- find_nearest_neighbour_proportions(cell_df, 
                                                      image_col,
                                                      phenotype_col,
                                                      x_coordinates, 
                                                      y_coordinates, 
                                                      k_closest,
                                                      max_dist)
  
  set.seed(random.state)
  cluster_objs <- kmeans(proportions_df %>% subset(select=-c(Image)), number_clusters_kmeans)
  cluster <- cluster_objs$cluster
  if (keep_proportions){
    cluster <- cbind(proportions_df, cluster)
  }
  return(cluster)
}

find_nearest_neighbour_proportions <- function(cell_df, 
                                               image_col,
                                               phenotype_col,
                                               x_coordinates, 
                                               y_coordinates, 
                                               k_closest=10,
                                               max_dist=50){
    cell_df$temp_cell_id <- rownames(cell_df)
    
    proportions_df <- cell_df %>% 
        group_by(!!as.name(image_col)) %>%
        group_modify(~ {
            
            
            find_nearest_neighbour_proportions_(
            cell_df=.x,
            phenotype_col=phenotype_col,
            x_coordinates=x_coordinates, 
            y_coordinates=y_coordinates, 
            k_closest=k_closest,
            max_dist=max_dist
        )}, .keep = TRUE) %>%
        ungroup()
    
    
    proportions_df <- proportions_df[match(cell_df$temp_cell_id, proportions_df$temp_cell_id),]
    proportions_df <- proportions_df %>% replace(is.na(.), 0)
    proportions_df <- proportions_df %>% subset(select=-c(temp_cell_id))
    
    return(proportions_df)
}


find_nearest_neighbour_proportions_ <- function(cell_df, 
                                                phenotype_col,
                                                x_coordinates, 
                                                y_coordinates, 
                                                k_closest = 10,
                                                max_dist = 50) {
  if (nrow(cell_df) == 1) {
    return(cell_df[, c("temp_cell_id")])
  }
  
  k_closest <- k_closest + 1
  if (k_closest > nrow(cell_df)) {
    warning(paste0(cell_df$Image[1], " has fewer rows than nearest neighbours. Using all rows."))
    k_closest <- nrow(cell_df)
  }
  
  cell_df <- data.frame(cell_df, check.names = FALSE)
  cell_df[[phenotype_col]] <- as.character(cell_df[[phenotype_col]])
  
  # Nearest neighbor analysis
  closest <- RANN::nn2(
    data = cell_df[, c(x_coordinates, y_coordinates)], 
    query = cell_df[, c(x_coordinates, y_coordinates)], 
    k = k_closest
  )
  
  dists <- data.frame(closest$nn.dists)[, -1, drop = FALSE]
  nn.idx <- data.frame(closest$nn.idx)[, -1, drop = FALSE]
  colnames(dists) <- paste("Dist", 1:ncol(dists), sep = ":")
  colnames(nn.idx) <- paste("NN:idx", 1:ncol(nn.idx), sep = ":")
  
  # Initialize neighbor phenotype matrix
  nn <- nn.idx
  colnames(nn) <- paste("NN", 1:ncol(nn.idx), sep = ":")
  
  nn[] <- cell_df[match(as.integer(unlist(nn.idx)), as.integer(rownames(cell_df))), phenotype_col]
  
  null_cell_type <- "TOO_FAR"
  nn[dists > max_dist] <- null_cell_type
  
  nn$temp_id <- as.numeric(rownames(nn))
  
  # Flatten and count
  long_nn <- pivot_longer(nn, cols = -temp_id, names_to = "Hierarchy:Level", 
                          values_to = "Phenotype")
  long_nn$Phenotype <- as.character(long_nn$Phenotype) #fix number two
  
  counts <- long_nn %>%
    group_by(temp_id, Phenotype) %>%
    summarise(n = n(), .groups = "drop")
  
  proportions <- counts %>%
    pivot_wider(names_from = Phenotype, values_from = n, values_fill = 0)
  
  proportions$temp_cell_id <- cell_df$temp_cell_id
  
  # Remove TOO_FAR if present
  if ("TOO_FAR" %in% colnames(proportions)) {
    proportions <- proportions %>% select(-TOO_FAR)
  }
  
  # Convert counts to proportions
  f <- function(x) x / (k_closest - 1)
  proportions <- proportions %>% mutate(across(where(is.numeric), f))
  
  return(proportions)
}
