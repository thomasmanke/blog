library(shiny)
library(tidyverse)
library(deSolve)
library(plotly)

#The lorenz functions in a for deSolve can understand
Lorenz<-function(t, state, parameters) {
    with(as.list(c(state, parameters)),{
        # ODE
        dX <- a * (Y-X)
        dY <- X * (b-Z) - Y
        dZ <- X*Y - c*Z        
        # return the rate of change
        list(c(dX, dY, dZ))
    })
}

solveIni <- function(state, ts=1:20, ps=parameters) {
  # solve ODE and convert to data frame
  ode(y = state, times = ts, func=Lorenz, parms=ps) %>% as.data.frame()
}

state2states <- function(state, N = 5, sd = 0.1){
  # input: initial state = named vector of length p (number of variables)
  # output: matrix of N row vectors of perturbed initial states
  p <- length(state)
  M <- matrix(rnorm(N * p, mean = 1, sd = sd), nrow = N)
  states <- M*state
  colnames(states) = names(state)
  return(states)
}

ui <- fluidPage( 
  titlePanel("Lorenz Attractor"),
  fluidRow(
    column(3, sliderInput("param_a", label = "a:", min = -10, max = 20, value = 10, step=0.001)),
    column(3, sliderInput("param_b", label = "b:", min = -10, max = 100, value = 28, step=0.001)),
    column(3, sliderInput("param_c", label = "c:", min = -10, max = 20, value = 8./3., step=0.001)),
    column(3, sliderInput("time", label = "Time Range:", min = 1, max = 200, value = c(1,100), step=1)),
    column(3, sliderInput("ini_n", label = "ini_n:", min = 1, max = 1000, value = 50, step=1)),
    column(3, sliderInput("ini_sd", label = "ini_sd:", min = 0, max = 10, value = 1, step=0.01)),
    column(6, sliderInput("ms", label = "ms / frame", min = 0, max = 500, value = 200, step=1)),
    tabsetPanel(
        tabPanel("Lorenz Attractor",plotlyOutput("animated",width="800px",height="800px")),
        tabPanel("(X,Y,Z) vs Time",plotOutput("time_series")),
        tabPanel("Session Info",verbatimTextOutput("session_info"))
    )
  )
)

server <- function(input, output) {
  vals <- reactiveValues()
    observe({
        parameters <- c(a = input$param_a, b = input$param_b, c = input$param_c)
        times <- seq(input$time[[1]], input$time[[2]], by = 0.01)
        state <- c(X = 1, Y = 1, Z = 1)                                    # single initial state
        states <- state2states(state, N=input$ini_n, sd=input$ini_sd)      # multiple initial states

        # single solution
        vals$out <- ode(y = state, times = times, func = Lorenz, parms = parameters) %>%
            as.data.frame()
        # multiple solution - coarse times
        times_c = seq(input$time[[1]], input$time[[2]], by=1)   
        res <- apply(states,1, solveIni, ts=times_c, ps=parameters)   # multiple solutions (list of dataframes)
        vals$df <- bind_rows(res, .id="start")            # convert list of df to single df with extra column
    })

    output$time_series <- renderPlot({
        vals$out %>% 
          pivot_longer(-time, names_to= "coord" , values_to = "value") %>%
          ggplot(aes(x = time, y = value)) +
          geom_path() +
          facet_wrap(~coord)
    })

    output$animated<-renderPlotly({
      plot_ly(data=vals$out, x = ~X, y = ~Y, type='scatter', mode='line') %>%
      add_trace(data= vals$df, x = ~X, y = ~Y, mode='markers', size=18, frame = ~time, color='red', showlegend=FALSE) %>%
      animation_opts(frame=input$ms, transition=input$ms, redraw=FALSE)

    })

    output$session_info <- renderPrint( sessionInfo() )
}

shinyApp(ui = ui, server = server)