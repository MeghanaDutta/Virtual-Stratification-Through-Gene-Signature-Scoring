## Pipeline for Survival Analysis and report

### Overview
The cox_cmdline.R and report.Rmd scripts are designed to perform survival analysis and give visualizations report. These scripts can be executed through the terminal.

### Input file 
- test_clin_ssgsea.csv - contains ssgsea scores, disease type along with some miscellaneous information 


### Running scripts through nextflow 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nextflow run pipeline.nf 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Make sure to update nextflow config file with your image ID 
Paths in nextflow file are set to working directory 


### Setting up docker 

The Dockerfile has all the necessary packages set up. 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# to build docker image 
docker build -t <image_name:tag> <path_to_dockerfile>
# to run rstudio server
docker-compose up -d
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Running scripts independently

### cox_cmdline.R
This scrript performs the virtual stratification. 

It takes 2 inputs - 
- gene signature score file - test_clin_ssgsea.csv
- path to the output directory (You could also add a name at the end of the output dir path which you would like to assign to the file). 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 cd sigmap-pipeline/
 
 Rscript cox_cmdline.R -i "test_clin_ssgsea_z.csv" -o "test"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### report.Rmd
It is an Rmd script to generate report containing results from ssgsea & zscore signature scores and cox result files. 

It takes 2 inputs - 
- test_clin_ssgsea.csv 
- test_ssgsea_cox.csv

The command line script is as follows -

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 cd sigmap-pipeline/

Rscript -e "rmarkdown::render('report.Rmd', params = list( input_2 = 'test_clin_ssgsea.csv', input_3 = 'test_ssgsea_cox.csv'))"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 
