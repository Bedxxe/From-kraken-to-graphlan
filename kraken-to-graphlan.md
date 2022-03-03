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

## Recommended Setup



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

[Link to dowload the kraken2 reports](link-to-draft)

## Using krakentools

After the generation of the kraken reports, Lets put everything in a folder that we will call `kraken-to-graphlan` inside any locality of your computer. Inside this folder we 
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
there is a file called `cyano-operations.sh`, copy it to the `mpa-files` folder. We 
will use this program to trim our Cyanobacterial OTUs. I want to explain what some 
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

## Generate the dendogram

We will return to the above folder `kraken-to-graphlan` to proceed to the next step 
of this tutorial. 


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