# Kallisto Indexer

A reusable module that uses kallisto index program to pre-index the reference before running a given data pipeline.
Each run generates a unique log file that contains useful information about the dataset and the version of the tool
used to generate the indexes.

The module was created to run either as a standalone application or as a downstream process of index trigger applications. 

## The Module Organization

The information under the root directory of the module is organized as follow:

- [Module Main Config File](#module-main-config-file)(kallisto.cfg)
- [The Indexer](#the-indexer)(Index)
- [Data Source Config Files](#data-source-config-files)(data_source_name-reference.cfg)


## Module Main Config File
## The Indexer
## Data Source Config Files

## About Kallisto Index Program
```
  Usage: $path2/kallisto index [arguments] FASTA-files

Required argument:

-i, --index=STRING          Filename for the kallisto index to be constructed

Optional argument:

-k, --kmer-size=INT         k-mer (odd) length (default: 31, max value: 31)
    --make-unique           Replace repeated target names with unique names

```
The Fasta file supplied can be either in plaintext or gzipped format.

See:https://pachterlab.github.io/kallisto/starting
