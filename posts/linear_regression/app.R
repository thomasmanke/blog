# Load the required libraries
library(shiny)
library(plotly)

# Define UI
ui <- fluidPage(
  titlePanel("Linear Regression"),  # Change the title
  
  sidebarLayout(
    sidebarPanel(
      titlePanel("Data Model:"),
      style = "width: 30%;",  # Set the width of the sidebarPanel
      numericInput("w_value", "Select w:", min = -10, max = 10, value = 1),
      numericInput("b_value", "Select b:", min = -10, max = 10, value = 0),
      numericInput("sigma_value", "Select sigma:", min = 0, max = 5, value = 1)
    ),
    
    mainPanel(
      style = "width: 70%;",  # Increase the width of the mainPanel
      tabsetPanel(
        tabPanel("Visualization", 
                 fluidRow(
                   column(6, plotlyOutput("data_plot")),
                   column(6, plotlyOutput("parameter_plot")),
                 )
        ),
        tabPanel("Session Info", verbatimTextOutput("session_info"))
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # generate data from linear model
  generated_data <- reactive({
    w <- input$w_value
    b <- input$b_value
    sigma <- input$sigma_value
    
    set.seed(123)  # Set seed for reproducibility
    x_vals <- seq(-1, 1, length.out = 10)
    epsilon <- rnorm(length(x_vals), mean = 0, sd = sigma)
    y_vals <- w * x_vals + b + epsilon
    data.frame(x = x_vals, y = y_vals)
  })
  
  # get parameter values by hovering over parameter_plot
  hovered_parameter <- reactive({
    hover_data <- event_data("plotly_hover", source = "parameter_plot")
    if (!is.null(hover_data)) {
      w_hovered <- hover_data[["x"]]
      b_hovered <- hover_data[["y"]]
      list(w = w_hovered, b = b_hovered)
    } else {
      list(w = input$w_value, b = input$b_value)  # Default to input values if no hover data
    }
  })
  
  # Ensure that w and b are not adjusted too often: debounce! Adjust the delay (in milliseconds) as needed
  debounced_hovered_parameter <- debounce(hovered_parameter, 50)  
  
  # Calculate squared mean error
  mse <- reactive({
    hover_values <- debounced_hovered_parameter()
    w_hovered <- hover_values$w
    b_hovered <- hover_values$b
    observed_data <- generated_data()
    predicted_y <- w_hovered * observed_data$x + b_hovered
    mse_value <- mean((observed_data$y - predicted_y)^2)
    mse_value
  })
  
  # Generate scatter plot with sample data
  output$data_plot <- renderPlotly({
    mse_value <- mse()
    title_string <-  paste("Data. MSE = ", format(mse_value, digits=4))
    # Plot data
    data_plot <- plot_ly(data = generated_data(), x = ~x, y = ~y, type = "scatter", mode = "markers", marker = list(color = "blue"), source = "data_plot", name = "data") %>%
      layout(title = title_string, margin= list(l=2,r=2,t=100,b=20))
    
    # Add regression line based on hovered parameter values
    hover_values <- debounced_hovered_parameter()
    w_hovered <- hover_values$w
    b_hovered <- hover_values$b
    data_plot <- add_trace(data_plot, x = c(-1, 1), y = c(-1 * w_hovered + b_hovered, 1 * w_hovered + b_hovered),
                           mode = "lines", line = list(color = "red"), name = "regression_line")
    data_plot
  })
  
  # Generate scatter plot with 2D plane and contour lines for MSE values
  output$parameter_plot <- renderPlotly({
    w_values <- seq(-10, 10, length.out = 101)
    b_values <- seq(-10, 10, length.out = 101)
    plane_data <- expand.grid(w = w_values, b = b_values)
    
    # Calculate MSE values for each combination of w and b
    mse_values <- apply(plane_data, 1, function(row) {
      w_current <- row["w"]
      b_current <- row["b"]
      predicted_y <- w_current * generated_data()$x + b_current
      mse_value <- mean((generated_data()$y - predicted_y)^2)
      mse_value
    })
    
    # Create a contour plot with MSE values
    plot_ly(data = plane_data, x = ~w, y = ~b, z = mse_values, type = "contour", contours = list(coloring = "heatmap"), source = "parameter_plot", name = "parameter") %>%
      layout(title = "Parameter Plot", margin = list(l=2,r=2,t=100,b=20)) %>%
      colorbar(title="MSE")
  })
  
  # Display session info
  output$session_info <- renderPrint({
    sessionInfo()
  })
}

# Run the application
shinyApp(ui = ui, server = server)