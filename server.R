server <- function(input, output, session) {
  
  # To yield consistent random results
  set.seed(1837)
  # Exclude scientific outputs 
  options(scipen=999)
  
  svle_df <- reactive({
    student_vle
  })
  
  output$year_sem_query <- renderUI({
    selectInput('sel_year_sem',
                label = "Select Academic Year & Semester",
                choices = unique(svle_df()$code_presentation),
                multiple = TRUE,
                selected = c("2013B", "2013J", "2014B", "2014J"))
  })
  
  output$date_period_query <- renderUI({
    sliderInput("sel_date_period", label = "Select the Number of days since start/end of year/semester",
                min = min(svle_df()$date), 
                max =  max(svle_df()$date), 
                step = 1,
                value = c(min(svle_df()$date), max(svle_df()$date)))
  })
  
  clicks_df <- reactive({
    req(input$sel_date_period[1])
    req(input$sel_date_period[2])
    req(input$sel_year_sem)
    svle_df() %>% 
      filter(date >= input$sel_date_period[1] & date <= input$sel_date_period[2] &
               code_presentation %in% input$sel_year_sem) %>%
      group_by(id_student) %>% 
      summarise(sum_click = sum(sum_click))
  })
  
  gmm_df <- reactive({
    select(clicks_df(), sum_click)
  })
  
  gmm_model <- reactive({
    req(input$gmm_el)
    gmm_model <- Mclust(gmm_df(), G=input$gmm_el, verbose = FALSE)
    gmm_model
  })
  
  clicks_df2 <- reactive({
    clicks_df <- clicks_df()
    clicks_df$engagement_level <- gmm_model()$classification
    clicks_df$uncertainty <- gmm_model()$uncertainty
    clicks_df
  })
  
  engagement_level_probabilities <- reactive({
    engagement_level_probabilities <- gmm_model()$z
    colnames(engagement_level_probabilities) <- paste0('engagement_level', 1:gmm_model()$G)
    options(scipen=999)
    # Create probabilities data frame
    engagement_level_probabilities <- engagement_level_probabilities %>%
      round(2) %>% 
      as.data.frame()
    # Add engagement level belonging of student
    engagement_level_probabilities$engagement_level <- clicks_df2()$engagement_level
    engagement_level_probabilities$uncertainty <- round(gmm_model()$uncertainty*100,2)
    engagement_level_probabilities$sum_click <- clicks_df2()$sum_click
    engagement_level_probabilities$id_student <- clicks_df2()$id_student
    engagement_level_probabilities
  })
  
  # Engagement Level Mean and Count
  engagement_level_stats <- reactive({
    # Engagement level mean table 
    engagement_level_avg_df <- as.data.frame(round(gmm_model()$parameters$mean))
    colnames(engagement_level_avg_df) <- "average_clicks"
    # Rename rownames to engagement_level 
    engagement_level_avg_df <- cbind(engagement_level = rownames(engagement_level_avg_df), engagement_level_avg_df)
    # Remove rownames 
    rownames(engagement_level_avg_df) <- NULL
    
    # Engagement level count table
    # Obtain number of observations in each cluster. 
    engagement_level_count_df <- clicks_df2() %>%
      group_by(engagement_level) %>%
      summarise(Number_of_students = n()) 
    engagement_level_stats <- merge(engagement_level_avg_df, engagement_level_count_df) %>% 
      arrange(average_clicks)
    engagement_level_stats
  })
  
  output$fig1 <- renderHighchart({
    hchart(engagement_level_probabilities()$uncertainty, color = "#B71C1C", name = "Uncertainty") %>% 
      hc_title(
        text = paste0("Distribution of Engagement Level Assignment Uncertainty")
      ) %>% 
      hc_xAxis(title = list(text = "Uncertainty"),
               labels = list(format = "{value}%")) %>% 
      hc_yAxis(title = list(text = "Number of Students"))
  })
  
  output$fig2 <- renderHighchart({
    hchart(engagement_level_stats(), "column", hcaes(x = engagement_level, y = average_clicks), 
           dataLabels = list(enabled = TRUE),
           name = "Average No. of Clicks") %>% 
      hc_title(
        text = paste0("Average Number of Clicks for Each Engagement Level")
      ) %>% 
      hc_xAxis(title = list(text = "Engagement Level")) %>% 
      hc_yAxis(title = list(text = "Average Number of Clicks"))%>% 
      hc_exporting(
        enabled = TRUE)
  })
  
  output$fig3 <- renderHighchart({
    hchart(engagement_level_stats(), "column", hcaes(x = engagement_level, y = Number_of_students), 
           dataLabels = list(enabled = TRUE),
           name = "No of Students") %>% 
      hc_title(
        text = paste0("Number of Students in Each Engagement Level")
      ) %>% 
      hc_xAxis(title = list(text = "Engagement Level")) %>% 
      hc_yAxis(title = list(text = "Number of Students")) %>% 
      hc_exporting(
        enabled = TRUE)
  })
  
  # Number formatting
  f1 <- function(num) {
    format(num, big.mark = ' ')
  }
  
  # Minimum Number of clicks
  min_clicks <- reactive({
    min_df <- engagement_level_probabilities() %>%
      summarise(min = f1(min(sum_click)))
    min_df$min
  })
  
  # Maximum Number of clicks
  max_clicks <- reactive({
    max_df <- engagement_level_probabilities() %>%
      summarise(max = f1(max(sum_click)))
    max_df$max
  })
  
  # Mean Number of clicks
  mean_clicks <- reactive({
    mean_df <- engagement_level_probabilities() %>%
      summarise(mean = f1(round(mean(sum_click),2)))
    mean_df$mean
  })
  
  # Mean Number of clicks
  mean_uncertainty<- reactive({
    mean_df <- engagement_level_probabilities() %>%
      summarise(mean = f1(round(mean(uncertainty),2)))
    mean_df$mean
  })
  
  output$test_output <- renderPrint({
    engagement_level_stats()
  })
  
  # Value boxes
  output$min_c <- renderValueBox({
    valueBox(
      value = min_clicks(),
      subtitle = "Min No. of Clicks",
      color = "warning",
      icon = icon("coins"),
      gradient = TRUE
      
    )
  })
  
  output$max_c <- renderValueBox({
    valueBox(
      value = max_clicks(),
      subtitle = "Max No. of Clicks",
      color = "warning",
      icon = icon("coins"),
      gradient = TRUE
      
    )
  })
  
  output$mean_c <- renderValueBox({
    valueBox(
      value = mean_clicks(),
      subtitle = "Avg No. of Clicks",
      color = "warning",
      icon = icon("coins"),
      gradient = TRUE
      
    )
  })
  
  output$mean_u <- renderValueBox({
    valueBox(
      value = mean_uncertainty(),
      subtitle = "Avg Uncertainty %",
      color = "warning",
      icon = icon("coins"),
      gradient = TRUE
      
    )
  })
  
  # Data Table
  output$table1 <- renderDT({
    DT::datatable(engagement_level_probabilities(),
                  rownames = F,
                  options = list(pageLength = 5, scrollX = TRUE, info = FALSE,
                                 initComplete = JS(
                                   "function(settings, json) {",
                                   "$(this.api().table().header()).css({'background-color': '#7cb5ec', 'color': 'black'});",
                                   "}")))
  })
  

  

}