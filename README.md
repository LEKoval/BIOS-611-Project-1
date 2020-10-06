BIOS 611 Project 1
==================

World-wide Causes of Death Other than Disease, 1980-2017
--------------------------------------------------------

Proposal
--------

### Introduction

People all over the world routinely face challenges that pose a risk to their health and well-being, many of which arise from external factors beyond the control of the individual. These challenges can be social, political, or environmental, though realistically they are a combination of all of these factors.

This project will attempt to uncover both spatial and temporal relationships between various causes of non-disease deaths and the frequency with which they occurred in countries all over the world from 1980-2017. Using descriptive statistics and time series analysis, I will look to answer questions such as, "Are there any long term trends in the cause of death due to conflict and terrorism at a regional or global level?" and "What would the projected number of deaths be due to an epidemic in the United States in 2020?"


### Datasets

The datasets I will be using are publicly available for download on Kaggle:


[global causes of deaths other than disease](https://www.kaggle.com/tahminashoaib86/global-cause-of-the-deaths-other-than-diseases)

[country to continent mapping](https://www.kaggle.com/statchaitya/country-to-continent)

Note that I renamed the first file to "Causes_of_Deaths.csv" for analysis

### Preliminary Figures

![](assets/cause_line_prelim.png)

This line graph shows the global number of deaths from five major causes each year from 1980- 2017. Because the number of deaths varies so greatly, it was difficult to scale the graph to get a clear indication of any trends. This is something I would like to continue to work on.




![](assets/region_death_heat_prelim.png)

This heatmap shows the total number of deaths by cause from 1980-2017 in various subregions around the world. Similarly to the line graph, it was difficult to scale the death counts to get a clear picture of what is going on. I would like to see if plotting the ratio of the number of deaths per subregion population would produce a more insightful figure. Having looked at the data, this will require significant cleaning and I will need to make decisions on how to handle missing data. 


### Using This Project


You will need Docker, and you will need be able to run docker as your user.

First you will need to build the container:
> docker build . -t project1_env

This Docker container is based on rocker/verse. To run rstudio server:
> docker run -v $(pwd):/home/rstudio -p 8787:8787 -e PASSWORD=yourpassword -t project1_env

You will then need to connect your machine to port 8787.



### Makefile

The Makefile is a nice resource to understand the aims and capabilities of the project.

For example, to generate the preliminary figures as seen above, you can use the command
> make figures/cause_line_prelim.png
