
library(shiny)
source("playground.R")

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Life Insurance Pricing"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("premium",
                   "Annual Premium",
                   value = 200,
                   step = 10),
      numericInput("term",
                   "Length of term (years)",
                   value = 20),
      numericInput("death_benefit",
                   "Death Benefit",
                   value = 50000,
                   step = 50000),
      numericInput("interest",
                   "Constant annual interest",
                   value = 0.03,
                   step = 0.01),
      numericInput("discount_loading",
                   "Discount Loading",
                   value = 0.05,
                   step = 0.01),
      numericInput("initial_commission",
                   "First Year Commission Percent",
                   value = 0.80,
                   step = 0.01),
      numericInput("annual_commission",
                   "Annual Commission Percent",
                   value = 0.05,
                   step = 0.01),
    ),
    
    mainPanel(
      textOutput("profit"),
      tableOutput("cashflows"),
      textOutput("notes")
    ),
  )
)

# Define server logic
server <- function(input, output) {
  
  calculations <- reactive(calculateProfit(input$premium, input$term, 
                                           input$death_benefit, input$interest,
                                           input$discount_loading, input$initial_commission,
                                           input$annual_commission))
  output$profit <- renderText({
    paste("Present value of profit:", calculations()$profit)
  })
  output$cashflows <- renderTable(calculations()$sheet, digits = 5)
  output$notes <- renderText( {"
    * Interest rate, lapse rate is constant.
    * Reserves calculated on a Net Premium basis.
    * Discounting calculated using Interest Rate + Discount Loading
    "
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
