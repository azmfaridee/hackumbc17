rm(list=ls())
library(tm)


#query <- c('Stacy Branham is a Lecturer in the Department of Information Systems at UMBC. Dr. Branham's teaching focuses on making computing more appealing, accessible, and welcoming to first-year students towards increasing retention and diversity. Dr. Branham's research focuses on the role of computer technologies in mediating communication between significant others, friends, and colleagues. She works with populations that exhibit cross-cultural communication: people who are blind and people who are sighted; students and teachers; women and men. Through qualitative field studies and participant-observer engagements, she reflects on the design of technologies that can foster empathic communication--a form of talking that involves sharing, intimate connection, and mutual growth.')

#dgfdfd


# build a corpus, and specify the source to be character vectors
myCorpus <- Corpus(VectorSource(query))

# convert to lower case
myCorpus <- tm_map(myCorpus, content_transformer(tolower))

# remove punctuation
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))

# remove stopwords
myStopwords <- c(setdiff(stopwords('english'), c("r", "big")),
                 "use", "see", "used", "via", "amp")
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)
# remove extra whitespace
myCorpus <- tm_map(myCorpus, stripWhitespace)
# keep a copy for stem completion later
myCorpusCopy <- myCorpus