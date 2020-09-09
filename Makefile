.PHONY: clean

clean:
				rm -f figures/*.png


figures/cause_line_prelim.png figures/region_death_heat_prelim.png: source_data/Causes_of_Deaths.csv source_data/countryContinent.csv prelim_figs.R
				Rscript prelim_figs.R
