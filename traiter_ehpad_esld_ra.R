library(XML)
library(curl)
library(plyr)
library(rjson)

codesDep = formatC(c(1:95, 97), width = 2, flag = 0)

recupererInfos = function(urlSource, codeDep){
  #Chargement de la page 0 pour récupérer le nombre de pages
  urlDep = sprintf(urlSource, codeDep, 0)
  conDep <- curl(urlDep)
  pageParsee = htmlTreeParse(readLines(conDep), useInternalNodes = TRUE)
  close(conDep)
  
  nbResultats = as.numeric(xpathSApply(pageParsee, "//h2[@id='cnsa_results-total']/b", xmlValue))
  nbPages = trunc(nbResultats/10)
  cat(sprintf("Il y a %s hébergements dans le département %s.\n", nbResultats, codeDep))
  
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
    
    infos = do.call(rbind.data.frame, fromJSON(nodeInfos))
    infosDep[[p+1]] = infos
  } 

  infosDep = do.call(rbind.fill, infosDep)
  colnames(infosDep) = gsub('results\\.', '', colnames(infosDep))
  infosDep$map = NULL
  return(infosDep)
}

#### Hébergements *4, Accueil de jour
urlEHPAD_perm = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-ehpad-en-hebergement-permanent/%s/0?page=%s"
urlEHPAD_temp = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-ehpad-en-hebergement-temporaire/%s/0?page=%s"
urlESLD = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-esld/%s/0?page=%s"
urlResidenceAutonomie = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-residence-autonomie/%s/0?page=%s"
urlAccueilJour = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-accueil-de-jour/%s/0?page=%s"
urlInfoRepit = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-points-dinformation-et-plateformes-de-repit/%s/0?page=%s"


infosESLD = Map(function(codesDep) {recupererInfos(urlESLD, codesDep)}, codesDep)
infosESLD = do.call(rbind.fill, infosESLD)

infosHebPermanent = Map(function(codesDep) {recupererInfos(urlEHPAD_perm, codesDep)}, codesDep)
infosHebPermanent = do.call(rbind.fill, infosHebPermanent)

infosHebTemp = Map(function(codesDep) {recupererInfos(urlEHPAD_temp, codesDep)}, codesDep)
infosHebTemp = do.call(rbind.fill, infosHebTemp)

infosResAutonomie = Map(function(codesDep) {recupererInfos(urlResidenceAutonomie, codesDep)}, codesDep)
infosResAutonomie = do.call(rbind.fill, infosResAutonomie)

# Empilement de tous les types d'établissement
infosTousEtablissements = rbind.fill(infosHebPermanent, 
                                     infosHebTemp, 
                                     infosESLD, 
                                     infosResAutonomie,
                                     infosAccueilJour)
infosTousEtablissements = unique(infosTousEtablissements)
infosTousEtablissements$map = NULL
infosTousEtablissements$tags2 = NULL

# Pour replacer les colonnes à un meilleur endroit // à améliorer
cdep = which(colnames(infosTousEtablissements) %in% c('gestionnaire', 'dateMaj'))
infosTousEtablissements = infosTousEtablissements[, c(1:5, 38,39, 6:37, 40:ncol(infosTousEtablissements))]
write.csv(infosTousEtablissements, 'base_ehpad_esld_ra.csv', row.names = F, 
          fileEncoding = "UTF-8", quote = TRUE)

#### Accueil de jour
infosAccueilJour = Map(function(codesDep) {recupererInfos(urlAccueilJour, codesDep)}, codesDep)
infosAccueilJour = do.call(rbind.fill, infosAccueilJour)
infosAccueilJour = unique(infosAccueilJour)
infosAccueilJour$tags2 = NULL
infosAccueilJour$map = NULL
infosAccueilJour$dateMaj = NULL
infosAccueilJour = infosAccueilJour[, !grepl('prixHeb|prixF|tarif|cap_log|pres', colnames(infosAccueilJour), ignore.case = T)]
write.csv(infosAccueilJour, 'base_accueil_jour.csv', row.names = F,
           fileEncoding = "UTF-8", quote = TRUE)

#### Centre CLIC et repit
infosInfoRepit = Map(function(codesDep) {recupererInfos(urlInfoRepit, codesDep)}, codesDep)
infosInfoRepit = do.call(rbind.fill, infosInfoRepit)
infosInfoRepit = unique(infosInfoRepit)
infosInfoRepit$tags2 = NULL
infosInfoRepit$map = NULL
write.csv(infosInfoRepit, 'base_infos_repit.csv', row.names = F,
           fileEncoding = "UTF-8", quote = TRUE)

#### Soins à domicile
urlSoinsDomicile = "https://www.pour-les-personnes-agees.gouv.fr/annuaire-soins-et-services-a-domicile/%s/%s"
infosSoinsDomicile = Map(function(codesDep) {recupererInfos(urlSoinsDomicile, codesDep)}, codesDep)
infosSoinsDomicile = do.call(rbind.fill, infosSoinsDomicile)
infosSoinsDomicile = unique(infosSoinsDomicile)
infosSoinsDomicile$map = NULL
infosSoinsDomicile$tags2 = NULL
infosSoinsDomicile$is_esa = NULL
infosSoinsDomicile$is_handi_vieil = NULL
write.csv(infosSoinsDomicile, 'base_soins_domicile.csv', row.names = F,
           fileEncoding = "UTF-8", quote = TRUE)

