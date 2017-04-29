library(shiny)
library(shinyjs)


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


# inline css for asterik
# appCSS <- ".mandatory_star { color: red; }"

# shiny app start
shinyApp(
  ui = fluidPage( theme = "style.css",
                  shinyjs::useShinyjs(),
                  # shinyjs::inlineCSS(appCSS),
    titlePanel("MeetYourProf - Suggesting best professors to work with"),
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

      textInput("r_intrests","Enter Research Interests: (Enter comma seperated values)",""),
      
      #text box for skills
      
      textInput("skills","Enter your skillsets:  (Enter comma seperated values)",""),      
      
      #submit button
      actionButton("submit", "Submit", class = "btn-primary")
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
      data <- t(data)
      data
    })
    
    # action to take when submit button is pressed
    Data = reactive({
      if (input$submit>0) {
        df <- data.frame(name=input$name, type_of_edu=input$type_of_edu, r_intrests=input$r_intrests,skills = input$skills,
                              stringsAsFactors=FALSE)
      write.csv(df,"Data.csv")
      } else {NULL}
    })
    
  }
)