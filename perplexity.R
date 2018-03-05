library(tm)
library(NLP)
library(topicmodels)
library(servr)
#library(parallel)
library(foreach)
library(ggplot2)
library(scales)
library(doParallel)

setwd("D:/Study/Knoesis/Zika/Data/Testing 31-10-2016/test")
filenames <- list.files(getwd(),pattern="*.txt")
files <- lapply(filenames,readLines)
docs <- Corpus(VectorSource(files))
toremove <- content_transformer(function(x, pattern) { return (gsub(pattern, "", x))})
docs <- tm_map(docs, toremove, "'")
docs <- tm_map(docs, toremove, '"')
toSpace <- content_transformer(function(x, pattern) { return (gsub(pattern, " ", x))})
docs <- tm_map(docs, toSpace, "-")
docs <- tm_map(docs, toSpace, "•")
docs <- tm_map(docs, removePunctuation)
docs <- tm_map(docs, removeNumbers)
docs <- tm_map(docs, stripWhitespace)
docs <- tm_map(docs, stemDocument)
#define and eliminate all custom stopwords
new_stop_words <- c("a", "an", "the", "is", "of", "to", "on", "for", "in", "at", "by", "and","it","be","so","this","that",
"or","you","will","we","are","your","be","how","what","can","from","as","zika","virus", "about", "like", "but", "my", "dont", "more",
 "all", "now", "not", "there", "if", "just")
doc.list<- strsplit(docs[[1]]$content, "[[:space:]]+")
term.table <- table(unlist(doc.list))
term.table <- sort(term.table, decreasing = TRUE)
del <- names(term.table) %in%  new_stop_words | term.table < 5 | nchar(names(term.table)) < 2
term.table <- term.table[!del]
#term.table <- term.table[term.table > 5]
#vocab <- names(term.table)
chunk <- 500
n <- length(del)
r <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
d <- split(del,r)
for (i in 1:length(d)) {
  docs <- tm_map(docs, removeWords, c(paste(d[[i]])))
}
data <- DocumentTermMatrix(docs)
K <- 5
iter <- 50
keep <- 50
burnin <- 1000
D <- ncol(data)
cluster <- makeCluster(detectCores(logical = TRUE) - 1)
registerDoParallel(cluster)
clusterEvalQ(cluster, {
   library(topicmodels)
})
folds <- 10
splitfolds <- sample(1:folds, D, replace = TRUE)
candidate_k <- c(2,3,4,5,6,7,8,9,10,15,20,30,40,50,100)
clusterExport(cluster, c("data", "burnin", "iter", "keep", "splitfolds", "folds", "candidate_k"))
system.time({
results <- foreach(j = 1:length(candidate_k), .combine = rbind, .packages='foreach') %dopar%{
   k <- candidate_k[j]
   results_1k <- matrix(0, nrow = folds, ncol = 2)
   colnames(results_1k) <- c("k", "perplexity")
   for(i in 1:folds){
      train_set <- data[,splitfolds != i]
      valid_set <- data[,splitfolds == i]
      fitted <- LDA(train_set, k = k, method = "Gibbs", control = list(burnin = burnin, iter = iter, keep = keep) )
      results_1k[i,] <- c(k, perplexity(fitted, newdata = valid_set))
   }
   return(results_1k)
}
})
stopCluster(cluster)
results_df <- as.data.frame(results)
ggplot(results_df, aes(x = k, y = perplexity)) +
   geom_point() +
   geom_smooth(se = FALSE) +
   ggtitle("10-fold cross-validation of topic modelling with the 'prevention' dataset") +
   labs(x = "Candidate number of topics", y = "Perplexity when fitting the trained model to the hold-out set")


