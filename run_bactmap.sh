#!/bin/bash
#
# Wrapper script to run the bactmap nextflow pipeline, see https://nf-co.re/bactmap/1.0.0
# Author: Jacqui Keane <drjkeane at gmail.com>
#
# Usage: run_bactmap.sh [-h] [-g] [-t tree_software] -i input_directory -r reference.fasta -o output_directory
#

# Parameterise number of jobs?
#

export NXF_ANSI_LOG=false
export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6
export SOFTWARE_HOME="/home/software"

function help
{
   # Display Help
   script=$(basename $0)
   echo 
   echo "usage: "$script" [-h] -i input_directory -r reference -o outout_directory"
   echo
   echo "Runs the bactmap nextflow pipeline, see https://nf-co.re/bactmap/1.0.0"
   echo
   echo "optional arguments:"
   echo "  -h			show this help message and exit"
   echo "  -g			remove recombination using gubbins"
   echo "  -t 			tree building software to use, choose from fasttree, iqtree, rapidnj or raxml, default is iqtree"
   echo
   echo "required arguments:"
   echo "  -i input		input CSV file 'samplesheet.csv' that contains the paths to your FASTQ files - see https://nf-co.re/bactmap/1.0.0/usage"
   echo "  -r reference		reference fasta file"
   echo "  -o output_directory	directory to write the pipeline output to"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

# Check number of input parameters 

NAG=$#

if [ $NAG -ne 1 ] && [ $NAG -ne 6 ] && [ $NAG -ne 7 ] && [ $NAG -ne 8 ] && [ $NAG -ne 9 ] && [ $NAG -ne 10 ]
then
  help
  echo "!!! Please provide the correct number of input arguments"
  echo
  exit;
fi

# Set default variables

TREE='iqtree'
GUBBINS=''

# Get the options
while getopts "htgi:r:o:" option; do
   case $option in
      h) # display help
         help
         exit;;
      t) # tree software
         TREE=$OPTARGS
      g) # remove recombination
         GUBBINS='--remove_recombination'
      i) # input directory
         INPUT=$OPTARG;;
      r) #  reference
         REF=$OPTARG;;
      o) # output directory
         OUTPUT=$OPTARG;;
     \?) # invalid option
         help
	 echo "!!!Error: Invalid arguments"
         exit;;
   esac
done

# Check the tree option is valid

if [ $TREE -ne 'fasttree' ] && [ $TREE -ne 'rapidnj' ] && [ $TREE -ne 'raxmlng' ] && [ $TREE -ne 'iqtree']
then
  help
  echo "!!! Please provide the correct option for tree building software, choose from fasttree, rapidnf, raxmlng or iqtree
  echo
  exit;
fi

# Check the input file, reference genome and output directory exists

if [ ! -f $INPUT ]
then
  help
  echo "!!! The file $INPUT does not exist"
  echo
  exit;
fi

if [ ! -f $REF ]
then
  help
  echo "!!! The reference file $REF does not exist"
  echo
  exit;
fi


if [ ! -d $OUTPUT ]
then
  help
  echo "!!! The directory $OUTPUT does not exist"
  echo
  exit;
fi

RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${OUTPUT}/bactmap-1.0.0_${RAND}
WORK_DIR=${OUT_DIR}/work
NEXTFLOW_PIPELINE_DIR='$SOFTWARE_HOME/nf-pipelines/nf-core-bactmap-1.0.0'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input file is: "$INPUT
echo "Output will be written to: "$OUT_DIR

nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${INPUT_DIR}/samplesheet.csv \
--outdir ${OUT_DIR} \
--reference ${REF} \
--${TREE}
-w ${WORK_DIR} \
-profile singularity \
-with-tower -resume \
-c $SOFTWARE_HOME/nf_pipeline_scripts/conf/bakersrv1.config,$SOFTWARE_HOME/nf_pipeline_scripts/conf/pipelines/bactmap.config \
${GUBBINS}

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi
