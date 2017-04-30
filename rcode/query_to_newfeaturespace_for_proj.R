rm(list=ls())
library(tm)


############################ Query ########################
###########################################################

#ref: http://www.rdatamining.com/docs/twitter-analysis-with-r

#query <- c('Stacy Branham is a Lecturer in the Department of Information Systems at UMBC. Dr. Branham\'s teaching focuses on making computing more appealing, accessible, and welcoming to first-year students towards increasing retention and diversity. Dr. Branham\'s research focuses on the role of computer technologies in mediating communication between significant others, friends, and colleagues. She works with populations that exhibit cross-cultural communication: people who are blind and people who are sighted; students and teachers; women and men. Through qualitative field studies and participant-observer engagements, she reflects on the design of technologies that can foster empathic communication--a form of talking that involves sharing, intimate connection, and mutual growth.')
query <- c('My research interests include big data, workflow, distributed computing, user programming')
#query <- c('health care')
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


############################ term - newfeature matrix ####################################
##########################################################################################

df <- read.csv("E:\\USA\\hackumbc2017\\hackumbc17\\out_matrices\\projects\\term_mat_U.csv",header = F)
m2 <- as.matrix(df)


terms <- read.table("E:\\USA\\hackumbc2017\\hackumbc17\\out_matrices\\projects\\terms.txt")
corpbow <-as.vector(terms$V1)



###########################  convert query in terms of corpus bag of words ################
###########################################################################################

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

querytv <- termVectorConv(corpbow, tdmvec)

m1 <- t(as.matrix(querytv))
colnames(m1) <- c()


#matrixmultiplication
#m1 1 x n and n x k
######################################
#####################################

querymat <- m1 %*% m2

#queryvecnewfeaturespace
qv_ns <- as.vector(querymat)




########################################### query similarity ##################
###############################################################################

cossim <- function(x,y){
  
  num <- sum(x*y)
  
  den <- sqrt(sum(x^2)) * sqrt(sum(y^2))
  
  cs <- num/den
  
  return(cs)
}

df1 <- read.csv("E:\\USA\\hackumbc2017\\hackumbc17\\out_matrices\\projects\\doc_mat_V.csv",header = F)
v <- as.matrix(df1)

similarity <- vector()

for( i in 1:nrow(v)){
  vec1 <- as.vector(v[i,])
  vec2 <- qv_ns
  similarity[i] <- cossim(vec1,vec2)
}


simtemp <- similarity
names(simtemp) <- c(1:length(similarity))

#order(simtemp, decreasing=TRUE)
pid <- c(1:length(similarity))
proj_sim <- data.frame(pid,similarity)
