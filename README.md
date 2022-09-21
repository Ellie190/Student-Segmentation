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
- Built a R Shiny dashboard with three main functionalities: GMM cluster Analysis, User Guide, Descriptive Analysis
