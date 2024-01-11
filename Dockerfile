FROM --platform=linux/amd64 rocker/tidyverse:4.3.0 

USER root

RUN apt-get update &&\
apt-get -y install zlib1g-dev libxml2-dev liblzma-dev libbz2-dev libjpeg-dev

RUN Rscript -e "install.packages(c('rmarkdown','caTools','bitops','codetools','rlang','promises','BH','httpuv','xtable','pheatmap','DT','RMySQL','printr','gtools','tictoc', 'dbscan', 'igraph', 'openxlsx', 'ggpubr', 'heatmaply', 'morpheus', 'plotly', 'ggplot2', 'tidyverse', 'survival', 'survminer', 'optparse', 'reticulate', 'reshape2', 'jsonlite'))"


