# Student-Segmentation
Web-based Clustering Application Using a Shiny Framework for Determining Student Engagement Levels in Virtual Learning Environments

## Project Overview 
- Explored two clustering algorithms - Gaussian Mixture Model and K-means 
- Compared and evaluated the clutering algorithms using the following metrics:
  - `Clustering Time:` How long it takes the algorithm to fit the data
  - `Silhoutte Coefficient:` Calculates the mean distance between the data points to find the better defined clusters - https://scikit-learn.org/stable/modules/generated/sklearn.metrics.silhouette_score.html#sklearn.metrics.silhouette_score
  - `Calinski-Harabasz Index:` Calculates the ratio of the sum of within and between cluster dispersion for all clusters used to find well-defined clusters - https://scikit-learn.org/stable/modules/generated/sklearn.metrics.calinski_harabasz_score.html
  - `Davies-Bouldin Index:`  Calculates the average similarity between each cluster and its most similar one, used to indicate well-partitioned clusters - https://scikit-learn.org/stable/modules/generated/sklearn.metrics.davies_bouldin_score.html#sklearn.metrics.davies_bouldin_score 
- More information on clustering metrics: https://scikit-learn.org/stable/modules/clustering.html
