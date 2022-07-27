# -*- coding: utf-8 -*-
"""
Created on Wed Jul 27 09:56:25 2022

@author: PACA
"""

import pandas as pd
import numpy as np
import urllib
import csv

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


