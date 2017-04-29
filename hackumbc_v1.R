rm(list=ls())
library(tm)

#ref: http://www.rdatamining.com/docs/twitter-analysis-with-r

query <- c('Stacy Branham is a Lecturer in the Department of Information Systems at UMBC. Dr. Branham\'s teaching focuses on making computing more appealing, accessible, and welcoming to first-year students towards increasing retention and diversity. Dr. Branham\'s research focuses on the role of computer technologies in mediating communication between significant others, friends, and colleagues. She works with populations that exhibit cross-cultural communication: people who are blind and people who are sighted; students and teachers; women and men. Through qualitative field studies and participant-observer engagements, she reflects on the design of technologies that can foster empathic communication--a form of talking that involves sharing, intimate connection, and mutual growth.')


# build a corpus, and specify the source to be character vectors
myCorpus <- Corpus(VectorSource(query))

# convert to lower case
myCorpus <- tm_map(myCorpus, content_transformer(tolower))

# remove punctuation
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))

# remove stopwords
myStopwords <- stopwords('english')
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

# remove extra whitespace
myCorpus <- tm_map(myCorpus, stripWhitespace)

# keep a copy
myCorpusCopy <- myCorpus


#tdm
tdmtemp <- TermDocumentMatrix(myCorpus,control = list(wordLengths = c(1, Inf)))
tdm <- as.matrix(tdmtemp[,])

tdmvec <- as.vector(tdm[,])
names(tdmvec) <- rownames(tdm)


#orpus bag of words
corpbow <- c(rownames(tdm),'web','retrieval','data','mining')



#convert it to term vector with terms from the corpus
querytv <- termVectorConv(corpbow, tdmvec)

termVectorConv <- function(corpbow,tdmvec){
  a <- corpbow
  b <- tdmvec
  
  res <- rep(NA,length(a))
  names(res) <- a
  
  
  for(i in 1:length(b)){
    x <- names(b)[i]
    y <- names(res)
    if( x %in% y){
      ind <- which(y %in% x,arr.ind = T)
      res[ind] <- b[i]
    }
  }
  
  res[is.na(res)] <- 0
  return(res)
}


#matrixmultiplication
#m1 1 x n and n x k

m1 <- t(as.matrix(querytv))
colnames(m1) <- c()

m2 <- matrix(data=0,nrow=65,ncol=5)

res <- m1 %*% m2
