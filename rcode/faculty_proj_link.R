fid <- c(1,1,12,15)
pid <- c(11,12,3,5)

faculty_proj <- data.frame(fid,pid)


sim <- c(0.9,0.7,0.6,0.5,0.45) 
fid <- c(1,10,12,13,15)
faculty_sim <- data.frame(sim,fid)


sim <- c(0.6,0.56,0.5,0.45,0.4) 
pid <- c(12,11,8,3,1)
proj_sim <- data.frame(sim,pid)


#for each faculty in the faculty_sim
#find their proj_ids
#for each proj_ids 
#see if it is there in proj_sim
#if yes pick the sim score for fac and proj and add

for(i in 1:length(faculty_sim$fid)){
  
  finalsim <- faculty_sim$sim[i]
  
  p <- faculty_proj[faculty_proj$fid==faculty_sim$fid[i],2]
  
}
