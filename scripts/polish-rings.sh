#!/bin/sh

cat grap-files/merged_abundance.annot.txt | grep p__ | grep clade_marker_size \
| while read line; do otu=$(echo $line | cut -d' ' -f1) ; \
value=$(echo $line | cut -d' ' -f3); \
echo $otu"\tring_color\t"1"\t#AAAA00";done >> rings-files/tring1.txt

cat rings-files/tring1.txt >> grap-files/merged_abundance.annot.txt
cat rings-files/tring2.txt >> grap-files/merged_abundance.annot.txt

echo color added to the first ring

echo "ring_label\t"1"\tPhyla-abundance" >> grap-files/merged_abundance.annot.txt
echo "ring_label\t"2"\tGenera-abundance" >> grap-files/merged_abundance.annot.txt

echo Label created for the two rings in the plot
