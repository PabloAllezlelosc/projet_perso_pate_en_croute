# https://shiny.rstudio.com/articles/shinyapps.html => Documentation pr deployer dans le web

library("shiny")
library("rsconnect")
library("devtools")
# On se connecte au compte shinyapp, on recupere identifiant sur le compte...

rsconnect::setAccountInfo(name='bva-data-viz',
                          token='9006602680FD08FDA5B4E2C2D0A46814',
                          secret='Oo/p3M5Va/9WQXwahkn1dqfxKk9QdA8IyOR0Rvmt')

deployApp('C:\\Users\\p.atalya\\OneDrive - BetClic Everest Group\\Desktop\\elections_landes',
appName='projet_pate_en_croute')




