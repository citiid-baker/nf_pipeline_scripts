#!/bin/bash
#
# Author: Jacqui Keane <drjkeane at gmail.com>
#
# Usage: run_scrnaseq.sh [-h] -i input_directory
#

export NXF_ANSI_LOG=false
export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   script=$(basename $0)
   echo 
   echo "usage: "$script" [-h] -i input_directory -f reference.fasta -g reference.gtf"
   echo
   echo "Runs the scrnaseq nextflow pipeline, see https://nf-co.re/scrnaseq/1.1.0"
   echo
   echo "optional arguments:"
   echo "  -h, --help           show this help message and exit"
   echo
   echo "required arguments:"
   echo "  -i input_directory	directory containing the FASTQ files - see https://nf-co.re/scrnaseq/1.1.0/usage"
   echo "  -f reference.fasta 	FASTA file of the reference"
   echo "  -g reference.gtf	GTF file containing the annotation"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

# Check number of input parameters 

NAG=$#

if [ $NAG -ne 1 ] && [ $NAG -ne 6 ] && [ $NAG -ne 7 ]
then
  help
  echo "!!! Please provide the correct number of input arguments"
  echo
  exit;
fi

# Get the options
while getopts "hi:f:g:" option; do
   case $option in
      h) # display help
         help
         exit;;
      i) # Input directory
         INPUT_DIR=$OPTARG;;
      f) # Reference fasta
         FASTA=$OPTARG;;
      g) # Reference GFF
         GTF=$OPTARG;;
     \?) # Invalid option
         help
         echo "!!!Error: Invalid arguments"
         exit;;
   esac
done

# Check the input directory exists

if [ ! -d $INPUT_DIR ]
then
  help
  echo "!!! The directory $INPUT_DIR does not exist"
  echo
  exit;
fi

if [ ! -f $FASTA ]
then
  help
  echo "!!! The file $FASTA does not exist"
  echo
  exit;
fi

if [ ! -f $GTF ]
then
  help
  echo "!!! The file $GTF does not exist"
  echo
  exit;
fi


RAND=$(date +%s%N | cut -b10-19)
OUT_DIR=${INPUT_DIR}/scrnase-1.1.0_${RAND}
WORK_DIR=${OUT_DIR}/work
NEXTFLOW_PIPELINE_DIR='/home/software/nf-pipelines/nf-core-scrnaseq-1.1.0'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input is: "$INPUT_DIR
echo "Output will be written to: "$OUT_DIR
echo

nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${INPUT_DIR}/'*{R,_}{1,2}.f*q.gz' \
--outdir ${OUT_DIR} \
--fasta ${FASTA} \
--gtf ${GTF} \
-w ${WORK_DIR} \
-profile singularity \
-with-tower -resume \
-c /home/software/nf_pipeline_scripts/conf/bakersrv1.config

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi
