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

cossim <- function(x,y){
  
  num <- sum(x*y)
  
  den <- sqrt(sum(x^2)) * sqrt(sum(y^2))
  
  cs <- num/den
  
  return(cs)
}



querymatch <- function(query, term_mat_filepath, doc_mat_filepath, terms_filepath){
  
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
  
  df <- read.csv(term_mat_filepath,header = F)
  m2 <- as.matrix(df)
  
  
  terms <- read.table(terms_filepath)
  corpbow <-as.vector(terms$V1)
  
  querytv <- termVectorConv(corpbow, tdmvec)
  
  m1 <- t(as.matrix(querytv))
  colnames(m1) <- c()
  
  
  querymat <- m1 %*% m2
  
  #queryvecnewfeaturespace
  qv_ns <- as.vector(querymat)
  
  
  df1 <- read.csv(doc_mat_filepath,header = F)
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
  id <- c(1:length(similarity))
  id_sim <- data.frame(id,similarity)
  
  
  return(id_sim)
  
}


combineprojfacsim <- function(w1,w2,faculty_sim,proj_sim,faculty_proj){
  
  finalsim <- vector()
  
  
  for(i in 1:length(faculty_sim$fid)){
    #print(i)
    finalsimtemp <- faculty_sim$sim[i] * w1
    
    p <- faculty_proj[faculty_proj$fid==faculty_sim$fid[i],'pid']
    
    if(length(p)!=0){
      for(j in 1:length(p)){
        projsimtemp <- proj_sim[proj_sim$pid==p[j],'similarity']
        
        if(length(projsimtemp)!=0){
          finalsimtemp <- finalsimtemp + (projsimtemp * w2)}
      }
    }
    
    finalsim[i] <- finalsimtemp
  }
  
  finalres <- data.frame(faculty_sim$fid,finalsim)
  finalres <- finalres[order(-finalres[,2]),]
  
  return(finalres)
  
}