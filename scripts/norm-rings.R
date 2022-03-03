# Set the working directory into the kraken-to-graphlan folder
setwd("D:/documentos/git/tools-for-metagenomics/kraken-to-graphlan")

#Define the funtion that we will use to normalize the abundance data.
norm1 <- function(x){(x-min(x))/(max(x)-min(x))}

# Read the first file, ring1.txt
ring1 <- read.table(file = "rings-files/ring1.txt")
# Normalize the data with the new 
ring1$V4 <- norm1(ring1$V4)
write.table(ring1, file = "rings-files/tring1.txt", sep ="\t" ,
            row.names = FALSE, col.names = FALSE, quote = FALSE)

ring2 <- read.table(file = "rings-files/ring2.txt")
ring2$V4 <- range01(ring2$V4)
write.table(ring2, file = "rings-files/tring2.txt", sep ="\t" ,
            row.names = FALSE, col.names = FALSE, quote = FALSE)
