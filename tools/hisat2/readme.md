# Hisat2 Indexer

A reusable module that uses Hisat2 index program to pre-index the reference before running a given data pipeline.
Each run generates a unique log file that contains useful information about the dataset and the version of the tool
used to generate the indexes.

The module was created to run either as a standalone application or as a downstream process of index trigger applications. 

## The Module Organization

The information under the root directory of the module is organized as follow:

- [Module Main Config File](#module-main-config-file)(bwa.cfg)
- [The Indexer](#the-indexer)(Index)
- [Data Source Config Files](#data-source-config-files)(data_source_name-reference.cfg)


## Module Main Config File
## The Indexer
## Data Source Config Files

## About Hisat2 Index Program
```
  Usage: $path2/hisat2-build [options]* <reference_in> <ht2_base>

Where <reference_in> is the absolute path to your reference file.

<reference_in>
A comma-separated list of FASTA files containing the reference sequences to be aligned to,
or, if -c is specified, the sequences themselves. E.g., <reference_in> might be chr1.fa,chr2.fa,
chrX.fa,chrY.fa, or, if -c is specified, this might be GGTCATCCT,ACGGGTCGT,CCGTTCTATGCGGCTTA.

<bt2_base>
The basename of the index files to write. By default, hisat2-build writes files named NAME.1.ht2, 
NAME.2.ht2, NAME.3.ht2, NAME.4.ht2, NAME.5.ht2, NAME.6.ht2, NAME.7.ht2, and NAME.8.ht2 
where NAME is <ht2_base>.

See: http://ccb.jhu.edu/software/hisat2/manual.shtml#the-hisat2-build-indexer

Notes:

If you use --snp, --ss, and/or --exon, hisat2-build will need about 200GB RAM for the human genome size 
as index building involves a graph construction.  Otherwise, you will be able to build an index 
on your desktop with 8GB RAM.


Main Options:

-f
The reference input files (specified as <reference_in>) are FASTA files (usually having extension .fa, .mfa, .fna or similar).

-c
The reference sequences are given on the command line. I.e. <reference_in> is a comma-separated list of sequences rather than a list of FASTA files.

--large-index
Force hisat2-build to build a large index, even if the reference is less than ~ 4 billion nucleotides long.

-a/--noauto
Disable the default behavior whereby hisat2-build automatically selects values for the --bmax, --dcv and [--packed] parameters according to available memory. Instead, user may specify values for those parameters. If memory is exhausted during indexing, an error message will be printed; it is up to the user to try new parameters.

--bmax <int>
The maximum number of suffixes allowed in a block. Allowing more suffixes per block makes indexing faster, but increases peak memory usage. Setting this option overrides any previous setting for --bmax, or --bmaxdivn. Default (in terms of the --bmaxdivn parameter) is --bmaxdivn 4. This is configured automatically by default; use -a/--noauto to configure manually.

--bmaxdivn <int>
The maximum number of suffixes allowed in a block, expressed as a fraction of the length of the reference. Setting this option overrides any previous setting for --bmax, or --bmaxdivn. Default: --bmaxdivn 4. This is configured automatically by default; use -a/--noauto to configure manually.

--dcv <int>
Use <int> as the period for the difference-cover sample. A larger period yields less memory overhead, but may make suffix sorting slower, especially if repeats are present. Must be a power of 2 no greater than 4096. Default: 1024. This is configured automatically by default; use -a/--noauto to configure manually.

--nodc
Disable use of the difference-cover sample. Suffix sorting becomes quadratic-time in the worst case (where the worst case is an extremely repetitive reference). Default: off.

-r/--noref
Do not build the NAME.3.ht2 and NAME.4.ht2 portions of the index, which contain a bitpacked version of the reference sequences and are used for paired-end alignment.

-3/--justref
Build only the NAME.3.ht2 and NAME.4.ht2 portions of the index, which contain a bitpacked version of the reference sequences and are used for paired-end alignment.

-o/--offrate <int>
To map alignments back to positions on the reference sequences, its necessary to annotate ("mark") some or all of the Burrows-Wheeler rows with their corresponding location on the genome. -o/--offrate governs how many rows get marked: the indexer will mark every 2^<int> rows. Marking more rows makes reference-position lookups faster, but requires more memory to hold the annotations at runtime. The default is 4 (every 16th row is marked; for human genome, annotations occupy about 680 megabytes).

-t/--ftabchars <int>
The ftab is the lookup table used to calculate an initial Burrows-Wheeler range with respect to the first <int> characters of the query. A larger <int> yields a larger lookup table but faster query times. The ftab has size 4^(<int>+1) bytes. The default setting is 10 (ftab is 4MB).

--localoffrate <int>
This option governs how many rows get marked in a local index: the indexer will mark every 2^<int> rows. Marking more rows makes reference-position lookups faster, but requires more memory to hold the annotations at runtime. The default is 3 (every 8th row is marked, this occupies about 16KB per local index).

--localftabchars <int>
The local ftab is the lookup table in a local index. The default setting is 6 (ftab is 8KB per local index).

-p <int>
Launch NTHREADS parallel build threads (default: 1).

--snp <path>
Provide a list of SNPs (in the HISAT2s own format) as follows (five columns).

SNP ID <tab> snp type (single, deletion, or insertion) <tab> chromosome name <tab> zero-offset based genomic position of a SNP <tab> alternative base (single), the length of SNP (deletion), or insertion sequence (insertion)

For example, rs58784443 single 13 18447947 T

Use hisat2_extract_snps_haplotypes_UCSC.py (in the HISAT2 package) to extract SNPs and haplotypes from a dbSNP file (e.g. http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/snp144Common.txt.gz). or hisat2_extract_snps_haplotypes_VCF.py to extract SNPs and haplotypes from a VCF file (e.g. ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/supporting/GRCh38_positions/ALL.chr22.phase3_shapeit2_mvncall_integrated_v3plus_nounphased.rsID.genotypes.GRCh38_dbSNP_no_SVs.vcf.gz).

--haplotype <path>
Provide a list of haplotypes (in the HISAT2s own format) as follows (five columns).

Haplotype ID <tab> chromosome name <tab> zero-offset based left coordinate of haplotype <tab> zero-offset based right coordinate of haplotype <tab> a comma separated list of SNP ids in the haplotype

For example, ht35 13 18446877 18446945 rs12381094,rs12381056,rs192016659,rs538569910

See the above option, --snp, about how to extract haplotypes. This option is not required, but haplotype information can keep the index construction from exploding and reduce the index size substantially.

--ss <path>
Note this option should be used with the following --exon option. Provide a list of splice sites (in the HISAT2s own format) as follows (four columns).

chromosome name <tab> zero-offset based genomic position of the flanking base on the left side of an intron <tab> zero-offset based genomic position of the flanking base on the right <tab> strand

Use hisat2_extract_splice_sites.py (in the HISAT2 package) to extract splice sites from a GTF file.

--exon <path>
Note this option should be used with the above --ss option. Provide a list of exons (in the HISAT2s own format) as follows (three columns).

chromosome name <tab> zero-offset based left genomic position of an exon <tab> zero-offset based right genomic position of an exon

Use hisat2_extract_exons.py (in the HISAT2 package) to extract exons from a GTF file.

--seed <int>
Use <int> as the seed for pseudo-random number generator.

--cutoff <int>
Index only the first <int> bases of the reference sequences (cumulative across sequences) and ignore the rest.

-q/--quiet
hisat2-build is verbose by default. With this option hisat2-build will print only error messages.

```
See: http:http://ccb.jhu.edu/software/hisat2/manual.shtml#the-hisat2-build-indexer

