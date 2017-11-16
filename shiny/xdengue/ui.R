#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  
  # Application title
  titlePanel("Classificador XDengue"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       selectInput("febre", "Febre", choices = c("Não" = FALSE, "Sim" = TRUE)),
       selectInput("vomito", "Vômito constante", choices = c("Não" = FALSE, "Sim" = TRUE)),
       selectInput("mialgia", "Dores de cabeça", choices = c("Não" = FALSE, "Sim" = TRUE)),
       selectInput("laco", "Prova do laço", choices = c("Não" = FALSE, "Sim" = TRUE)),
       selectInput("obito", "Morte", choices = c("Não" = FALSE, "Sim" = TRUE)),
       actionButton("ver", "Visualizar")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      h1("Classificação em grupos por meio de sintomas"),
      p("A dengue é uma doença transmitida pelo mosquito Aedes Aegypti e suas consequências podem variar desde um mal estar intenso como até mesmo a morte."),
      p("Mesmo sendo uma doença com um perfil bastante conhecido no Brasil, muitas pessoas ainda não conseguem perceber que estão com os sinais e sintomas que indicam a presença da doença."),
      hr(),
      conditionalPanel(
        condition = "output.tipo == 'A'",
        div(class="groups",
          div(class="a active", h2("A")),
          div(class="b", h2("B")),
          div(class="c", h2("C")),
          div(class="d", h2("D"))
        )
      ),
      conditionalPanel(
        condition = "output.tipo == 'B'",
        div(class="groups",
            div(class="a", h2("A")),
            div(class="b active", h2("B")),
            div(class="c", h2("C")),
            div(class="d", h2("D"))
        )
      ),
      conditionalPanel(
        condition = "output.tipo == 'C'",
        div(class="groups",
            div(class="a", h2("A")),
            div(class="b", h2("B")),
            div(class="c active", h2("C")),
            div(class="d", h2("D"))
        )
      ),
      conditionalPanel(
        condition = "output.tipo == 'D'",
        div(class="groups",
            div(class="a", h2("A")),
            div(class="b", h2("B")),
            div(class="c", h2("C")),
            div(class="d active", h2("D"))
        )
      ),
      h6(class="tipo", textOutput("tipo"))
    )
  )
)
