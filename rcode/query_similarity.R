#qv_ns


df1 <- read.csv("E:\\USA\\hackumbc2017\\hackumbc17\\out_matrices\\doc_mat_V.csv",header = F)
v <- as.matrix(df1)

similarity <- vector()

for( i in 1:nrow(v)){
  vec1 <- as.vector(v[i,])
  vec2 <- qv_ns
  similarity[i] <- cossim(vec1,vec2)
}




cossim <- function(x,y){
  
  num <- sum(x*y)
  
  den <- sqrt(sum(x^2)) * sqrt(sum(y^2))
  
  cs <- num/den
  
  return(cs)
}