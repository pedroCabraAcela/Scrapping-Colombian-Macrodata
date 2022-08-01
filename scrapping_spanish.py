# -*- coding: utf-8 -*-
"""
Created on Wed Jul 27 09:56:25 2022

@author: PACA
"""

import pandas as pd
import numpy as np
import csv
import requests,shutil
import bs4
import tempfile
from requests_html import AsyncHTMLSession
import asyncio
import warnings
#pip install certifi
###############################################
# TRM: Superintendencia financiera colombiana
##############################################

def get_TRM():
    # Function to extract the TRM (COP/USD) time serie from the Colombian Financial Supervision Office.
    
    print("Extrayendo datos, puede tomar unos minutos")
    # Extracting data from Colombian Financial Supervision Office.
    TRM = pd.read_csv("https://www.datos.gov.co/api/views/32sa-8pi3/rows.csv?accessType=DOWNLOAD")
    # leaving date and value columns
    TRM = TRM[['VIGENCIAHASTA','VALOR']]
    # date to datetime format
    TRM['VIGENCIAHASTA'] = pd.to_datetime(TRM['VIGENCIAHASTA'],format="%d/%m/%Y").dt.normalize()
    # sorting by date
    TRM = TRM.sort_values(by='VIGENCIAHASTA',ignore_index=True)
    # changing the column names
    TRM.columns = ["Fecha", "TRM"]
    #printing the summary of the results
    print("Se obtuvo datos para la TRM desde",TRM['Fecha'][0].date(), "hasta", TRM['Fecha'][len(TRM['Fecha'])-1].date())
    print("Fuente: Superintendencia Financiera Colombiana")
    #return
    return(TRM)

#########################################
# IPC: Dane
##########################################

def get_IPC_dane():
    # Function to extract the IPC time serie from DANE.
    #url to retrieve the data from DANE
    url = "https://www.dane.gov.co/files/investigaciones/ipc/jun22/IPC_Indices.xlsx"  
    #getting the excel
    print("Extrayendo datos, puede tomar unos minutos")
    resp = requests.get(url)
    #writting it in a tempfile
    tempdir = tempfile.mkdtemp()
    path_excel = tempdir + "\\" + 'data.xlsx'
    output = open(path_excel, 'wb')
    output.write(resp.content)
    output.close()
    data = pd.read_excel(path_excel)
    shutil.rmtree(tempdir)
    #removing all the rows that we dont need
    pos1 = np.where(np.array(data.iloc[:,0])=="Mes")[0][0] #first row
    pos2 = np.where(np.array(data.iloc[:,0])=="Diciembre")[0][0] #last row
    #cutting the data frame
    data = data.iloc[pos1:(pos2+1),]
    data.columns = data.iloc[0]
    data = data.rename_axis(index=None)
    data.reset_index(inplace=True, drop=True)
    data = data.drop(0,axis=0)    
    data.reset_index(inplace=True, drop=True)
    #form wide to long
    data = pd.melt(data, id_vars='Mes')
    data.columns = ["Mes","Ano","IPC"]
    #replacing month with the corresponding number and years to int
    data.iloc[:,1] = data.iloc[:,1].astype(int)
    months = ["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]
    data["month_num"] = int()
    data['year'] = data['Ano'] #just for reference
    # moving one month for making easier the following steps
    for i in range(12):
        if (i + 2) <= 12:
            data.loc[data["Mes"]==months[i],"month_num"] = int(i + 2)
        else:
            #december + 1 is january from the next year
            data.loc[data["Mes"]==months[i],"month_num"] = 1
            data.loc[data["Mes"]==months[i],"year"] = data.loc[data["Mes"]==months[i],"year"] + 1
    #creating a column of the string of date
    data["date_str"] = data['year'].astype(str) + "-" + data['month_num'].astype(str) + "-" + "1"
    #converting to date
    data["date_str"] = pd.to_datetime(data['date_str'],format="%Y-%m-%d").dt.normalize()
    #minus one day to have the right date
    data["date_str"] = data["date_str"] - pd.Timedelta(days=1)
    #only the data we are gonna use
    data = data[["date_str","IPC"]]
    #dropping na
    data = data.dropna()
    #sort by date
    data = data.sort_values(by='date_str',ignore_index=True)
    data.columns = ["Fecha", "IPC"]
    #printing the summary of the results
    print("Se obtuvo datos para el IPC desde",data['Fecha'][0].date(), "hasta", data['Fecha'][len(data['Fecha'])-1].date())
    print("Fuente: DANE")
    #return
    return(data)


######################################
# Colcap: Banco de la republica de Colombia
######################################
def get_Colcap():
    # Function to extract the Colcap time serie from BanRep.
    #url to retrieve the data from BanRep    
    url = "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20%C3%8Dndices%20de%20mercado%20burs%C3%A1til%20colombiano%2F1.1.%20IGBC%2C%20IBB%20e%20IBOMED%2F1.1.1.IMBC_COLCAP_IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1"
    #headers
    headers = {}
    headers["Host"]="totoro.banrep.gov.co"
    headers["User-Agent"] = "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0"
    headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    headers["Accept-Language"] = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3"
    headers["Accept-Encoding"] = "gzip, deflate"
    headers["Connection"] = "keep-alive"
    #extracting the url
    print("Extrayendo datos, puede tomar unos minutos")
    asession = AsyncHTMLSession()
    async def main(url,headers):
        return(await asession.get(url,headers=headers))
    r = asyncio.run(main(url,headers))
    #r = await asession.get(url,headers=headers)
    warnings.filterwarnings("ignore")
    r.html.arender()
    #writting it in a tempfile 
    tempdir = tempfile.mkdtemp()
    path_excel = tempdir + "\\" + 'data.xlsx'
    output = open(path_excel, 'wb')
    output.write(r.content)
    output.close()
    data = pd.read_excel(path_excel)
    shutil.rmtree(tempdir)
    #leaving the rows we need    
    pos1 = np.where(np.array(data.iloc[:,1])=="Valor COLCAP")[0][0]
    data = data.iloc[pos1:,:]
    #changing column names
    data.columns = data.iloc[0]
    data = data.rename_axis(index=None)
    data.reset_index(inplace=True, drop=True)
    data = data.drop(0,axis=0)
    data.reset_index(inplace=True, drop=True)
    #leaving only the two first columns and dropping na
    data = data.iloc[:,0:2]
    data = data.dropna()
    data.columns = ["Fecha", "Colcap"]
    #to date
    data["Fecha"] = pd.to_datetime(data['Fecha']).dt.normalize()
    #sorting just in case
    data = data.sort_values(by='Fecha',ignore_index=True)
    #printing the summary of the results
    print("Se obtuvo datos para el Colcap desde",data['Fecha'][0].date(), "hasta", data['Fecha'][len(data['Fecha'])-1].date())
    print("Fuente: Banco de la Republica de Colombia")
    #return
    return(data)


######################################
# Tasa intervencion: Banco de la republica de Colombia
######################################
def get_TasaIntBanRep():
    # Function to extract the Central Bank's Policy Rate time serie from the Colombian Central Bank.
    #url to retrieve the data from BanRep    
    url = "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20Tasa%20de%20intervenci%C3%B3n%20de%20pol%C3%ADtica%20monetaria%2F1.2.TIP_Serie%20hist%C3%B3rica%20diaria%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1"
    #headers
    headers = {}
    headers["Host"]="totoro.banrep.gov.co"
    headers["User-Agent"] = "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0"
    headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    headers["Accept-Language"] = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3"
    headers["Accept-Encoding"] = "gzip, deflate"
    headers["Connection"] = "keep-alive"
    #extracting the url
    print("Extrayendo datos, puede tomar unos minutos")
    asession = AsyncHTMLSession()
    async def main(url,headers):
        return(await asession.get(url,headers=headers))
    r = asyncio.run(main(url,headers))
    #r = await asession.get(url,headers=headers)
    warnings.filterwarnings("ignore")
    r.html.arender()
    #writting it in a tempfile 
    tempdir = tempfile.mkdtemp()
    path_excel = tempdir + "\\" + 'data.xlsx'
    output = open(path_excel, 'wb')
    output.write(r.content)
    output.close()
    data = pd.read_excel(path_excel)
    shutil.rmtree(tempdir)
    #leaving the rows we need    
    pos1 = np.where(np.array(data.iloc[:,0])=="Fecha (dd/mm/aaaa)")[0][0]
    data = data.iloc[pos1:,:]
    #changing column names
    data.columns = data.iloc[0]
    data = data.rename_axis(index=None)
    data.reset_index(inplace=True, drop=True)
    data = data.drop(0,axis=0)
    data.reset_index(inplace=True, drop=True)
    #leaving only the two first columns and dropping na
    data = data.iloc[:,0:2]
    data = data.dropna()
    data.columns = ["Fecha", "tasaIntBanRep_%"]
    #to date
    data["Fecha"] = pd.to_datetime(data['Fecha']).dt.normalize()
    #sorting by date
    data = data.sort_values(by='Fecha',ignore_index=True)
    #printing the summary of the results
    print("Se obtuvo datos para la Tasa de intervencion BanRep desde",data['Fecha'][0].date(), "hasta", data['Fecha'][len(data['Fecha'])-1].date())
    print("Fuente: Banco de la Republica de Colombia")
    #return
    return(data)

######################################
#  Tasa de desempleo en Colombia: Banco de la republica de Colombia
######################################
def get_TasaDesempleoCol():
    # Function to extract the unemployment rate time serie from the Colombian Central Bank.
    #url to retrieve the data from BanRep    
    url = "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20Empleo%20y%20desempleo%2F1.1%20Serie%20hist%C3%B3rica%2F1.1.1.EMP_Total%20nacional%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1"
    #headers
    headers = {}
    headers["Host"]="totoro.banrep.gov.co"
    headers["User-Agent"] = "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0"
    headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    headers["Accept-Language"] = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3"
    headers["Accept-Encoding"] = "gzip, deflate"
    headers["Connection"] = "keep-alive"
    #extracting the url
    print("Extrayendo datos, puede tomar unos minutos")
    asession = AsyncHTMLSession()
    async def main(url,headers):
        return(await asession.get(url,headers=headers))
    r = asyncio.run(main(url,headers))
    #r = await asession.get(url,headers=headers)
    warnings.filterwarnings("ignore")
    r.html.arender()
    #writting it in a tempfile 
    tempdir = tempfile.mkdtemp()
    path_excel = tempdir + "\\" + 'data.xlsx'
    output = open(path_excel, 'wb')
    output.write(r.content)
    output.close()
    data = pd.read_excel(path_excel)
    shutil.rmtree(tempdir)
    #leaving the rows we need  
    pos1 = np.where(np.array(data.iloc[:,1].astype(str).str.contains("^Tasa")))[0][0]
    data = data.iloc[pos1:,:]
    #changing column names
    data.columns = data.iloc[0]
    data = data.rename_axis(index=None)
    data.reset_index(inplace=True, drop=True)
    data = data.drop(0,axis=0)
    data.reset_index(inplace=True, drop=True)
    #leaving only the first and third columns and dropping na
    data = data.iloc[:,[0,2]]
    data = data.dropna()
    data.columns = ["Fecha", "tasa_desempleo_%"]
    #creating a date with Fecha
    data['fecha'] = pd.to_datetime((data['Fecha'].astype(str) + "-1"),format="%Y-%m-%d").dt.normalize()
    #moving to the last day of the month
    data['fecha'] = data['fecha'] - pd.Timedelta(days=1) + pd.DateOffset(months=1)
    #only two columns again
    data['Fecha'] = data['fecha']
    data = data[["Fecha", "tasa_desempleo_%"]]
    #sorting by date
    data = data.sort_values(by='Fecha',ignore_index=True)
    #printing the summary of the results
    print("Se obtuvo datos para la Tasa de desempleo desde",data['Fecha'][0].date(), "hasta", data['Fecha'][len(data['Fecha'])-1].date())
    print("Fuente: Banco de la Republica de Colombia")
    #return
    return(data)
######################################
# IBR: Banco de la republica de Colombia
######################################
# def get_TasaIntBanRep(nom = "ON"):
#     # Function to extract the nominal IBR rate time serie from the Colombian Central Bank. 
    
#     # links available
#     links = ["https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20IBR%2F%201.1.IBR_Plazo%20overnight%20nominal%20para%20un%20rango%20de%20fechas%20dado%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1",
#           "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20IBR%2F%201.2.IBR_Plazo%20un%20mes%20nominal%20para%20un%20rango%20de%20fechas%20dado%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1",
#           "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20IBR%2F%201.3.IBR_Plazo%20tres%20meses%20nominal%20para%20un%20rango%20de%20fechas%20dado%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1",
#           "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&Path=%2fshared%2fSeries%20Estad%C3%ADsticas_T%2f1.%20IBR%2f1.5.IBR_Plazo%20seis%20meses%20nominal%20para%20un%20rango%20de%20fechas%20dado%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1"
#           ]
    
#     # getting the url of the period from nom
#     url = links[["ON","1M", "3M", "6M"].index(nom)]
#     #headers
#     headers = {}
#     headers["Host"]="totoro.banrep.gov.co"
#     headers["User-Agent"] = "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0"
#     headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
#     headers["Accept-Language"] = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3"
#     headers["Accept-Encoding"] = "gzip, deflate"
#     headers["Connection"] = "keep-alive"
#     #extracting the url
#     print("Extrayendo datos, puede tomar unos minutos")
#     asession = AsyncHTMLSession()
#     async def main(url,headers):
#         r = await asession.get(url,headers=headers)
#         await r.html.arender()
#         return(r)
#     r = asyncio.run(main(url,headers))
#     #r = await asession.get(url,headers=headers)
#     warnings.filterwarnings("ignore")
#     r.html.arender()
#     #writting it in a tempfile 
#     tempdir = tempfile.mkdtemp()
#     path_excel = tempdir + "\\" + 'data.xlsx'
#     output = open(path_excel, 'wb')
#     output.write(r.content)
#     output.close()
#     data = pd.read_excel(path_excel)
#     shutil.rmtree(tempdir)
#     #leaving the rows we need    
#     pos1 = np.where(np.array(data.iloc[:,0])=="Fecha (dd/mm/aaaa)")[0][0]
#     data = data.iloc[pos1:,:]
#     #changing column names
#     data.columns = data.iloc[0]
#     data = data.rename_axis(index=None)
#     data.reset_index(inplace=True, drop=True)
#     data = data.drop(0,axis=0)
#     data.reset_index(inplace=True, drop=True)
#     #leaving only the two first columns and dropping na
#     data = data.iloc[:,0:2]
#     data = data.dropna()
#     data.columns = ["Fecha", "tasaIntBanRep_%"]
#     #to date
#     data["Fecha"] = pd.to_datetime(data['Fecha']).dt.normalize()
#     #sorting by date
#     data = data.sort_values(by='Fecha',ignore_index=True)
#     #printing the summary of the results
#     print("Se obtuvo datos para la Tasa de intervencion BanRep desde",data['Fecha'][0].date(), "hasta", data['Fecha'][len(data['Fecha'])-1].date())
#     print("Fuente: Banco de la Republica de Colombia")
#     #return
#     return(data)








######################################
# Acciones: Bolsa de Valores de Colombia BVC
######################################

fecha_ini = "2011-01-01"
fecha_fin = "2011-05-01"
accion = "BCOLOMBIA"

url = "https://www.bvc.com.co/mercados/DescargaXlsServlet?archivo=acciones_detalle&nemo=" 
url = url + accion + "&tipoMercado=1&fechaIni=" + fecha_ini + "&fechaFin=" + fecha_fin 
#headers
headers = {}
headers["Host"]="totoro.banrep.gov.co"
headers["User-Agent"] = "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0"
headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
headers["Accept-Language"] = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3"
headers["Accept-Encoding"] = "gzip, deflate"
headers["Connection"] = "keep-alive"
#getting the excel
resp = requests.get(url,headers=headers)
#writting it in a tempfile
tempdir = tempfile.mkdtemp()
path_excel = tempdir + "\\" + 'data.xlsx'
output = open(path_excel, 'wb')
output.write(resp.content)
output.close()
data = pd.read_excel(path_excel)
shutil.rmtree(tempdir)
              
####
from requests_html import HTMLSession
session = HTMLSession()
url = "https://totoro.banrep.gov.co/analytics/saw.dll?Go&Path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20Empleo%20y%20desempleo%2F1.1%20Serie%20hist%C3%B3rica%2F1.1.1.EMP_Total%20nacional%20IQY&lang=es&Action=Prompt"
#url = 'https://python.org/'
r = session.get(url,headers=headers)
r.html.render()
r.content




from requests_html import AsyncHTMLSession
url = "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xlsx&BypassCache=true&path=%2Fshared%2fSeries%20Estad%c3%adsticas_T%2F1.%20Empleo%20y%20desempleo%2F1.1%20Serie%20hist%C3%B3rica%2F1.1.1.EMP_Total%20nacional%20IQY&lang=es&NQUser=publico&NQPassword=publico123&SyncOperation=1"
asession = AsyncHTMLSession()
r = await asession.get(url)
await r.html.arender(wait=60)
r.content

tempdir = tempfile.mkdtemp()
path_excel = tempdir + "\\" + 'data.xlsx'
output = open(path_excel, 'wb')
output.write(r.content)
output.close()
data = pd.read_excel(path_excel)
shutil.rmtree(tempdir)
