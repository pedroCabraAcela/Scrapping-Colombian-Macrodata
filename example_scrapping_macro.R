
# Setting the path 
# Definiendo la ruta
path <- gsub("example_scrapping_macro.R","",rstudioapi::getActiveDocumentContext()$path)
setwd(path)
# Loading the required packages y loading the functions
# Cargando paquetes y script de funciones
source("scrapping_spanish.R",encoding = "utf-8")
packages_download()
# Some additionals for the example
# Algunos adicionales para el ejemplo

# For the example we'll use Colombian CPI, TRM, IBR ON and unemployment rate
# Utilizaremos para el ejemplo el IPC, la TRM, IBR ON y la tasa de desempleo de Colombia
ipc <- get.IPC()
trm <- get.TRM()
ibr <- get.IBR()
unemp <- get.TasaDesempleoCol()
