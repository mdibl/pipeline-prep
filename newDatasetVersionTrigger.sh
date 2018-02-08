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
indexers_base=tools

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

##Set Path to input reference data - or exit if can't
# get current version of the data
CURRENT_VERSION_FILE=${EXTERNAL_DATA_BASE}/$data_source_name/current_release_NUMBER 
if [  ! -f $CURRENT_VERSION_FILE ];then
 echo "ERROR: missing $CURRENT_VERSION_FILE"
 exit 1
 fi

CURRENT_VERSION=`cat $CURRENT_VERSION_FILE`
DATA_DIR=$data_source_name-$CURRENT_VERSION
REFERENCE_BASE=${FASTA_FILES_BASE}/$DATA_DIR

#
## Check that the current version of this data source
# as defined in $data_source_config - was uncompressesd where expected
#
if [ ! -d $REFERENCE_BASE ]
then
  echo "ERROR $REFERENCE_BASE missing on `uname -n`"
  exit 1
fi
##Set path to logs
LOG_FILE=${LOGS_BASE}/$SCRIPT_NAME.$DATA_DIR.log
#
rm -rf $LOG_FILE
touch $LOG_FILE
date | tee -a $LOG_FILE
echo "**********              *******************" | tee -a $LOG_FILE
echo "Running indexes for $DATA_DIR" | tee -a $LOG_FILE
echo "**********  *******************************" | tee -a $LOG_FILE
echo "Alignment Tools: $ALIGN_INDEX_TOOLS" | tee -a $LOG_FILE
echo "Reference config file: $REFERENCE_FILE "| tee -a $LOG_FILE
#
## indexers_base is relative to this script
# or under the root directory of this repos
if [ ! -d $indexers_base ]
then
   echo "ERROR: $indexers_base directory missing" | tee -a $LOG_FILE
   exit
fi
cd $indexers_base
WORKING_DIR=`pwd`
for tool in $ALIGN_TOOLS_LIST
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
       echo "Generating $tool Indexes for $DATA_DIR $organism.$dataset dataset" | tee -a $LOG_FILE
       echo "Running $tool_name indexer from `pwd`" | tee -a $LOG_FILE
       indexer_cmd="Index $data_source_name $DATA_DIR $organism $dataset $tool_name $TOOL_VERSION $index_prefix"
       echo "Command: $indexer_cmd" | tee -a $LOG_FILE 
       ./$indexer_cmd 2>&1 | tee -a $log

       date | tee -a $LOG_FILE
     done
done


exit 0
