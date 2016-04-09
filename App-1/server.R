library(shiny)
library(ggplot2)
library(RSQLite)
library(DT)

insects<-readRDS("data/insect_sprays.rds")
fields<-c("count","spray","state","date")
sqlitePath <- "data/insects.sqlite"
table <- "Insects"

saveData <- function(data) {
  # Connect to the database
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the update query by looping over the data fields
  query <- sprintf(
    "INSERT INTO %s (%s) VALUES ('%s')",
    table, 
    paste(names(data), collapse = ", "),
    paste(data, collapse = "', '")
  )
  # Submit the update query and disconnect
  dbGetQuery(db, query)
  dbDisconnect(db)
}

loadData <- function() {
  # Connect to the database
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the fetching query
  query <- sprintf("SELECT * FROM %s", table)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should re-execute automatically
  #     when inputs change
  #  2) Its output type is a plot
  # Whenever a field is filled, aggregate all form data

    formData <- reactive({
      data <- sapply(fields, function(x) input[[x]])
      data["date"]<-format(input$date[1])
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      validate(
      	need(input$count<=50 & input$count>0,"Please enter a valid number greater than 0 but less than 50"),
      	need(is.na(as.Date(input$date[1],format="%Y%m%d"))==FALSE, "Enter valid date")
      )
      saveData(formData())
    })
    
    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses <- DT::renderDataTable({
      input$submit
	  loadData()
    })     
  output$distPlot <- renderPlot({
  	input$submit
  	validate(
    	need(input$count<=50 & input$count>0,"Please enter a valid number greater than 0 but less than 50"),
    	need(is.na(as.Date(input$date[1],format="%Y%m%d"))==FALSE, "Enter valid date")
    )
  	ggplot(loadData(),aes(x=spray,y=count,fill=spray))+geom_bar(stat="identity")+facet_grid(state~.)
  })
})