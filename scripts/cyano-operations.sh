#!/bin/sh
# This program is used to trim the cyanobacteria assignation. Since kraken2 does not put class to other 
# cyanobacteria than Gloeobacteria, we need to add it manually. 

# First, extract the Gloeobacteria counts in the six samples
x1=$(cat combine.mpa | grep Cyanobacteria | grep Gloeobacteria| sed -n '1p'| cut -f2)
x2=$(cat combine.mpa | grep Cyanobacteria | grep Gloeobacteria| sed -n '1p'| cut -f3)
x3=$(cat combine.mpa | grep Cyanobacteria | grep Gloeobacteria| sed -n '1p'| cut -f4)
x4=$(cat combine.mpa | grep Cyanobacteria | grep Gloeobacteria| sed -n '1p'| cut -f5)
x5=$(cat combine.mpa | grep Cyanobacteria | grep Gloeobacteria| sed -n '1p'| cut -f6)
x6=$(cat combine.mpa | grep Cyanobacteria | grep Gloeobacteria| sed -n '1p'| cut -f7)
x7=$(cat combine.mpa | grep Cyanobacteria | grep Gloeobacteria| sed -n '1p'| cut -f8)

# Then, extract the entire cyanobacterial counts
y1=$(cat combine.mpa | grep Cyanobacteria |sed -n '1p'| cut -f2)
y2=$(cat combine.mpa | grep Cyanobacteria |sed -n '1p'| cut -f3)
y3=$(cat combine.mpa | grep Cyanobacteria |sed -n '1p'| cut -f4)
y4=$(cat combine.mpa | grep Cyanobacteria |sed -n '1p'| cut -f5)
y5=$(cat combine.mpa | grep Cyanobacteria |sed -n '1p'| cut -f6)
y6=$(cat combine.mpa | grep Cyanobacteria |sed -n '1p'| cut -f7)
y7=$(cat combine.mpa | grep Cyanobacteria |sed -n '1p'| cut -f8)

# Now substract xn to yn to be added to c__Cyanophyceae abundance in each sample
z1=$(echo $(($y1 - $x1)))
z2=$(echo $(($y2 - $x2)))
z3=$(echo $(($y3 - $x3)))
z4=$(echo $(($y4 - $x4)))
z5=$(echo $(($y5 - $x5)))
z6=$(echo $(($y6 - $x6)))
z7=$(echo $(($y7 - $x7)))

# We will begin to assemble the cyano.mpa file, where the trimmed information will be allocated.
# Extract the p__Cyanobacteria first line of information ans put it in a new file
cat combine.mpa | grep Cyanobacteria | sed -n '1p'|head > cyanos.mpa
# Now we will add the Gloeobacteria lines 
cat combine.mpa | grep Cyanobacteria | sed -n '1!p'| grep Gloeobacteria >> cyanos.mpa
# Then, we will create a line for the new class 
cat combine.mpa | grep Cyanobacteria | sed -n '1p'| while read line; do first=$(echo $line | cut -d' ' -f1); second=$(echo $line | cut -d' ' -f2,3,4,5,6,7,8 ); echo $first"|c__Cyanophyceae\t"$z1"\t"$z2"\t"$z3"\t"$z4"\t"$z5"\t"$z6; done >> cyanos.mpa
# Moreover, add the rest of the lines with the next command:
cat combine.mpa | grep Cyanobacteria | sed -n '1!p'| grep -v Gloeobacteria| while read line; do first=$(echo $line | cut -d'|' -f1,2); second=$(echo $line | cut -d'|' -f3,4,5,6,7,8 ); echo $first"|c__Cyanophyceae|"$second; done >> cyanos.mpa

# We will use awk to create tab separations instead of blank spaces
awk -v OFS="\t" '$1=$1' cyanos.mpa > cyano.mpa
# Remove the old cyanos.mpa file
rm cyanos.mpa

#Let's add this trimmed information to the entire data
cat combine.mpa | grep  -v Cyanobacteria > trim-combine.mpa
cat cyano.mpa >> trim-combine.mpa
