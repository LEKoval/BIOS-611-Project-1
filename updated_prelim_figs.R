library(tidyverse)
library(RColorBrewer)

rm(list=ls())


home<- getwd()


causes <- read_csv(paste(home,"/derived_data/cleaned_pop_data.csv",sep=""))
continents <- read_csv(paste(home,"/source_data/countryContinent.csv",sep=""))

#get total populations
annual_pop <- causes %>% group_by(Year) %>% summarise(sum(Pop))

#pivot causes
death_counts <- causes %>% select(Year, Conflict.and.Terrorism, Epidemics, Famine, Natural.Disaster, Other.Injuries) %>% pivot_longer(cols = !Year, names_to="cause", values_to="deaths") 

#get total number from all causes in all years
yearly_total_deaths <- death_counts %>% group_by(Year) %>% summarise(sum(deaths))

#get number of deaths per cause by year 
death_counts <- death_counts %>% group_by(Year, cause) %>% summarise(sum(deaths))

#get the ratio of the number of deaths per cause by the total number of deaths that year
death_ratio<- merge(death_counts, yearly_total_deaths, by="Year", all.x=TRUE)
death_ratio <- death_ratio %>% mutate(death_ratio= `sum(deaths).x`/`sum(deaths).y`)

#get the ratio of deaths per cause by the total population that year
death_pop_merge <- merge(death_counts, annual_pop, by="Year", all.x=TRUE)
death_pop_merge <- death_pop_merge %>% mutate(death_ratio= death_pop_merge$`sum(deaths)`/death_pop_merge$`sum(Pop)`)


#make line graphs to look at ratios of death relative to population and to total annual deaths
death_pop<- death_pop_merge %>% select(Year, cause, death_ratio)

death_death <- death_ratio %>% select(Year, cause, death_ratio)


p1 <-ggplot(death_pop, aes(x=Year, y=death_ratio, group=cause, color=cause))+geom_line()+geom_point()+ggtitle("Global Ratio of the Number of Deaths by Cause to Annual Population from 1980-2017")+theme(plot.title = element_text(hjust = 0.5))
ggsave("figures/deaths_population_ratio_line_graph.png", height=11.5, width=20, unit="in",plot=p1)


p2 <- ggplot(death_death, aes(x=Year, y=death_ratio, group=cause, color=cause))+geom_line()+geom_point()+ggtitle("Global Ratio of the Number of Deaths by Cause to Annual Total Deaths from 1980-2017")+theme(plot.title = element_text(hjust = 0.5))
ggsave("figures/deaths_ratio_line_graph.png", height=11.5, width=20, unit="in",plot=p2)




#Read in sub_region data
country_continent <- merge(x=causes, y=continents, by.x="ISO_CODE", by.y="code_3", all.x=TRUE)
country_continent <- country_continent %>% select (Conflict.and.Terrorism, Epidemics, Famine, Natural.Disaster, Other.Injuries, sub_region) %>% pivot_longer(cols = !sub_region, names_to="cause", values_to="deaths") 


#get the total number of deaths per cause by sub_region from 1980-2017
region_death_cause <- country_continent %>% group_by(cause, sub_region) %>% summarise(sum(deaths))
region_death_cause$cause_death_count <- region_death_cause$`sum(deaths)`
region_death_cause$`sum(deaths)` <- NULL


#get the total number of deaths from all causes from 1980-2017 for all sub_regions
region_death_total <- region_death_cause %>% group_by(sub_region) %>% summarise(sum(cause_death_count))
region_death_total$total_death <- region_death_total$`sum(cause_death_count)`
region_death_total$`sum(cause_death_count)` <- NULL


#get the ratio of the number of deaths per cause to the total number of deaths in each sub_region
merge_deaths <- merge(region_death_cause, region_death_total, by="sub_region", all.x=TRUE)
merge_deaths <- merge_deaths %>% mutate(death_ratio=cause_death_count/total_death)

merge_deaths <- merge_deaths %>% select(sub_region, cause, death_ratio) 


#make heatmap
p3 <- ggplot(merge_deaths, aes(x=cause, y=sub_region, fill=death_ratio))+
  geom_tile(colour="white",size=0.25)+
  coord_fixed(ratio=.5)+
  scale_fill_distiller(palette="GnBu", direction=1)+
  theme(axis.text.x = element_text(angle = 45, hjust=0.95), plot.title = element_text(hjust = 0.5))+
  labs(title="Ratio of Total Deaths by Cause to Total Deaths\nfrom 1980-2017 by Subregion ", y="subregion")

ggsave("figures/deaths_ratio_heatmap.png", height=16, width=10, unit="in",plot=p3)
