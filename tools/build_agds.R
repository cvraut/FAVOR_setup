args <- commandArgs(trailingOnly = TRUE)
arg1 <- args[1]
arg2 <- args[2]

library(gdsfmt)
library(SeqArray)
library(readr)

agds.file <- arg1
annot.file <- arg2

genofile <- seqOpen(agds.file, readonly = FALSE)

CHR <- as.numeric(seqGetData(genofile, "chromosome"))
position <- as.integer(seqGetData(genofile, "position"))
REF <- as.character(seqGetData(genofile, "$ref"))
ALT <- as.character(seqGetData(genofile, "$alt"))

VarInfo <- paste0(CHR,"-",position,"-",REF,"-",ALT)

my_df <- data.frame(list(
  VarInfo=VarInfo
))

FunctionalAnnotation <- read_csv(annot.file,show_col_types=FALSE)
dim(FunctionalAnnotation)
FunctionalAnnotation <- merge(my_df,FunctionalAnnotation,by="VarInfo",all.x=TRUE)
dim(FunctionalAnnotation)

Anno.folder <- index.gdsn(genofile, "annotation/info")
add.gdsn(Anno.folder, "FAVORFullDB", val=FunctionalAnnotation, compress="LZMA_ra", closezip=TRUE)
genofile

seqClose(genofile)