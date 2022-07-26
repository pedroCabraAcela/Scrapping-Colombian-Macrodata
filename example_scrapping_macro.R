
# Setting the path 
# Definiendo la ruta
path <- gsub("example_scrapping_macro.R","",rstudioapi::getActiveDocumentContext()$path)
setwd(path)
# Loading the required packages y loading the functions
# Cargando paquetes y script de funciones
source("scrapping_spanish.R",encoding = "utf-8")
packages_download()
if (!require(xts))install.packages("xts");library(xts)
# Some additionals for the example
# Algunos adicionales para el ejemplo

# For the example we'll use Colombian CPI, TRM, IBR ON and olcap
# Utilizaremos para el ejemplo el IPC, la TRM, IBR ON y el olcap
ipc <- get.IPC()
trm <- get.TRM()
ibr <- get.IBR()
colcap <- get.Colcap()
