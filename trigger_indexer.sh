#!/bin/sh

# Organization: MDIBL
# Author: Lucie Hutchins
# Date: June 2018
#
# This script is a warpper to call
# a script that pre-indexes datasets for
# each alignment tool
#
# Usage: ./program  <data_source> <tool_name>
# Assumptions:
# 1) data_source is the naming format of the directory where we store external data 
# 2) tool_name is the directory name where the tool indexer can be found

## See /mnt/data/external and /opt/sotware/external/ respectively
#

cd `dirname $0`

SCRIPT_NAME=`basename $0`
WORKING_DIR=`pwd`


if [ $# -lt 2 ]
then
  echo "Usage: ./${SCRIPT_NAME} <data_source_name> <tool_name>"
  echo "Example: ./${SCRIPT_NAME} ensembl bwa"
  exit 1
fi
data_source_name=$1
tool_name=$2


##Path relative to this script base
main_config=Configuration.cfg
data_source_config=data_sources/${data_source_name}.cfg
TOOL_BASE=tools/$tool_name
TOOL_CONFIG=${tool_name}.cfg
#
## indexers_base is relative to this script
# or under the root directory of this repos
if [ ! -d ${TOOL_BASE} ]
then
   echo "ERROR: ${TOOL_BASE} directory missing from `pwd`" 
   exit 1
fi

##
if [ ! -f ${main_config} ]
then
  echo "ERROR: ${main_config} file missing from `pwd`"
  exit 1 
fi
if [ ! -f ${data_source_config} ]
then
  echo "ERROR: ${data_source_config} file missing from `pwd`"
  exit 1
fi
if [ ! -f ${TOOL_BASE}/${TOOL_CONFIG} ] 
then
   echo "ERROR: ${TOOL_CONFIG} file missing from ${TOOL_BASE}"
   exit 1
fi
##Set global variables
source ./${main_config}
[ ! -d ${INDEX_BASE} ] && mkdir -p ${INDEX_BASE}
[ ! -d ${LOGS_BASE} ] && mkdir -p ${LOGS_BASE}
##Set Path to input reference data - or exit if can't
# get current version of the data
CURRENT_VERSION_FILE=${EXTERNAL_DATA_BASE}/${data_source_name}/current_release_NUMBER 
if [  ! -f ${CURRENT_VERSION_FILE} ];then
 echo "ERROR: missing ${CURRENT_VERSION_FILE}"
 exit 1
 fi

CURRENT_VERSION=`cat ${CURRENT_VERSION_FILE}`
DATA_DIR=${data_source_name}-${CURRENT_VERSION}
REFERENCE_BASE=${FASTA_FILES_BASE}/${DATA_DIR}
# Set global variables specific to this data source
source ./${data_source_config}
#
## Check that the current version of this data source
# as defined in $data_source_config - was uncompressesd where expected
#
if [ ! -d ${REFERENCE_BASE} ]
then
  echo "ERROR ${REFERENCE_BASE} missing on `uname -n`"
  exit 1
fi
##set reference file name from data source config 
reference_file_name=${REFERENCE_FILE}
cd ${TOOL_BASE}
# get this tool version
source ./${TOOL_CONFIG}
##Set path to logs
LOG_FILE=${LOGS_BASE}/${SCRIPT_NAME}.${DATA_DIR}.${TOOL_VERSION}.log
#
rm -rf ${LOG_FILE}
touch ${LOG_FILE}
date | tee -a ${LOG_FILE}
echo "**********              *******************" | tee -a ${LOG_FILE}
echo "Indexing  ${DATA_DIR} datasets using ${TOOL_VERSION}" | tee -a ${LOG_FILE}
echo "**********  *******************************" | tee -a ${LOG_FILE}
echo "Datasets Reference config file: `pwd`/${reference_file_name} "| tee -a ${LOG_FILE}


[ ! -f ${reference_file_name} ] && exit 1
for line in  `cat ${reference_file_name}`
do
    IFS=', ' read -r -a fields <<< "$line"
    [ "$tool_name" != ${fields[0]} ] && continue
    organism=${fields[2]}
    dataset=${fields[3]}
    index_prefix=${fields[5]}
    echo "##" | tee -a ${LOG_FILE}
    date | tee -a ${LOG_FILE}
    echo "Generating ${tool} Indexes for ${DATA_DIR} ${organism}.${dataset} dataset" | tee -a ${LOG_FILE}
    #
    #
    ## Next if indexes for this dataset version have alrready created for this tool verion
    if [ -d ${INDEX_BASE}/${TOOL_VERSION}/${DATA_DIR}/${organism}-${dataset} ]
    then
        echo "SKIPPING:  ${INDEX_BASE}/${TOOL_VERSION}/${DATA_DIR}/${organism}-${dataset} - Index already exists"
        continue
    fi
    echo "Running ${tool_name} indexer from `pwd`" | tee -a ${LOG_FILE}
    indexer_cmd="Index ${data_source_name} ${DATA_DIR} ${organism} ${dataset} ${tool_name} ${TOOL_VERSION} ${index_prefix}"
    echo "Command: ${indexer_cmd}" | tee -a ${LOG_FILE} 
    ./${indexer_cmd} 2>&1 | tee -a ${LOG_FILE} 

    date | tee -a ${LOG_FILE}
done

exit 0
