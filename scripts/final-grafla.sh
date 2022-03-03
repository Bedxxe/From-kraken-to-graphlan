#!/bin/sh

graphlan_annotate.py --annot grap-files/merged_abundance.annot.txt grap-files/merged_abundance.tree.txt grap-files/final_abundance.xml

echo Generating the .png file
graphlan.py --dpi 300 --size 10 grap-files/final_abundance.xml final_graph.png --external_legends