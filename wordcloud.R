#Code for Topic Modeling using LDA (Gibbs Sampling method) and also implements wordcloud for visulaization of the results

library(tm)
library(NLP)
library(topicmodels)
library(lda)
library(servr)
library(foreach)
library(ggplot2)
library(scales)
library(doParallel)
library(RColorBrewer)
library(magrittr)
library(dplyr)
library(tidyr)
library(wordcloud)

setwd("folder path")
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
docs <- tm_map(docs,stemDocument)

#define and eliminate all custom stopwords
new_stop_words <- c("a", "an", "the", "is", "of", "to", "on", "for", "in", "at", "by", "and","it","be","so","this","that",
"or","you","will","we","are","your","be","how","what","can","from","as","zika","virus", "about", "like", "but", "my", "dont", "more",
 "all", "now", "not", "there", "if", "just")
doc.list<- strsplit(docs[[1]]$content, "[[:space:]]+")
term.table <- table(unlist(doc.list))
term.table <- sort(term.table, decreasing = TRUE)
del <- names(term.table) %in%  new_stop_words | term.table < 5 | nchar(names(term.table)) < 2
term.table <- term.table[!del]
vocab <- names(term.table)

get.terms <- function(x) {
  index <- match(x, vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
}
documents <- lapply(doc.list, get.terms)
D <- length(documents)  # number of documents 
W <- length(vocab)  # number of terms in the vocab 
doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens per document 
N <- sum(doc.length)  # total number of tokens in the data 
term.frequency <- as.integer(term.table)

K <- 5
G <- 500
alpha <- 0.02
eta <- 0.02

# Fit the model:
library(lda)
set.seed(357)
t1 <- Sys.time()
fit <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = vocab, 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)
t2 <- Sys.time()
t2 - t1  # about 24 minutes on laptop
theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))
n <- 100
palette = "Greens"
w1 <- as.data.frame(t(phi)) 
w2 <- w1 %>%
   mutate(word = rownames(w1)) %>%
   gather(topic, weight, -word) 
pal <- rep(brewer.pal(9, palette), each = ceiling(n / 9))[n:1]
wd <- setwd(tempdir())
unlink("*.png")
for(i in 1:ncol(w1)){
   file <- paste0("destination path for wordcloud", i)
   png(paste0(file, ".png"), 8 * 100, 8 * 100, res = 100)
   par(bg = "grey95")
   w3 <- w2 %>%
      filter(topic == paste0("V",i)) %>%
      arrange(desc(weight))
   with(w3[1:n, ], 
        wordcloud(word, freq = weight, random.order = FALSE, ordered.colors = TRUE, colors = pal))
   title(paste("Topic", i))
   dev.off()
}