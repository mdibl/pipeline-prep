# Pipeline Indexers Repos

This package can be used to create automations that trigger pre-indexing of the reference each 
time one of the following events happen:

1. A new version of the alignment tool was installed, or
2. A new release of the reference was downloaded

Indexes are created by tool version -> data source version > organism-dataset.
Each data source specifies the format of each of its datasets and each tool has 
its own sets of command to index the reference data.

The package is currently written in bash shell and assumes the reference datasets 
are already downloaded and the alignment tool(s) installed.

Package Documentation:  https://github.com/mdibl/pipeline-prep/wiki
