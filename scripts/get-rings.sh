#!/bin/sh

mkdir rings-files

cat grap-files/merged_abundance.annot.txt | grep p__ | grep clade_marker_size \
| while read line; do otu=$(echo $line | cut -d' ' -f1) ; \
value=$(echo $line | cut -d' ' -f3); \
echo $otu"\tring_alpha\t"1"\t"$value;done > rings-files/ring1.txt
cat grap-files/merged_abundance.annot.txt | grep g__ | grep clade_marker_size \
| while read line; do otu=$(echo $line | cut -d' ' -f1) ; \
value=$(echo $line | cut -d' ' -f3); \
echo $otu"\tring_height\t"2"\t"$value;done > rings-files/ring2.txt

echo New files are locates in the rings-files folder
