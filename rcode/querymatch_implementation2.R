#Faculty
term_mat_filepath <- paste("E:\\USA\\hackumbc2017\\hackumbc17\\out_matrices\\faculty\\term_mat_U.csv",sep="")
doc_mat_filepath <- paste("E:\\USA\\hackumbc2017\\hackumbc17\\out_matrices\\faculty\\doc_mat_V.csv",sep="")
terms_filepath <- paste("E:\\USA\\hackumbc2017\\hackumbc17\\out_matrices\\faculty\\terms.txt",sep="")
query <- 'system design'

faculty_sim <- querymatch(query,term_mat_filepath,doc_mat_filepath,terms_filepath)
names(faculty_sim) <- c('fid','similarity')
faculty_sim <- faculty_sim[order(-faculty_sim[,2]),]


#Project
term_mat_filepath <- paste("E:\\USA\\hackumbc2017\\hackumbc17\\out_matrices\\projects\\term_mat_U.csv",sep="")
doc_mat_filepath <- paste("E:\\USA\\hackumbc2017\\hackumbc17\\out_matrices\\projects\\doc_mat_V.csv",sep="")
terms_filepath <- paste("E:\\USA\\hackumbc2017\\hackumbc17\\out_matrices\\projects\\terms.txt",sep="")
query <- 'system design'

proj_sim <- querymatch(query,term_mat_filepath,doc_mat_filepath,terms_filepath)
names(proj_sim) <- c('pid','similarity')
proj_sim <- proj_sim[order(-proj_sim[,2]),]

#
fac_proj <- read.csv("E:\\USA\\hackumbc2017\\hackumbc17\\pid_fid_map.csv")
faculty_proj <- data.frame(fac_proj$fid,fac_proj$pid)
names(faculty_proj) <- c('fid','pid')
w1 <- 0.60
w2 <- 0.40
finalres <- combineprojfacsim(w1,w2,faculty_sim[1:5,],proj_sim[1:5,],faculty_proj)