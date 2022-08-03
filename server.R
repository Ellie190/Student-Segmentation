server <- function(input, output, session) {
  
  # To yield consistent random results
  set.seed(1837)
  # Exclude scientific outputs 
  options(scipen=999)
  
  # GMM DATA ANALYSIS ----
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
    sliderInput("sel_date_period", label = "Select the Number of days since start-end of year & semester",
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
    hchart(engagement_level_probabilities()$uncertainty, color = "#B71C1C", name = "GMM Uncertainty") %>% 
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
      summarise(mean = f1(round(mean(sum_click),0)))
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
      subtitle = "Minimum No. of Clicks",
      color = "danger",
      icon = icon("computer-mouse"),
      gradient = TRUE
      
    )
  })
  
  output$max_c <- renderValueBox({
    valueBox(
      value = max_clicks(),
      subtitle = "Maximum No. of Clicks",
      color = "danger",
      icon = icon("computer-mouse"),
      gradient = TRUE
      
    )
  })
  
  output$mean_c <- renderValueBox({
    valueBox(
      value = mean_clicks(),
      subtitle = "Average No. of Clicks",
      color = "danger",
      icon = icon("computer-mouse"),
      gradient = TRUE
      
    )
  })
  
  output$mean_u <- renderValueBox({
    valueBox(
      value = paste0(mean_uncertainty(), "%"),
      subtitle = "Average GMM Uncertainty",
      color = "danger",
      icon = icon("laptop-code"),
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
  
 # INSTRUCTIONAL METHODS ----
  
  # Merging the dataframes to link students with activities
  # Long execution code
  
  output$activity_el_query <- renderUI({
    selectizeInput('activity_el_sel',
                   label = "Select Engagement Level(s) to Visual/Compare",
                   choices = 1:6,
                   selected = 1:3,
                   multiple = TRUE,
                   options = list(maxItems = 3))
  })
  
  svle_vle_df <- reactive({
    svle_vle_df <- data.table::merge.data.table(student_vle, vle, by = "id_site")
    svle_vle_df
  })
    
  # Long execution code
  # Number of Times student accessed an activity 
  activity_df <- reactive({
    activity_df <- svle_vle_df() %>% 
      group_by(id_student,activity_type) %>% 
      summarise(activity_access_count = n()) %>% 
      as.data.frame()
    activity_df
  })
    
    
  clicks_activity_df <- reactive({
    # Merging data frames
    clicks_activity_df <- merge.data.table(activity_df(), clicks_df2(), by = "id_student")
    clicks_activity_df
  })
    
    activity_stats <- reactive({
      activity_stats <- clicks_activity_df() %>% 
        filter(engagement_level %in% input$activity_el_sel) %>% 
        group_by(engagement_level, activity_type) %>%
        summarise(activity_access_count = n()) %>% 
        mutate(activity_access_percent = round(activity_access_count / sum(activity_access_count) * 100, 1)) %>% 
        arrange(desc(activity_access_percent))
      activity_stats
    })
    
  
  output$fig4 <- renderHighchart({
    hchart(activity_stats(), "column", hcaes(x = activity_type, y = activity_access_percent, group = engagement_level), 
           dataLabels = list(enabled = TRUE, format = "{y}"),
           stacking = "normal") %>% 
      hc_title(
        text = paste0("Percentage of Students that Access each VLE Activity in Engagement Level")
      ) %>% 
      hc_xAxis(title = list(text = "VLE Activity")) %>% 
      hc_yAxis(title = list(text = "Percentage of Students"),
               labels = list(format = "{value}%")) %>% 
      hc_legend(title = list(text = "Engagement Level")) %>% 
      hc_exporting(
        enabled = TRUE) 
  })
  
  # Merging with student info data frame
  clicks_student_df <- reactive({
    clicks_student_df <- merge.data.table(student, clicks_df2(), by = "id_student")
    clicks_student_df
  })
  
  module_stats <- reactive({
    module_stats <- clicks_student_df() %>% 
      filter(engagement_level %in% c(1:6)) %>% # default: all
      group_by(engagement_level, code_module) %>%
      summarise(number_of_students = n()) %>% 
      mutate(percentage_of_students = round(number_of_students / sum(number_of_students) * 100, 1)) %>% 
      arrange(desc(percentage_of_students))
    module_stats
  })
  
  output$fig5 <- renderHighchart({
    hchart(module_stats(), "column", hcaes(x = code_module, y = percentage_of_students, group = engagement_level), 
           dataLabels = list(enabled = TRUE, format = "{y}%")) %>% 
      hc_title(
        text = paste0("Modules Accessed by Engagement Level(s):")
      ) %>% 
      hc_xAxis(title = list(text = "Module")) %>% 
      hc_yAxis(title = list(text = "Percentage of Students"), 
               labels = list(format = "{value}%")) %>% 
      hc_legend(title = list(text = "Engagement Level")) %>% 
      hc_exporting(
        enabled = TRUE)
  })
  
  # STUDENT CHARACTERISTICS ----
  
  gender_stats <- reactive({
    gender_stats <- clicks_student_df() %>% 
      filter(engagement_level %in% c(1:6)) %>% # default: all
      group_by(engagement_level, gender) %>%
      summarise(number_of_students = n()) %>% 
      mutate(percentage_of_students = round(number_of_students / sum(number_of_students) * 100, 1)) %>% 
      arrange(desc(percentage_of_students))
    gender_stats
  })
  
  output$fig6 <- renderHighchart({
    hchart(gender_stats(), "column", hcaes(x = gender, y = percentage_of_students, group = engagement_level), 
           dataLabels = list(enabled = TRUE, format = "{y}%")) %>% 
      hc_title(
        text = paste0("Gender Representation in Engagement Level(s):")
      ) %>% 
      hc_xAxis(title = list(text = "Gender")) %>% 
      hc_yAxis(title = list(text = "Percentage of Students"), 
               labels = list(format = "{value}%")) %>% 
      hc_legend(title = list(text = "Engagement Level")) %>% 
      hc_exporting(
        enabled = TRUE)
  })
  
  age_stats <- reactive({
    age_stats <- clicks_student_df() %>% 
      filter(engagement_level %in% c(1:6)) %>% # default: all
      group_by(engagement_level, age_band) %>%
      summarise(number_of_students = n()) %>% 
      mutate(percentage_of_students = round(number_of_students / sum(number_of_students) * 100, 1)) %>% 
      arrange(desc(percentage_of_students))
    age_stats
  })
  
  output$fig7 <- renderHighchart({
    hchart(age_stats(), "column", hcaes(x = age_band, y = percentage_of_students, group = engagement_level), 
           dataLabels = list(enabled = TRUE, format = "{y}%")) %>% 
      hc_title(
        text = paste0("Student Age Band Representation in Engagement Level(s):")
      ) %>% 
      hc_xAxis(title = list(text = "Age Band")) %>% 
      hc_yAxis(title = list(text = "Percentage of Students"), 
               labels = list(format = "{value}%")) %>% 
      hc_legend(title = list(text = "Engagement Level")) %>% 
      hc_exporting(
        enabled = TRUE)
  })
  
  disability_stats <- reactive({
    disability_stats <- clicks_student_df() %>% 
      filter(engagement_level %in% c(1:6)) %>% # default: all
      group_by(engagement_level, disability) %>%
      summarise(number_of_students = n()) %>% 
      mutate(percentage_of_students = round(number_of_students / sum(number_of_students) * 100, 1)) %>% 
      arrange(desc(percentage_of_students))
    disability_stats$disability <- as.character(disability_stats$disability)
    disability_stats
  })
  
  output$fig8 <- renderHighchart({
    hchart(disability_stats(), "column", hcaes(x = disability, y = percentage_of_students, group = engagement_level), 
           dataLabels = list(enabled = TRUE, format = "{y}%")) %>% 
      hc_title(
        text = paste0("Student with/without a Disability Representation in Engagement Level(s):")
      ) %>% 
      hc_xAxis(title = list(text = "Disability")) %>% 
      hc_yAxis(title = list(text = "Percentage of Students"), 
               labels = list(format = "{value}%")) %>% 
      hc_legend(title = list(text = "Engagement Level")) %>% 
      hc_exporting(
        enabled = TRUE)
  })
  
  prev_attempts_stats <- reactive({
    prev_attempts_stats <- clicks_student_df() %>% 
      filter(engagement_level %in% c(1:6)) %>% # default: all
      group_by(engagement_level, num_of_prev_attempts) %>%
      summarise(number_of_students = n()) %>% 
      mutate(percentage_of_students = round(number_of_students / sum(number_of_students) * 100, 1)) %>% 
      arrange(desc(percentage_of_students))
    prev_attempts_stats$num_of_prev_attempts <- as.character(prev_attempts_stats$num_of_prev_attempts)
    prev_attempts_stats
  })
  
  output$fig9 <- renderHighchart({
    hchart(prev_attempts_stats(), "column", hcaes(x = num_of_prev_attempts, 
                                                y = percentage_of_students, group = engagement_level), 
           dataLabels = list(enabled = TRUE, format = "{y}%")) %>% 
      hc_title(
        text = paste0("Number of Previous Attempts in Course according to each Engagement Level")
      ) %>% 
      hc_xAxis(title = list(text = "Number of Previous Attempts")) %>% 
      hc_yAxis(title = list(text = "Percentage of Students"), 
               labels = list(format = "{value}%")) %>% 
      hc_legend(title = list(text = "Engagement Level")) %>% 
      hc_exporting(
        enabled = TRUE)
  })
  
  final_results_stats <- reactive({
    final_results_stats <- clicks_student_df() %>% 
      filter(engagement_level %in% c(1:6)) %>% # default: all
      group_by(engagement_level, final_result) %>%
      summarise(number_of_students = n()) %>% 
      mutate(percentage_of_students = round(number_of_students / sum(number_of_students) * 100, 1)) %>% 
      arrange(desc(percentage_of_students))
    final_results_stats
  })
  
  output$fig10 <- renderHighchart({
    hchart(final_results_stats(), "column", hcaes(x = final_result, 
                                                y = percentage_of_students, group = engagement_level), 
           dataLabels = list(enabled = TRUE, format = "{y}%")) %>% 
      hc_title(
        text = paste0("Student Final Academic Outcome in each Engagement Level")
      ) %>% 
      hc_xAxis(title = list(text = "Final Result")) %>% 
      hc_yAxis(title = list(text = "Percentage of Students"), 
               labels = list(format = "{value}%")) %>% 
      hc_legend(title = list(text = "Engagement Level")) %>% 
      hc_exporting(
        enabled = TRUE)
  })
  
  output$region_el_query <- renderUI({
    selectizeInput('region_el_sel',
                   label = "Select Engagement Level(s) to Visual/Compare",
                   choices = 1:6,
                   selected = 1:3,
                   multiple = TRUE,
                   options = list(maxItems = 3))
  })
  
  region_stats <- reactive({
    region_stats <- clicks_student_df() %>% 
      filter(engagement_level %in% input$region_el_sel) %>% # default: all
      group_by(engagement_level, region) %>%
      summarise(number_of_students = n()) %>% 
      mutate(percentage_of_students = round(number_of_students / sum(number_of_students) * 100, 1)) %>% 
      arrange(desc(percentage_of_students))
    region_stats
  })
  
  output$fig11 <- renderHighchart({
    hchart(region_stats(), "column", hcaes(x = region, y = percentage_of_students, group = engagement_level), 
           dataLabels = list(enabled = TRUE, format = "{y}%")) %>% 
      hc_title(
        text = paste0("Engagement Level Representation based on Student's Region of Stay")
      ) %>% 
      hc_xAxis(title = list(text = "Regions")) %>% 
      hc_yAxis(title = list(text = "Percentage of Students"), 
               labels = list(format = "{value}%")) %>% 
      hc_legend(title = list(text = "Engagement Level")) %>% 
      hc_exporting(
        enabled = TRUE)
  })
  
  
  
  
  
  
  
  
  

}