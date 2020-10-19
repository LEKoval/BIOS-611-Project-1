library(tidyverse)
library(RColorBrewer)

home<- getwd()


setwd(paste(home,"/source_data",sep=""))
causes <- read_csv("Causes_of_Deaths.csv")
continents <- read_csv("countryContinent.csv")

setwd(home)

cause_subset <- causes %>% select(Year, Deaths, Cause)
by_year<- cause_subset %>% pivot_wider(names_from = Cause, values_from=Deaths) 

conf_count <- lapply(by_year$`Conflict and Terrorism`,sum)
epi_count <- lapply(by_year$Epidemics,sum)
fam_count <- lapply(by_year$Famine, sum)
nd_count <- lapply(by_year$`Natural Disaster`, sum)
other_count <- lapply(by_year$`Other Injuries`, sum)

by_year<- by_year %>% select(Year) %>%  rename("year"="Year") %>% mutate(conflict_and_terrorism=conf_count, epidemics=epi_count, famine=fam_count, natural_disaster=nd_count, other_injuries=other_count)

tidy_data_year <- pivot_longer(by_year, cols=!year, names_to="cause", values_to="deaths")
tidy_data_year$deaths <- as.numeric(tidy_data_year$deaths)

p <- ggplot(tidy_data_year, aes(x=year, y=deaths, group=cause, color=cause))+geom_line()+geom_point()+ggtitle("Global Number of Deaths per Year by\nCause from 1980-2017")+theme(plot.title = element_text(hjust = 0.5))

ggsave(paste(home,"/figures/cause_line_prelim.png",sep=""),height=11.5, width=13.4, unit="in", plot=p)
ggsave(paste(home,"/assets/cause_line_prelim.png",sep=""), height=11.5, width=13.4, unit="in",plot=p)





country_continent <- merge(x=causes, y=continents, by.x="ISO_CODE", by.y="code_3", all.x=TRUE)
country_continent <- country_continent %>% select(sub_region, Cause, Deaths)

by_region <- country_continent %>% pivot_wider(names_from=Cause, values_from=Deaths)

conf_count <- lapply(by_region$`Conflict and Terrorism`,sum)
epi_count <- lapply(by_region$Epidemics,sum)
fam_count <- lapply(by_region$Famine, sum)
nd_count <- lapply(by_region$`Natural Disaster`, sum)
other_count <- lapply(by_region$`Other Injuries`, sum)

by_region<- by_region %>% select(sub_region) %>% mutate(conflict_and_terrorism=conf_count, epidemics=epi_count, famine=fam_count, natural_disaster=nd_count, other_injuries=other_count)


tidy_data_region <- pivot_longer(by_region, cols=!sub_region, names_to="cause", values_to="deaths")
tidy_data_region$deaths <- as.numeric(tidy_data_region$deaths)

p <- ggplot(tidy_data_region, aes(x=cause, y=sub_region, fill=deaths))+geom_tile(colour="white",size=0.25)+coord_fixed(ratio=.5)+scale_fill_distiller(palette="YlGnBu")+theme(axis.text.x = element_text(angle = 90))+labs(title="Total Number of Deaths by Cause in\nSubregions from 1980-2017", y="subregion")+theme(plot.title = element_text(hjust = 0.5))

ggsave(paste(home,"/figures/region_death_heat_prelim.png",sep=""),height=11.5, width=13.4, unit="in", plot=p)
ggsave(paste(home,"/assets/region_death_heat_prelim.png",sep=""),height=11.5, width=13.4, unit="in", plot=p)
