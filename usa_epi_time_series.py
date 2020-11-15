import pandas as pd
from plotnine import *
import statsmodels.api as sm
import itertools
import numpy as np

#read in cleaned data, isolate the U.S., plot all causes
df= pd.read_csv("derived_data//cleaned_pop_data.csv")
usa=df.loc[df.ISO_CODE=="USA"]
usa=usa[usa.columns[1:]]
usa_melt=pd.melt(usa, id_vars=["ISO_CODE","Year","Pop"], var_name="cause", value_name="deaths")
fig=(ggplot(usa_melt, aes("Year","deaths",color="cause")))+geom_point()+geom_line()

#Isolate just the Epidemics cause for the U.S. and plot it to get a clearer picture
usa_epi=usa_melt.loc[usa_melt.cause=="Epidemics"]
usa_epi=usa_epi[["Year", "deaths"]]
epi_fig=(ggplot(usa_epi, aes("Year","deaths")))+geom_point()+geom_line()+ggtitle("Annual Deaths in the USA due to an Epidemic 1980-2017")
epi_fig.save("figures//usa_epidemics_trend.png", dpi=150)

#convert year to datetime object and set it as the index for time series analysis
usa_epi.Year=pd.to_datetime(usa_epi.Year, format="%Y")
usa_epi=usa_epi.set_index("Year")

#use an additive model from the statsmodel library to decompose the USA epidemics deaths from 1980-2017
#into the general trend, the seasonal trend, and the residuals of the data. save the plot.
decomp=sm.tsa.seasonal_decompose(usa_epi, model="additive")
d_fig=decomp.plot()
d_fig.savefig("figures//usa_epidemics_time_series_decomp.png", dpi=200)

#run grid search test to determine the optimal parameters for the SARIMAX model where p accounts for the seasonality, trend, and noise in data.
p = d = q = range(0, 2)
pdq = list(itertools.product(p, d, q))
seasonal_pdq = [(x[0], x[1], x[2], 12) for x in list(itertools.product(p, d, q))]

for param in pdq:
    for param_seasonal in seasonal_pdq:
        try:
            mod = sm.tsa.statespace.SARIMAX(usa_epi,
                                            order=param,
                                            seasonal_order=param_seasonal,
                                            enforce_stationarity=False,
                                            enforce_invertibility=False)
            results = mod.fit()
            print('ARIMA{}x{}12 - AIC:{}'.format(param, param_seasonal, results.aic))
        except:
            continue

#build model. Optimal parameters, indicated by the lowest, AIC are (0, 1, 1) and (0, 1, 1, 12)
mod=sm.tsa.statespace.SARIMAX(usa_epi, order=(0,1,1), seasonal_order=(0, 1, 1,12), enforce_stationarity=False, enforce_invertibility=False)

#fit model
results=mod.fit()

#check model validity. Get predictions for 2002 on and plot predictions and 95% CI with observed
pred = results.get_prediction(start=pd.to_datetime('2002-01-01'), dynamic=False)
pred_ci = pred.conf_int()
ax = usa_epi['1980':].plot(label="observed")
pred.predicted_mean.plot(ax=ax, alpha=.7, figsize=(14, 7), label="forecasted deaths")
ax.fill_between(pred_ci.index,
                pred_ci.iloc[:, 0],
                pred_ci.iloc[:, 1], color='k', alpha=.2)
ax.set_xlabel('Year')
ax.set_ylabel('Deaths')
ax.legend(loc="best")

ax.set_title("Predicted Deaths due to an Epidemic in the United States")

ax.figure.savefig("figures//usa_epidemics_time_series_predict.png", dpi=200)


#Look at the MSE and RMSE
epi_forecasted = pred.predicted_mean
epi_truth = usa_epi['2002-01-01':]
mse = ((epi_forecasted - epi_truth.deaths) ** 2).mean()
print('The Mean Squared Error of our forecasts is {}'.format(round(mse, 2)))

print('The Root Mean Squared Error of our forecasts is {}'.format(round(np.sqrt(mse), 2)))


#make predictions for the next 5 years and plot forecast
pred_uc = results.get_forecast(steps=5)
pred_mean=pred_uc.predicted_mean
pred_ci = pred_uc.conf_int()

ax = usa_epi.plot(label='observed', figsize=(14, 7))
pred_uc.predicted_mean.plot(ax=ax, label='forecasted deaths')
ax.fill_between(pred_ci.index,
                pred_ci.iloc[:, 0],
                pred_ci.iloc[:, 1], color='k', alpha=.25)
ax.set_xlabel('Year')
ax.set_ylabel('Deaths')
ax.legend(loc="best")
ax.set_title("Forecasted Deaths due to an Epidemic in the United States")

ax.figure.savefig("figures//usa_epidemics_time_series_forecast.png", dpi=200)

print(pred_mean)
print(pred_ci)


forecast_csv=pd.concat([pred_mean, pred_ci], axis=1)
forecast_csv.reset_index(inplace=True)
forecast_csv.rename(columns={"index":"Year"}, inplace=True)
forecast_csv.Year=forecast_csv.Year.dt.strftime("%Y")

forecast_csv.to_csv("derived_data//usa_epi_5yr_forecast.csv", index=False)
