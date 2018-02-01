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

if [ $# -lt 2 ]
then
  echo "Usage: ./$SCRIPT_NAME tool_name tool_config.cfg"
  echo "Example: ./$SCRIPT_NAME bwa  bwa.cfg"
  exit 1
fi
# Path relative to the root of this script
data_source_config=$1/$2
if [ ! -f $data_source_config ]
then
  echo "ERROR: $data_source_config file missing from `pwd`"
  exit 1
fi
source ./$data_source_config
LOG_FILE="${LOGS_BASE}/$SCRIPT_NAME.$TOOL_VERSION.log"

if [ ! -f $TOOL_DIR ]
then
  echo "ERROR $TOOL_DIR file missing on `uname -n`"
  exit 1
fi
rm -rf $LOG_FILE
touch $LOG_FILE
date | tee -a $LOG_FILE
echo "**********              *******************" | tee -a $LOG_FILE
echo "Creating indexes for $TOOL_VERSION"| tee -a $LOG_FILE
echo "**********  *******************************"| tee -a $LOG_FILE
echo "Tool Version: $TOOL_VERSION"
echo "Reference config files: $REFERENCE_FILE "

if [ ! -d $INDEX_SCRIPT_BASE ]
then
   echo "ERROR: $INDEX_SCRIPT_BASE directory missing"
   exit
fi

cd $INDEX_SCRIPT_BASE
WORKING_DIR=`pwd`
echo "Based directory for tool index scripts : $INDEX_SCRIPT_BASE"

for tool in $ALIGN_INDEX_TOOLS
do
    TOOL_BASE=$WORKING_DIR/$tool
    TOOL_CONFIG=$tool.cfg
    [ ! -d $TOOL_BASE ] && continue
    cd $TOOL_BASE
    [ ! -f $REFERENCE_FILE ] && continue
    [ ! -f $TOOL_CONFIG ] && continue
    for line in  `cat $REFERENCE_FILE`
    do
       IFS=', ' read -r -a fields <<< "$line"
       tool_name=${fields[0]}
       [ ! -d $WORKING_DIR/$tool_name ] && continue
       # get this tool version
       source ./$TOOL_CONFIG
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
