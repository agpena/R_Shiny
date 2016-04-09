library(shiny)
library(ggplot2)
library(RSQLite)
library(DT)

fields<-c("count","spray","state","date")

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme="bootstrap.css",

  # Application title
  titlePanel("Insects Data"),

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
    	numericInput("count", "Number of Insects Sprayed:",
                   min = 1, max = 50, value = 5, step = 1),
        radioButtons("spray", "Type of Spray Used:",LETTERS[1:10]),
        selectInput("state", "Select State:",state.abb),
        dateInput("date", "Date Collected:"),
        actionButton("submit", "Submit")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot"),
      dataTableOutput("responses")#, width = 300
    )
    )
  )
)