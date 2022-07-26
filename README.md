# Scrapping Colombian Macrodata

## Spanish version

Construir modelos econométricos de variables macrofinancieras colombianas tiene como uno de sus principales retos la obtención de datos. 

Es cierto que en su mayoría se encuentran gratis en internet. Sin embargo, su búsqueda, importación y armonización suele ser un paso que retrasa de la producción de modelos :hourglass:.

Con esto en mente, este repositorio pretende ser un aporte a la creación de modelos para Colombia, proveyendo un set de funciones de webscrapping de algunos indicadores de interés. Todas las fuentes que se utilizan son públicas y gratis, pero la ventaja de estas funciones es que directamente descargan y armonizan en el ambiente de R sin necesidad de importar o descargar archivos adicionales ¡Solo necesita conexión a internet!

En futuras etapas este repositorio se convertirá en un paquete de R y su desarrollador pretende hacer una versión en Python :smile:. 

### ¿Qué encontrará en este repositorio? :pencil2:
 - **scrapping_spanish.R:**
 Encontrará las funciones de webscrapping en su versión para R.
 
 	:hammer: **packages_download:** Función para descargar y cargar los paquetes que se necesitan para correr las demás funciones.
	
	:chart_with_upwards_trend: **get.TRM:** Función para extraer la serie histórica de la TRM desde la Superintendencia Financiera.
	
	:chart_with_upwards_trend: **get.IPC:** Función para extraer la serie histórica del IPC desde el Banco de la República.
	
	:chart_with_upwards_trend: **get.TasaDesempleoCol:** Función para extraer la serie histórica de la tasa de desempleo desde el Banco de la República.
	
	:chart_with_upwards_trend: **get.Colcap:**  Función para extraer la serie histórica del Colcap desde el Banco de la República.
	
	:chart_with_upwards_trend: **get.TasaIntBanRep:**  Función para extraer la serie histórica de la tasa de intervención desde el Banco de la República.
	
	:chart_with_upwards_trend: **get.IBR:**  Función para extraer la serie histórica de la IBR nominal a diferentes plazos desde el Banco de la República. Los plazos que permite esta función son:
  
	  >:pushpin: **ON:** Overnight
  
	  >:pushpin: **1M:** 1 Mes
  
	  >:pushpin: **3M:** 3 Meses
  
	  >:pushpin: **6M:** 6 Meses
	
	:chart_with_upwards_trend: **get.Acciones:** Función que extrae la serie histórica de precios y volúmenes de algunas acciones colombianas desde la Bolsa de Valores de Colombia. Las acciones que permite esta función son:
  
	>:pushpin:: **BCOLOMBIA:** Bancolombia
  
	>:pushpin: **ECOPETROL:** Ecopetrol
  
	>:pushpin: **EXITO:** Éxito
  
	>:pushpin: **AVIANCA:** Avianca
  
	>:pushpin: **GRUPOSURA:** Grupo Sura
  
	>:pushpin: **GRUPOAVAL:** Grupo Aval
  
	>:pushpin: **ETB:** ETB

- **example_scrapping_macro.R:**
Encontrará un ejemplo de cómo aplicar estas funciones con un modelo muy simple de predicción de la inflación mensual del 2019 :black_nib:.

## English version

One of the main challenges in producing econometric models for Colombian macro-financial variables is obtaining the data.

Most of the variables are indeed available on the internet for free. However, searching, importing and harmonizing this information is a step that slows down the models' production :hourglass:.

This repository aims to contribute to the econometric models' production by providing a set of webscrapping functions of some of the main macrofinancial indicators. All the sources are public and free, but the advantage of these functions is that they directly download and harmonize the information in R's environment. No need to import or download additional files. You only need an internet connection!

In the foreseeable future, the developer of this repository intends to create an R package with these functions and also a Python version :smile:. 

### What´s inside? :pencil2:
 - **scrapping_spanish.R:**
 The webscrapping function for R.
 
 	:hammer: **packages_download:** Function to download and load the packages needed for the following functions.
	
	:chart_with_upwards_trend: **get.TRM:** Function to extract the TRM time serie from the Colombian Financial Supervision Office.
	
	:chart_with_upwards_trend: **get.IPC:** Function to extract the Colombian CPI time serie from the Colombian Central Bank.
	
	:chart_with_upwards_trend: **get.TasaDesempleoCol:** Function to extract the Colombian unemployment rate time serie from the Colombian Central Bank.
	
	:chart_with_upwards_trend: **get.Colcap:**  Function to extract the Colcap time serie from the Colombian Central Bank.
	
	:chart_with_upwards_trend: **get.TasaIntBanRep:**  Function to extract the Colombian Central Bank's Policy Rate time serie from the Colombian Central Bank.
	
	:chart_with_upwards_trend: **get.IBR:**  Function to extract the nominal IBR rate time serie from the Colombian Central Bank. The periods available are:
  
	  >:pushpin: **ON:** Overnight
  
	  >:pushpin: **1M:** 1 Month
  
	  >:pushpin: **3M:** 3 Months
  
	  >:pushpin: **6M:** 6 Months
	
	:chart_with_upwards_trend: **get.Acciones:** Function to extract the price and volume time series of some Colombian assets from the "Bolsa de Valores de Colombia". The assets available are:
  
	>:pushpin:: **BCOLOMBIA:** Bancolombia
  
	>:pushpin: **ECOPETROL:** Ecopetrol
  
	>:pushpin: **EXITO:** Éxito
  
	>:pushpin: **AVIANCA:** Avianca
  
	>:pushpin: **GRUPOSURA:** Grupo Sura
  
	>:pushpin: **GRUPOAVAL:** Grupo Aval
  
	>:pushpin: **ETB:** ETB

- **example_scrapping_macro.R:**
An example of the usage of these functions on a simple prediction model of 2019's monthly inflation rate :black_nib:.
