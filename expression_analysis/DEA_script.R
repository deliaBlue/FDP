###############################################################################
###############################################################################
#                                                                             #
#     miRNA and isomiRs Differential Expression Analysis in Breast Cancer     #
#                                                                             #
###############################################################################
###############################################################################


library(edgeR)
library(tidyverse)
library(dplyr)
library(readxl)
library(limma)
library(reshape2)
library(statmod)


###############################################################################
# DATA LOADING AND PREPROCESSING
###############################################################################


  # Per case metadata
raw_case_metadata <- read_excel("case_metadata.xlsx",
                           sheet = 1,
                           col_types = NULL)

case_metadata <- raw_case_metadata %>% 
  select(2:34) %>% 
  filter(type == "BRCA")

  # Per sample metadata
raw_sample_metadata <- read.table("./sample_metadata.csv",
                                  sep = "\t",
                                  header = TRUE)

sample_metadata <- raw_sample_metadata %>% 
  select(c(File.Name, Case.ID, Sample.ID, Sample.Type))

for (i in 1:nrow(sample_metadata)){
  sample_metadata$File.Name[i] <- substr(raw_sample_metadata$File.Name[i], 6, 28)
  sample_metadata$Plate[i] <- strsplit(sample_metadata$File.Name[i], "-")[[1]][5]
}

  # Sample selection
sample_metadata <- sample_metadata %>% 
  group_by(Case.ID) %>% 
  filter( n() == 2 ,
          any(Sample.Type == "Solid Tissue Normal"), 
          !Sample.Type == "Metastatic") %>%
  arrange(Case.ID)

sample_metadata$Sample.Type[sample_metadata$Sample.Type == "Primary Tumor"] <- "Tumor"
sample_metadata$Sample.Type[sample_metadata$Sample.Type == "Solid Tissue Normal"] <- "Normal"

case_metadata <- case_metadata %>%
  filter(bcr_patient_barcode %in% sample_metadata$Case.ID,
         !(vital_status == "Dead"& tumor_status == "TUMOR FREE"),
         gender == "FEMALE",
         !is.na(tumor_status),
         is.na(new_tumor_event_type),
         race != "[Not Available]",
         histological_type == "Infiltrating Ductal Carcinoma",
         !ajcc_pathologic_tumor_stage %in% c("Stage IIIB", 
                                             "Stage IIIC", 
                                             "Stage IV")) %>%
  select(bcr_patient_barcode, 
         age_at_initial_pathologic_diagnosis,
         race, 
         ajcc_pathologic_tumor_stage,
         vital_status,
         tumor_status, 
         menopause_status, 
         initial_pathologic_dx_year, 
         birth_days_to, 
         death_days_to) 
colnames(case_metadata)[1] <- "Case.ID"

sample_metadata <- sample_metadata %>%
  filter(Case.ID %in% case_metadata$Case.ID) %>%
  select(File.Name, Case.ID, Sample.Type, Plate) %>%
  arrange(File.Name)

  # Metadata merging
metadata <- sample_metadata %>% 
  inner_join(case_metadata, by = "Case.ID")

metadata <- column_to_rownames(metadata, var = "File.Name")

metadata$ajcc_pathologic_tumor_stage[metadata$Sample.Type == "Normal"] <- "None"

  # miRNA counts loading
options(scipen=999)

fnames <- list.files("./mirna_samples", full.names = T)
mirna_counts <-  read.csv(fnames[1],sep = "\t", header = TRUE)

for (table in fnames[-1]){
  table <- read.csv(table, header = TRUE, sep = "\t")
  mirna_counts <- mirna_counts %>% full_join(table)
}

mirna_counts[is.na(mirna_counts)] <- 0

rownames(mirna_counts) <- mirna_counts[,1]
mirna_counts <- mirna_counts[,-1]

colnames(mirna_counts) <-gsub("\\.", "-", colnames(mirna_counts))

  # DGEList object building
dge <- DGEList(counts = mirna_counts, group = as.factor(metadata$Sample.Type))
options(digits = 2)


###############################################################################
# EXPLORATORY DATA ANALYSIS
###############################################################################


  # Filtering by expression
mirna2keep <- filterByExpr(dge)
dge <- dge[mirna2keep, , keep.lib.sizes=F]

  # Data normalization
dge <- calcNormFactors(dge, method = "TMMwsp")

  # Principal Component Analysis
log_norm_mirna <- cpm(dge, log = T, normalized.lib.sizes = )
PCA <- prcomp(t(log_norm_mirna), scale. = T)


  # Outliers removal 
outliers <-  c("BH-A0BZ-01A-31R-A12O-13",
               "BH-A1FN-01A-11R-A13P-13",
               "E2-A1LH-01A-11R-A14C-13")

dge <- dge[, !rownames(dge$samples) %in% outliers]
metadata <- metadata[!rownames(metadata) %in% outliers, ]

mirna2keep <- filterByExpr(dge)
dge <- dge[mirna2keep, , keep.lib.sizes = F]

dge <- calcNormFactors(dge, method = "TMMwsp")
log_norm_mirna <- cpm(dge, log = T, normalized.lib.sizes = T)

PCA <- prcomp(t(log_norm_mirna), scale. = T)


###############################################################################
# DIFFERENTIAL EXPRESSION ANALYSIS
###############################################################################


  # Design matrix
design_mat <- model.matrix(~0 + dge$samples$group)
colnames(design_mat) <- levels(dge$samples$group)

  # Dispersion estimates
dge <- estimateDisp(dge, design_mat, robust=TRUE)

  # Quasi-Likelihood fit
fit <- glmQLFit(dge, design_mat, robust=TRUE)

  # Contrast matrix
contrast_mat <- makeContrasts(Normal - Tumor, levels = design_mat)

  # DEA relative to p-value
res <- glmQLFTest(fit, contrast = contrast_mat)
top <- topTags(res, n = Inf, p.value = 0.01)

  # DEA relative to logFC threshold
res2 <- glmTreat(fit, contrast = contrast_mat, lfc = log2(1.5))
top2 <- topTags(res2, n = Inf, p.value = 0.01)


