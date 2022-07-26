###########################################
#'                                        #
#'     Ejemplo del uso del paquete,       #
#'     prediccion basica de la inflacion  #
#'     mensual colombiana                 #
#'                                        #
#'     Author: PACA                       #
#'#########################################

#' We want to predict the colombian monthly inflation rate from 2019, 
#' using some monthly macrodata.
#' Vamos a predecir la inflacion mensual colombiana de 2019 usando datos macro.

rm(list=ls())
# Setting the path (Do not run)
# Definiendo la ruta (No correr)
# path <- gsub("example_scrapping_macro.R","",rstudioapi::getActiveDocumentContext()$path)
# setwd(path)
# Loading the required packages y loading the functions
# Cargando paquetes y script de funciones
source("scrapping_spanish.R",encoding = "utf-8")
packages_download()
# Some additionals for the example
# Algunos adicionales para el ejemplo
if (!require(xts))install.packages("xts");library(xts)
if (!require(forecast))install.packages("forecast");library(forecast)
if (!require(ggplot2))install.packages("ggplot2");library(ggplot2)
# For the example we'll use the Colombian CPI, TRM, IBR ON, unemployment rate and Colcap
# Utilizaremos para el ejemplo el IPC, la TRM, IBR ON, tasa de desempleo y el Colcap
ipc <- get.IPC()
trm <- get.TRM()
ibr <- get.IBR()
colcap <- get.Colcap()
unemp <- get.TasaDesempleoCol()
# We get the monthly inflation rate from the CPI
# Hallamos la inflacion mensual desde el IPC
inflation <- ipc
inflation[,2] <- c(NA,inflation[-1,2]/inflation[-nrow(inflation),2] - 1)
# We get trm and colcap returns, and ibr and unemployment rate changes
# Hallamos los retornos de la trm y el colcap, y las diferencias de la ibr y la
# tasa de desempleo
trm_ret <- trm
trm_ret[,2] <- c(NA,trm_ret[-1,2]/trm_ret[-nrow(trm_ret),2] - 1)
colcap_ret <- colcap
colcap_ret[,2] <- c(NA,colcap_ret[-1,2]/colcap_ret[-nrow(colcap_ret),2] - 1)
ibr_diff <- ibr
ibr_diff[,2] <- c(NA,diff(ibr_diff[,2]/100))
unemp_diff <- unemp
unemp_diff[,2] <- c(NA,diff(unemp_diff[,2]/100))
# Creating a xts of the daily data
# Ponemos los datos diarios en un mismo xts
daily_xts <- xts(trm_ret[,2],order.by = trm_ret[,1])
daily_xts <- merge.xts(daily_xts,xts(colcap_ret[,2],order.by = colcap_ret[,1]))
daily_xts <- merge.xts(daily_xts,xts(ibr_diff[,2],order.by = ibr_diff[,1]))
daily_xts <- daily_xts[complete.cases(daily_xts)]
colnames(daily_xts) <- c("trm_ret","colcap_ret","ibr_diff")
# for getting monthly data we are going to usea mean function
# Para mensualizar los datos aplicamos la funcion promedio
monthly_xts <- apply.monthly(daily_xts,mean)
# Fixing dates to the last of the month
# Arreglando las fechas para que sean las de final de mes
dates <- index(monthly_xts)
dates <- as.Date(paste(year(dates),month(dates),1,sep="-"))%m+%months(1) - 1
index(monthly_xts) <- dates
# We add unemployment rate to the xts
# Agregamos la tasa de desempleo al xts
monthly_xts <- merge.xts(monthly_xts,xts(unemp_diff[,2],order.by = unemp_diff[,1]))
colnames(monthly_xts)[ncol(monthly_xts)] <- "unemp_diff"
monthly_xts <- monthly_xts[complete.cases(monthly_xts)]
# To avoid data leaking in this simple model, we are going to use the lags
# Para evitar usar informacion que se supone no tendriamos en el momento del tiempo,
# utilizaremos los lags
monthly_xts <- lag(monthly_xts)
# Finally we add monthly dummies to remove seasonality
# Finalmente agregamos dummies mensuales para remover estacionalidad
monthly_xts <- merge.xts(monthly_xts,
                         xts(seasonaldummy(ts(monthly_xts[,1],f=12)),
                             order.by=index(monthly_xts)))
# We add the inflation
# Agregamos la inflacion
monthly_xts <- merge.xts(monthly_xts,xts(inflation[,2],order.by = inflation[,1]))
monthly_xts <- monthly_xts[complete.cases(monthly_xts)]
colnames(monthly_xts)[ncol(monthly_xts)] <- "inflation"

# Now we are ready for the model
# Ahora estamos listos para el modelo

# We  only take the data from 2008 to 2019
# Dejamos los datos hasta el 2019
monthly_xts <- monthly_xts[index(monthly_xts)<=as.Date("2019-12-31")]
# We split the data set in training and test
# Dividimos los datos en entrenamiento y prueba
training <- monthly_xts[index(monthly_xts)<=as.Date("2018-12-31")]
test <- monthly_xts[index(monthly_xts)>as.Date("2018-12-31")]
# We use auto.arima to get a good prediction model
# Usamos autoarima para generar un buen modelo
model <- auto.arima(training[,"inflation"],xreg = training[,-ncol(training)])
# Getting a quick prediction using forecast
# Obtenemos una rapida prediccion usando forecast
pred <- forecast(model,xreg = test[,-ncol(test)])
# Quick plot to see the results
# Grafico rapido para ver los resultados
df <- data.frame(x = 1:12,
                 ypred = as.vector(pred$mean),
                 lb = as.vector(pred$lower),
                 ub = as.vector(pred$upper),
                 y = as.vector(test[,ncol(test)]))
ggplot(df,aes(x=x)) +
  geom_errorbar(aes(ymin = lb, ymax = ub)) +
  geom_point(aes(y=y),size = 4) +
  geom_line(aes(y=ypred),color="red")

# Not that bad for the number of observation :)
# Nada mal para el numero de observaciones :)