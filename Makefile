.PHONY: clean
.PHONY: shiny_bar

clean:
				rm -f figures/*.png
				rm -f assets/*.png
				rm -f derived_data/*.csv
				rm -f project_1_report.pdf


project_1_report.pdf:\
 figures/deaths_ratio_line_graph.png\
 figures/deaths_ratio_heatmap.png\
 figures/eritrea_population.png\
 figures/kuwait_population.png\
 figures/palestine_population.png\
 figures/serbia_population.png\
 figures/region_death_heat_prelim.png\
 figures/cause_line_prelim.png\
 figures/usa_epidemics_trend.png\
 figures/usa_epidemics_time_series_decomp.png\
 figures/usa_epidemics_time_series_predict.png\
 figures/usa_epidemics_time_series_forecast.png\
 derived_data/usa_epi_5yr_forecast.csv
				R -e "rmarkdown::render('project_1_report.Rmd', output_format= 'pdf_document')"

figures/usa_epidemics_trend.png\
 figures/usa_epidemics_time_series_decomp.png\
 figures/usa_epidemics_time_series_predict.png\
 figures/usa_epidemics_time_series_forecast.png\
 derived_data/usa_epi_5yr_forecast.csv:\
 derived_data/cleaned_pop_data.csv\
 usa_epi_time_series.py
				python3 usa_epi_time_series.py


shiny_bar:\
 derived_data/cleaned_pop_data.csv
				Rscript shiny_bar.R ${PORT}


figures/deaths_population_ratio_line_graph.png\
 figures/deaths_ratio_line_graph.png\
 figures/deaths_ratio_heatmap.png:\
 derived_data/cleaned_pop_data.csv\
 source_data/countryContinent.csv\
 updated_prelim_figs.R
				Rscript updated_prelim_figs.R

figures/cause_line_prelim.png\
 figures/region_death_heat_prelim.png:\
 source_data/Causes_of_Deaths.csv\
 source_data/countryContinent.csv\
 prelim_figs.R
				Rscript prelim_figs.R

figures/eritrea_population.png\
 figures/kuwait_population.png\
 figures/palestine_population.png\
 figures/serbia_population.png:\
 source_data/Causes_of_Deaths.csv\
 fix_pop_data.R
				Rscript fix_pop_data.R

derived_data/adjusted_eritrea_population.csv\
 derived_data/adjusted_kuwait_population.csv\
 derived_data/adjusted_palestine_population.csv\
 derived_data/adjusted_serbia_population.csv\
 derived_data/cleaned_pop_data.csv:\
 source_data/Causes_of_Deaths.csv\
 fix_pop_data.R
				Rscript fix_pop_data.R


assets/cause_line_prelim.png\
 assets/region_death_heat_prelim.png:\
 source_data/Causes_of_Deaths.csv\
 source_data/countryContinent.csv\
 prelim_figs.R
				Rscript prelim_figs.R
