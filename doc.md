# About This Project

Pipeline-prep project's goal is in two folds - first creates a set reusable modules used in running the first two steps of a given data pipeline then create and automation to run the pre-indexing step. 

The goals :
  1) Pre-Indexing reference genome/transcripome
  2) Automate Pre-indexing step
  ```
    a) Create a trigger to index a New Data version 
    b) Create a trigger to index a New Tool version 
  ```
  3) Pre-processing the reads.
  

## Pre-Indexing reference genome/transcripome

Indexes are created by tool version -> data source version > organism-dataset. Each data source specifies
data format for a given dataset and each tool has its own sets of command to index the reference data.

The root directory of the project contains two main diretories:

 * tools
 * data_sources

### The Data Sources Directory

Each data source is config file (tool.cfg) under data_sources/  - Each config file contains the following 
global environment variables:
  1) DATASETS - Mapping between each dataset and its file format 
  2) GENOME - AN ARRAY of the names of datasets that are genomic (the whole genome) - used as a flag for indexing options
  3) DATA_SOURCE - name of the data source
  4) ORGANISMS - list of organism as provived (datasets are stored by organisms)
  5) and more
  

### The Tools Directory

Each tool is a directory under tools  and each directory contains the following files:

1)	A readme.md file
2)	A config file tool.cfg
3)	Refeence.csv file mapping tool to datasets
4)	The Index shell script to setup and index datasets



## Automate Pre-indexing step

## Pre-processing the reads


