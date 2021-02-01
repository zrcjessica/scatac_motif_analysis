library(GenomicRanges)
library(ggplot2)
library(dplyr)
library(plyr)
library(argparse)

print("running convert_dapeaks_to_bed.R")

parser <- ArgumentParser(description = "process input arguments")
parser$add_argument('--input', action = "store", type = "character", 
	help = "path to parsed dapeaks file to convert to bed")
# parser$add_argument("--plot", action = "store_true",
# 	help = "if true, plot histograms of peak widths")
# parser$add_argument("sample", action = "store", type = "character",
# 	help = "sample name")
# parser$add_argument()
parser$add_argument('--outdir', action = "store", type = "character",
	help = "path to save output bed files")

args <- parser$parse_args()

peaks <- read.csv(args$input, row.names = 1)

gr <- makeGRangesFromDataFrame(peaks, keep.extra.columns = TRUE)

bed <- data.frame(gr) %>% select(gene, everything()) %>%
select(c(seqnames, start, end), everything())

colnames(bed)[4] <- "peak"

# split bed by cell type
bed.split <- dlply(bed, "cluster", identity)
names(bed.split) <- sub(" ", "_", names(bed.split))

for (i in 1:length(bed.split)) {
	celltype <- names(bed.split)[i]
	outfh <- file.path(args$outdir, sprintf("%s_da_peaks.bed", celltype))
	cat(sprintf("writing bed file for %s to %s\n", celltype, outfh))
	write.table(bed.split[i],
		file = outfh,
		quote = FALSE,
		sep = '\t',
		row.names = FALSE,
		col.names = FALSE)
}

# if (args$plot) {
# 	width.df <- data.frame(peak = bed$peak,
# 		celltype = bed$cluster,
# 		width = width(gr))
# 	p <- ggplot(width.df, aes(x = celltype, y = width, fill = celltype)) +
# 	geom_boxplot() + theme_minimal() + 
# 	scale_x_discrete(labels = c("Precursor Oligodendrocytes" = "Precursor\nOligodendrocytes",
# 		"Mature Oligodendrocytes" = "Mature\nOligodendrocytes")) +
# 	theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
# 	ggtitle(sprintf("%s differential peak widths", args$sample))
# }