#Topic Modeling
Topic modeling is a statistical method to discover the underlying abstract topics in a collection of documents (unlabelled text). Topic models uses contextual clues to connect similar meaning words and generates a topic for a cluster of words which co-occur frequently.

## LDA
[Latent Dirichlet Allocation (LDA)](http://www.jmlr.org/papers/volume3/blei03a/blei03a.pdf) is a common method of topic modelling. LDA is a generative probabilistic model for discovering the hidden topics within the data set and helps to unravel more information regarding the data. The only observable features that the model sees are the words appearing in documents, other parameters such as topics are latent or inferred. The user need to tell the LDA model how many topics it should make and some extra rules on how they should be constructed. The output for LDA is mixtures of topics that contains words with certain probabilities.

## Perplexity measure
When dealing with probabilistic model such as LDA, the most common way to measure is by log-likelihood. A low perplexity indicates the probability distribution is good at predicting the sample. Different number of topics were chosen for LDA topic modelling and perplexity is computed for each and the best number is chosen based on this measure, thereby helping us to get the number of topics for topic modelling for the given dataset. [Click here for the code.](perplexity.R)

## LDAvis
An interactive visualization tool called LDAvis was used for topic modelling to explore and discover or interpret the meaning of the different topics. We could see the words involved in each topic and get more information from the data. Once the words are clustered we can observe the frequency of words in each cluster and helps us to assign a topic name. [Click here for the code.](Ldavis.R)


## Word cloud
Word clouds as known as text cloud or tag cloud were generated for each topic to get the visual representation of text data within the topic. The format of the word or tag is depended on the relative prominence which was based on the probability distribution of these words with each topic. [Click here for the code.](wordcloud.R)