# function to log each step 
logging=function(msg, tag="INFO", append=TRUE)
{
  msg = paste0("[", Sys.time(), "] ", ifelse(!is.null(tag), paste0(tag, ": ", msg), msg))
  message(msg)
  if (tag!="WARN") cat(paste0(msg, "\n"), file= log_file , append=append)
}


# function to load packages 
load_pkg <- function(pkg) {
  pkg <- as.character(pkg)
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
  library(pkg, character.only = TRUE)
}

# function to extract data from cox results 
extract <- function(x, sig, type) {
  sig <- sig
  type <- type
  p.value<-signif(x$waldtest["pvalue"], digits=2)
  logrank.p.value<-signif(x$logtest["pvalue"], digits=2)
  beta<-signif(x$coef[1], digits=2);#coeficient beta
  HR <-signif(x$coef[2], digits=2);#exp(beta)
  HR.confint.lower <- signif(x$conf.int[,"lower .95"], 2)
  HR.confint.upper <- signif(x$conf.int[,"upper .95"],2)
  res<-c(sig, type, beta, HR, HR.confint.lower, HR.confint.upper, logrank.p.value, p.value)
  names(res)<-c("Signature ID", "Type", "beta", "HR","HR.confint.lower" , "HR.confint.upper" , "logrank.p.value", 
                "p.value")
  y <- as.data.frame(t(res))
  return(y)
}


# define function to perform gene enrichment (ssGSEA, Zscore)
gene_surv <- function(merge_all, destfold) {
  
  # Wrap the code in a tryCatch block
  tryCatch(expr = { 
    
    withCallingHandlers({
      
      nam <- colnames(merge_all)
      # create a list of patient signatures to count significant stratification 
      logging("create list of patient signatures")
      pt_sig <- unique(merge_all$`Signature ID`)
      pt_type <- unique(merge_all$`type`)
      
      # Performing cox analysis 
      logging("Define cox output variables")
      cox_results_s <- data.frame()
      logging("Performing cox hazard analysis")
      
      # cox analysis loop 
      #filter based on signature
      for (sig in pt_sig) {
        first_cox <- merge_all[ merge_all$`Signature ID` == sig, ]
        
        #filter based on type 
        for (x in pt_type){
          test_cox <- first_cox[first_cox$`type` == x, ]
          
          test_cox$group_s <- ifelse(test_cox$ssgsea_scores > median(test_cox$ssgsea_scores), 1, 0)
          # getting the time column 
          p <- test_cox[, nam[3]]
          p <- unlist(p)
          # getting the status column 
          q <- test_cox[, nam[4]]
          q <- unlist(q)
          cox_model_s <- coxph(Surv(OS.time, vital_status) ~ group_s, data = test_cox)
          cox_results_s <- rbind(cox_results_s, extract(summary(cox_model_s), sig, x))
        
        }
        
      }
      
      logging("cox hazard analysis performed")
      logging("removing incomplete cases")
      cox_results_s <- na.omit(cox_results_s)
      
      # to avoid having p value column as char
      cox_results_s$p.value <- as.numeric(cox_results_s$p.value)
      
    
      # Write ssGSEA cox output to a parquet file
      logging("Creating the ssgsea cox output file")
      path_1 <- paste0(destfold, "_ssgsea_cox.csv") 
      write.csv(cox_results_s, path_1)
      
  
    },
  warning = function(w) {
    logging(paste0('sig: ', w), "WARN")
    invokeRestart("muffleWarning")
  })
  }, 
  error = function(e) {
    logging(paste0('sig: ', e), "ERROR") 
  })
}


# get variables from the request document 
args <- commandArgs(trailingOnly = TRUE)

# script to run from command line 


pkg_to_load <- c("optparse")
for (pkg in pkg_to_load) {
  load_pkg(pkg)
}

# command line options 
if (length(args)>0) {
  option_list=list(
    make_option(c("-i", "--inputfile"),
                type="character",
                default= NULL,
                help="input file to run"),
    make_option(c("-o", "--outputdir"),
                type="character",
                default= NULL,
                help="output directory to store results"
    )
  )
  
  opt <- parse_args(OptionParser(option_list=option_list))
  
  pkg_to_load <- c("tidyverse", "ggplot2", "arrow", "jsonlite", "reticulate", "reshape2", "tibble", "survminer", "survival", "plotly", "optparse")
  for (pkg in pkg_to_load) {
    load_pkg(pkg)
  }
  
  sig_file <- opt$inputfile 
  output_file <-  opt$outputdir
 
  
  # define the log file 
  log_file <<- paste0(output_file, "_running.log")
  logging(paste0("logging to: ", log_file))
  logging("Reading request file")
  
  merge_all <- read_csv(sig_file)
  destfold <- output_file
  
  gene_surv(merge_all, destfold)

  
} else {
  print('missing file!');
  print(args)
}

