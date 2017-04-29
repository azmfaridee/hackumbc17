library(shiny)
library(shinyjs)
library(shinythemes)

# mandatroy fileds in the form
fieldsMandatory <- c("name", "r_intrests","skills")

# function to add asterick to the mandatiry filed
labelMandatory <- function(label) {
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
saveData <- function(data) {
  data <- as.data.frame(t(data))
  if (exists("responses")) {
    responses <<- rbind(responses, data)
  } else {
    responses <<- data
  }
}


# Load all previous responses
# ---- This is one of the two functions we will change for every storage type ----
loadData <- function() {
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
                  titlePanel("MeetYourProf - Suggesting best professors to work with"),
                  
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
                    actionLink("submit_another", "Submit another response")
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
    
    observeEvent(input$submit_another, {
      shinyjs::show("form")
      shinyjs::hide("thankyou_msg")
    })  
  }
)