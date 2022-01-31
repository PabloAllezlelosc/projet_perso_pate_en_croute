library("plotly") 
library("leaflet")
library("GADMTools") # To have data GADM36SF
library("sp")
library("maptools")
library("RColorBrewer")
library("GADMTools")
library("raster") # => FonctiongetData to have data
library("leaflet")
library("binr")
library('rgdal')
library("dplyr")

FRA <- getData('GADM', country='FRA', level=5)
FRA$NAME_5=tolower(iconv(  FRA$NAME_5  , from="UTF-8",to="ASCII//TRANSLIT"  ))
LANDES=FRA[FRA$NAME_2 == "Landes",]

#--------------------------------------------#
#       COde avec import automatisé          #
#--------------------------------------------#

ALL_RESULTATS=readRDS("./data/ALL_RESULTATS.RData")
print("names(ALL_RESULTATS)")
print(names(ALL_RESULTATS))

server <- function(input, output, session) {
  
  
      output$name_graphic=renderText ({
        
        req(input$type_election)
        req(input$date_election)
        req(input$tour_election)
        req(input$partis_election)
        name_graphic=paste0(input$type_election," / " , input$date_election, " / ", input$tour_election , "  -  ", input$partis_election)
        name_graphic
        
      })
      output$type_election_ui=renderUI({
        
        selectInput("type_election","type_election", sort(names(ALL_RESULTATS)) , multiple = FALSE, selected = c("DEPARTEMENTALES"))
      })
      
      output$date_election_ui=renderUI({
        req(input$type_election)
        selectInput("date_election","date_election", sort(names(ALL_RESULTATS[[input$type_election]])) , multiple = FALSE)
      })
      
      output$tour_election_ui=renderUI({
        req(input$type_election)
        req(input$date_election)
        selectInput("tour_election","tour_election", names(ALL_RESULTATS[[input$type_election]][[input$date_election]])  , multiple = FALSE)
      })
      
      output$partis_election_ui=renderUI({
        
        req(input$type_election)
        req(input$date_election)
        req(input$tour_election)
        selectInput("partis_election","partis_election", colnames(ALL_RESULTATS[[input$type_election]][[input$date_election]][[input$tour_election]])[c(7:length(ALL_RESULTATS[[input$type_election]][[input$date_election]][[input$tour_election]]))] , multiple = FALSE)
        
      })
      
      output$mymap <- renderLeaflet({

        leaflet() %>% addTiles() %>% setView(-0.8, 44, zoom = 9)
      })
      
      observe({

        req(input$type_election)
        req(input$date_election)
        req(input$tour_election)
        req(input$partis_election)
        req(ALL_RESULTATS)
        
        tryCatch(
          expr = {

            LANDES_WITH_DATA=ALL_RESULTATS[[input$type_election]][[input$date_election]][[input$tour_election]]
            LANDES_WITH_DATA_AFTER_MERGE=merge(LANDES, LANDES_WITH_DATA , by= "NAME_5")
            
            selected_vars <- colnames( LANDES_WITH_DATA_AFTER_MERGE@data)[colnames( LANDES_WITH_DATA_AFTER_MERGE@data) %in% input$partis_election]
            if(length(selected_vars) > 0)
            {
              # LANDES_WITH_DATA_OK table definitive filtrée sur donnees non manquantes
              LANDES_WITH_DATA_OK=LANDES_WITH_DATA_AFTER_MERGE[is.na(LANDES_WITH_DATA_AFTER_MERGE@data[,selected_vars])==FALSE,]
              if(is.null(LANDES_WITH_DATA_OK@data)==FALSE & nrow(LANDES_WITH_DATA_OK@data)>0)
              {
                bins1=unique(as.numeric( quantile( LANDES_WITH_DATA_OK@data[,selected_vars] , c(0, 0.2, 0.4, 0.6, 0.8 , 1))))
                pal1 <- colorBin("YlOrRd", domain = LANDES_WITH_DATA_OK@data[,selected_vars] , bins = bins1)
                
                labels1 <- sprintf(
                  paste0("<strong>%s</strong><br/>" ," : %g "),
                  LANDES_WITH_DATA_OK@data$NAME_5, LANDES_WITH_DATA_OK@data[,selected_vars]
                ) %>% lapply(htmltools::HTML)
                
                leafletProxy("mymap") %>%  addPolygons(
                  data=LANDES_WITH_DATA_OK ,
                  fillColor = ~pal1(LANDES_WITH_DATA_OK@data[,selected_vars]),
                  weight = 2,
                  opacity = 1,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7,
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = TRUE
                  ),
                  label=labels1,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")
                )  %>% clearControls() %>%
                  addLegend(
                    data=LANDES_WITH_DATA_OK ,
                    pal = pal1, values = ~LANDES_WITH_DATA_OK@data[,selected_vars]
                    , opacity = 0.7, title = NULL, position = "bottomright"
                  ) 
              }
            }
          },
          error = function(e){
            message('Caught an error!')
            print(e)
            leafletProxy("mymap") %>% clearShapes() %>% clearControls()
          },
          warning = function(w){
            message('Caught an warning!')
            print(w)
          },
          finally = {
            message('All done, quitting.')
          }
        )  
        
      })
}