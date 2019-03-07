##
## Assumptions: assumes the following structure under the working directory
#   1) cfgs
#   2) src
## Assumptions: assumes the following config files in the cfgs directory
#  1) biocore.cfg
# 
source /etc/profile.d/biocore.sh

cd `dirname $0`
script_name=`basename $0`
## Check expected structure
working_dir=`pwd`
parent_dir=`dirname $working_dir`
cfgs_dir=$parent_dir/cfgs

##Matches team names  under /data/internal
PIPELINE_OWNER=$1
PROJECT_TEAM_NAME=$2
PROJECT_NAME=$3
ORGANISM=$4
REF_DATABASE=$5
REF_DATABASE_VERSION=$6
# transcriptome_joined = cat  *.rna *.ncrna
REF_DATASET=$7
# Set the format of R1 and R2
READ1=$8
READ2=$9
## use {} to access the value of argument number > 9
TARGET_CWL=${10}

if [ ! -d $cfgs_dir ]
then
   echo "ERROR: Expected cfgs directory missing under $parent_dir"
   exit 1
fi
if [ ! -f $cfgs_dir/biocore.cfg ]
then
   echo "ERROR: Missing biocore.cfg under $cfgs_dir"
   exit 1
fi
source  $cfgs_dir/biocore.cfg
TEMP_RESULTS_DIR=${BIOCORE_INFO_PATH[SCRATCH_BASE]}/${PROJECT_TEAM_NAME}/${PROJECT_NAME}/results
FINAL_RESULTS_DIR=${BIOCORE_INFO_PATH[PROJECTS_BASE]}/${PROJECT_TEAM_NAME}/${PROJECT_NAME}
if [ -z "$TARGET_CWL" ]
then
   CWL_SCRIPT=${BIOCORE_INFO_PATH[PIPELINE_PROJECTS_BASE]}/${PROJECT_NAME}/${PROJECT_NAME}.cwl
else
   CWL_SCRIPT=$TARGET_CWL
fi
##We expect to find a json file for each sample under this path
# flename format sampleID.organism.json
PATH2_JSON_FILES=${BIOCORE_INFO_PATH[PIPELINE_PROJECTS_BASE]}/${PROJECT_NAME}
## Where we will store the pipeline meta config file for each sample
# name format sampleID.organism.pcf
PIPELINE_META_BASE=${BIOCORE_INFO_PATH[PIPELINE_META_BASE]}
## Setup path samples and design file 
ORIGINAL_READS_BASE=${BIOCORE_INFO_PATH[INTERNAL_DATA_BASE]}/${PROJECT_TEAM_NAME}/${PROJECT_NAME}
DESIGN_FILE=${ORIGINAL_READS_BASE}/${PROJECT_NAME}.design.txt
### To do
## 1) Check if ORIGINAL_READS_BASE exists
## 2) Check if design file exists
#  
pipeline_config_base=${TEMP_RESULTS_DIR}/cfgs
[ ! -d $pipeline_config_base ] && mkdir -p $pipeline_config_base

pipeline_cfg_file=$pipeline_config_base/pipeline.cfg
[ -f $pipeline_cfg_file ] && rm -f $pipeline_cfg_file
touch $pipeline_cfg_file
echo "###################################################" >> $pipeline_cfg_file
echo "## ${PROJECT_NAME} Pipeline Global Config File " >> $pipeline_cfg_file
echo "## " >> $pipeline_cfg_file
echo "## Date:`date` " >> $pipeline_cfg_file
echo "###################################################" >> $pipeline_cfg_file
echo "## Set path to local storage" >> $pipeline_cfg_file
for info_path in "${!BIOCORE_INFO_PATH[@]}"
do
    echo "$info_path=${BIOCORE_INFO_PATH[$info_path]}">>$pipeline_cfg_file
done
echo "">>$pipeline_cfg_file
echo "## Set this pipeline ownership">>$pipeline_cfg_file
echo "PIPELINE_OWNER=$PIPELINE_OWNER">>$pipeline_cfg_file
echo "## Set project info">>$pipeline_cfg_file
echo "PROJECT_TEAM_NAME=$PROJECT_TEAM_NAME">>$pipeline_cfg_file
echo "PROJECT_NAME=$PROJECT_NAME">>$pipeline_cfg_file
echo "">>$pipeline_cfg_file
echo "## Set path to cwl script - filename format: project_name.cwl">>$pipeline_cfg_file
echo "CWL_SCRIPT=$CWL_SCRIPT">>$pipeline_cfg_file
echo "## We expect to find a json file for each sample under this path">>$pipeline_cfg_file
echo "## filename format: sampleID.organism.json">>$pipeline_cfg_file
echo "PATH2_JSON_FILES=$PATH2_JSON_FILES">>$pipeline_cfg_file
echo "">>$pipeline_cfg_file
echo "## Where we will store the pipeline meta config file for each sample">>$pipeline_cfg_file
echo "## filename format:sampleID.organism.pcf">>$pipeline_cfg_file
echo "PIPELINE_META_BASE=$PIPELINE_META_BASE">>$pipeline_cfg_file
echo "">>$pipeline_cfg_file
echo "## Set path to intermediary results">>$pipeline_cfg_file
echo "TEMP_RESULTS_DIR=$TEMP_RESULTS_DIR">>$pipeline_cfg_file
echo "## Set path to final results">>$pipeline_cfg_file
echo "FINAL_RESULTS_DIR=${FINAL_RESULTS_DIR}">>$pipeline_cfg_file
echo "## Set Reference organism info">>$pipeline_cfg_file
echo "ORGANISM=$ORGANISM">>$pipeline_cfg_file
echo "REF_DATABASE=$REF_DATABASE">>$pipeline_cfg_file
echo "REF_DATABASE_VERSION=$REF_DATABASE_VERSION">>$pipeline_cfg_file
echo "## Reference dataset used to generate indexes">>$pipeline_cfg_file
echo "REF_DATASET=$REF_DATASET">>$pipeline_cfg_file
echo "">>$pipeline_cfg_file
echo "## Setup path sample reads and design file ">>$pipeline_cfg_file
echo "ORIGINAL_READS_BASE=${ORIGINAL_READS_BASE}">>$pipeline_cfg_file
echo "DESIGN_FILE=${DESIGN_FILE}">>$pipeline_cfg_file
echo "">>$pipeline_cfg_file
echo "## Set the format of R1 and R2">>$pipeline_cfg_file
echo "declare -A READS">>$pipeline_cfg_file
echo "READS["1"]=\"$READ1\"">>$pipeline_cfg_file
echo "READS["2"]=\"$READ2\"">>$pipeline_cfg_file
echo "## Load sample IDs from the experiment design file into a container" >> $pipeline_cfg_file
echo "## Sample IDs are in the first column of the file" >> $pipeline_cfg_file
echo "declare -a SAMPLES" >> $pipeline_cfg_file

echo '[ -f $DESIGN_FILE ] && SAMPLES=`cat $DESIGN_FILE | cut -f1 | sort | uniq`'>> $pipeline_cfg_file
echo "$pipeline_cfg_file generated"
date
