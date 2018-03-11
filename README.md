#Topic Modeling
Topic modeling is a statistical method to discover the underlying abstract topics in a collection of documents (unlabelled text). Topic models uses contextual clues to connect similar meaning words and generates a topic for a cluster of words which co-occur frequently.

## LDA
Latent Dirichlet Allocation (LDA) is a common method of topic modelling(https://github.com/facebook/react/wiki/Sites-Using-React). LDA is a generative probabilistic model for collections of discrete data such as text corpora. It is a popular statistical model for discovering the hidden topics within the data set and helps to unravel more information regarding the data. LDA was developed by David M. Blei, Andrew Y. Ng and Michael I. Jordan in 2003 and since then has seen many areas of application document classification sentiment analysis even bio informatics. The only observable features that the model sees are the words appearing in documents, other parameters such as topics are latent or inferred. LDA is a bag of words model so there's no syntax rules. It assumes that the words in the same document are related and then try tries to learn a model that would explain how such document collection could have been generated in the first place. The user need to tell the LDA model how many topics it should make and some extra rules on how they should be constructed.The output for LDA is mixtures of topics that contains words with certain probabilities. 	

## Perplexity measure
When dealing with probabilistic model such as LDA, the most common way to measure is by log-likelihood. A low perplexity indicates the probability distribution is good at predicting the sample. We train the LDA) on the training set, and then you see how perplexed the model is on the testing set. Different number of topics were chosen for LDA topic modelling and perplexity was computed for each and the best number was chosen based on this measure, thereby helping us to get the number of topics for topic modelling for the given dataset.

##LDAvis
An interactive visualization tool called LDAvis was used for topic modelling to explore topic modelling and discover or interpret the meaning of the different topics.

##Word cloud
Word clouds as known as text cloud or tag cloud were generated for each topic to get the visual representation of text data within the topic. The format of the word or tag is depended on the relative prominence which was based on the probability distribution of these words with each topic.