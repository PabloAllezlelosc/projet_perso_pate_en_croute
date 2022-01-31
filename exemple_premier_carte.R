#---------------------------------------#
#          Landes Elections             #
#---------------------------------------#

# https://abcdr.thinkr.fr/comment-lire-le-contenu-dun-shapefile-avec-r/

path <- "C:\\Users\\p.atalya\\OneDrive - BetClic Everest Group\\Desktop\\elections_landes"
setwd(path)


#install.packages("rgdal")
#install.packages("sp")
#install.packages("leaflet")
#install.packages("xlsx")
#install.packages("readxl")
#install.packages("GADMTools")
#install.packages("sp",dependencies=TRUE)
#install.packages("RColorBrewer",dependencies=TRUE)
#install.packages("maptools",dependencies=TRUE)
#install.packages("raster")
#install.packages("leaflet",dependencies=TRUE)
#install.packages("rlang")
#install.packages("Rtools")
# install.packages(c("Rcpp","raster"))
#install.packages('dplyr')
#install.packages("tinytest")
#install.packages("devtools")

library("devtools")

# installation a faire apres devtools qui va necessiter installation de rtools, obligatoire car sur shinyapps on ne peut
# avoir recours uniquement a des librairies publiées sur site du CRAN ou GITHUB
#install_github("rspatial/terra")


library("dplyr")
library("tinytest")
library('rgdal')
library('sp')
library('leaflet')
library("readxl")
library("raster")
library("sessioninfo")

#package_info(
#  pkgs = c("loaded", "attached", "installed")[1],
#  include_base = FALSE,
#  dependencies = NA
#)

# On récupère les géométries les plus récentes avec la fonction getData de la librairie Raster. Level5 = communes
FRA <- getData('GADM', country='FRA', level=5)

# On enleve les accents et on passe tous les noms de commune en miniscule sans accent pour faciliter jointures entre noms
# dans l'objet spatial et les noms dans les fichiers xlsx
FRA$NAME_5=tolower(iconv(  FRA$NAME_5  , from="UTF-8",to="ASCII//TRANSLIT"  ))
LANDES=FRA[FRA$NAME_2 == "Landes",]

# On filtre au niveau departement landes
LANDES=FRA[FRA$NAME_2 == "Landes",]
#View(LANDES@data)

# on importe les resultats des elections depuis lobjet créé dans data_user_friendly.R
all_data <- readRDS("ALL_RESULTATS.RData")
# on prend 1 election en particulier pr lexemple

data=all_data[["Regionales"]][["2021"]][["T2"]]

# On merge les resultats a l'objet spatial sur la clé "NAME_5"
LANDES_WITH_DATA=merge(LANDES, data , by= "NAME_5")
str(LANDES_WITH_DATA@data)

# Choix de la variable à mettre sur la carte
variable='UDI_LEG_17'

# On enlève les communes donnees manquantes pour la variable choisie (exemple parti non present ou commune sans second tour)

LANDES_WITH_DATA_OK=LANDES_WITH_DATA[is.na(LANDES_WITH_DATA@data[,variable])==FALSE,]
str(LANDES_WITH_DATA_OK@data)

# On met unique au cas ou des quantiles seraient egaux pr eviter souci
bins1=unique(as.numeric( quantile( LANDES_WITH_DATA_OK@data[,variable] , c(0, 0.2, 0.4, 0.6, 0.8 , 1))))
pal1 <- colorBin("YlOrRd", domain = LANDES_WITH_DATA_OK@data[,variable] , bins = bins1)

labels1 <- sprintf(
  paste0("<strong>%s</strong><br/>", variable ," : %g"),
  LANDES_WITH_DATA_OK@data$NAME_5, LANDES_WITH_DATA_OK@data[,variable]
) %>% lapply(htmltools::HTML)

#-----------------------------------------#
#         Carte tres simple               # 
#-----------------------------------------#

m <- leaflet( LANDES_WITH_DATA_OK) %>% addTiles() 
m %>% addPolygons(
  fillColor = ~pal1(LANDES_WITH_DATA_OK@data[,variable]),
  weight = 2,
  opacity = 1,
  color = "white",
  dashArray = "3",
  fillOpacity = 0.7,
  group='gauche')

#-----------------------------------------------#
#     Carte un peu plus detaillée avec hover    #
#-----------------------------------------------#


m <- leaflet() %>% addTiles() %>% setView(-0.8, 44, zoom = 9)
m %>%  addPolygons(
  data=LANDES_WITH_DATA_OK,
  fillColor = ~pal1(LANDES_WITH_DATA_OK@data[,variable]),
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
)  %>%
  addLegend(
    data=LANDES_WITH_DATA_OK,
    pal = pal1, values = ~LANDES_WITH_DATA_OK@data[,variable]
    , opacity = 0.7, title = NULL, position = "bottomright"
)