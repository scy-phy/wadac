library(shiny)
library(shinythemes)

PAGE_TITLE = "WADAC"

shinyUI(fluidPage(navbarPage(theme=shinytheme("flatly"),tags$b("WADAC"),br(),
                             # PAGE_TITLE = "WADAC",
                             # titlePanel(windowTitle = PAGE_TITLE,
                             #            title =
                             #              div(
                             #                img(
                             #                  src = "framework.pdf",
                             #                  height = 100,
                             #                  width = 100,
                             #                  style = "margin:10px 10px"
                             #                ),
                             #                PAGE_TITLE
                             #              )
                             # ),
                             
                             div(style="display:inline-block",actionButton("stop","STOP!"), style="float:right"),
                              tabPanel("Anomaly Detector", 
                                      fluidRow(
                  # column(4,
                  #                       # div(style="display:inline-block",actionButton("start","Get Packets"), style="float:right"),
                  #              div(style="display:inline-block",actionButton("stop","STOP!"), style="float:right")
                  #              ),                                        
                  column(12,h4("MSE vs Time plot",align="center"),
                  plotOutput("anomaly_detector")                  
                                        )
                                      )),
                  tabPanel("Feature Analysis",fluidRow(
                    # sidebarPanel(),
                    column(12,h4("Feature Analysis",align="center"),
                              plotOutput("af1"),
                              plotOutput("af2"),
                              plotOutput("af3")
                              )
                    
                  )),
                  
                  tabPanel("Attack Classification",fluidRow(
                    # sidebarPanel(),
                    column(12,h4("Attack Classification",align = "center"),
                              plotOutput("attack_class"))
                  )),
                  
                  tabPanel("Attack Features",fluidRow(
                    # sidebarPanel(),
                    column(12,h4("Attack Features",align = "center"),
                              plotOutput("ac1"),
                              plotOutput("ac2"),
                              plotOutput("ac3"),
                              plotOutput("ac4")
                              )
                  )),
                  
                  tabPanel("Data", h4("Data Analysis"),
                           tableOutput("head_tab")
                           )
                  
                             )
                  
                  
                  ))
                             