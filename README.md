# Student-Segmentation
Web-based Clustering Application Using a Shiny Framework for Determining Student Engagement Levels in Virtual Learning Environments

## Project Overview 
- Explored two clustering algorithms - Gaussian Mixture Model and K-means 
- Compared and evaluated the clutering algorithms using the following metrics:
  - `Clustering Time:` How long it takes the algorithm to fit the data
  - `Silhoutte Coefficient (SC):` Calculates the mean distance between the data points to find the better defined clusters - [SC scikit-learn](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.silhouette_score.html#sklearn.metrics.silhouette_score)
  - `Calinski-Harabasz Index (CHI):` Calculates the ratio of the sum of within and between cluster dispersion for all clusters used to find well-defined clusters - [CHI scikit-learn](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.calinski_harabasz_score.html)
  - `Davies-Bouldin Index (DBI):`  Calculates the average similarity between each cluster and its most similar one, used to indicate well-partitioned clusters - [DBI scikit-learn](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.davies_bouldin_score.html#sklearn.metrics.davies_bouldin_score)
- More information on clustering metrics: https://scikit-learn.org/stable/modules/clustering.html
- Built a R Shiny dashboard with three main functionalities: `GMM cluster Analysis`, `User Guide`, `Descriptive Analysis`

## Methodology 
Knowledge Discovery in Database (KDD) Methodology

## Context 
- Higher Educational Institutions are greatly relying on online learning platforms, such as Moodle, Blackboard, Canvas and etc to assess, communicate and share resources with students. 
- These platforms capture and store each user's online interaction data in the system (both students and educators) by generating large and varied data sets providing the opportunity to discover valuable information
- Opportunity - using clustering algorithms:
  - To determine low engaged students online
  - To understand the different students engaging with online learning platforms
  - To perform student segmentation 
  - To provide personalised support students to students engaging with the platforms differently

## Resources 
**R Version:** RStudio 2022.07.1+554 "Spotted Wakerobin" Release (7872775ebddc40635780ca1ed238934c3345c5de, 2022-07-22) for Windows
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) QtWebEngine/5.12.8 Chrome/69.0.3497.128 Safari/537.36 <br>
**Libraries:** `tidyverse`, `mclust`, `highcharter`, `shiny`, `bs4Dash`, `waiter`, `shinycssloaders`, `DT`, `callr`, `data.table`, `rintrojs`, `readxl`, `lubridate`, `oulad` <br>
**Open University Learning Analytics Dataset (OULAD):** https://analyse.kmi.open.ac.uk/open_dataset




 
