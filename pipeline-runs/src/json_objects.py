# -*- coding: utf-8 -*-
"""
Template data models for different dataset metadata.

Returns:
     Sets global  
Raises:
     Nothing

BiocoreInfoDOM: Stores biocore info directories map
RnaSeqPipelineJsonDOM: Stores the data model of pipeline json file for rna-seq type analysis 
PipelinePcfDOM: Stores the data model of pipeline pcf file

"""
class BiocoreInfoDOM:
    def __init__(self):
        self.external_data=None    #Where we store downloaded data
        self.internal_data=None    #Where we store internal data
        self.external_software=None    #Where we store downloaded packages
        self.internal_software=None    #Where we store internal packages
        self.scratch=None          #Working space
        self.transformed=None      #Where we store tools' generated indexes
        self.projects=None    #Completed projects space

    def set_external_data(self,ext_data_dir):
        self.external_data=ext_data_dir
    def set_internal_data(self,int_data_dir):
        self.internal_data=int_data_dir
    def set_external_software(self,ext_soft_dir):
        self.external_software=ext_soft_dir
    def set_internal_software(self,int_soft_dir):
        self.internal_software=int_soft_dir
    def set_scratch(self,scratch_dir):
        self.scratch=scratch_dir
    def set_transformed(self,transformed_dir):
        self.transformed=transformed_dir 
    def set_projects(self,projects_dir):
        self.projects=projects_dir

#class ExperimentConfigDOM:
class PipelinePcfDOM:
    def __init__(self):
        self.cwl_script=None          #cwl script for this pipeline
        self.json_file=None           #json file for this pipeline
        self.cwl_cmd_options=None     #cwl command line options
        self.pipeline_owner=None         #User
        self.pipeline_results_base=None  #Where to store the pipeline results

    def set_cwl_script(self,file_name):
        self.cwl_script=file_name
    def set_json_file(self,file_name):
        self.json_file=file_name
    def set_cwl_cmd_options(self,options):
        self.cwl_cmd_options=options
    def set_pipeline_owner(self,user_name):
        self.pipeline_owner=user_name
    def set_cwl_script(self,dir_name):
        self.cwl_script=dir_name
    
class RnaSeqPipelineJsonDOM:
    def __init__(self):
        self.=None 
        self.=None 
        self.=None 
        self.=None 
        self.=None 
        self.=None 
        self.=None 
        self.=None 
        self.=None 
        self.=None 
        self.=None 
