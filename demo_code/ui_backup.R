library(shiny)
library(shinythemes)


shinyUI(fluidPage(navbarPage(theme=shinytheme("flatly"),tags$b("WADAC"),br(),
                             tabPanel("Anomaly Detector", 
                                      sidebarLayout(
                                        sidebarPanel(div(style="display:inline-block",actionButton("start","Get Packets"), style="float:right"),
                                                     div(style="display:inline-block",actionButton("stop","STOP!"), style="float:right")
                                        ),                                        
                                        mainPanel(h4("MSE vs Time plot",align="center"),
                                                  plotOutput("anomaly_detector")                  
                                        )
                                      )),
                             tabPanel("Feature Analysis",sidebarLayout(
                               sidebarPanel(),
                               mainPanel(h4("Feature Analysis",align="center"),
                                         plotOutput("af1"),
                                         plotOutput("af2"),
                                         plotOutput("af3")
                               )
                               
                             )),
                             
                             tabPanel("Attack Classification",sidebarLayout(
                               sidebarPanel(),
                               mainPanel(h4("Attack Classification",align = "center"),
                                         plotOutput("attack_class"))
                             )),
                             
                             tabPanel("Attack Features",sidebarLayout(
                               sidebarPanel(),
                               mainPanel(h4("Attack Features",align = "center"),
                                         plotOutput("ac1"),
                                         plotOutput("ac2"),
                                         plotOutput("ac3"),
                                         plotOutput("ac4")
                               )
                             ))
                             
)


))
