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
REF_DATASET=""
# Set the format of R1 and R2
READ1=""
READ2=""
## use {} to access the value of argument number > 9
CWL_SCRIPT=$7
current_timestamp=${PROJECT_NAME}_$(date +%s)
## Where we will store the pipeline meta config file for each sample
# name format sampleID.organism.pcf
PCF_BASE=$8
PCF_PROJECT_BASE=$PCF_BASE/${PROJECT_TEAM_NAME}/${PROJECT_NAME}/$current_timestamp
##We expect to find a json file for each sample under this path
# flename format sampleID.organism.json
JSON_BASE=$9
JSON_PROJECT_BASE=$JSON_BASE/${PROJECT_TEAM_NAME}/${PROJECT_NAME}/$current_timestamp
READS_BASE=${10}/${PROJECT_TEAM_NAME}/${PROJECT_NAME}
## Setup path samples and design file 
#DESIGN_FILE=${READS_BASE}/${PROJECT_NAME}.design.txt
GIT_REPOS=${11}
RESULTS_DIR_BASE=${12}/${PROJECT_TEAM_NAME}/${PROJECT_NAME}/results
RESULTS_DIR=${RESULTS_DIR_BASE}/$current_timestamp


pipeline_config_base=${RESULTS_DIR}/cfgs
pipeline_cfg_file=$pipeline_config_base/pipeline.cfg
## Setup path samples and design file 
DESIGN_FILE=${13}
git_base=""

if [[ $PIPELINE_PCF_BASE =~ .*($BIOCORE_PROJECTS_GIT_REPOS.*) ]] ; then
    git_base="${BASH_REMATCH[1]}"
fi

echo "The git repos is: $git_base"


GIT_REPOS_PCF_BASE=$GIT_REPOS/`basename $PCF_BASE`/${PROJECT_TEAM_NAME}/${PROJECT_NAME}
GIT_REPOS_JSON_BASE=$GIT_REPOS/`basename $JSON_BASE`/${PROJECT_TEAM_NAME}/${PROJECT_NAME}

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
[ ! -d $pipeline_config_base ] && mkdir -p $pipeline_config_base
[ -f $pipeline_cfg_file ] && rm -f $pipeline_cfg_file

source  $cfgs_dir/biocore.cfg
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
echo "PATH2_JSON_FILES=$JSON_PROJECT_BASE">>$pipeline_cfg_file
echo "">>$pipeline_cfg_file
echo "## Where we will store the pipeline meta config file for each sample">>$pipeline_cfg_file
echo "## filename format:sampleID.organism.pcf">>$pipeline_cfg_file
echo "PIPELINE_META_BASE=$PCF_PROJECT_BASE">>$pipeline_cfg_file
echo "">>$pipeline_cfg_file
echo "## Set path to intermediary results">>$pipeline_cfg_file
echo "RESULTS_DIR=$RESULTS_DIR">>$pipeline_cfg_file
echo "## Set Reference organism info">>$pipeline_cfg_file
echo "ORGANISM=$ORGANISM">>$pipeline_cfg_file
echo "REF_DATABASE=$REF_DATABASE">>$pipeline_cfg_file
echo "REF_DATABASE_VERSION=$REF_DATABASE_VERSION">>$pipeline_cfg_file
echo "## Reference dataset used to generate indexes">>$pipeline_cfg_file
echo "REF_DATASET=$REF_DATASET">>$pipeline_cfg_file
echo "">>$pipeline_cfg_file
echo "## Setup path sample reads and design file ">>$pipeline_cfg_file
echo "READS_BASE=${READS_BASE}">>$pipeline_cfg_file
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
echo "$pipeline_cfg_file"
exit 0
