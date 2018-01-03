A set of scripts and config files to create indexes in Kallisto

To prepare the reference for mapping you must first index it by typing the following command

```
  Usage: $path2/kallisto index [arguments] FASTA-files
```
Required argument:

-i, --index=STRING          Filename for the kallisto index to be constructed

Optional argument:

-k, --kmer-size=INT         k-mer (odd) length (default: 31, max value: 31)
    --make-unique           Replace repeated target names with unique names


The Fasta file supplied can be either in plaintext or gzipped format.

See:https://pachterlab.github.io/kallisto/starting
