#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: January 2018
#
# This script is a warpper to call
# a script that pre-indexes datasets for
# each alignment tool
#

cd `dirname $0`

SCRIPT_NAME=`basename $0`
WORKING_DIR=`pwd`


if [ $# -lt 1 ]
then
  echo "Usage: ./$SCRIPT_NAME data_source_name "
  echo "Example: ./$SCRIPT_NAME ensembl "
  exit 1
fi
data_source_name=$1

##Path relative to this script base
main_config=Configuration.cfg
data_source_config=data_sources/$data_source_name.cfg

##
if [ ! -f $main_config ]
then
  echo "ERROR: $main_config file missing from `pwd`"
  exit 1 
fi
if [ ! -f $data_source_config ]
then
  echo "ERROR: $data_source_config file missing from `pwd`"
  exit 1
fi
source ./$main_config
source ./$data_source_config

[ ! -d $LOGS_BASE ] && mkdir -p $LOGS_BASE
#
##Set path to logs
LOG_FILE="${LOGS_BASE}/$SCRIPT_NAME.$data_source_name.log"
#
## Check that the current version of this data source
# as defined in $data_source_config - was uncompressesd where expected
#
if [ ! -d $REFERENCE_BASE ]
then
  echo "ERROR $REFERENCE_BASE missing on `uname -n`"
  exit 1
fi
rm -rf $LOG_FILE
touch $LOG_FILE
date | tee -a $LOG_FILE
echo "**********              *******************" | tee -a $LOG_FILE
echo "Running indexes for $DATA_DIR"| tee -a $LOG_FILE
echo "**********  *******************************"| tee -a $LOG_FILE
echo "Alignment Tools: $ALIGN_INDEX_TOOLS"
echo "Index Script Base: $INDEX_SCRIPT_BASE"
echo "Reference config file: $REFERENCE_FILE "

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
