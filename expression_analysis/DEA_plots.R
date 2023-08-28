###############################################################################
###############################################################################
#                                                                             #
# miRNA and isomiRs Differential Expression Analysis in Breast Cancer: Plots  #
#                                                                             #
###############################################################################
###############################################################################


library(ggplot2)
library(Glimma)
library(plotly)
library(reshape2)


###############################################################################
# RAW COUNTS PER SAMPLE
###############################################################################
#
# This plot requires a DGEList object.
# The y-axis contains the counts, the x-axis the samples and each horizontal
# line, represents a miRNA.
#
# Given the large size of the plot, it is recommendable to store it in a
# variable and print it just when/if necessary
#

mirna_melt <- melt(as.matrix(dge$counts))

t <- ggplot(mirna_melt, aes(x = Var2, 
                            y = value, 
                            group = Var1, 
                            color = Var2)) +
  geom_line(stat = "identity") +
  labs( title = "miRNA Species Counts per Sample", 
        x = "Sample", y = "Counts") +
  theme(legend.position = "none", 
        axis.text.x = element_blank())

  # Display plot
#t


###############################################################################
# NORMALIZED COUNTS PER miRNA
###############################################################################
#
# This plot requires a data frame with the normalized log counts with
# features in the rows and samples in the coulmns (log_norm_mirna).
# The x-axis contains the counts, the y-axis the amount of a miRNA has that
# amount of counts.
#

mirna_melt3 <- melt(log_norm_mirna)

ggplot(mirna_melt3, aes(x = value)) +
  geom_histogram(binwidth = 0.5, 
                 color = "#FFFFFF", 
                 fill = "#9900CC",
                 alpha = 0.7) +
  labs( title = "Normalized log Counts Distribution", 
        x = "Counts", y = "miRNA species") +
  theme(legend.position = "none")


###############################################################################
# PRINCIPAL COMPONENTS ANALYSIS
###############################################################################
#
# This plot requires a `prcomp` object (PCA).
# For plotting it using `ggplot`, you must create a data frame from the 
# PCA results.
#
# The % in PC1 and PC2 must be found beforehand in order to add it to the x and
# y labels.
#
# All the defined variables are added to the main layer `aes` in order to be
# present in the interactive plot when hoovering over a sample
#

components <- data.frame(PCA$x)

Case <- metadata$Case.ID
Sample <- rownames(components)
Stage <- metadata$ajcc_pathologic_tumor_stage
Tissue <- metadata$Sample.Type
"Vital status" <- metadata$vital_status
Plate <- metadata$Plate

plates_col = c( "#4B0082", "#00BFFF", "#FF0000", "#EB22BE", "#7CFC00",
                "#FF1493", "#8A2BE2", "#228B22", "#C71585", "#FF8C00",
                "#9900CC", "#A52A2A", "#00FFFF", "#FFD700", "#00FA9A")

  # Tissue PCA
gg <- ggplot(components,aes(x = PC1, y= PC2, 
                            case = Case,
                            sample = Sample,
                            shape = Tissue, 
                            color = Tissue, 
                            stage = Stage, 
                            vital = `Vital status`)) +
  geom_point(alpha = 0.8, size = 4) +
  geom_hline(yintercept=0, linetype="dashed", alpha = 0.2) +
  geom_vline(xintercept=0, linetype="dashed", alpha = 0.2) +
  labs(title = "miRNA Expression Across Samples PCA", 
       x = "PC1 (23.01%)", 
       y = "PC2 (9.35%)") +
  scale_color_manual(values=c("#40E0D0","#8A2BE2")) +
  scale_shape_manual(values = c(1, 5))

  # Make interactive plot
ggplotly(gg)

  # Tissue and plate PCA
gg2 <- ggplot(components,aes(x = PC1, y= PC2, 
                            case = Case,
                            sample = Sample,
                            stage = Stage, 
                            color = Plate,
                            shape = Tissue,
                            vital = `Vital status`)) +
  geom_point(alpha = 0.8, size = 4) +
  geom_hline(yintercept=0, linetype="dashed", alpha = 0.2) +
  geom_vline(xintercept=0, linetype="dashed", alpha = 0.2) +
  labs(title = "miRNA Expression Across Samples per Plate PCA", 
       x = "PC1 (27.37%)", 
       y = "PC2 (14.02%)") +
  scale_color_manual(values = plates_col) +
  scale_shape_manual(values = c(1, 5))

  # Make interactive plot
ggplotly(gg2)


###############################################################################
# NEGATIVE BIONMIAL DISPERSION ESTIMATES
###############################################################################
#
# This plot requires a DGEList object created using the function `estimateDisp`
# The extra options are used to unify the lower and left plot frames 
#

plotBCV(dge, main = "miRNA Counts Dispersion Estimates", 
        frame.plot=FALSE , 
        col.trend = "#8A2BE2", col.common = "#00BFFF")
box(bty="l")
axis(2)
axis(1)


###############################################################################
# QUASI-LIKELIHOOD DISPERSION ESTIMATES
###############################################################################
#
# This plot requires a DGEList object created using the function `glmQLFit`
# The extra options are used to unify the lower and left plot frames 
#

plotQLDisp(fit,  main = "miRNA Counts Quasi-Likelihood Dispersion Estimates", 
           frame.plot=FALSE , 
           col.trend = "#8A2BE2", col.shrunk = "#00BFFF")
box(bty="l")
axis(2)
axis(1)


###############################################################################
# GLIMMA INTERACTIVE VOLCANO PLOT
###############################################################################
#
# This plot requires a DGEList object created using the function `glmQLFit` 
# (fit) and a DGELRT object created with either `glmQLFTest` or `glmTreat` (res)
#
# The `decideTestsDGE` sets whether a miRNA is differentially expressed or not
# If `p.value` is not specified, it equals to 0.05
#
# If you want to save the plot in a separate html the option `html = filename`
# must be added
#

glimmaVolcano(res, dge = fit, 
              status = decideTestsDGE(res, p.value = 0.01),
              main = "Normal vs Tumor")

