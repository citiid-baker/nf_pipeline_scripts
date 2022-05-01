#!/bin/bash
#
# Author: Jacqui Keane <drjkeane at gmail.com>
#
# Usage: run_fetchngs.sh [-h] -i accessions -o output_directory
#

export NXF_ANSI_LOG=false
export NXF_OPTS="-Xms8G -Xmx8G -Dnxf.pool.maxThreads=2000"
export NXF_VER=21.10.6

function help
{
   # Display Help
   script=$(basename $0)
   echo 
   echo "usage: "$script" [-h] -f accessions -o output_directory"
   echo
   echo "Runs the fetchngs nextflow pipeline, see https://nf-co.re/fetchngs/1.5"
   echo
   echo "optional arguments:"
   echo "  -h, --help          	show this help message and exit"
   echo
   echo "required arguments:"
   echo "  -i accessions		TXT file listing accessions to download, file must end in .txt see https://nf-co.re/fetchngs/1.5/usage"
   echo "  -o output_directory	location to store the downloaded data"
   echo
   echo "To run this pipeline with alternative parameters, copy this script and make changes to nextflow run as required"
   echo
}

# Check number of input parameters 

NAG=$#

if [ $NAG -ne 2 ]
then
  help
  echo "!!! Please provide the correct number of input arguments"
  echo
  exit;
fi

# Check the input file exists

INPUT=$1
OUT_DIR=$2

if [ ! -f $INPUT ]
then
  help
  echo "!!! The file $INPUT does not exist"
  echo
  exit;
fi

RAND=$(date +%s%N | cut -b10-19)
WORK_DIR=${OUT_DIR}/work_fetchngs-1.5_${RAND}
NEXTFLOW_PIPELINE_DIR='/home/software/nf-pipelines/nf-core-fetchngs-1.5'

echo "Pipeline is: "$NEXTFLOW_PIPELINE_DIR
echo "Input file is: "$INPUT
echo "Output will be written to: "$OUT_DIR
echo ""

nextflow run ${NEXTFLOW_PIPELINE_DIR}/workflow/main.nf \
--input ${INPUT} \
--outdir ${OUT_DIR} \
-w ${WORK_DIR} \
-profile singularity \
-with-tower -resume \
-c /home/software/nf_pipeline_scripts/conf/bakersrv1.config

# Clean up on sucess/exit 0
status=$?
if [[ $status -eq 0 ]]; then
  rm -r ${WORK_DIR}
fi
