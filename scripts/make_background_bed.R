library(GenomicRanges)
library(argparse)
library(dplyr)

# given narrowPeak files for different cell types
# returns bg set of peaks from all *other* cell types

parser <- ArgumentParser(description = "parse inputs")
parser$add_argument("--files", nargs = "+",
	help = "input narrowpeak files")
parser$add_argument("--celltypes", nargs = "+",
	help = "cell types corresponding to input narrowpeak files")
parser$add_argument("--outdir",
	help = "where to save background bed files")

args <- parser$parse_args()

print(args$celltypes)

all.list <- list()
for (i in 1:length(args$files)) {
	df <- read.table(args$files[[i]])[,c(1:6)]
	df$celltype <- args$celltypes[i]
	all.list[[i]] <- df
}

all <- do.call(rbind, all.list)

for (type in args$celltypes) {
	cat(sprintf("making background bed files for %s\n", type))
	bg.bed <- filter(all, celltype != type)
	bg.bed[,1] <- paste0('chr', bg.bed[,1])
	write.table(bg.bed,
           file = file.path(args$outdir, sprintf("%s_bg.bed", type)), 
           quote = FALSE,
           sep = "\t",
           row.names = FALSE,
           col.names = FALSE)
}
