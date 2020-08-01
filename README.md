# Etablissements pour les personnes âgées

Ce code **R** permet de consolider les annuaires concernant les établissements référencés sur la plateforme https://www.pour-les-personnes-agees.gouv.fr/annuaires. Les données sont consolidées au sein de trois fichiers rendus disponible sur https://data.gouv.fr : 

* les [Points d'informations locaux pour les personnes âgées](https://www.data.gouv.fr/fr/datasets/points-dinformations-locaux-pour-les-personnes-agees/),
* les [Etablissements EHPAD, ESLD, résidences autonomie, accueils de jour](https://www.data.gouv.fr/fr/datasets/etablissements-ehpad-esld-residences-autonomie-accueils-de-jour/),
* les [Services d’aide et de soins à domicile](https://www.data.gouv.fr/fr/datasets/services-daide-et-de-soins-a-domicile/).

Le code **Python** permet d'automatiser le téléversement vers data.gouv.fr.

# Documentation du jeu

Liste, coordonnées et caractéristiques de l'ensemble des établissements pour les personnes âgées (structures médicalisées, résidences autonomie et autres types d'hébergement). Ces données sont issues du site https://www.pour-les-personnes-agees.gouv.fr/annuaire-ehpad-et-maisons-de-retraite

Cet annuaire regroupe les types d'établissements suivants :
* les **structures médicalisées** :
   * les **EHPAD** (établissement d'hébergement pour les personnes âgées dépendantes) : adresse, coordonnées et principales caractéristiques, notamment prix et prestations,
   * les **établissements de soins de longue durée** : adresse, coordonnées et principales caractéristiques,
   * les établissements proposant des places d'**accueil de jour** : adresse et coordonnées.
* les **résidences autonomie**, ensembles de logements adaptés avec des services pour les personnes âgées : adresse, coordonnées et principales caractéristiques : statut, capacités, prix mensuel par type d’hébergement...
* les autres types d'hébergement pour personnes âgées (EHPA, Petite unité de vie...) : adresse et coordonnées

**ATTENTION : La CNSA a récemment changé le format des données.**

## Description des champs

### Informations générales sur l'établissement
- `id` : identifiant de l'établissement
- `title` :  nom de l'établissmeent
- `updatedAt` : date de la dernière mise à jour de la fiche établissement
- `noFinesset` : numéro finess de l'établissement (identifiant unique)
- `capacity` : nombre de places
- `legal_status` : statut de l'établissement (public, privé à but non lucratif, privé à but commercial)

### Type d'établissement, accompagnement spécifique et aides publiques
- `isViaTrajectoire` : le dossier d'inscription peut-il être fait par la plateforme "via Trajectoire" ?
- `IsEHPAD` : l'établissement est-il un EHPAD, établissement accueillant des personnes dépendantes ?
- `IsEHPA` : l'établissement est-il un EHPAD, établissement d'hébergement pour des personnes autonomes ou semi-valides ?
- `IsESLD` : l'établissement est-il un établissement de soin longue durée ?
- `IsRA` : l'établissement est-il une résidence autonomie ?
- `IsAJA` : l'établissement propose t-il un accueil de jour ?
- `IsHCOMPL` : l'établissement propose t-il un hébergement permanent ?
- `IsHTEMPO` : l'établissement propose t-il un hébergement temporaire ?
- `IsACC_JOUR` : l'établissement propose t-il un accueil de jour ?
- `IsACC_NUIT` : l'établissement propose t-il un accueil de nuit ?
- `IsHAB_AIDE_SOC` : l'établissement est-il habilité à aide sociale ?
- `IsCONV_APL` : conventionné APL aide personnalisée au logement
- `IsALZH` : unité Alzheimer
- `IsUHR` : unité UHR Unité hébergement renforcé
- `IsPASA` : unité PASA Pôle d'activité et de soins adaptés
- `IsPUV` : l'établissement propose t-il des petites unités de vie ?
- `IsF1` : l'établissement propose t-il des logements de type F1 ?
- `IsF1Bis` : l'établissement propose t-il des logements de type F1Bis ?
- `IsF2` : l'établissement propose t-il des logements de type F2 ?

- `raPrice` : [vide]
- `cerfa` : [vide]
- `prixMin` : ce prix est calculé sur la base du prix pour une chambre seule, hors aides publiques (Aide sociale à l’hébergement, aides au logement et APA).

### Coordonnées de l'établissement
- `coordinates._id` : [vide]
- `coordinates.title` : [vide]
- `coordinates.isPublished` : [vide]
- `coordinates.createdAt` : [vide]
- `coordinates.updatedAt` : [vide]
- `coordinates.street` : adresse de l'établissement
- `coordinates.postcode` : code postal
- `coordinates.deptcode` : code de département
- `coordinates.deptname` : nom du département
- `coordinates.city` : ville
- `coordinates.phone` : téléphone
- `coordinates.emailContact` : email
- `coordinates.gestionnaire` : identité du gestionnaire
- `coordinates.website` : site internet
- `coordinates.latitude` : latitude de l'établissement, système WGS84    
- `coordinates.longitude` : longitude de l'établissement, système WGS84    
             
### Prix des hébergements EHPAD et ESLD, en €/jour    
- `ehpadPrice._id` : identifiant de prix
- `ehpadPrice.updatedAt` : date de la dernière mise à jour des prix
- `ehpadPrice.prixHebPermCs` : prix hébergement permanent chambre simple
- `ehpadPrice.prixHebPermCd` : prix hébergement permanent chambre double
- `ehpadPrice.prixHebPermCsa` : prix hébergement permanent chambre simple pour les bénéficiaires de l'ASH (aide sociale à l'hébergement)
- `ehpadPrice.prixHebPermCda` : prix hébergement permanent chambre doublepour les bénéficiaires de l'ASH
- `ehpadPrice.prixHebTempCs` : prix hébergement temporaire chambre simple
- `ehpadPrice.prixHebTempCd` : prix hébergement temporaire chambre double
- `ehpadPrice.prixHebTempCsa` : prix hébergement temporaire chambre simple pour les bénéficiaires de l'ASH
- `ehpadPrice.prixHebTempCda` : prix hébergement temporaire chambre doublepour les bénéficiaires de l'ASH
- `ehpadPrice.tarifHebJour` :  prix de l'accueil de jour
- `ehpadPrice.tarifGir12` : tarif dépendance GIR 1-2
- `ehpadPrice.tarifGir34` : tarif dépendance GIR 3-4
- `ehpadPrice.tarifGir56` : tarif dépendance GIR 5-6
- `ehpadPrice.autrePrestation` : autres prestations proposées (champ "brut", non retraité, avec les balises)
- `ehpadPrice.autreTarifPrest` : tarif des autres prestations

### Loyer mensuel des logements Résidence Autonomie, en €/mois
- `raPrice._id` : identifiant de prix des RA
- `raPrice.updatedAt` : date de la dernière mise à jour des prix
- `raPrice.PrixF1` : loyer mensuel d'un logement de type F1
- `raPrice.PrixF1ASH` : loyer mensuel d'un logement de type F1 pour les bénéficiaires de l'ASH
- `raPrice.PrixF1Bis` : loyer mensuel d'un logement de type F1 bis
- `raPrice.PrixF1BisASH` : loyer mensuel d'un logement de type F1 bis pour les bénéficiaires de l'ASH
- `raPrice.PrixF2` : loyer mensuel d'un logement de type F2
- `raPrice.PrixF2ASH` : loyer mensuel d'un logement de type F2 pour les bénéficiaires de l'ASH
- `raPrice.autreTarifPrest` : tarif des autres prestations
- `raPrice.prestObligatoire` : autres prestations obligatoire [vide]


