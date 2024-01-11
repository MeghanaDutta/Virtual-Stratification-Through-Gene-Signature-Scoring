params.scores = "/test_clin_ssgsea.csv"
params.r_script = "/cox_cmdline.R"
params.r_report = "/report.Rmd"


process survival {
  
input:
  path scores 
  
output:
  path 'test_ssgsea_cox.csv'
  
script:
"""
Rscript $params.r_script -i "$scores" -o "test" 
"""
}


process report {

input:
  path scores
  val x
  
output:
  path ''
 
script: 
"""
Rscript -e "rmarkdown::render('$params.r_report', params = list(input_2 = '$scores' , input_3 = '$x'))" 
"""
}


workflow {
  survival(params.scores)
  report(params.scores, survival.out)
}