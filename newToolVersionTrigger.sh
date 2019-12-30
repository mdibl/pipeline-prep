#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: January 2018
#
# This script is a warpper to call
# a script that pre-index datasets when
# a new version of the tool is installed
#
# Input: tool name
#
cd `dirname $0`

SCRIPT_NAME=`basename $0`
WORKING_DIR=`pwd`
if [ $# -lt 1 ]
then
  echo "Usage: ./$SCRIPT_NAME tool_name"
  echo "Example: ./$SCRIPT_NAME bwa"
  exit 1
fi
##Path relative to this script base
main_config=Configuration.cfg
tool_name=$1
tool_base=tools/$tool_name
tool_config=$tool_name.cfg

if [ ! -f $main_config ]
then
   echo "$main_config main configuration file is missing from `pwd`"
   exit 1
fi
# Path to tool indexer base - relative to the root of this script
if [ ! -d $tool_base ]
then
  echo "ERROR: $tool_base directory missing from `pwd`"
  exit 1
fi
#Get path to EXTERNAL_DATA_BASE,FASTA_FILES_BASE,INDEX_BASE,EXTERNAL_TOOLS_BASE,LOGS_BASE
# from the main config file
source ./$main_config

cd $tool_base
if [ ! -f $tool_config ]
then
  echo "ERROR $tool_config config file missing on `uname -n` under: `pwd`"
  exit 1
fi
source ./$tool_config

[ ! -d ${INDEX_BASE} ] && mkdir -p ${INDEX_BASE}
[ ! -d ${LOGS_BASE} ] && mkdir -p ${LOGS_BASE}

LOG_FILE="${LOGS_BASE}/$SCRIPT_NAME.$TOOL_VERSION.log"
rm -rf $LOG_FILE
touch $LOG_FILE
date | tee -a $LOG_FILE
echo "**********              *******************" | tee -a $LOG_FILE
echo "Creating indexes for $TOOL_VERSION"| tee -a $LOG_FILE
echo "**********  *******************************"| tee -a $LOG_FILE
echo `date` | tee -a $LOG_FILE
echo "Tool Version: $TOOL_VERSION"
## I need to store 
for data_source in "${!REFERENCE_FILE[@]}"
do
    reference_config=${REFERENCE_FILE[$data_source]}
    [ ! -f $reference_config ] && continue
    ##get the current release for this data source 
    data_release_file=${RELEASE_FILE[$data_source]}
    
    if [ ! -f $data_release_file ]
    then
       echo "ERROR: Can't detect current release file for $data_source" | tee -a $LOG_FILE
       echo "File missing: $data_release_file" | tee -a $LOG_FILE
       continue
    fi
    data_release_number=`cat $data_release_file`
    echo ""
    echo "**********************************************"
    echo "Indexing datasets in  : $reference_config"
    echo "**********************************************"
    ##How we store unzipped data : source_name/release-version 
    DATA_VERSION=release-$data_release_number
    for line in  `cat $reference_config`
    do
       IFS=', ' read -r -a fields <<< "$line"
       target_name=${fields[0]}
       organism=${fields[2]}
       dataset=${fields[3]}
       index_prefix=${fields[5]}
       [ "$target_name" != $tool_name ] && continue
       echo "##" | tee -a $LOG_FILE
       date | tee -a $LOG_FILE
       echo "Generating $tool_name Indexes for $data_source/$DATA_VERSION $organism.$dataset dataset" | tee -a $LOG_FILE
       #
       ## Next if indexes for this dataset version have alrready created for this tool verion
       if [ -d ${INDEX_BASE}/${TOOL_VERSION}/$data_source/${DATA_VERSION}/${organism}-${dataset} ]
       then
           echo "SKIPPING:  ${INDEX_BASE}/${TOOL_VERSION}/$data_source/${DATA_VERSION}/${organism}-${dataset} already exists"
           continue
       fi
       
       echo "Running $tool_name indexer from `pwd`" | tee -a $LOG_FILE
       indexer_cmd="Index $data_source $DATA_VERSION $organism $dataset $tool_name $TOOL_VERSION $index_prefix"
       echo "Command: ./$indexer_cmd"| tee -a $LOG_FILE 
       ./$indexer_cmd 2>&1 | tee -a $log

       date | tee -a $LOG_FILE
     done
done


exit 0
