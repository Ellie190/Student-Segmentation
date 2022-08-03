# Open University Learning Analytics Dataset
library(oulad)

# Data Analyis and Visualisation
library(tidyverse)

# Statistical Summary
library(tigerstats)

# Gaussian mixture model (GMM)
library(mclust)

# Interactive Data Visualization 
library(highcharter)

library(shiny)
library(bs4Dash)
library(waiter)
library(shinycssloaders)
library(DT)

dashboardPage(
  #preloader = list(html = tagList(spin_1(), "Loading ..."), color = "#18191A"),
  fullscreen = TRUE,
  dashboardHeader(title = dashboardBrand(
    title = "EDM Dashboard",
    color = "danger",
    image = "logo.jpg"
  ),
  titleWidth = 500), # end of header
  dashboardSidebar(
    skin = "light",
    status = "danger",
    sidebarUserPanel(
      name = "Modelling",
      image = "modelling.png"
    ),
    sidebarMenu(
      menuItem("GMM Data Analysis", tabName = "da", icon = icon("magnifying-glass-chart"))),
    sidebarUserPanel(
      name = "Engagement Level EDA",
      image = "data_analysis.jpeg"
    ),
    sidebarMenu(id = "sidebar",
                menuItem("Instructional Methods", tabName = "im", icon = icon("person-chalkboard")),
                menuItem("Student Characteristics", tabName = "sc", icon = icon("user-graduate")))
  ), # end of Sidebar
  dashboardBody(
    tabItems(
      tabItem("da",
              fluidPage(
                tags$head(tags$style(".butt{background:#dc3545;} .butt{color: white;}")),
                fluidRow(
                  column(5,
                         box(title = "Query Box", 
                             solidHeader = TRUE, width = 12,status = "gray-dark",
                             maximizable = FALSE, icon = icon("magnifying-glass"),
                             uiOutput("year_sem_query"),
                             uiOutput("date_period_query"),
                             numericInput("gmm_el", "Enter Number of Engagement Levels",
                                          value = 6,
                                          min = 3, max = 6,
                                          width = "auto"),
                             actionButton(inputId = "submit", "Submit Query", status = "danger",
                                          icon = icon("play")),
                             downloadButton("report", "Download Report", class = "butt"))),
                  column(7,
                         box(title = "Student Engagement Level Assignment Uncertainty", 
                             width = 12, status = "gray-dark", icon = icon("chart-area"),
                             solidHeader = TRUE, maximizable = TRUE,
                             #verbatimTextOutput("test_output"),
                             highchartOutput("fig1", height = 320)))),
                fluidRow(
                  valueBoxOutput('min_c', width = 3),
                  valueBoxOutput("max_c", width = 3),
                  valueBoxOutput("mean_c", width = 3),
                  valueBoxOutput("mean_u", width = 3)
                ),
                fluidRow(
                  column(6,
                         box(title = "Average Clicks Per Engagement Level", width = 12, status = "gray-dark",
                             solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                             highchartOutput("fig2"))),
                  column(6,
                         box(title = "Student Count Per Engagement Level", width = 12, status = "gray-dark",
                             solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                             highchartOutput("fig3")))),
                fluidRow(box(title = "Student Engagement Level Information Table", 
                             solidHeader = TRUE, width = 12,status = "gray-dark", collapsed = TRUE,
                             maximizable = TRUE, withSpinner(DTOutput("table1"))))
              ) # end of fluid page
              ), # end of GMM data analysis tab
      tabItem("im",
              fluidPage(
                fluidRow(box(title = "Virtual Learning Environment (VLE) Activity Access",
                             width = 12, status = "danger",
                             solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                             uiOutput("activity_el_query"),
                             highchartOutput("fig4"))),
                fluidRow(box(title = "Virtual Learning Environment (VLE) Module or Course Access",
                             width = 12, status = "white", collapsed = TRUE,
                             solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                             # uiOutput("activity_el_query"),
                             highchartOutput("fig5")))
              ) # end of fluid page
              ), # end of instructional methods tab
      tabItem("sc",
              fluidPage(
                fluidRow(
                  column(5,
                         box(title = "Gender", width = 12, status = "gray-dark",
                             solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                             highchartOutput("fig6"))),
                  column(7,
                         box(title = "Age Band", width = 12, status = "gray-dark",
                             solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                             highchartOutput("fig7")))),
                fluidRow(
                  column(5,
                         box(title = "Disability", width = 12, status = "gray-dark",
                             solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                             highchartOutput("fig8"))),
                  column(7,
                         box(title = "Number of Previous Attempts", width = 12, status = "gray-dark",
                             solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                             highchartOutput("fig9")))),
                fluidRow(
                  tabBox(maximizable = TRUE, width = 12,
                         solidHeader = FALSE, status = "white", selected = "Region of Stay",
                         tabPanel("Final Academic Result", icon = icon("chart-bar"),
                                  highchartOutput("fig10")),
                         tabPanel("Region of Stay", icon = icon("chart-bar"),
                                  uiOutput("region_el_query"),
                                  highchartOutput("fig11")))
                )
              ) # end of fluid page
              ) # end of student characteristics tab
    ) # end of tab items
  ) # end of body
) # end of page