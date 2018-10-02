SCRIPT_NAME=`basename $0`
cd `dirname $0`
echo "Running script from `pwd`"

if [ $# -lt 5 ]
then
  echo "Usage: ./$SCRIPT_NAME  source source-version organism dataset path2/gtf_file [tool-version]"
  echo "Example: ./$SCRIPT_NAME ensembl ensembl-91 danio_rerio genome /data/scratch/ensembl-91/danio_rerio-gtf/Danio_rerio.GRCz10.91.gtf [RSEM-v1.3.0]"
  echo "The default tool-version is the current version of the tool"
  echo "The default index-prefix is tool_name-data_source_name-dataset"
  exit 1
fi

EXTERNAL_TOOLS_BASE=/opt/software/external
INDEX_BASE=/data/transformed
FASTA_FILES_BASE=/data/scratch
short_name=rsem
GIT_REPOS=RSEM
organism=$3
dataset=$4
data_source=$1
gtf_file=$5
source_version=$2
TOOL_INDEX_EXEC="rsem-prepare-reference"
THREADS="-p 8"
GTFfile="--gtf $gtf_file"

PACKAGE_INSTALL_BASE=${EXTERNAL_TOOLS_BASE}/${short_name}
CURRENT_VERSION_FILE=$PACKAGE_INSTALL_BASE/current_release_NUMBER
CURRENT_VERSION=`cat $CURRENT_VERSION_FILE`
TOOL_VERSION=$GIT_REPOS-$CURRENT_VERSION
tool_version=$TOOL_VERSION
[ $# -gt 5 ] && tool_version=$6

tool_index_base=$INDEX_BASE/$tool_version
tool_exec=$PACKAGE_INSTALL_BASE/$tool_version/$TOOL_INDEX_EXEC
index_dir=$tool_index_base/$source_version/$organism-$dataset
datasets_fasta_dir=$FASTA_FILES_BASE/$source_version/$organism-$dataset
index_options="$tool_exec $GTFfile $THREADS"
log=$SCRIPT_NAME.$tool_version.$source_version.$organism-$dataset.log
touch $log
if [ -d $index_dir ]
then
  echo "$source_version/$organism-$dataset is already indexed"
  exit 0
fi
mkdir -p $index_dir 
if [ ! -d $datasets_fasta_dir ]
then
   echo "ERROR: directory $datasets_fasta_dir does not exists" | tee -a $log
   exit 1
fi
file_pattern=".genome.fa"
FASTA_FILES=`ls $datasets_fasta_dir | grep $file_pattern`
for target_file  in $FASTA_FILES
do
    reference_file=$datasets_fasta_dir/$target_file
    index_cmd="$index_options  $reference_file $index_dir"
    echo "Dataset file: $reference_file" | tee -a $log
    echo "Cmd: $index_cmd" | tee -a $log
    echo "=== $tool_exec's Logs start Here ===" | tee -a $log
    $index_cmd 2>&1 | tee -a $log
    echo "=== $tool_exec's Logs end Here ===" | tee -a $log
done
echo "Program Complete" | tee -a $log
exit 0


