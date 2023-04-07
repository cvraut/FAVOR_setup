args <- commandArgs(trailingOnly = TRUE)
arg1 <- args[1]

library(gdsfmt)
library(SeqArray)
library(readr)

gds.file <- arg1

## open GDS
genofile <- seqOpen(gds.file, readonly = FALSE)
# genofile
CHR <- as.numeric(seqGetData(genofile, "chromosome"))
position <- as.integer(seqGetData(genofile, "position"))
REF <- as.character(seqGetData(genofile, "$ref"))
ALT <- as.character(seqGetData(genofile, "$alt"))
seqClose(genofile)

# build variant list
my_df <- data.frame(list(
  chrom=CHR,
  pos=position,
  ref=REF,
  alt=ALT
))
csv.file <- paste0(basename(gds.file),".csv")
write.csv(my_df, csv.file, row.names = FALSE, quote=FALSE)

