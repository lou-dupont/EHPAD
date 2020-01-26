options(stringsAsFactors = F)
options(java.parameters = "-Xmx1g")

library(curl)
library(data.table)
library(plyr)
library(rjson)
library(xlsx)
library(XML)

codesDep = formatC(c(1:95, 97), width = 2, flag = 0)

recupererInfos = function(urlSource, codeDep){
  
  #Chargement de la page 0 pour recuperer le nombre de pages
  urlDep = sprintf(urlSource, codeDep, 0)
  conDep <- curl(urlDep)
  pageParsee = htmlTreeParse(readLines(conDep), useInternalNodes = TRUE)
  close(conDep)
  
  nbResultats = as.numeric(xpathSApply(pageParsee, "//h2[@id='cnsa_results-total']/b", xmlValue))
  nbPages = trunc(nbResultats/10)
  cat(sprintf("Il y a %s hebergements dans le departement %s.\n", nbResultats, codeDep))
  
  if (nbResultats == 0){
    return(NULL)
  }
  
  # Boucle sur les pages
  infosDep = list()
  for (p in 0:nbPages){
    urlPage = sprintf(urlSource, codeDep, p)
    con <- curl(urlPage)
    pageParsee = htmlTreeParse(readLines(con), useInternalNodes = TRUE)
    close(con)
    nodes <- getNodeSet(pageParsee, "//script")[11]
    nodeInfos = gsub('.*(\\{"results"\\:\\[\\{.*\\}\\]\\}).*', '\\1', xmlValue(nodes[[1]]))
    
    results = fromJSON(nodeInfos)$results
    results = data.table(t(sapply(results, function(x) unlist(lapply(x, function(x) ifelse(is.null(x), '', x))))))
    
    infosDep[[p+1]] = results
  } 

  infosDep = do.call(rbind.data.frame, infosDep)
  infosDep$map = NULL
  infosDep$tags2 = NULL
  return(infosDep)
}

construireTableau = function (url) {
  tableau = Map(function (x) { recupererInfos(url, x) }, codesDep)
  tableau = do.call(rbind.fill, tableau)
  tableau = unique(tableau)
  return(tableau)
}

sauverTableau = function (tableau, nom) {
  write.csv(tableau, paste0(nom, '.csv'), row.names = F, fileEncoding = "UTF-8")
  write.xlsx(tableau, paste0(nom, '.xlsx'), sheetName = "data", col.names = T, row.names = F, append = F)
  print(paste(nom, ':', nrow(tableau), 'lignes'))
}

#### Hebergements *4, Accueil de jour
urlEHPAD_perm = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-ehpad-en-hebergement-permanent/%s/0?page=%s"
urlEHPAD_temp = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-ehpad-en-hebergement-temporaire/%s/0?page=%s"
urlESLD = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-esld/%s/0?page=%s"
urlResidenceAutonomie = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-residence-autonomie/%s/0?page=%s"
urlAccueilJour = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-accueil-de-jour/%s/0?page=%s"
urlInfoRepit = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-points-dinformation-et-plateformes-de-repit/%s/0?page=%s"
urlSoinsDomicile = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-soins-et-services-a-domicile/%s/%s"

# Empilement de tous les types d'etablissement
infosESLD = construireTableau(urlESLD)
infosHebPermanent = construireTableau(urlEHPAD_perm)
infosHebTemp = construireTableau(urlEHPAD_temp)
infosResAutonomie = construireTableau(urlResidenceAutonomie)
infosTousEtablissements = rbind.fill(infosHebPermanent, infosHebTemp, infosESLD, infosResAutonomie)
infosTousEtablissements = unique(infosTousEtablissements)
# Pour replacer les colonnes au meilleur endroit // faire mieux
infosTousEtablissements = infosTousEtablissements[, c(1:5, 38, 39, 6:37, 40:ncol(infosTousEtablissements))]
sauverTableau(infosTousEtablissements, 'base_ehpad_esld_ra')

#### Accueil de jour
infosAccueilJour = construireTableau(urlAccueilJour)
infosAccueilJour$dateMaj = NULL
infosAccueilJour = infosAccueilJour[, !grepl('prixHeb|prixF|tarif|cap_log|pres', colnames(infosAccueilJour), ignore.case = T)]
sauverTableau(infosAccueilJour, 'base_accueil_jour')

#### Centre CLIC et repit
infosInfoRepit = construireTableau(urlInfoRepit)
sauverTableau(infosInfoRepit, 'base_clic_repit')

#### Soins a domicile
infosSoinsDomicile = construireTableau(urlSoinsDomicile)
infosSoinsDomicile$is_esa = NULL
infosSoinsDomicile$is_handi_vieil = NULL
sauverTableau(infosSoinsDomicile, 'base_soins_domicile')
