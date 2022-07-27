# -*- coding: utf-8 -*-
"""
Created on Wed Jul 27 09:56:25 2022

@author: PACA
"""

import pandas as pd
import numpy as np
import csv
import requests,shutil
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
    #se retorna
    return(TRM)

#########################################
# IPC: Banco de la republica de Colombia
##########################################

def get_IPC():
    
    #url to retrieve the data from BanRep
    link = "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&NQUser=publico&NQPassword=publico123&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.5.IPC_Serie_variaciones"
    #link = "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20Meta%20de%20inflaci%C3%B3n%20base%202018%2F1.1.INF_Serie%20hist%C3%B3rica%20Meta%20de%20inflaci%C3%B3n%20IQY"
    print("Extrayendo datos, puede tomar unos minutos")
    #creating headers
    file_name = "1.2.5.IPC_Serie_variaciones.xlsx"
    headers ={}
    headers["Host"] = "totoro.banrep.gov.co"
    #headers["User-Agent"] = "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0"
    headers["User-Agent"] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'
    headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    headers["Accept-Language"] = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3"
    headers["Accept-Encoding"] = "gzip, deflate"
    headers["Connection"] = "keep-alive"
    headers["Content-Type"] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    headers["Content-Disposition"] = "attachment;filename=" + file_name

    # #requesting the url
    # response=requests.get(url=link, headers=headers)
    # response=response.content
    
    
    # import urllib3
    # http = urllib3.PoolManager()
    # r = http.request('GET', link, preload_content=False)
    # r.read()


    # with open('test.xlsx', 'wb') as out_file:
    #     shutil.copyfileobj(response.raw, out_file)
    # del response
