library("readxl")

path <- "C:\\Users\\p.atalya\\OneDrive - BetClic Everest Group\\Desktop\\elections_landes\\data"
setwd(path)
urls_xlsx <- iconv(list.files(path, pattern = "*.xlsx", recursive = TRUE),from="UTF-8",to="UTF-8")

ALL_LIB_SUBCOM=NULL
ALL_RESULTATS=list()
for (i in 1:length(urls_xlsx))
{
  nom_fichier=urls_xlsx[i]
  TYPE=unlist(strsplit( nom_fichier , "_"))[1]
  DATE=unlist(strsplit( nom_fichier , "_"))[2]
  TOUR=unlist(strsplit( unlist(strsplit( nom_fichier , "_"))[3] , ".xlsx"))[1]
  
  data <- read_excel(nom_fichier)
  colnames(data)[which(names(data) == "LIBSUBCOM")] <- "NAME_5"
  data$NAME_5=tolower(iconv(  data$NAME_5  , from="UTF-8",to="ASCII//TRANSLIT"  ))
  ALL_LIB_SUBCOM= union(ALL_LIB_SUBCOM, data$NAME_5)
  length(ALL_LIB_SUBCOM)
  ALL_RESULTATS[[TYPE]][[DATE]][[TOUR]]=data
}
ALL_RESULTATS

saveRDS(ALL_RESULTATS, file = "./ALL_RESULTATS.RData")
#TEST_LOAD=readRDS("ALL_RESULTATS.RData")
#TEST_LOAD