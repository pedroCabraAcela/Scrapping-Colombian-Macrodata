###########################################
#'                                        #
#'     Scrapping macrodatos colombianos   #
#'                v1                      #
#'              espanol                   #
#'#########################################

######################################
# Esta funcion descarga y lee los paquetes requeridos
######################################
packages_download <- function(){
  if (!require(openxlsx))install.packages("openxlsx");library(openxlsx)
}             


###############################################
# TRM: Superintendencia financiera colombiana
##############################################

get.TRM <- function(){
  
  #' Funcion que hace webscrapping del csv de Superintendencia financiera colombiana
  #' para obtener la TRM diaria
  #'
  #' OUTPUT:
  #' @return data frame con las fechas y la trm
  
  print("Extrayendo datos, puede tomar unos minutos")
  #se extraen los datos de la trm de la super intendencia en formato csv
  TRM <- read.csv(url("https://www.datos.gov.co/api/views/32sa-8pi3/rows.csv?accessType=DOWNLOAD"))
  #se arregla el formato
  ##se dejan las columnas fecha y valor
  TRM <- TRM[,c(3,1)]
  ##se pasa a formato fecha
  TRM[,1] <- as.Date(as.character(TRM[,1]),format='%d/%m/%Y')
  ##se ordenan las fechas
  TRM <- TRM[order(TRM[,1]),]
  ##se quitan los nombres de las filas y se le pone nombres a las variables
  rownames(TRM) <- NULL
  names(TRM) <- c("Fecha", "TRM")
  
  #se anuncia cuantos datos se consiguieron
  print(paste0("Se obtuvo datos para la TRM desde ", 
               TRM$Fecha[1], " hasta ", TRM$Fecha[nrow(TRM)] ))
  print("Fuente: Superintendencia Financiera Colombiana")
  #se retorna
  return(TRM)
}
