##
## Assumptions: assumes the following structure under the  working directory
#   1) cfgs
#   2) src
## Assumptions: assumes the following config files in the cfgs directory
#  1) trimmomatic.tool_options.cfg
#  2) pipeline.cfg
# 
source /etc/profile.d/biocore.sh 

date

cd `dirname $0`
script_name=`basename $0`
## Check expected structure
working_dir=`pwd`
parent_dir=`dirname $working_dir`
cfgs_dir=$parent_dir/cfgs

if [ ! -d $cfgs_dir ]
then
   echo "ERROR: Expected cfgs directory missing under $parent_dir"
   exit 1
fi

if [ $# -lt 5 ]
then
  echo "************************************************"
  echo ""
  echo "Usage: ./$script_name  <TRIM_JAR> <TRIM_VERSION> <READS_BASE> <RESULTS_BASE><RESULTS_SUFFIX>"
  echo "Example: ./$script_name  /path2/trimmomatic-0.36.jar 0.36 /data/rna-seq/project1 /path2/rna-seq/project1/results fastq.gz" 
  echo ""
  echo "************************************************"
  exit 1
fi
if [ ! -f $cfgs_dir/trimmomatic.tool_options.cfg ]
then
   echo "ERROR: Missing trimmomatic.tool_options.cfg under $cfgs_dir"
   exit 1
fi
if [ ! -f $cfgs_dir/pipeline.cfg ]
then
   echo "ERROR: Missing reads.cfg under $cfgs_dir"
   exit 1
fi
#Where to look for the reads
TOOL_EXEC=$1
TOOL_VERSION=trimmomatic-$2
READS_BASE=$3
RESULTS_BASE=$4
RESULTS_SUFFIX=$5

source $cfgs_dir/trimmomatic.tool_options.cfg
source $cfgs_dir/pipeline.cfg
#Where to store the alignment results
TOOL_RESULTS_DIR=$RESULTS_BASE/$TOOL_VERSION
RESULTS_LOG_DIR=$RESULTS_BASE/logs
[ ! -d $TOOL_RESULTS_DIR ]&& mkdir -p $TOOL_RESULTS_DIR
[ ! -d $RESULTS_LOG_DIR ]&& mkdir -p $RESULTS_LOG_DIR
cmd_log_file=$RESULTS_LOG_DIR/$script_name.cmds.log
log_file=$RESULTS_LOG_DIR/$script_name.log
rm -f $cmd_log_file
rm -f $log_file
touch $cmd_log_file
touch $log_file

#
# sample reads filename info
#READS_FILE_SUFFIX=noadapt.fastq.gz
for SAMPLE_ID in $SAMPLES
do
   # get this sample reads files
   # get this sample reads files
   READ1=${READS["1"]}
   READ2=${READS["2"]}
   READ2_FILE=""
   READ1_FILE_PREFIX="$SAMPLE_ID$SAMPLE_READ_DELIMITER$READ1"
   READ2_FILE_PREFIX="$SAMPLE_ID$SAMPLE_READ_DELIMITER$READ2"
   READS_CMD=""
   READ1_FILE=$READS_BASE/`ls $READS_BASE/ | grep  $READ1_FILE_PREFIX`
   if [ ! -f $READ1_FILE ]
   then
      echo "ERROR: $READ1_FILE NOT a file"
      continue
   fi
   ##detect type of reads: paired_end/single_end
   if [ ! -z "$READ2" ]
   then
       READ2_FILE=$READS_BASE/`ls $READS_BASE/ | grep  $READ2_FILE_PREFIX`
       if [ ! -f $READ2_FILE ]
       then
            echo "ERROR: $READ2_FILE NOT a file"
            continue
       fi
       out_read1_paired="$TOOL_RESULTS_DIR/${READ1_FILE_PREFIX}_paired.$RESULTS_SUFFIX"
       out_read1_unpaired="$TOOL_RESULTS_DIR/${READ1_FILE_PREFIX}_unpaired.$RESULTS_SUFFIX"
       out_read2_paired="$TOOL_RESULTS_DIR/${READ2_FILE_PREFIX}_paired.$RESULTS_SUFFIX"
       out_read2_unpaired="$TOOL_RESULTS_DIR/${READ2_FILE_PREFIX}_unpaired.$RESULTS_SUFFIX"

       READS_CMD=" $READ1_FILE $READ2_FILE $out_read1_paired $out_read1_unpaired $out_read2_paired $out_read2_unpaired "
    else
       out_file="$TOOL_RESULTS_DIR/${READ1_FILE_PREFIX}.$RESULTS_SUFFIX"
       READS_CMD=" $READ1_FILE $out_file"
    fi
   # Set path to cmd
   CMD="$JAVA_CMD $TOOL_EXEC $TRIMM_CMD_OPTIONS $READS_CMD $ILLUMINACLIP_OPTIONS"
   echo "##$SAMPLE_ID:" | tee -a $cmd_log_file
   echo "##$SAMPLE_ID:" | tee -a $log_file
   echo "start-time-`date`" | tee -a $log_file
   echo "$CMD" | tee -a $cmd_log_file
   #$CMD  2>&1 | tee -a $log_file 
   echo "end-time-`date`" | tee -a $log_file
done
exit 0
