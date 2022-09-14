library(oulad)
library(tidyverse)
library(mclust)
library(highcharter)
library(shiny)
library(bs4Dash)
library(waiter)
library(shinycssloaders)
library(DT)
library(callr)
library(data.table)
library(rintrojs)

dashboardPage(
  preloader = list(html = tagList(spin_1(), "Loading ..."), color = "#18191A"),
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
                menuItem("Student Characteristics", tabName = "sc", icon = icon("user-graduate"))),
    sidebarUserPanel(
      name = "Dashboard Information",
      image = "info.jpg"
    ),
    actionButton("show", "Press for Info", icon = icon("circle-info"), status = "primary")
  ), # end of Sidebar
  dashboardBody(
    tabItems(
      tabItem("da",
              fluidPage(
                introjsUI(),
                tags$head(tags$style(".butt{background:#dc3545;} .butt{color: white;}"),
                          tags$style(
                            HTML(".shiny-notification {
             position:fixed;
             top: calc(50%);
             left: calc(50%);
             }
             "
                            )
                          )),
                fluidRow(
                  column(5,
                         introBox(
                           data.step = 1,
                           data.intro = p("This is the Gaussian Mixture Modeling (GMM) Query Box. You are required to press 
                                          ", strong("Submit Query "), 
                                          "with default inputs or enter inputs of your own choosing to generate GMM analysis"),
                           box(title = "Query Box", 
                               solidHeader = TRUE, width = 12,status = "gray-dark",
                               maximizable = FALSE, icon = icon("magnifying-glass"),
                               introBox(
                                 data.step = 2,
                                 data.intro = "This is the academic year (e.g., 2013) and semester (e.g., B/J) you wish to 
                               perform GMM on.",
                                 uiOutput("year_sem_query")),
                               introBox(
                                 data.step = 3,
                                 data.intro = "This is the number of days before the start (0) of the selected year & semester
                               and the number of days after the start (0) of the selected year & semester.",
                                 uiOutput("date_period_query")),
                               introBox(
                                 data.step = 4,
                                 data.intro = "This is the number student engagement levels you want to create to understand 
                               how low and high engaged students interact with the VLE by clicks",
                                 numericInput("gmm_el", "Enter Number of Engagement Levels",
                                              value = 3,
                                              min = 1, max = 25,
                                              width = "auto")),
                               actionButton(inputId = "submit", "Submit Query", status = "danger",
                                            icon = icon("play")),
                               downloadButton("report", "Download Report", class = "butt"),
                               actionButton("help", "User Guide", status = "primary",
                                            icon = icon("circle-info"))))),
                  column(7,
                         introBox(
                           data.step = 5,
                           data.intro = "The chart that will be/is displayed in this box shows how uncertain the GMM model
                           is on assigning students to the selected number of engagement levels. 
                           The uncertainty ranges from 0% - 100%. Uncertainty values close to 100% is an 
                           indication of great uncertainty in assigning students to the different engagement levels.",
                           box(title = "Student Engagement Level Assignment Uncertainty", 
                               width = 12, status = "gray-dark", icon = icon("chart-area"),
                               solidHeader = TRUE, maximizable = TRUE,
                               #verbatimTextOutput("test_output"),
                               highchartOutput("fig1", height = 320))))),
                fluidRow(
                  valueBoxOutput('min_c', width = 3),
                  valueBoxOutput("max_c", width = 3),
                  valueBoxOutput("mean_c", width = 3),
                  valueBoxOutput("mean_u", width = 3)
                ),
                fluidRow(
                  column(6,
                         introBox(
                           data.step = 6,
                           data.intro = "The bar chart that will be/is displayed in this box shows how many times 
                           a student in a particular engagement level interacted with the VLE on average based on clicks for 
                           the selected academic period (year, semester & days).",
                           box(title = "Average Clicks Per Engagement Level", width = 12, status = "gray-dark",
                               solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                               highchartOutput("fig2")))),
                  column(6,
                         introBox(
                           data.step = 7,
                           data.intro = "The bar chart that will be/is displayed in this box shows how many students 
                           belong to each engagement level. This is for easily communicating how many students are highly 
                           engaged or disengaged with the VLE",
                           box(title = "Student Count Per Engagement Level", width = 12, status = "gray-dark",
                               solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                               highchartOutput("fig3"))))),
                fluidRow(
                  column(12,
                         introBox(
                           data.step = 8,
                           data.intro = "The table that will be/is displayed in this box shows the probability of a student 
                    belonging to every engagement level, the engagement level a student belongs to, the uncertainty of 
                    a student belonging to an engagement level, the number of times a student interacted with the materials 
                    in the VLE for the selected academic period.",
                           box(title = "Student Engagement Level Information Table", 
                               icon = icon("table"),
                               solidHeader = TRUE, width = 12,status = "gray-dark", collapsed = TRUE,
                               maximizable = TRUE, withSpinner(DTOutput("table1"))))))
              ) # end of fluid page
      ), # end of GMM data analysis tab
      tabItem("im",
              fluidPage(
                fluidRow(box(title = "Virtual Learning Environment (VLE) Activity Access",
                             width = 12, status = "danger",
                             solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                             uiOutput("activity_el_query"),
                             withSpinner(highchartOutput("fig4")))),
                fluidRow(box(title = "Virtual Learning Environment (VLE) Module or Course Access",
                             width = 12, status = "white", collapsed = FALSE,
                             solidHeader = TRUE, maximizable = TRUE, icon = icon("chart-bar"),
                             withSpinner(highchartOutput("fig5"))))
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