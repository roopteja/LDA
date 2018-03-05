library(LDAvis)
library(tm)
library(NLP)
library(topicmodels)
library(lda)
library(servr)

setwd("D:/Study/Knoesis/Zika/Data/other/single")
filenames <- list.files(getwd(),pattern="*.txt")
files <- lapply(filenames,readLines)
docs <- Corpus(VectorSource(files))
docs <-tm_map(docs,content_transformer(tolower))
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
stop_words <- c("a", "an", "the", "is", "of", "to", "on", "for", "in", "at", "by", "and", "it", "be", "so", "this", "that",
"or", "you", "will", "we", "are", "your", "be", "how", "what", "can", "from", "as", "about", "like", "but", "my", "dont", "more",
 "all", "now", "not", "there", "if", "just", "was", "has", "have", "they", "with", "went", "he", "had", "did", "then", "since", 
"get", "would", "when", "were", "which", "been", "their", "isn't", "into", "it", "his", "it'", "didn't")
doc.list<- strsplit(docs[[1]]$content, "[[:space:]]+")

term.table <- table(unlist(doc.list))
term.table <- sort(term.table, decreasing = TRUE)
del <- names(term.table) %in%  stop_words | term.table < 5 | nchar(names(term.table)) < 2

term.table <- term.table[!del]
vocab <- names(term.table)

get.terms <- function(x) {
  index <- match(x, vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
}
documents <- lapply(doc.list, get.terms)
D <- length(documents)  # number of documents (2,000)
W <- length(vocab)  # number of terms in the vocab (14,568)
doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens per document [312, 288, 170, 436, 291, ...]
N <- sum(doc.length)  # total number of tokens in the data (546,827)
term.frequency <- as.integer(term.table)

K <- 5
G <- 5000
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
zika <- list(phi = phi,
                     theta = theta,
                     doc.length = doc.length,
                     vocab = vocab,
                     term.frequency = term.frequency)

json <- createJSON(phi = zika$phi, 
                   theta = zika$theta, 
                   doc.length = zika$doc.length, 
                   vocab = zika$vocab, 
                   term.frequency = zika$term.frequency, R = 15)

serVis(json, out.dir = 'ldavis', open.browser = FALSE)

