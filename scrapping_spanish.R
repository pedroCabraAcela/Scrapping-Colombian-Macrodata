###########################################
#'                                        #
#'     Scrapping macrodatos colombianos   #
#'                v1                      #
#'              espanol                   #
#'     Author: PACA                       #
#'#########################################

######################################
# Esta funcion descarga y lee los paquetes requeridos
######################################

packages_download <- function(){
  if (!require(openxlsx))install.packages("openxlsx");library(openxlsx)
  if (!require(httr))install.packages("httr");library(httr)
  if (!require(lubridate))install.packages("lubridate");library(lubridate)
  if (!require(readxl))install.packages("readxl");library(readxl)
  if (!require(utils))install.packages("utils");library(utils)
  if (!require(stats))install.packages("stats");library(stats)
}             


#' TRM extraction
#'
#' Function to extract the TRM (COP/USD) time serie from the Colombian Financial Supervision Office.
#' @return The dataframe with dates and the TRM.
#' @examples
#' \dontrun{
#' TRM <- get.TRM();
#' }
#' @export
get.TRM <- function(){
  
  # print("Extrayendo datos, puede tomar unos minutos")
  message("Extrayendo datos, puede tomar unos minutos")
  #se extraen los datos de la trm de la super intendencia en formato csv
  TRM <- utils::read.csv(url("https://www.datos.gov.co/api/views/32sa-8pi3/rows.csv?accessType=DOWNLOAD"))
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
  # print(paste0("Se obtuvo datos para la TRM desde ",
  #              TRM$Fecha[1], " hasta ", TRM$Fecha[nrow(TRM)] ))
  # print("Fuente: Superintendencia Financiera Colombiana")
  
  message(paste0("Se obtuvo datos para la TRM desde ",
                 TRM$Fecha[1], " hasta ", TRM$Fecha[nrow(TRM)] ))
  message("Fuente: Superintendencia Financiera Colombiana")
  #se retorna
  return(TRM)
}

#' IPC extraction
#'
#' Function to extract the Colombian CPI time serie from the Colombian Central Bank.
#' @return The dataframe with dates and the Colombian CPI.
#' @examples
#' \dontrun{
#' IPC <- get.IPC();
#' }
#' @export
get.IPC <- function(){
  
  #link del excel del ipc del banrep
  link <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&NQUser=publico&NQPassword=publico123&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.5.IPC_Serie_variaciones"
  
  #se hace un print de que inicio el proceso
  # print("Extrayendo datos, puede tomar unos minutos")
  message("Extrayendo datos, puede tomar unos minutos")
  #se crea un archov temporal
  path_excel <- tempfile(fileext = ".xlsx")
  
  #se extraen los datos de la descarga
  
  while(class(try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T))=="try-error"){
    r <- httr::GET(link,
                   httr::add_headers(
                     Host="totoro.banrep.gov.co",
                     `User-Agent`="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
                     Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                     `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
                     `Accept-Encoding` = "gzip, deflate",
                     Connection = "keep-alive"
                   ))
    #se pasan a formato excel
    bin <- httr::content(r, "raw")
    writeBin(bin, path_excel)
    
    #se leen
    d <- try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T)
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
  d <- d[stats::complete.cases(d),]
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
  # print(paste0("Se obtuvo datos para el IPC desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  # print("Fuente: Banco de la Republica de Colombia")
  message(paste0("Se obtuvo datos para el IPC desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(d)
  
}

#' Colombian Unemployment Rate extraction
#'
#' Function to extract the Colombian unemployment rate time serie from the Colombian Central Bank.
#' @return The dataframe with dates and the Colombian Unemployment Rate.
#' @examples
#' \dontrun{
#' unemp <- get.TasaDesempleoCol();
#' }
#' @export
get.TasaDesempleoCol <- function(){
  
  #link del excel de la tasa de desempleo del banrep
  link <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20Empleo%20y%20desempleo%2F1.1%20Serie%20hist%C3%B3rica%2F1.1.1.EMP_Total%20nacional%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1"
  
  #se hace un print de que inicio el proceso
  # print("Extrayendo datos, puede tomar unos minutos")
  message("Extrayendo datos, puede tomar unos minutos")
  #se crea un archov temporal
  path_excel <- tempfile(fileext = ".xlsx")
  
  #se extraen los datos de la descarga
  
  while(class(try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T))=="try-error"){
    r <- httr::GET(link,
                   httr::add_headers(
                     Host="totoro.banrep.gov.co",
                     `User-Agent`="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
                     Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                     `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
                     `Accept-Encoding` = "gzip, deflate",
                     Connection = "keep-alive"
                   ))
    #se pasan a formato excel
    bin <- httr::content(r, "raw")
    writeBin(bin, path_excel)
    
    #se leen
    d <- try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T)
  }
  #se borra el excel
  unlink(path_excel)
  
  #se arregla el formato
  ##se dejan solo las fechas y la tasa de desempleo (se busca en las filas 'MES' y en las columnas
  #desempleo)
  d <- d[grep('Mes',d[,1]):nrow(d),c(1,grep('desempleo',d[grep('Mes',d[,1]),]))]
  ##la primera fila se quita
  d <- d[-1,]
  ##se pasa la primera coluna a fecha (lo que no funciona asi es porque eran filas que no sirven)
  d[,1] <- lubridate::`%m+%`(as.Date(paste0(d[,1],'-1')),months(1)) - 1
  ##se deja de una vez solo lo que no sea NA en ninguna de las dos columnas
  ##asi se borra tanto lo que era texto antes como lo que no tiene dato
  d <- d[stats::complete.cases(d),]
  
  #se arreglan los nombres de las columnas
  names(d) <- c("Fecha", "tasa_desempleo_%")
  #se ordena
  d <- d[order(d$Fecha),]
  #se quitan los nombres de las filas
  rownames(d) <- NULL
  #se vuelven numeros las tasas y se divide en 100
  # d[,2] <- as.numeric(d[,2])/100
  d[,2] <- as.numeric(d[,2])
  #se anuncia cuantos datos se consiguieron
  # print(paste0("Se obtuvo datos para la tasa de desempleo desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  # print("Fuente: Banco de la Republica de Colombia")
  # print(paste0("Se obtuvo datos para la tasa de desempleo desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  # print("Fuente: Banco de la Republica de Colombia")
  message(paste0("Se obtuvo datos para la tasa de desempleo desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(d)
  
}

#' Colcap extraction
#'
#' Function to extract the Colcaptime serie from the Colombian Central Bank.
#' @return The dataframe with dates and the Colcap.
#' @examples
#' \dontrun{
#' colcap <- get.Colcap();
#' }
#' @export
get.Colcap <-function(){
  
  #link del excel del ipc del banrep
  link <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20%C3%8Dndices%20de%20mercado%20burs%C3%A1til%20colombiano%2F1.1.%20IGBC%2C%20IBB%20e%20IBOMED%2F1.1.1.IMBC_COLCAP_IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1"
  
  
  #se hace un print de que inicio el proceso
  # print("Extrayendo datos, puede tomar unos minutos")
  message("Extrayendo datos, puede tomar unos minutos")
  #se crea un archov temporal
  path_excel <- tempfile(fileext = ".xlsx")
  
  #se extraen los datos de la descarga
  
  while(class(try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T))=="try-error"){
    r <- httr::GET(link,
                   httr::add_headers(
                     Host="totoro.banrep.gov.co",
                     `User-Agent`="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
                     Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                     `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
                     `Accept-Encoding` = "gzip, deflate",
                     Connection = "keep-alive"
                   ))
    #se pasan a formato excel
    bin <- httr::content(r, "raw")
    writeBin(bin, path_excel)
    
    #se leen
    d <- try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = T),silent=T)
  }
  #se borra el excel
  unlink(path_excel)
  
  #SI CAMBIA EL FORMATO DE LOS EXCELES ES POSIBLE QUE HAYA QUE MODIFICAR ESTO
  #se arregla el formato
  ##se dejan solo las fechas y el ipc (primeras dos columnas)
  d <- d[,1:2]
  ##se deja de una vez solo lo que no sea NA en ninguna de las dos columnas
  ##asi se borra tanto lo que era texto antes como lo que no tiene dato
  d <- d[stats::complete.cases(d),]
  ##se quita la primera fila
  d <- d[-1,]
  ##se ponen los nombres a las columnas
  names(d) <- c("Fecha","Colcap")
  ##se pasa a formato fecha
  d$Fecha <- as.Date(d$Fecha)
  ##se pasa a formato numerico
  d$Colcap <- as.numeric(d$Colcap)
  
  #se ordena
  d <- d[order(d$Fecha),]
  #se quitan los nombres de las filas
  rownames(d) <- NULL
  #se vuelven numeros las tasas
  d[,2] <- as.numeric(d[,2])
  #se anuncia cuantos datos se consiguieron
  # print(paste0("Se obtuvo datos para el Colcap desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  # print("Fuente: Banco de la Republica de Colombia")
  message(paste0("Se obtuvo datos para el Colcap desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se retorna el data frame
  return(d)
  
}

#' Colombian Central Bank's Policy Rate extraction
#'
#' Function to extract the Colombian Central Bank's Policy Rate time serie from the Colombian Central Bank.
#' @return The dataframe with dates and the Policy Rate.
#' @examples
#' \dontrun{
#' intRate <- get.TasaIntBanRep();
#' }
#' @export
get.TasaIntBanRep <- function(){
  
  #link del excel del ipc del banrep
  link <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20Tasa%20de%20intervenci%C3%B3n%20de%20pol%C3%ADtica%20monetaria%2F1.2.TIP_Serie%20hist%C3%B3rica%20diaria%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1"
  
  
  #se hace un print de que inicio el proceso
  # print("Extrayendo datos, puede tomar unos minutos")
  message("Extrayendo datos, puede tomar unos minutos")
  #se crea un archov temporal
  path_excel <- tempfile(fileext = ".xlsx")
  
  #se extraen los datos de la descarga
  
  while(class(try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T))=="try-error"){
    r <- httr::GET(link,
                   httr::add_headers(
                     Host="totoro.banrep.gov.co",
                     `User-Agent`="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
                     Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                     `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
                     `Accept-Encoding` = "gzip, deflate",
                     Connection = "keep-alive"
                   ))
    #se pasan a formato excel
    bin <- httr::content(r, "raw")
    writeBin(bin, path_excel)
    
    #se leen
    d <- try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = T),silent=T)
  }
  #se borra el excel
  unlink(path_excel)
  
  ##se borra desde la posicion que dice Fecha
  posQuitar <- grep("Fecha",d[,1])
  d <- d[-c(1:posQuitar),]
  ##se quita lo que no este completo
  d <- d[stats::complete.cases(d),]
  ##se convierte en fecha la primera columna
  d[,1] <- as.Date(d[,1])
  ##se cambian los nombres
  names(d) <- c("Fecha","tasaIntBanRep_%")
  #se ordena
  d <- d[order(d$Fecha),]
  #se quitan los nombres de las filas
  rownames(d) <- NULL
  #se vuelven numeros las tasas
  d[,2] <- as.numeric(d[,2])
  #se anuncia cuantos datos se consiguieron
  # print(paste0("Se obtuvo datos para la Tasa de intervencion BanRep desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  # print("Fuente: Banco de la Republica de Colombia")
  message(paste0("Se obtuvo datos para la Tasa de intervencion BanRep desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(d)
  
}

#' IBR extraction
#'
#' Function to extract the nominal IBR rate time serie from the Colombian Central Bank.
#' @param nom The interest rate period. \cr
#' The periods available are: \cr
#' \itemize{
#'  \item ON: Overnight
#'  \item 1M: 1 Month
#'  \item 3M: 3 Months
#'  \item 6M: 6 Months
#' }
#' Default is "ON".
#' @return The dataframe with dates and the IBR.
#' @examples
#' \dontrun{
#' ON <- get.IBR("ON");
#' M1 <- get.IBR("1M");
#' M3 <- get.IBR("3M");
#' M6 <- get.IBR("6M");
#' }
#' @export

get.IBR <- function(nom = "ON"){
  
  #se buscan la posicion de los nodos que se quieren extraer
  posNodos <- grep(paste(nom,collapse="|"),c("ON","1M", "3M", "6M"))
  
  #Son los links de descargade cada uno de los nodos "ON","1M", "3M", "6M".
  #Si cambian los links hay que cambiar este vector
  links <- c("https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20IBR%2F%201.1.IBR_Plazo%20overnight%20nominal%20para%20un%20rango%20de%20fechas%20dado%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1",
             "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20IBR%2F%201.2.IBR_Plazo%20un%20mes%20nominal%20para%20un%20rango%20de%20fechas%20dado%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1",
             "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20IBR%2F%201.3.IBR_Plazo%20tres%20meses%20nominal%20para%20un%20rango%20de%20fechas%20dado%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1",
             "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&Path=%2fshared%2fSeries%20Estad%C3%ADsticas_T%2f1.%20IBR%2f1.5.IBR_Plazo%20seis%20meses%20nominal%20para%20un%20rango%20de%20fechas%20dado%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1"
  )
  
  #se sacan solo los nodos que se quieren
  link <- links[posNodos]
  
  #se hace un print de que inicio el proceso
  # print("Extrayendo datos, puede tomar unos minutos")
  message("Extrayendo datos, puede tomar unos minutos")
  #se crea un archov temporal
  path_excel <- tempfile(fileext = ".xlsx")
  
  #se extraen los datos de la descarga
  
  while(class(try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T))=="try-error"){
    r <- httr::GET(link,
                   httr::add_headers(
                     Host="totoro.banrep.gov.co",
                     `User-Agent`="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
                     Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                     `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
                     `Accept-Encoding` = "gzip, deflate",
                     Connection = "keep-alive"
                   ))
    #se pasan a formato excel
    bin <- httr::content(r, "raw")
    writeBin(bin, path_excel)
    
    #se leen
    d <- try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = T),silent=T)
  }
  #se borra el excel
  unlink(path_excel)
  
  #SI CAMBIA EL FORMATO DE LOS EXCELES ES POSIBLE QUE HAYA QUE MODIFICAR ESTO
  #se dejan solo las fechas y la tasa nominal
  ##se busca la palabra fecha en la primera columna
  posIniFilas <- grep("^fecha",tolower(d[,1]))
  ##una fila arriba de esta se busca la tasa nominal
  posCol <- grep("nominal",tolower(d[posIniFilas-1,]))
  ##se saca ese pedazo del excel (la columna de fechas y la de tasa nominal sin titulos)
  d <- d[(posIniFilas+1):nrow(d),c(1,posCol)]
  
  #se arregla el formato
  ##se arreglan los nombres de las columnas
  names(d) <- c("Fecha", paste0(nom,"_%"))
  ##se cambian las comas por puntos y se quitan los % para volverlo numero
  d[,2] <- gsub(x = d[,2], pattern = ",", ".")
  d[,2] <- gsub(x = d[,2], pattern = "%", "")
  d[,2] <- as.numeric(d[,2])
  ##se divide en 100 para que quede como una tasa normal
  #d[,2] <- (d[,2])/100
  ##se dejan solo los que tengan fecha y tasa
  d <- d[stats::complete.cases(d),]
  nominal <- d
  #se dejan solo las fechas que tienen dato para todas las tasas
  nominal <- nominal[stats::complete.cases(nominal),]
  #se convierte en fecha la variable de fecha
  nominal$Fecha <- as.Date(nominal$Fecha)
  #se ordena
  nominal <- nominal[order(nominal$Fecha),]
  #se quitan los nombres de las filas
  rownames(nominal) <- NULL
  #se anuncia cuantos datos se consiguieron
  # print(paste0("Se obtuvo datos para la IBR  ",nom," desde ", nominal$Fecha[1], " hasta ", nominal$Fecha[nrow(nominal)] ))
  # print("Fuente: Banco de la Republica de Colombia")
  message(paste0("Se obtuvo datos para la IBR  ",nom," desde ", nominal$Fecha[1], " hasta ", nominal$Fecha[nrow(nominal)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(nominal)
  
}

#' Colombian Assets extraction
#'
#' Function to extract the price and volume time series of some Colombian assets from the "Bolsa de Valores de Colombia" (BVC).
#' If it takes more than 5 minutes is because the BVC's Server is not correctly working and it is better to try later.
#' @param accion The asset's ticket. \cr
#' The assets available are: \cr
#'  \itemize{
#'  \item Bancolombia: "BCOLOMBIA";
#'  \item Ecopetrol: "ECOPETROL";
#'  \item Exito: "EXITO";
#'  \item Avianca: "AVIANCA";
#'  \item Grupo Sura: "GRUPOSURA";
#'  \item Grupo Aval: "GRUPOAVAL";
#'  \item ETB: "ETB";
#'  }
#' @param verbose print the dates already extracted. Default FALSE.
#' Default is "BCOLOMBIA".
#' @return The dataframe with dates and the asset prices and volume.
#' @examples
#' \dontrun{
#' BCOLOMBIA <- get.Acciones("BCOLOMBIA");
#' ECOPETROL <- get.Acciones("ECOPETROL");
#' EXITO <- get.Acciones("EXITO");
#' AVIANCA <- get.Acciones("AVIANCA");
#' }
#' @export
get.Acciones <- function(accion="BCOLOMBIA",verbose = FALSE){
  
  #valores que se extraeran
  nom <- c("Volumen","Precio Cierre","Precio Mayor","Precio Medio","Precio Menor")
  #se define la fecha de hoy e inicial
  hoy <- as.Date(lubridate::today())
  fechaIni <- as.Date("2011-1-1")
  
  
  #solo se puede sacar datos en lapsos de 5 meses entonces se hace una secuencia
  #de cada 5 meses desde fechaIni hasta hoy
  fechasExtraer <- seq(fechaIni,hoy,by="5 months")
  ##si la ultima fecha de hoy no esta en la secuencia, se agrega
  if(fechasExtraer[length(fechasExtraer)]!=hoy){fechasExtraer = c(fechasExtraer,hoy)}
  
  #se hace un print de que inicio el proceso
  #print("Extrayendo datos, puede tomar unos minutos")
  message("Extrayendo datos, puede tomar unos minutos")
  #se crea un archov temporal
  path_excel <- tempfile(fileext = ".xlsx")
  
  listaAccion <- lapply(1:(length(fechasExtraer)-1),function(x){
    
    #link del excel de la accion del banrep
    link <- paste0("https://www.bvc.com.co/mercados/DescargaXlsServlet?archivo=acciones_detalle&nemo=",
                   accion,"&tipoMercado=1&fechaIni=",fechasExtraer[x]+1,"&fechaFin=",
                   fechasExtraer[x+1])
    if(verbose){
      cat(paste("Extrayendo de",fechasExtraer[x]+1,"hasta",fechasExtraer[x+1]))
    }
    
    
    
    # #se extraen los datos
    # r <- httr::GET(link,
    #          httr::add_headers(
    #            `User-Agent`="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
    #            Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    #            `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
    #            `Accept-Encoding` = "gzip, deflate",
    #            Connection = "keep-alive"
    #          ))
    # #se pasan a formato excel
    # bin <- httr::content(r, "raw")
    # writeBin(bin, path_excel)
    
    while(class(try(openxlsx::read.xlsx(path_excel, sheet = 1),silent=T))=="try-error"){
      r <- httr::GET(link,
                     httr::add_headers(
                       Host="totoro.banrep.gov.co",
                       `User-Agent`="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
                       Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                       `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
                       `Accept-Encoding` = "gzip, deflate",
                       Connection = "keep-alive"
                     ))
      #se pasan a formato excel
      bin <- httr::content(r, "raw")
      writeBin(bin, path_excel)
    }
    
    #se leen
    d <- try(readxl::read_xls(path_excel, sheet = 1),silent=T)
    
    if(class(d)[1]=="try-error"){
      #no deberia pasar
      return(NA)
    }else{
      d <- suppressWarnings(data.frame(d))
      
      ##se pasa a formato fecha las fechas
      d$fecha <- as.Date(d$fecha)
      
      #se ordena
      d <- d[order(d$fecha),]
      
      d
      
      
    }
    
    
  })
  unlink(path_excel)
  
  
  listaAccion <- do.call(rbind,listaAccion)
  
  #SI CAMBIA EL FORMATO DE LOS EXCELES ES POSIBLE QUE HAYA QUE MODIFICAR ESTO
  #se arregla el formato
  ##se quitan variable que no se usan
  listaAccion <- listaAccion[,-c(1,3,9,10)]
  listaAccion <- data.frame(listaAccion)
  ##se cambian los nombres
  names(listaAccion) <- c("Fecha","Volumen","Precio Cierre","Precio Mayor",
                          "Precio Medio","Precio Menor")
  listaAccion <- listaAccion[,c("Fecha",nom)]
  ##se quitan los casos donde hayan NA
  listaAccion <- listaAccion[stats::complete.cases(listaAccion),]
  ##se quitan los que tengan solo ceros en todo menos la fecha
  listaAccion <- listaAccion[!rowSums(listaAccion[,-1])==0,]
  ##se quitan los nombres de las filas
  rownames(listaAccion) <- NULL
  
  #se anuncia cuantos datos se consiguieron
  # print(paste0("Se obtuvo datos para el ", accion, " desde ", listaAccion$Fecha[1], " hasta ", listaAccion$Fecha[nrow(listaAccion)] ))
  # print("Fuente: Bolsa de Valores de Colombia")
  message(paste0("Se obtuvo datos para el ", accion, " desde ", listaAccion$Fecha[1], " hasta ", listaAccion$Fecha[nrow(listaAccion)] ))
  message("Fuente: Bolsa de Valores de Colombia")
  #se returna el data frame
  return(listaAccion)
  
}


