

#for each faculty in the faculty_sim
#find their proj_ids
#for each proj_ids 
#see if it is there in proj_sim
#if yes pick the sim score for fac and proj and add
#w1 <- weight for fac sim
#w2 <- weight for prac sim

w1 <- 0.60
w2 <- 0.30
w3 <- 0.10

finalsim <- vector()


for(i in 1:length(faculty_sim$fid)){
  print(i)
  #get faculty rating
  rating <- facrating[facrating$fid==faculty_sim$fid[i],'rating']
    
  finalsimtemp <- faculty_sim$sim[i] * w1 + rating * w3
  
  p <- faculty_proj[faculty_proj$fid==faculty_sim$fid[i],2]
  
  if(length(p)!=0){
  for(j in 1:length(p)){
    projsimtemp <- proj_sim[proj_sim$pid==p[j],1]
    
    if(length(projsimtemp)!=0){
    finalsimtemp <- finalsimtemp + (projsimtemp * w2)}
  }
  }
  
  finalsim[i] <- finalsimtemp
}

finalres <- data.frame(faculty_sim$fid,finalsim)
finalres[order(-finalres[,2]),]
