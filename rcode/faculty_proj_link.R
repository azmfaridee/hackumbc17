

#for each faculty in the faculty_sim
#find their proj_ids
#for each proj_ids 
#see if it is there in proj_sim
#if yes pick the sim score for fac and proj and add

for(i in 1:length(faculty_sim$fid)){
  
  finalsim <- faculty_sim$sim[i]
  
  p <- faculty_proj[faculty_proj$fid==faculty_sim$fid[i],2]
  
}
