# Bowtie2 Indexer

A reusable module that uses bowtie2 index program to pre-index the reference before running a given data pipeline.
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

## About Bowtie2 Index Program
```
  Usage: $path2/bowtie2-build [options]* <reference_in> <bt2_base>

Where <reference_in> is the absolute path to your reference file.

<reference_in>
A comma-separated list of FASTA files containing the reference sequences to be aligned to,
or, if -c is specified, the sequences themselves. E.g., <reference_in> might be chr1.fa,chr2.fa,
chrX.fa,chrY.fa, or, if -c is specified, this might be GGTCATCCT,ACGGGTCGT,CCGTTCTATGCGGCTTA.

<bt2_base>
The basename of the index files to write. By default, bowtie2-build writes files named NAME.1.bt2,
NAME.2.bt2, NAME.3.bt2, NAME.4.bt2, NAME.rev.1.bt2, and NAME.rev.2.bt2, where NAME is <bt2_base>.

Options:

  Options

-f
The reference input files (specified as <reference_in>) are FASTA files (usually having extension .fa, .mfa, .fna or similar).

-c
The reference sequences are given on the command line. I.e. <reference_in> is a comma-separated list of sequences rather than a list of FASTA files.

--large-index
Force bowtie2-build to build a large index, even if the reference is less than ~ 4 billion nucleotides inlong.

-a/--noauto
Disable the default behavior whereby bowtie2-build automatically selects values for the --bmax, --dcv and --packed parameters according to available memory. Instead, user may specify values for those parameters. If memory is exhausted during indexing, an error message will be printed; it is up to the user to try new parameters.

-p/--packed
Use a packed (2-bits-per-nucleotide) representation for DNA strings. This saves memory but makes indexing 2-3 times slower. Default: off. This is configured automatically by default; use -a/--noauto to configure manually.

--bmax <int>
The maximum number of suffixes allowed in a block. Allowing more suffixes per block makes indexing faster, but increases peak memory usage. Setting this option overrides any previous setting for --bmax, or --bmaxdivn. Default (in terms of the --bmaxdivn parameter) is --bmaxdivn 4 * number of threads. This is configured automatically by default; use -a/--noauto to configure manually.

--bmaxdivn <int>
The maximum number of suffixes allowed in a block, expressed as a fraction of the length of the reference. Setting this option overrides any previous setting for --bmax, or --bmaxdivn. Default: --bmaxdivn 4 * number of threads. This is configured automatically by default; use -a/--noauto to configure manually.

--dcv <int>
Use <int> as the period for the difference-cover sample. A larger period yields less memory overhead, but may make suffix sorting slower, especially if repeats are present. Must be a power of 2 no greater than 4096. Default: 1024. This is configured automatically by default; use -a/--noauto to configure manually.

--nodc
Disable use of the difference-cover sample. Suffix sorting becomes quadratic-time in the worst case (where the worst case is an extremely repetitive reference). Default: off.

-r/--noref
Do not build the NAME.3.bt2 and NAME.4.bt2 portions of the index, which contain a bitpacked version of the reference sequences and are used for paired-end alignment.

-3/--justref
Build only the NAME.3.bt2 and NAME.4.bt2 portions of the index, which contain a bitpacked version of the reference sequences and are used for paired-end alignment.

-o/--offrate <int>
To map alignments back to positions on the reference sequences, it necessary to annotate ("mark") some or all of the Burrows-Wheeler rows with their corresponding location on the genome. -o/--offrate governs how many rows get marked: the indexer will mark every 2^<int> rows. Marking more rows makes reference-position lookups faster, but requires more memory to hold the annotations at runtime. The default is 5 (every 32nd row is marked; for human genome, annotations occupy about 340 megabytes).

-t/--ftabchars <int>
The ftab is the lookup table used to calculate an initial Burrows-Wheeler range with respect to the first <int> characters of the query. A larger <int> yields a larger lookup table but faster query times. The ftab has size 4^(<int>+1) bytes. The default setting is 10 (ftab is 4MB).

--seed <int>
Use <int> as the seed for pseudo-random number generator.

--cutoff <int>
Index only the first <int> bases of the reference sequences (cumulative across sequences) and ignore the rest.

-q/--quiet
bowtie2-build is verbose by default. With this option bowtie2-build will print only error messages.

--threads <int>
By default bowtie2-build is using only one thread. Increasing the number of threads will speed up the 
index building considerably in most cases.
```

See: http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#the-bowtie2-build-indexer

