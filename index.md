---

source: md
title: "From kraken to graphlan"

---

# From kraken to graphlan

I got enthralled by figures representing metagenomic taxonomic assignation and phylogenies using graphlan. During my master's degree research project, I tried different taxonomic
assignation programs (one of them was metaphlan), but the one that gave me the best results was kraken. After reading a little bit and trying to find a way to traduce my kraken 
output to work with graphlan I found a way to generate this good-looking figures using the kraken output. In order to obtain this desired results we will use the next set of 
softwares:

| Software | Version | Manual | 
| -------- | ------------ | ------ | ------------- | 
| [kraken2](https://github.com/DerrickWood/kraken2) | 2.1.2 | [Link](https://github.com/DerrickWood/kraken2/blob/master/docs/MANUAL.markdown) | 
| [krakentools](https://github.com/jenniferlu717/KrakenTools) | 1.2 | [Link](https://github.com/jenniferlu717/KrakenTools/) |
| [graphlan](https://github.com/biobakery/graphlan) | 1.1.3 | [Link](https://huttenhower.sph.harvard.edu/graphlan/) |
|[export2graphlan](https://github.com/SegataLab/export2graphlan) | 0.22 | [Link](https://github.com/SegataLab/export2graphlan)|

## Recommended Setup

python --version 2.7


## Taxonomic assignation with kraken2

A team from I am part of have develop a [lesson](https://github.com/carpentries-incubator/metagenomics/blob/gh-pages/_episodes/06-taxonomic.md) on The Carpentries platform where the taxonomic assingnation is explained. Here, I will leave an example code only for ilustrative purpose, but I will like to highlight that in order to use kraken2 for
taxonomic assignation, a machine (or cluster) with at least 64 Gb of RAM, 200 Gb of disk space, and 12 cores is recommended:
~~~
mkdir taxonomy/kraken

kraken2 --db kraken-db --threads 12 --paired --fastq-input $file1 $file2 --output taxonomy/kraken/prefix_kraken.kraken --report taxonomy/kraken/prefix_kraken.report
bracken -d kraken-db -i taxonomy/kraken/prefix_kraken.report -o taxonomy/kraken/prefix.bracken
~~~
{: .bash}

Where the `file1` and `file2` are the files where the forward and reverse reads are resepctively localized, and the prefix a disired identification that you want to give to 
all your working files from that sample.

In order to follow the next steps without requiring to download the reads files, I attached the resulting kraken2 reports from a set of samples from the work [Population genomics of cycad coralloid-root bacterial microbiome in contrasting environments(Unpublished)](link-to-draft) to serve as an example of the following steps.

The kraken reports for this example are located in the `reports` [folder](https://github.com/Bedxxe/From-kraken-to-graphlan/tree/main/reports) in the 
GitHub-page

## Using krakentools

Lets put everything in a folder that we will call `kraken-to-graphlan` inside any locality of your computer. Inside this folder we 
will create a folder to relocate the `.report` files, we will call it `kraken-reports`. Move the reports to this new folder to end with a folder-structure as follows:


As part of the tools offered by [krakentools](https://github.com/jenniferlu717/KrakenTools), there is a function called `kreport2mpa.py`. This program takes the 
[kraken2](https://github.com/DerrickWood/kraken2) output report file and generate a MetaPhlAn-style text file that we will use.

~~~
$ tree
~~~
{: .bash}

~~~
.
└── kraken-reports
    ├── QroArlegundo_kraken.report
    ├── QroDCuatro_kraken.report
    ├── QroPocitos1_kraken.report
    ├── QroPocitos2_kraken.report
    ├── SLPCarrizal1_kraken.report
    ├── SLPCarrizal2_kraken.report
    └── SLPLimones_kraken.report
~~~
{: .output}

If we call the the `kreport2mpa.py` in the terminal, we will obtain an output explaining the way to use it:
~~~
kreport2mpa.py
~~~
{: .bash}

~~~
usage: kreport2mpa.py [-h] -r R_FILE -o O_FILE [--display-header]
                      [--read_count] [--percentages] [--intermediate-ranks]
                      [--no-intermediate-ranks]
kreport2mpa.py: error: the following arguments are required: -r/--report-file/--report, -o/--output
~~~
{: .output}

You can use this program to process each report separately. We will take the report `QroPocitos1_kraken.report` to explain this by using the next piece of code:
~~~
$ kreport2mpa.py -r kraken-reports/QroPocitos1_kraken.report -o QroPocitos1.mpa
$ ls
~~~
{: .bash}

~~~
QroPocitos1.mpa  kraken-reports
~~~
{: .output}

If we explore the insides of this new file, we will obtained a MetaPhlan-style text
file:

~~~
$ head -n 10 QroPocitos1.mpa
~~~
{: .bash}

~~~
k__Bacteria     11123979
k__Bacteria|p__Cyanobacteria    10675084
k__Bacteria|p__Cyanobacteria|o__Nostocales      10608906
k__Bacteria|p__Cyanobacteria|o__Nostocales|f__Nostocaceae       9978629
k__Bacteria|p__Cyanobacteria|o__Nostocales|f__Nostocaceae|g__Nostoc     9834713
k__Bacteria|p__Cyanobacteria|o__Nostocales|f__Nostocaceae|g__Nostoc|s__Nostoc_sp._'Lobaria_pulmonaria_(5183)_cyanobiont'      4719169
k__Bacteria|p__Cyanobacteria|o__Nostocales|f__Nostocaceae|g__Nostoc|s__Nostoc_flagelliforme     1144071
k__Bacteria|p__Cyanobacteria|o__Nostocales|f__Nostocaceae|g__Nostoc|s__Nostoc_linckia   956414
k__Bacteria|p__Cyanobacteria|o__Nostocales|f__Nostocaceae|g__Nostoc|s__Nostoc_punctiforme       916756k__Bacteria|p__Cyanobacteria|o__Nostocales|f__Nostocaceae|g__Nostoc|s__Nostoc_sp._'Peltigera_membranacea_cyanobiont'_N6       801547
~~~
{: .output}

To maintain a good organization of this little example, let's create a folder where we will locate the `mpa` files and move this output there.

~~~
$ mkdir mpa-files
$ mv QroPocitos1.mpa mpa-files/
~~~
{: .bash}

For different reasons, is desireable to process a group of report files together 
to display the taxonomic assignation of a set of samples. We will do this with
all the report files we have in our `kraken-reports` folder using the next 
piece of code:
~~~
$ ls kraken-reports/*.report | while read line; do name=$(echo $line | cut -d'/' -f2 |cut -d'_' -f1); kreport2mpa.py -r $line -o mpa-files/$name.mpa; done
~~~
{: .bash}

And we will combine this `.mpa` files into one with the program `combine_mpa.py`. To
use it, we will need to specify the `.mpa` files that we want to combine and the
name of the output file:

~~~
$ combine_mpa.py --input mpa-files/*.mpa --output mpa-files/combine.mpa
~~~
{: .bash}

~~~
 Number of files to parse: 7
 Number of classifications to write: 5495
        5495 classifications printed
~~~
{: .output}

~~~
$ ls mpa-files/
~~~
{: .bash}

~~~
QroArlegundo.mpa  QroPocitos1.mpa  SLPCarrizal1.mpa  SLPLimones.mpa
QroDCuatro.mpa    QroPocitos2.mpa  SLPCarrizal2.mpa  combine.mpa
~~~
{: .output}

By exploring the new file, we will se that we have all the samples integrated in 
columns in this new `.mpa` file:

~~~
$ head -n10 combine.mpa
~~~
{: .bash}

~~~
#Classification Sample #1       Sample #2       Sample #3       Sample #4       Sample #5       Sample #6       Sample #7
k__Bacteria     13023490        15523665        11123979        5990058 9812341 13672293        13687393
k__Bacteria|p__Coprothermobacterota     0       1       3       2       2       2       0
k__Bacteria|p__Coprothermobacterota|c__Coprothermobacteria      0       1       3       2       2       2       0
k__Bacteria|p__Coprothermobacterota|c__Coprothermobacteria|o__Coprothermobacterales     0       1       3       2       2       2       0
k__Bacteria|p__Coprothermobacterota|c__Coprothermobacteria|o__Coprothermobacterales|f__Coprothermobacteraceae   0       1       3       2       2       2       0
k__Bacteria|p__Coprothermobacterota|c__Coprothermobacteria|o__Coprothermobacterales|f__Coprothermobacteraceae|g__Coprothermobacter      0       1       3       2       2       2       0
k__Bacteria|p__Coprothermobacterota|c__Coprothermobacteria|o__Coprothermobacterales|f__Coprothermobacteraceae|g__Coprothermobacter|s__Coprothermobacter_proteolyticus   0       1       3       2       2       0
k__Bacteria|p__Chrysiogenetes   5       10      18      79      0       237     4
k__Bacteria|p__Chrysiogenetes|c__Chrysiogenetes 5       10      18      79      0       237     4
~~~
{: .output}

## Adjusting Cyanobacterial OTUs

If we pay close inspection to how Cyanobacteria are classified, we will see 
something unexpected. We will se that the majority of the Cyanobacterial OTUs 
do not have an assigned Class to its classification.

~~~
$ grep "Cyanobacteria" combine.mpa | head -n 10
~~~
{: .bash}

~~~
k__Bacteria|p__Cyanobacteria    11970156        15042312        10675084        5286452 9045418 13337317       11338702
k__Bacteria|p__Cyanobacteria|o__Gloeoemargaritales      57      23      9       535     265     24    8
k__Bacteria|p__Cyanobacteria|o__Gloeoemargaritales|f__Gloeomargaritaceae        57      23      9     535      265     24      8
k__Bacteria|p__Cyanobacteria|o__Gloeoemargaritales|f__Gloeomargaritaceae|g__Gloeomargarita      57    23       9       535     265     24      8
k__Bacteria|p__Cyanobacteria|o__Gloeoemargaritales|f__Gloeomargaritaceae|g__Gloeomargarita|s__Gloeomargarita_lithophora        57      23      9       535     265     24      8
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria   290     2684    224     176     147     856     166
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria|o__Gloeobacterales        290     2684    224     176   147      856     166
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria|o__Gloeobacterales|f__Gloeobacteraceae    290     2684  224      176     147     856     166
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria|o__Gloeobacterales|f__Gloeobacteraceae|g__Gloeobacter   290      2684    224     176     147     856     166
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria|o__Gloeobacterales|f__Gloeobacteraceae|g__Gloeobacter|s__Gloeobacter_kilaueensis 6       15      53      9       4       834     154
~~~
{: .output}

This is a serious problem, because as we will see in the final graph, each of 
the taxonomic levels will be a node in the final dendogram. So, almost all 
Cyanobacteria will have a shorter arm that the rest of the OTUs. **If for any 
reason you do not have the above problem (*e.g* kraken2 database version), 
you can continue to the next section ""**

First, let's see which of the Cyanobacterial OTUs have an assigned Class:

~~~
$ grep "Cyanobacteria" combine.mpa | grep c__
~~~
{: .bash}

~~~
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria   290     2684    224     176     147     856     166
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria|o__Gloeobacterales        290     2684    224     176  147      856     166
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria|o__Gloeobacterales|f__Gloeobacteraceae    290     2684 224      176     147     856     166
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria|o__Gloeobacterales|f__Gloeobacteraceae|g__Gloeobacter  290      2684    224     176     147     856     166
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria|o__Gloeobacterales|f__Gloeobacteraceae|g__Gloeobacter|s__Gloeobacter_kilaueensis        6       15      53      9       4       834     154
k__Bacteria|p__Cyanobacteria|c__Gloeobacteria|o__Gloeobacterales|f__Gloeobacteraceae|g__Gloeobacter|s__Gloeobacter_violaceus  284     2669    169     167     143     20      12
~~~
{: .output}

There are some OTUs with the Gloeobacteria Class assigned. So we will need to make some adjustments to the file. We will extract the number of reads assigned to the 
Gloeobacteria Class in the first sample with the next line of code

~~~
$ cat combine.mpa | grep Cyanobacteria | grep Gloeobacteria| sed -n '1p'| cut -f2
~~~
{: .bash}

~~~
290
~~~
{: .output}

Let's try to untangle the code a little bit. `sed -n '1p'` will help us to get just 
the first line of the result after searching for `Gloeobacteria`; `cut -f2` will 
print the abundance of the first sample. Now, we will assign this value to a 
variable that we will call `x1`:

~~~
$ x1=$(cat combine.mpa | grep Cyanobacteria | grep Gloeobacteria| sed -n '1p'| cut -f2)
$ echo $x1
~~~
{: .bash}

~~~
290
~~~
{: .output}

We will also need to obtain the value of the Cyanobacterial counts, so that we 
can supress the value of Gloeobacteria from the rest of the Cyanobacterial counts. 
Let's do it for the first sample an assign the value to a variable `y1`:

~~~
$ y1=$(cat combine.mpa | grep Cyanobacteria |sed -n '1p'| cut -f2)
$ echo $y1
~~~
{: .bash}

~~~
11970156
~~~
{: .output}

Finally, we will substract the `x1` from the `y1` value and store it in a new 
variable called `z1`:
~~~
$ z1=$(echo $(($y1 - $x1)))
$ echo $z1
~~~
{: .bash}

~~~
11969866
~~~
{: .output}

As you can see in the structure of the file `combine.mpa`, each superior level of 
classification cotains all the abundance of the reads in its inferior OTUs. For 
example, the 57 reads of the species `_Gloeomargarita_lithophora` in sample one 
are contained in the total amount of reads of `Cyanobacteria` (*i.e.* 11970156) 
for that first sample:

~~~
$ grep "Cyanobacteria" combine.mpa | sed -n '5p'
~~~
{: .bash}

~~~
k__Bacteria|p__Cyanobacteria|o__Gloeoemargaritales|f__Gloeomargaritaceae|g__Gloeomargarita|s__Gloeomargarita_lithophora        57      23      9       535     265     24      8
~~~
{: .output}

~~~
grep "Cyanobacteria" combine.mpa | sed -n '1p'
~~~
{: .bash}

~~~
k__Bacteria|p__Cyanobacteria    11970156        15042312        10675084        5286452 9045418 13337317       11338702
~~~
{: .output}

That is why we need this substraction, we need to create a new line for the missing 
Class `c__Cyanophyceae`, which will contain all the reads assigned to the phylum 
cyanobacteria with the exception of those with the `Gloeobacteria` Class.
So, we need to do this for each of the seven samples. Included in this repository 
there is the [folder](https://github.com/Bedxxe/From-kraken-to-graphlan/tree/main/scripts) `scripts` where the scripts that we will use are located. Inside, you 
can find a file called `cyano-operations.sh`, move it to the `mpa-files` folder. We 
will use this script to trim our Cyanobacterial OTUs. I want to explain what some 
of this lines are going to do:

~~~
$ tail -n 18 cyano-operations.sh
~~~
{: .bash}

~~~
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
~~~
{: .output}

We will run the `cyano-operations.sh` and see that this will generate two new files 
`cyano.mpa` `trim-combine.mpa`:
~~~
$ sh cyano-operations.sh
$ ls
~~~
{: .bash}

~~~
QroArlegundo.mpa  QroPocitos2.mpa   SLPLimones.mpa       cyano.mpa
QroDCuatro.mpa    SLPCarrizal1.mpa  combine.mpa          trim-combine.mpa
QroPocitos1.mpa   SLPCarrizal2.mpa  cyano-operations.sh
~~~
{: .output}

`cyano.mpa` is where the trimmed OTUs are saved, and `trim-combine.mpa` is the new 
`.mpa` object where this Cyanobacterial OTUs and the rest of them are combined. As 
you can see, now the Cyanobacterial OTUs have a Class assignet to them:

~~~
$ grep 'Cyanobacteria' trim-combine.mpa | grep -v 'c__Gloeobacteria'| head -n5
~~~
{: .bash}

~~~
k__Bacteria|p__Cyanobacteria    11970156        15042312        10675084        5286452 9045418 13337317       11338702
k__Bacteria|p__Cyanobacteria|c__Cyanophyceae    11969866        15039628        10674860        5286279045271  13336461
k__Bacteria|p__Cyanobacteria|c__Cyanophyceae|o__Gloeoemargaritales      57      23      9       535   265      24      8
k__Bacteria|p__Cyanobacteria|c__Cyanophyceae|o__Gloeoemargaritales|f__Gloeomargaritaceae        57    23       9       535     265     24      8
k__Bacteria|p__Cyanobacteria|c__Cyanophyceae|o__Gloeoemargaritales|f__Gloeomargaritaceae|g__Gloeomargarita     57      23      9       535     265     24      8
~~~
{: .output}

## Generate the plot 

We will return to the above folder `kraken-to-graphlan` to proceed to the next step 
of this tutorial. In the `scripts` [folder](https://github.com/Bedxxe/From-kraken-to-graphlan/tree/main/scripts) you will find a file named `grafla.sh` ,
download it inside your `kraken-to-graphlan` folder.

~~~
$ cat grafla.sh
~~~
{: .bash}

~~~
#!/bin/sh

mkdir grap-files

export2graphlan.py --skip_rows 1,2 -i mpa-files/trim-combine.mpa --tree grap-files/merged_abundance.tree.txt \
--annotation grap-files/merged_abundance.annot.txt --most_abundant 100 --annotations 2 \
--external_annotations 6 --abundance_threshold 15 --ftop 1000 \
--annotation_legend_font_size 8 --def_font_size 30
echo Output files saved inside grap-files folder

echo Color for Bacteroidetes changed from $#2d19ff to $#e6ab02
sed 's/#2d19ff/#e6ab02/g' grap-files/merged_abundance.annot.txt > temp.txt && mv temp.txt grap-files/merged_abundance.annot.txt

echo Color for Actinobacteria changed from $#29cc36 to $#e7298a
sed 's/#29cc36/#e7298a/g' grap-files/merged_abundance.annot.txt > temp.txt && mv temp.txt grap-files/merged_abundance.annot.txt

echo Color for Firmicutes changed from $#ff3333 to $#d95f03
sed 's/#ff3333/#d95f03/g' grap-files/merged_abundance.annot.txt > temp.txt && mv temp.txt grap-files/merged_abundance.annot.txt

echo Color for Cyanobacteria changed from $#00bfff to $#1b9e77
sed 's/#00bfff/#1b9e77/g' grap-files/merged_abundance.annot.txt > temp.txt && mv temp.txt grap-files/merged_abundance.annot.txt

echo Color for Bacteroidetes changed from $#00ff80 to $#7570b3
sed 's/#00ff80/#7570b3/g' grap-files/merged_abundance.annot.txt > temp.txt && mv temp.txt grap-files/merged_abundance.annot.txt


graphlan_annotate.py --annot grap-files/merged_abundance.annot.txt grap-files/merged_abundance.tree.txt grap-files/merged_abundance.xml

echo Generating the .png file
graphlan.py --dpi 300 --size 10 grap-files/merged_abundance.xml graphlan_graph.png --external_legends
~~~
{: .output}

All the inital parameters from the `export2graphlan.py` can be found in its GitHub 
[repository](https://github.com/SegataLab/export2graphlan). This programm gives a 
predertermined set of colors to highlight the most abundant OTUs at different 
taxonomic level. This can be changed by different ways, but the option that I am 
showing here changes also the colors of all the highlighted OTUs inside the 
dominant Phyla. This changes must be done in the `merged_abundance.annot.txt` file. 
So the lines of code that beggin with the function `sed`, are changing the default 
colors. As posted in [graphlan](https://github.com/biobakery/graphlan) repository, 
the last four lines of code generate a `.xml` file that will dictate the 
instructions for `graphlan.py` to generate the cladogram `graphlan_graph.png`.

Let's run it and see the new files that this will generate:

~~~
$ sh grafla.sh
$ ls
~~~
{: .bash}

~~~

~~~
{: .output}

Now we have a nwe folder `grap-files` and three `.png` files. Inside 
`graphlan_graph.png` is the desired plot.

<a href="{{ page.root }}/fig/graphlan_graph.png">
  <img src="{{ page.root }}/fig/graphlan_graph.png" alt="The resulting cladogram 
  where the dominant Phyla are highlighted and the dominant Genera as well" />
</a>
<em> Figure 1. Cladogram where the dominant Phyla are highlighted 
    and the dominant Genera as well. <em/>

Inside the other two `.png` files we will find the legend and annotation of the highlighted Phyla and Genera respectively. This is delivered in this way because 
we used the flag `--external_legends` for the `graphlan.py` program.

<a href="{{ page.root }}/fig/graphlan_graph_legend.png">
  <img src="{{ page.root }}/fig/graphlan_graph_legend.png" alt="The legend of the dominant Phyla in the main plot" />
</a>
<em> Figure 2. The legend of the dominant Phyla in the main plot. <em/>

<a href="{{ page.root }}/fig/graphlan_graph_annot.png">
  <img src="{{ page.root }}/fig/graphlan_graph_annot.png" alt="Annotation of the dominan Genera" />
</a>
<em> Figure 3. Annotation of the dominan Genera. <em/>

## Adding rings to the figure



~~~

~~~
{: .bash}

~~~

~~~
{: .output}


#Make sure that your python version is compatible with export2graphlan.py script, in my case I created an enviroment with python2.7
#conda create --name py27 python=2.7
#Activate the enviroment when using export2graphlan
conda activate py27
#Produce with the new metaphlan file the two files needed by graphlan: annotation and tree
export2graphlan.py -i combine.mpa --annotation merged_abundance.annot.txt --tree merged_abundance.tree.txt --most_abundant 25 --annotations 3,4,5,6 --external_annotations 7 --abundance_threshold 10 --min_clade_size 5


Aquí ontienes el dendograma que se encuentra en el archivo "merged_abundance.tree.txt".



~~~

~~~
{: .bash}

~~~

~~~
{: .output}

kraken2 taxonomic assignation method by k-mers gives great results in analyzing shotgun metagenomics data. A great visualization tool for taxonomic assignation and phylogenies is graphlan. In this repository, I will describe the process of how to generate graphics with graphlan using the output from kraken2.


export2graphlan.py -i ${OUPATH}${prefix}.comb.mpa.txt -a ${OUPATH}${prefix}.annot.txt -t ${OUPATH}${prefix}.tree.txt --most_abundant 50 --annotations 2,3,4 --external_annotations 6 --abundance_threshold 10 --ftop 200
