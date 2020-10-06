.PHONY: clean

clean:
				rm -f figures/*.png
				rm -f assets/*.png
				rm -f derived_data/*.csv


figures/cause_line_prelim.png: source_data/Causes_of_Deaths.csv source_data/countryContinent.csv prelim_figs.R
				Rscript prelim_figs.R

figures/region_death_heat_prelim.png: source_data/Causes_of_Deaths.csv source_data/countryContinent.csv prelim_figs.R
				Rscript prelim_figs.R

assets/cause_line_prelim.png: source_data/Causes_of_Deaths.csv source_data/countryContinent.csv prelim_figs.R
				Rscript prelim_figs.R

assets/region_death_heat_prelim.png: source_data/Causes_of_Deaths.csv source_data/countryContinent.csv prelim_figs.R
				Rscript prelim_figs.R
