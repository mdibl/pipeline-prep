#See: http://deweylab.biostat.wisc.edu/rsem/rsem-calculate-expression.html
rsem-calculate-expression --bowtie2 \
      --bowtie2-path /opt/software/external/bowtie2/bowtie2 \
      -p 8 \
      --paired-end \
      /data/scratch/rna-seq/AmbyAmp1/14-09157-3A_AAACAT_L001_R2_001.fastq \
      /data/scratch/rna-seq/AmbyAmp1/14-09157-3A_AAACAT_L001_R1_001.fastq \
      /data/transformed/bowtie2-2.3.4.3-linux-x86_64/axolotl-omics-transcriptome-Am_3.4/axolotl-transcriptome/bowtie2-axolotl-omics-transcriptome-transcriptome \
      axolotl-transcriptome_paired_end_8threads 
 
