###########################################
#'                                        #
#'     Scrapping colombian macrodata      #
#'                v1                      #
#'              english                   #
#'######################################### 

#' This function downloads and loads the require packages
packages_download <- function(){
  if (!require(openxlsx))install.packages("openxlsx");library(openxlsx)
}   