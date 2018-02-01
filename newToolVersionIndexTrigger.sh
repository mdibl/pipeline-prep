#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: January 2018
#
# This script is a warpper to call
# a script that pre-index datasets when
# a new version of the tool is sinstalled
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
tool_name=$1
tool_base=tools/$tool_name
if [ -f Configuration.cfg ]
then
   echo "Configuration.cfg main configuration file is missing from `pwd`"
   exit 1
fi
#Get path to EXTERNAL_DATA_BASE,FASTA_FILES_BASE,INDEX_BASE,EXTERNAL_TOOLS_BASE,LOGS_BASE
# from the main config file
source ./Configuration.cfg

# Path to tool indexer base - relative to the root of this script
if [ ! -d $tool_base ]
then
  echo "ERROR: $tool_base directory missing from `pwd`"
  exit 1
fi
cd $tool_base
if [ ! -f $tool_base.cfg ]
then
  echo "ERROR $tool_base.cfg config file missing on `uname -n` under: `pwd`"
  exit 1
fi
source ./$tool_base.cfg
LOG_FILE="${LOGS_BASE}/$SCRIPT_NAME.$TOOL_VERSION.log"
rm -rf $LOG_FILE
touch $LOG_FILE
date | tee -a $LOG_FILE
echo "**********              *******************" | tee -a $LOG_FILE
echo "Creating indexes for $TOOL_VERSION"| tee -a $LOG_FILE
echo "**********  *******************************"| tee -a $LOG_FILE
echo date | tee -a $LOG_FILE
echo "Tool Version: $TOOL_VERSION"
## I need to store 
for data_source in REFERENCE_FILE
do
    reference_config=$REFERENCE_FILE[$data_source]
    [ ! -f $reference_config ] && continue
    echo "Indexing datasets in  : $reference_config"
    ##get the current release for this data source 
    for line in  `cat $reference_config`
    do
       IFS=', ' read -r -a fields <<< "$line"
       tool_name=${fields[0]}
       organism=${fields[2]}
       dataset=${fields[3]}
       index_prefix=${fields[5]}
       echo "##" | tee -a $LOG_FILE
       date | tee -a $LOG_FILE
      
       echo "Generating $tool Indexes for $DATA_VERSION $organism.$dataset dataset" | tee -a $LOG_FILE
       echo "Running $tool_name indexer from `pwd`" | tee -a $LOG_FILE
       indexer_cmd="Index $SHORT_NAME $DATA_VERSION $organism $dataset $tool_name $TOOL_VERSION $index_prefix"
       echo "Command: ./$indexer_cmd"| tee -a $LOG_FILE 
       ./$indexer_cmd 2>&1 | tee -a $log

       date | tee -a $LOG_FILE
     done
done


exit 0
