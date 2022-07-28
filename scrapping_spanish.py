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
    # Function to extract the IPC time serie from DANE.
    #url to retrieve the data from BanRep
    url = "https://www.dane.gov.co/files/investigaciones/ipc/jun22/IPC_Indices.xlsx"  
    #getting the excel
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
    data = pd.melt(data, id_vars='Mes')
    #replacing month with the corresponding number

