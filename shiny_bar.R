library(shiny)
library(plotly)
library(tidyverse)
library(RColorBrewer)

rm(list=ls())


home<- getwd()


causes <- read_csv(paste(home,"/derived_data/cleaned_pop_data.csv",sep=""))

#pivot causes
death_counts <- causes %>% select(Year, Conflict.and.Terrorism, Epidemics, Famine, Natural.Disaster, Other.Injuries) %>% pivot_longer(cols = !Year, names_to="cause", values_to="deaths") 

#get total number from all causes in all years
yearly_total_deaths <- death_counts %>% group_by(Year) %>% summarise(sum(deaths))

#get number of deaths per cause by year 
death_counts <- death_counts %>% group_by(Year, cause) %>% summarise(sum(deaths))

#get the ratio of the number of deaths per cause by the total number of deaths that year
death_ratio<- merge(death_counts, yearly_total_deaths, by="Year", all.x=TRUE)
death_ratio <- death_ratio %>% mutate(death_ratio= 100*(`sum(deaths).x`/`sum(deaths).y`))


# Define UI for app that draws a histogram ----
ui <- fluidPage(

  # App title ----
  titlePanel("Percentage of Annual Total Deaths by Cause"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Input: Slider for the number of bins ----
      sliderInput(inputId = "Year",
                  label = "Year:",
                  min = 1980,
                  max = 2017,
                  value = 2000,
                  sep="")

    ),

    
    mainPanel(

      
      plotOutput(outputId = "barPlot")

    )
  )
)


server <- function(input, output) {

  output$barPlot <- renderPlot({
    
    plot_temp <- death_ratio %>% filter(Year==input$Year) 

    plot_temp %>% ggplot(aes(x=cause, y=death_ratio, fill=cause))+geom_bar(stat="identity")+labs(x="cause", y="percentage of deaths")
    

  })

}

# Start the Server
shinyApp(ui=ui,server=server,
         options=list(port=8080, host="0.0.0.0"))