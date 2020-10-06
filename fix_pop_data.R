library(tidyverse)
library(RColorBrewer)
library(gridExtra)

rm(list=ls())

home<- getwd()


setwd(paste(home,"/source_data",sep=""))
causes <- read_csv("Causes_of_Deaths.csv")

setwd(home)

cause_subset <- causes %>% rename(Pop=`Total Pop`) %>% select(Country, ISO_CODE, Year, Deaths, Pop, Cause)
by_year<- cause_subset %>% pivot_wider(names_from = Cause, values_from=Deaths) 



"""
182 of 194 countries are missing pop data for every year only for the epidemic cause. This can be fixed by merging
rows of the same country and same year from the by_year df which contains deaths for all causes in an individual year
in a single row except for Epidemics, which is present in a second row where the country, ISO_CODE, and Year are the
same, but all the other causes are null. Going to split data into two sets,one for those 182 countries which can be 
fixed in a systematic way, and the others which may require a different strategy.
"""

#get entries with missing pop data and summarize number of missing years of for each country
no_pop <- cause_subset %>% filter(is.na(Pop)) 
miss_counts <- no_pop %>% count(ISO_CODE, Sort=TRUE)

#split into two sets
epi_miss <- miss_counts %>% filter(n==38) %>% select(ISO_CODE)
other_miss <- miss_counts %>% filter(n!=38) %>% select(ISO_CODE)

#Merge the rows for the 182 countries.
epi_miss <- by_year %>% subset(ISO_CODE %in% epi_miss$ISO_CODE) %>% group_by(ISO_CODE,Year) %>% arrange(.by_group = TRUE)
fixed_epi <- aggregate(epi_miss, by=list(epi_miss$Country, epi_miss$ISO_CODE, epi_miss$Year), FUN = max, na.rm=TRUE)
fixed_epi <- fixed_epi %>% select(Country, ISO_CODE, Year, Pop, `Conflict and Terrorism`, Epidemics, Famine, `Natural Disaster`, `Other Injuries`)





#Look into the other countries. n=190 means that pop data is missing for all years. I will drop these from the dataset.
#Find rate of pop growth in ERI, KWT, PSE, SRB and use to predict the Pop data for missing years.
other_miss <- miss_counts %>% filter(ISO_CODE %in% other_miss$ISO_CODE)



#Eritrea


#select eritrea data and aggregate epidemics deaths with other deaths. 
eritrea <- by_year %>% filter(ISO_CODE=="ERI")
eritrea <- aggregate(eritrea, by=list(eritrea$Year), FUN=max, na.rm=TRUE)
eritrea <- eritrea %>% mutate(Pop=ifelse(is.infinite(Pop),NA,Pop))

ggplot(eritrea, aes(x=Year, y=Pop))+geom_line()+geom_point()+ggtitle("Eritrea Population")+theme(plot.title = element_text(hjust = 0.5))


#run a linear model and a quartic model 
eri_glm <- glm(data = eritrea, formula= Pop~Year)
eri_quar <- glm(data=eritrea, formula = Pop~poly(Year,4))

#predict the population from both models
eritrea$glm_model <- predict(object=eri_glm, newdata= eritrea)
eritrea <- eritrea %>% mutate(glm_model=floor(glm_model))

eritrea$quartic_model <- predict(object=eri_quar, newdata= eritrea)
eritrea <- eritrea %>% mutate(quartic_model=floor(quartic_model))


#plot population for reported data and models
eritrea_pivot <- eritrea %>% select(Year, Pop, glm_model, quartic_model) %>% pivot_longer(!Year, names_to="type", values_to="Pop")

eri_models <- ggplot(eritrea_pivot, aes(x=Year, y=Pop, group=type, color=type))+geom_line()+geom_point()+ggtitle("Eritrea Population Models")+
  scale_color_manual(labels = c("linear model", "reported population data","quartic polynomial model"), values = c("firebrick1","palegreen3","steelblue1"))+
  theme(plot.title = element_text(hjust = 0.5))+labs(color="model type")

#quartic model is better so set the Pop to the quartic prediction for the years that don't have reported pop data
eritrea <- eritrea %>% mutate(pop_stat=ifelse(is.na(Pop)==FALSE,TRUE, FALSE ))
eritrea_predict <- eritrea %>% mutate(Pop=ifelse(pop_stat==FALSE,eritrea$quartic_model,Pop))

#plot "new" complete eritrea pop data with fixed years
eri_fix <- ggplot(eritrea_predict, aes(x=Year, y=Pop, color=pop_stat, group=1))+geom_line()+geom_point()+ggtitle("Adjusted Eritrea Population")+
  scale_color_manual(labels = c("predicted populatuion","reported population data"), values = c("steelblue1","palegreen3"))+
  theme(plot.title = element_text(hjust = 0.5))+labs(color="population type")

#create df of eritrea data to use moving forward
eritrea_final <- eritrea_predict %>% select(!c(Group.1,glm_model,quartic_model,pop_stat))

#use grid extra to show both eritre population plots
eri_compare <- grid.arrange(eri_models, eri_fix, nrow=2)


#write final df to csv and save grid extra plot
ggsave("figures/eritrea_population.png", height=11.5, width=13.4, unit="in",plot=eri_compare)
write_csv(eritrea_final,"derived_data/adjusted_eritrea_population.csv")





#Kuwait
#Repeat general process as Eritrea

kuwait <- by_year %>% filter(ISO_CODE=="KWT")
kuwait <- aggregate(kuwait, by=list(kuwait$Year), FUN=max, na.rm=TRUE)
kuwait <- kuwait %>% mutate(Pop=ifelse(is.infinite(Pop), NA, Pop))

ggplot(kuwait, aes(x=Year, y=Pop))+geom_line()+geom_point()+ggtitle("Kuwait Population")+theme(plot.title = element_text(hjust = 0.5))

#Relationship looks pretty linear from 1991-1995 so only use those years for the model
kwt_glm <- glm(data=subset(kuwait, Year==1991 | Year==1995), formula= Pop~Year)


kuwait$glm_model <- predict(object=kwt_glm, newdata= kuwait)
kuwait <- kuwait %>% mutate(glm_model=floor(glm_model))


kuwait_pivot <- kuwait %>% select(Year, Pop, glm_model) %>% pivot_longer(!Year, names_to="type", values_to="Pop")

kwt_models <- ggplot(kuwait_pivot, aes(x=Year, y=Pop, group=type, color=type))+geom_line()+geom_point()+ggtitle("Kuwait Population Model")+
  scale_color_manual(labels = c("linear model", "reported population data"), values = c("steelblue1","palegreen3"))+
  theme(plot.title = element_text(hjust = 0.5))+labs(color="model type")

kuwait <- kuwait %>% mutate(pop_stat=ifelse(is.na(Pop)==FALSE,TRUE, FALSE ))
kuwait_predict <- kuwait %>% mutate(Pop=ifelse(pop_stat==FALSE,kuwait$glm_model,Pop))


kwt_fix <- ggplot(kuwait_predict, aes(x=Year, y=Pop, color=pop_stat, group=1))+geom_line()+geom_point()+ggtitle("Adjusted Kuwait Population")+
  scale_color_manual(labels = c("predicted populatuion","reported population data"), values = c("steelblue1","palegreen3"))+
  theme(plot.title = element_text(hjust = 0.5))+labs(color="population type")

kuwait_final <- kuwait_predict %>% select(!c(Group.1,glm_model,pop_stat))

kwt_compare <- grid.arrange(kwt_models, kwt_fix, nrow=2)

ggsave("figures/kuwait_population.png", height=11.5, width=13.4, unit="in",plot=kwt_compare)
write_csv(kuwait_final,"derived_data/adjusted_kuwait_population.csv")




#Palestine


pal <- by_year %>% filter(ISO_CODE=="PSE")
pal <- aggregate(pal, by=list(pal$Year), FUN = max, na.rm=TRUE)
pal <- pal %>% mutate(Pop=ifelse(is.infinite(Pop), NA, Pop))

ggplot(pal, aes(x=Year, y=Pop))+geom_line()+geom_point()+ggtitle("Palestine Population")+theme(plot.title = element_text(hjust = 0.5))

pal_glm <- glm(data=pal, formula= Pop~Year)


pal$glm_model <- predict(object=pal_glm, newdata= pal)
pal <- pal %>% mutate(glm_model=floor(glm_model))

pal_pivot <- pal %>% select(Year, Pop, glm_model) %>% pivot_longer(!Year, names_to="type", values_to="Pop")

pal_models <- ggplot(pal_pivot, aes(x=Year, y=Pop, group=type, color=type))+geom_line()+geom_point()+ggtitle("Palestine Population Model")+
  scale_color_manual(labels = c("linear model", "reported population data"), values = c("steelblue1","palegreen3"))+
  theme(plot.title = element_text(hjust = 0.5))+labs(color="model type")

pal <- pal %>% mutate(pop_stat=ifelse(is.na(Pop)==FALSE,TRUE, FALSE ))
pal_predict <- pal %>% mutate(Pop=ifelse(pop_stat==FALSE,pal$glm_model,Pop))


pal_fix <- ggplot(pal_predict, aes(x=Year, y=Pop, color=pop_stat, group=1))+geom_line()+geom_point()+ggtitle("Adjusted Palestine Population")+
  scale_color_manual(labels = c("predicted populatuion","reported population data"), values = c("steelblue1","palegreen3"))+
  theme(plot.title = element_text(hjust = 0.5))+labs(color="population type")

pal_final <- pal_predict %>% select(!c(Group.1,glm_model,pop_stat))

pal_compare <- grid.arrange(pal_models, pal_fix, nrow=2)

ggsave("figures/palestine_population.png", height=11.5, width=13.4, unit="in",plot=pal_compare)
write_csv(pal_final,"derived_data/adjusted_palestine_population.csv")




#Serbia

serbia <- by_year %>% filter(ISO_CODE=="SRB")
serbia <- aggregate(serbia, by=list(serbia$Year), FUN = max, na.rm=TRUE)
serbia <- serbia %>% mutate(Pop=ifelse(is.infinite(Pop), NA, Pop))

ggplot(serbia, aes(x=Year, y=Pop))+geom_line()+geom_point()+ggtitle("Serbia Population")+theme(plot.title = element_text(hjust = 0.5))


srb_glm <- glm(data = serbia, formula= Pop~Year)
srb_quad <- glm(data=serbia, formula = Pop~poly(Year,2))

serbia$glm_model <- predict(object=srb_glm, newdata= serbia)
serbia <- serbia %>% mutate(glm_model=floor(glm_model))

serbia$quad_model <- predict(object=srb_quad, newdata= serbia)
serbia <- serbia %>% mutate(quad_model=floor(quad_model))


#plot population for reported data and models
serbia_pivot <- serbia %>% select(Year, Pop, glm_model, quad_model) %>% pivot_longer(!Year, names_to="type", values_to="Pop")

srb_models <- ggplot(serbia_pivot, aes(x=Year, y=Pop, group=type, color=type))+geom_line()+geom_point()+ggtitle("Serbia Population Models")+
  scale_color_manual(labels = c("linear model", "reported population data","quadratic model"), values = c("firebrick1","palegreen3","steelblue1"))+
  theme(plot.title = element_text(hjust = 0.5))+labs(color="model type")


#Kind of an arbitrary choice here but I like the quadratic fit better, so set the Pop to the quadratic prediction for the years that don't have reported pop data
serbia <- serbia %>% mutate(pop_stat=ifelse(is.na(Pop)==FALSE,TRUE, FALSE ))
serbia_predict <- serbia %>% mutate(Pop=ifelse(pop_stat==FALSE,serbia$quad_model,Pop))

srb_fix <- ggplot(serbia_predict, aes(x=Year, y=Pop, color=pop_stat, group=1))+geom_line()+geom_point()+ggtitle("Adjusted Serbia Population")+
  scale_color_manual(labels = c("predicted populatuion","reported population data"), values = c("steelblue1","palegreen3"))+
  theme(plot.title = element_text(hjust = 0.5))+labs(color="population type")

serbia_final <- serbia_predict %>% select(!c(Group.1,glm_model,quad_model,pop_stat))

srb_compare <- grid.arrange(srb_models, srb_fix, nrow=2)


ggsave("figures/serbia_population.png", height=11.5, width=13.4, unit="in",plot=srb_compare)
write_csv(serbia_final,"derived_data/adjusted_serbia_population.csv")






#Final fixed dataset omitting the countries that had missing data for every year


fixed_epi <- fixed_epi %>% group_by(ISO_CODE,Year) %>% arrange(.by_group = TRUE)

final_data <- rbind(fixed_epi,eritrea_final)
final_data <- rbind(final_data,kuwait_final)
final_data <- rbind(final_data,pal_final)
final_data <- rbind(final_data,serbia_final)


final_data <- data.frame(final_data %>% group_by(ISO_CODE,Year) %>% arrange(.by_group = TRUE))

write_csv(final_data,"derived_data/cleaned_pop_data.csv")





