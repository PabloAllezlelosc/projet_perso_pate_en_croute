library("shiny")
library("scales")
library("shinydashboard")
library("plotly")
library("DT")
library("shinyBS")
library("shinyjs")
library("shinydashboard")
library("leaflet")

ui <- dashboardPage(
  
  dashboardHeader(title = tags$a(
                                 tags$img(src='logo4.png',height='48',width='auto')
                                 
  )),
  
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Resultats", tabName = "Resultats", icon = icon("dashboard")),
      menuItem("Autre", tabName = "Autre", icon = icon("th"))
    )
  ),
  ## Body content
  dashboardBody(
    
    tabItems(
      # First tab content
      tabItem(tabName = "Resultats",
              
              fluidRow(
                box(
                  title = "Résultats Elections",
                  status = "primary",
                  width = 12,
                  solidHeader = FALSE,
                  collapsible = TRUE,
                  collapsed = FALSE ,
                  column( uiOutput('type_election_ui'),width=3) ,
                  column(  uiOutput('date_election_ui'),width=3),
                  column(  uiOutput('tour_election_ui'),width=3),
                  column(  uiOutput('partis_election_ui'),width=3),
                  h2(textOutput('name_graphic')),
                  leafletOutput("mymap",height='600px'),
                  p()
                )
              )
      ),
      
      # Second tab content
      tabItem(tabName = "Autre",
              h2("blablabla")
      )
    )
  )    
)
