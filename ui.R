#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("GDP of English speaking countries as a graph"),
  
  tabsetPanel(type="tabs",
   tabPanel("Documentation", h1("Documentation"), htmlOutput("frame")),
   tabPanel("Plot",
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(
         h4("Choose Year"),
         sliderInput("years",
                     "Start/End Year",
                     min = 2010,
                     max = 2016,
                     value = c(2010,2016),
                     sep=""),
         h4("Choose Countries"),
         checkboxInput("usa","USA",value = T),
         checkboxInput("uk","UK",value = T),
         checkboxInput("can","Canada",value = T),
         checkboxInput("aus","Australia",value = T),
         checkboxInput("nz","New Zealand",value = T),
         h4("Choose Data Format"),
         selectInput("select","Select Data Tranformation", 
                     choices=c("Billions(USD)","Trillions(USD)","% of US-GDP"),
                     selected = 1),
         h4("Choose Type of graph"),
         radioButtons("barType",label="Plot Type",choices=c("Bar","Line"))
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        textOutput("msg",h3),
        plotlyOutput("plot")
      )
    )
  ))
))
