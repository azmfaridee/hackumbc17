library(shiny)
library(shinyjs)
library(shinythemes)
library(tm)

# Faculty

term_mat_filepath_fac <<- paste("C:\\Users\\Prathamesh\\Documents\\GitHub\\hackumbc17\\out_matrices\\faculty\\term_mat_U.csv",sep="")
doc_mat_filepath_fac <<- paste("C:\\Users\\Prathamesh\\Documents\\GitHub\\hackumbc17\\out_matrices\\faculty\\doc_mat_V.csv",sep="")
terms_filepath_fac <<- paste("C:\\Users\\Prathamesh\\Documents\\GitHub\\hackumbc17\\out_matrices\\faculty\\terms.txt",sep="")

#Project
term_mat_filepath_pro1 <<- paste("C:\\Users\\Prathamesh\\Documents\\GitHub\\hackumbc17\\out_matrices\\projects\\term_mat_U.csv",sep="")
doc_mat_filepath_pro1 <<- paste("C:\\Users\\Prathamesh\\Documents\\GitHub\\hackumbc17\\out_matrices\\projects\\doc_mat_V.csv",sep="")
terms_filepath_pro1 <<- paste("C:\\Users\\Prathamesh\\Documents\\GitHub\\hackumbc17\\out_matrices\\projects\\terms.txt",sep="")

fac_proj <<- read.csv("C:\\Users\\Prathamesh\\Documents\\GitHub\\hackumbc17\\pid_fid_map.csv")
fid_rating <<- read.csv("C:\\Users\\Prathamesh\\Documents\\GitHub\\hackumbc17\\out_matrices\\fid_rating_new.csv")
facrating <<- data.frame(fid_rating$fid,fid_rating$rating)
colnames(facrating) <<- c('fid','rating')

similarity <<- vector()

w1 <<- 0.60
w2 <<- 0.20
w3 <<- 0.20

#cosine function
cossim <<- function(x,y){
  
  num <- sum(x*y)
  
  den <- sqrt(sum(x^2)) * sqrt(sum(y^2))
  
  cs <- num/den
  
  return(cs)
}


# mandatroy fileds in the form
fieldsMandatory <<- c("name", "r_intrests","skills")

# function to add asterick to the mandatiry filed
labelMandatory <<- function(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}

# function to store the response
fieldsAll <- c("name", "type_of_edu", "grad_year", "r_intrests", "skills")
responsesDir <- file.path("responses")
epochTime <- function() {
  as.integer(Sys.time())
}


# Save a response
# ---- This is one of the two functions we will change for every storage type ----
saveData <<- function(data) {
  data <- as.data.frame(t(data))
  if (exists("responses")) {
    responses <<- rbind(responses, data)
  } else {
    responses <<- data
  }
}


termVectorConv <<- function(corpbow,tdmvec){
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

#query match function
querymatch <<- function(query, term_mat_filepath, doc_mat_filepath, terms_filepath){
  
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

# combineproject and fac and rating data

combineprojfacsim <<- function(w1,w2,w3,faculty_sim,proj_sim,faculty_proj,facrating){
  
  finalsim <- vector()
  
  for(i in 1:length(faculty_sim$fid)){
    #get faculty rating
    rating <- facrating[facrating$fid==faculty_sim$fid[i],'rating']
    
    finalsimtemp <- faculty_sim$sim[i] * w1 + rating * w3
    
    #print(i)
    # finalsimtemp <- faculty_sim$sim[i] * w1
    
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


# Load all previous responses
# ---- This is one of the two functions we will change for every storage type ----
loadData <<- function() {
  if (exists("responses")) {
    responses
  }
}


# inline css for asterik
# appCSS <- ".mandatory_star { color: red; }"

# shiny app start
shinyApp(
  ui = fluidPage( theme = "style.css",
                  shinyjs::useShinyjs(),
                  # shinyjs::inlineCSS(appCSS),
                  titlePanel("MeetYourProf - Find your research match"),
                  
                  tabsetPanel(type = "tabs", id = 'myTabs' 
                              ,tabPanel(title = "Tab1",value = "tab1" ,
                                        
                                        div(id = "outer",
                                            div(
                                              id = "form",
                                              #name
                                              textInput("name","Name", ""),
                                              
                                              #graduate or undergraduate
                                              selectInput("type_of_edu", "Graduate or Undergraduate:",
                                                          c("Graduate",
                                                            "Undergraduate")),
                                              #graduation year
                                              selectInput("grad_year", "Expected Year of Graduation",
                                                          c("2015","2016","2017","2018","2019","2020","2021","2022")),
                                              
                                              #text box for research intrests
                                              
                                              textInput("r_intrests","Enter Research Interests",""),
                                              
                                              #text box for skills
                                              
                                              textInput("skills","Enter your skillsets",""),
                                              
                                              #submit button
                                              actionButton("submit", "Submit", class = "btn-primary")
                                            )
                                        ),
                                        
                                        shinyjs::hidden(
                                          div(
                                            id = "thankyou_msg",
                                            h3("Thanks, your response was submitted successfully!"),
                                            actionButton("submit_another","Recommendations")
                                          )
                                        )
                                        
                              ), 
                              
                              tabPanel(title = "Tab2", value = "tab2",
                                       dataTableOutput('output_disp')
                              )
                  )
                  
                  
  ),
  
  
  # server side code
  server = function(input, output, session) {
    
    # check in if all the mandatory fileds are selected    
    observe({
      # check if all mandatory fields have a value
      mandatoryFilled <-
        vapply(fieldsMandatory,
               function(x) {
                 !is.null(input[[x]]) && input[[x]] != ""
               },
               logical(1))
      mandatoryFilled <- all(mandatoryFilled)
      
      # enable/disable the submit button
      shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
    })
    
    
    # function to loop thorugh and save the data
    formData <- reactive({
      data <- sapply(fieldsAll, function(x) input[[x]])
      data <- c(data, timestamp = epochTime())
      data
    })
    
    
    # action to take when submit button is pressed
    observeEvent(input$submit, {
      saveData(formData())
      shinyjs::reset("form")
      shinyjs::hide("form")
      shinyjs::show("thankyou_msg")
    })
    
    # new window code
    observeEvent(input$submit_another, {
      
      updateTabsetPanel(session = session 
                        ,inputId = 'myTabs'
                        ,selected = 'tab2')
    })
    
    output$output_disp <- renderDataTable({
      
      c_r_intrest <- responses[nrow(responses),4]
      faculty_sim1<- querymatch(c_r_intrest,term_mat_filepath_fac,doc_mat_filepath_fac,terms_filepath_fac)
      names(faculty_sim1) <- c('fid','similarity')
      faculty_output <- faculty_sim1[order(-faculty_sim1[,2]),]

      proj_sim1 <- querymatch(c_r_intrest,term_mat_filepath_pro1,doc_mat_filepath_pro1,terms_filepath_pro1)
      names(proj_sim1) <- c('pid','similarity')
      project_output <- proj_sim1[order(-proj_sim1[,2]),]

      faculty_proj1 <- data.frame(fac_proj$fid,fac_proj$pid)
      names(faculty_proj1) <- c('fid','pid')
      finalres1 <- combineprojfacsim(w1,w2,w3,faculty_output[1:5,],project_output[1:5,],faculty_proj1,facrating)
      names(finalres1) <- c("id","similarity")
      
      output <- as.vector(5)
      
      for(i in 1: length(finalres1$id)){ 
        
          output[i] <- as.character(fid_rating[fid_rating$fid==finalres1$id[i],'qualifiedNames'])
      }
      
      output <- as.data.frame(output)
      colnames(output) <- "Recommended Professors"
      output

    })
    
  }
)