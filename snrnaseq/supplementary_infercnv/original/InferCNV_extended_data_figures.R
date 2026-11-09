# Record of the two analyses behind Extended Data Fig. 4F and 1B that are not in InferCNV_original.Rmd.
# Kept as run, except that home-folder paths are replaced with placeholders. Not part of the container stage.

library(infercnv)
library(Seurat)
library(dplyr)

# ---------------------------------------------------------------------------
# Extended Data Fig. 4F: inferCNV for patient 2221 (ICGC_0105) by Lv.2.Anno, to check the malignant Tuft cells
# sts.simspec.final: the annotated object with Lv.2.Anno
# Note: subset(downsample = 1000) picks cells at random, and no seed was set
# ---------------------------------------------------------------------------

# Repeat P2221 to check malignant Tuft
# Load #P2221 from pdacnorm VM using Lv.2.Annotation
ADMsamples <- sts.simspec.final %>% subset(Patient_ID %in% c("2221") & Lv.2.Anno %in% c("PDAC", "Endothelial", "Pericytes","PDAC","Tuft","Tuft.persistent"))
Idents(ADMsamples) <- "Lv.2.Anno"
ADMsamples <- subset(ADMsamples, downsample=1000)
df <- FetchData(ADMsamples, vars = c("Cell_Ids", "Lv.2.Anno"))
write.table(df, file ='/path/to/data/sample_annotation.Lv2Anno.P2221.tsv', sep = '\t', quote = F, row.names = F, col.names = F) # this is a correct format

counts <- ADMsamples@assays$RNA@counts

infercnv_obj = CreateInfercnvObject(raw_counts_matrix=as.matrix(counts),
                                    annotations_file= '/path/to/data/sample_annotation.Lv2Anno.P2221.tsv',
                                    delim="\t",
                                    gene_order_file="/path/to/gene_positions.txt",
                                    ref_group_names= c("Endothelial","Pericytes")
                                    )

inferCNV.subclusters <- infercnv::run(infercnv_obj,
cutoff = 0.1, # key, and recommened set = 0.1 for 10X data
out_dir = "/path/to/data/P2221.lv2anno.out/",
cluster_by_groups = T, # to perform separate clustering for the tumor cells according to the patient type, as defined in the cell annotations file. Set this T if we want to look at each malignant sample separately
analysis_mode = 'subclusters',
denoise = T, # enable denoise procedure
HMM = T, # enable CNV prediction, important to
noise_logistic = TRUE,
sd_amplifier = 3,
BayesMaxPNormal = 0.3, # default is 0.5, we can reduce this to filter out low confident CNV prediction
tumor_subcluster_pval=0.05,
leiden_resolution = 0.001, # default is 0.05, this step is to reduce number of subclustering that are detected, which is important for HMM, used 0.0005 but this is too few clustering, can still see cells that can be clustered more
#up_to_step = 15, # use this so then we can inspect subclustering before
)

# ---------------------------------------------------------------------------
# Extended Data Fig. 1B: WGS copy number for sample 2992 (ICGC_0235), compared with its inferCNV output (P2992.out)
# Input: PURPLE copy-number segments from the tumour WGS (patient data, not deposited)
# cnSpec() is from the GenVisR package; genomeBoundaries is not defined in this record
# ---------------------------------------------------------------------------

wgs_2992 <- read.csv("/path/to/apgi_2992/APGI_2992__ICGC_0235_T.purple.segment.tsv", header = TRUE, sep = "")
wgs.2992 <- wgs_2992 %>%
  dplyr::select(chromosome, start, end, refNormalisedCopyNumber) %>%
  dplyr::rename(segmean = refNormalisedCopyNumber) %>%
  dplyr::mutate(sample = "WGS2992") %>%
  dplyr::select(sample, everything())
cnSpec(wgs.2992, y=genomeBoundaries)
