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
  if (!require(httr))install.packages("httr");library(httr)
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

######################################
# IPC: Banco de la republica de Colombia
######################################
get.IPC = function(){
  
  #' Funcion que hace webscrapping a los exceles del Banco de la republica de Colombia
  #' para obtener el historico del IPC en niveles mensuales
  #'
  #' OUTPUT:
  #' @return data frame con las fechas y el IPC
  
  #link del excel del ipc del banrep
  link <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&NQUser=publico&NQPassword=publico123&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.5.IPC_Serie_variaciones"
  
  #se hace un print de que inicio el proceso
  print("Extrayendo datos, puede tomar unos minutos")
  #se crea un archov temporal
  path_excel <- tempfile(fileext = ".xlsx")
  
  #se extraen los datos de la descarga
  
  while(class(try(read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T))=="try-error"){
    r <- GET(link,
            add_headers(
              Host="totoro.banrep.gov.co",
              `User-Agent`="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
              Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
              `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
              `Accept-Encoding` = "gzip, deflate",
              Connection = "keep-alive"
            ))
    #se pasan a formato excel
    bin <- content(r, "raw")
    writeBin(bin, path_excel)
    
    #se leen
    d <- try(read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T)
  }
  
  #eliminando el temporal
  unlink(path_excel)
  #se arregla el formato
  ##se dejan solo las fechas y el ipc (primeras dos columnas)
  d <- d[,1:2]
  ##se pasa la primera columna a numerico
  d[,1] <- suppressWarnings(as.numeric(d[,1]))
  ##se deja de una vez solo lo que no sea NA en ninguna de las dos columnas
  ##asi se borra tanto lo que era texto antes como lo que no tiene dato
  d <- d[complete.cases(d),]
  ##las fechas estan en numerico pero es un formato anho mes, se ponen todas al final
  ##del mes
  ###se extrae el anho (los primeros 4 numeros)
  ano <- as.numeric(substr(d[,1],start=1,stop=4))
  ####se extrae el mes
  mes <- as.numeric(substr(d[,1],start=5,stop=nchar(d[,1])))
  ###se suma uno al mes, para luego restarle uno a la fecha (porque no se en que dia acaba cada mes)
  mes <- mes +1
  ano <- ifelse(mes==13,ano+1,ano)
  mes <- ifelse(mes==13,1,mes)
  ###se construye la fecha
  fechasIPC <- as.Date(paste(ano,mes,1,sep="/"),format="%Y/%m/%d")-1
  
  #se arreglan los nombres de las columnas
  names(d) <- c("Fecha", "IPC")
  #se intercambia la columna de fecha por las fechas construidas
  d$Fecha <- fechasIPC
  #se ordena
  d <- d[order(d$Fecha),]
  #se quitan los nombres de las filas
  rownames(d) <- NULL
  #se vuelven numeros las tasas
  d[,2] <- as.numeric(d[,2])
  #se anuncia cuantos datos se consiguieron
  print(paste0("Se obtuvo datos para el IPC desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  print("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(d)
  
}
