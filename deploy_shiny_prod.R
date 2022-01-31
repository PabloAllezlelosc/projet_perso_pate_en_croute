# https://shiny.rstudio.com/articles/shinyapps.html => Documentation pr deployer dans le web

library("shiny")
library("rsconnect")
library("devtools")
# On se connecte au compte shinyapp, on recupere identifiant sur le compte...

rsconnect::setAccountInfo(name='bva-data-viz',
                          token='XXXX',
                          secret='XXXX')

deployApp('C:\\Users\\p.atalya\\OneDrive - BetClic Everest Group\\Desktop\\elections_landes',
appName='projet_pate_en_croute')




