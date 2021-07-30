# Guide to qualtRics package - https://cran.r-project.org/web/packages/qualtRics/vignettes/qualtRics.html
# libraries ----
#library(tidyverse) # if you need to do any data manipulation
library(qualtRics) # for the API
library(writexl) # for writing the data to excel
library(here) # for file paths
library(esquisse)
# for visualising

# API Cred ----
# to get API token - https://api.qualtrics.com/instructions/docs/Instructions/api-key-authentication.md
# to get base url - https://api.qualtrics.com/instructions/docs/Instructions/base-url-and-datacenter-ids.md
# You only need to do this once, so it is commented out for now
#qualtrics_api_credentials(api_key = "ChMOaqesLzGnyOL4QVddQtqmBEeRLRyfRBpCk2Dc", 
#                          base_url = "lse.fra1.qualtrics.com",
#                          install = TRUE,
#                          overwrite = TRUE)

# Pull all surveys ----
surveys <- all_surveys() 

# check what the name and ids are
surveys$name
surveys$id

# load lent term eval survey ----
LT_Eval <- fetch_survey(surveyID = surveys$id[4])

# load MT eval survey ----
MT_Eval <- fetch_survey(surveyID = surveys$id[6], 
                         verbose = TRUE)

# check data
summary(LT_Eval)
names(LT_Eval)
dim(LT_Eval)

# Explore data to excel
writexl::write_xlsx(LT_Eval, here('R', 'Data', 'LT_Eval.xlsx'))

esquisser()
