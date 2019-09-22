import pandas as pd 
import numpy as np
from sklearn.svm import SVR
import matplotlib.pyplot as plt 
import csv

dates = []
prices = []

# Load the data from csv file downloaded from Yahoo Finance 

def get_data(filename):

    with open(filename,'r') as csvfile:
        csvFileReader = csv.reader(csvfile)
        next(csvFileReader)
        for row in csvFileReader:

            if row[1] != 'null':

                dates.append(int(row[0].split('-')[2]))
                prices.append(float(row[1]))

    return

# Design the model
def predict_prices(dates,prices,x):

    dates = np.reshape(dates,(len(dates),1))

    svr_lin = SVR(kernel = 'linear',C=1e3)
    svr_poly = SVR(kernel = 'poly',C=1e3, degree =2)
    svr_rbf = SVR(kernel = 'rbf',C=1e3, gamma =0.1)

    svr_lin.fit(dates,prices)
    svr_poly.fit(dates,prices)
    svr_rbf.fit(dates,prices)

    #print(dates)

    plt.scatter(dates,prices,color='black',label='Data')
    plt.plot(dates,svr_rbf.predict(dates),color='red',label='RBF_model')
    plt.plot(dates,svr_lin.predict(dates),color='green',label='Linear_model')
    plt.plot(dates,svr_poly.predict(dates),color='blue',label='Polynomial_model')
    plt.xlabel('Date')
    plt.ylabel('Price')
    plt.title('Support Vector Regression')
    plt.legend()
    plt.show()
    #print(svr_rbf.predict(x)[0],svr_lin(x)[0],svr_rbf(x)[0])
    #print(">>>>>prediction")
    return svr_lin.predict(x)[0],svr_poly.predict(x)[0],svr_rbf.predict(x)[0]

get_data('NSEI_Aug2019_Daily.csv')

pred_dates = [[31]]

predicted_prices = predict_prices(dates,prices,pred_dates)
print(predicted_prices)

