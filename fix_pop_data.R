library(tidyverse)
library(RColorBrewer)

home<- getwd()


setwd(paste(home,"/source_data",sep=""))
causes <- read_csv("Causes_of_Deaths.csv")
continents <- read_csv("countryContinent.csv")

setwd(home)

cause_subset <- causes %>% rename(Pop=`Total Pop`) %>% select(Country, ISO_CODE, Year, Deaths, Pop, Cause)
by_year<- cause_subset %>% pivot_wider(names_from = Cause, values_from=Deaths) 


#182 of 194 countries are missing pop data for every year only for the epidemic cause. Just
#need to set that value to the value of Population for that country in that year according
#to the the other causes. 

no_pop <- cause_subset %>% filter(is.na(Pop)) 
miss_counts <- no_pop %>% count(ISO_CODE, Sort=TRUE)

#182 countries are missing pop data just for the epidemics cause every year. Get the list of ISO Codes for those countries
epi_miss <- miss_counts %>% filter(n==38) %>% select(ISO_CODE)



#get list of population values to use
fam_pops_to_use <- merge(epi_miss, cause_subset %>% filter(Cause=="Famine") %>% select(ISO_CODE,Year,Pop), by="ISO_CODE", all.x=TRUE)
fam_pops_to_use <- fam_pops_to_use %>% group_by(ISO_CODE,Year) %>% arrange(.by_group = TRUE)




# Previous Code I might want to reuse at some point
# 
# x <- cause_subset %>% filter(ISO_CODE %in% epi_miss$ISO_CODE & is.na(cause_subset$Pop)) %>% group_by(ISO_CODE,Year) %>% arrange(.by_group = TRUE) %>% mutate(cause_subset$Pop=fam_pops_to_use$Pop)
# 
# conf_count <- lapply(by_year$`Conflict and Terrorism`,sum)
# epi_count <- lapply(by_year$Epidemics,sum)
# fam_count <- lapply(by_year$Famine, sum)
# nd_count <- lapply(by_year$`Natural Disaster`, sum)
# other_count <- lapply(by_year$`Other Injuries`, sum)
# 
# by_year<- by_year %>% select(Year) %>%  rename("year"="Year") %>% mutate(conflict_and_terrorism=conf_count, epidemics=epi_count, famine=fam_count, natural_disaster=nd_count, other_injuries=other_count)
# 
# tidy_data_year <- pivot_longer(by_year, cols=!year, names_to="cause", values_to="deaths")
# tidy_data_year$deaths <- as.numeric(tidy_data_year$deaths)
# 
# p <- ggplot(tidy_data_year, aes(x=year, y=deaths, group=cause, color=cause))+geom_line()+geom_point()+ggtitle("Global Number of Deaths per Year by\nCause from 1980-2017")+theme(plot.title = element_text(hjust = 0.5))
# 
# ggsave(paste(home,"/figures/cause_line_prelim.png",sep=""), plot=p)
# ggsave(paste(home,"/assets/cause_line_prelim.png",sep=""), plot=p)
# 
# 
# 
# 
# 
# country_continent <- merge(x=causes, y=continents, by.x="ISO_CODE", by.y="code_3", all.x=TRUE)
# country_continent <- country_continent %>% select(sub_region, Cause, Deaths)
# 
# by_region <- country_continent %>% pivot_wider(names_from=Cause, values_from=Deaths)
# 
# conf_count <- lapply(by_region$`Conflict and Terrorism`,sum)
# epi_count <- lapply(by_region$Epidemics,sum)
# fam_count <- lapply(by_region$Famine, sum)
# nd_count <- lapply(by_region$`Natural Disaster`, sum)
# other_count <- lapply(by_region$`Other Injuries`, sum)
# 
# by_region<- by_region %>% select(sub_region) %>% mutate(conflict_and_terrorism=conf_count, epidemics=epi_count, famine=fam_count, natural_disaster=nd_count, other_injuries=other_count)
# 
# 
# tidy_data_region <- pivot_longer(by_region, cols=!sub_region, names_to="cause", values_to="deaths")
# tidy_data_region$deaths <- as.numeric(tidy_data_region$deaths)
# 
# p <- ggplot(tidy_data_region, aes(x=cause, y=sub_region, fill=deaths))+geom_tile(colour="white",size=0.25)+coord_fixed(ratio=.5)+scale_fill_distiller(palette="YlGnBu")+theme(axis.text.x = element_text(angle = 90))+labs(title="Total Number of Deaths by Cause in\nSubregions from 1980-2017", y="subregion")+theme(plot.title = element_text(hjust = 0.5))
# 
# ggsave(paste(home,"/figures/region_death_heat_prelim.png",sep=""), plot=p)
# ggsave(paste(home,"/assets/region_death_heat_prelim.png",sep=""), plot=p)
