.PHONY: clean

clean:
				rm -f figures/*.png
				rm -f assets/*.png
				rm -f derived_data/*.csv


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

figures/deaths_population_ratio_line_graph.png\
 figures/deaths_ratio_line_graph.png\
 figures/deaths_ratio_heatmap.png:\
 derived_data/cleaned_pop_data.csv\
 source_data/countryContinent.csv\
 updated_prelim_figs.R
 				Rscript updated_prelim_figs.R


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
