options(stringsAsFactors = F)
options(java.parameters = "-Xmx2g")

library(plyr)
library(xlsx)
library(jsonlite)

codesDep = formatC(c(1:19, 21:95, 971, 972, 973, 974, 976), width = 2, flag = 0)
codesDep = c(codesDep, c('2A', '2B'))

urlEtablissements = "https://www.pour-les-personnes-agees.gouv.fr/api/v1/establishment/search?departement=%20(code)"
urlSoinsDomicile = "https://www.pour-les-personnes-agees.gouv.fr/api/v1/services_annuaire/search?departement=%20(code)"
urlPointsInformation = "https://www.pour-les-personnes-agees.gouv.fr/api/v1/point_information/search?departement=%20(code)"

recupererInfos = function (url, codeDep) {
   urlDep = gsub("code", codeDep, url)
   cat(urlDep, '\n')
   infos = tryCatch({
      infos = fromJSON(urlDep, flatten = T, simplifyDataFrame = T)
      infos = infos[, which(grepl('item', colnames(infos)))]
      colnames(infos) = gsub('item\\.', '', colnames(infos)) 
      if ('schedules' %in% colnames(infos)){
         infos$schedules = sapply(infos$schedules, paste, collapse = "|")
      }
      return(infos)
   }, error = function(e) {
      return(NULL)
   })
}

sauverTableau = function (url, nom) {
   
   infos = Map(function (x) {recupererInfos(url, x)}, codesDep)
   tableau = rbind.fill(infos)
   cat(paste(nom, ':', nrow(tableau), 'lignes\n'))
   write.csv(tableau, paste0(nom, '.csv'), row.names = F, fileEncoding = "UTF-8")
   write.xlsx2(tableau, paste0(nom, '.xlsx'), sheetName = "data", col.names = T, row.names = F, append = F)
}

sauverTableau(urlEtablissements, 'base_etablissements')
sauverTableau(urlSoinsDomicile, 'base_soins_a_domicile')
sauverTableau(urlPointsInformation, 'base_points_info')
