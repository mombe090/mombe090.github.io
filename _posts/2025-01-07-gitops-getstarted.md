---
layout: post
title:  "Introduction aux GitOps avec ArgoCD"
description: "Gérer vos déploiement avec la méthodologie GitOps avec ArgoCD"
categories: [kubernetes, gitops]
tags: [argocd, fluxcd, rancher-fleet]
author: "mombe090"
image:
  path: /assets/img/header/kind.webp
---

## Contexte :
Le `GitOps` est un framework/outil basé sur la méthodologie `DevOps` comme l'intégration continue et la livraison continue. <br />

Il permet de définir un état desiré d'une infra (kubernetes dans notre cas) dans un dépôt `git` qui devient la seule source de vérité de celle-ci. <br />

Un `daemon` ou `agent` est installé sur l'infra ciblé (le cluster kubernetes) et monitor votre dépôt, il fait des pull à des intervalles réguliers, compare l'existe et la dernière version du manifest du dépôt git et fait applique `aumagiquement` s'il y lieu le changement. <br />

Du coup un `dev` va utiliser avec lequel il est familiarisé pour définir toute son infrastructure ou déploiement dans 

Etant donné que tout se passe via git, le mechanism traditionnel du dévelopment s'applique, pull ou merge request, code review. <br />

- Pour l'équipe, ça facilite la collaboration, le tout est facilement audit via la codebase sur git et en cas de problème le rollback est plus simple (on revert le code, ni vue ni connue :) `serieusement on pourrai même automatiser le rollback en se basant metrics` )  
- Pour l'équipe plus aucun dev ne fait directement du kubectl apply, donc plus sécuritaire

Vous l'aurez compris le `GitOps` propose beaucoup d'avantages, actuellement plus facilement implémentable avec du kubernetes du fait de design déclarative mais dévrait pouvoir fonctionné en dehors même si les outils sont ou presque pas existant 

### Qui aura la plus grosse du gâteau ?

Comme pour tout nouveau concept dans le milieu, comme celà a été pour `kubernetes` vs `Mesos` vs `Swarm` (batail des orchestrateurs de conteneurs), le `GitOps`ne fait pas d'exceptions.

Voici une liste des 3 meilleurs outils `opensource` qui ont partagé l'`Octogone` :

- [FluxCD](https://fluxcd.io/) qui a été le pionnier, la 1ère release date du 28 Octobre 2016 (pas loin de la 1er de kube lui même)
  - Comme tout pionnier on apprend de nos erreurs pendant que d'autres outils emergent
  - fluxv2 est realisé le 6 May 2020, changement complètement d'architecture et même dépôt github, ils ont laissé 6,9K d'étoils à la v1.
  - Aujourd'hui, au moment d'écrire cet articel la v2 est encore à 6.7K 
  - L'entreprise qui coordonnait l'évolution de flux  (`weave work`) à fermer porte en 2024.
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) s'inspirant des apprentissages de la v1 de fluxcd, argo fait sa 1er release le 12 Mars 2018.
  - `ArgoCD` est orienté developpeurs avec une UI qui change complètement la manière de voir des déploiements d'objets kubernetes.
  - Aujourd'hui le dépôt [github](htt) totalise plus 18,3K d'étoiles 
  - Argo a beaucoup plus de budget et de contribution de la part de la `BigTech`
- [Rancher Fleet](https://fleet.rancher.io/)
  - `Fleet` est le plus jeune des 3, il faut encore convaincre `Dana` de lui donner la chance pour la ceinture, mais tout de même fait bien son boulot.
  - Totalise 1.5K d'étoils 

> Note: tous les 2 projets sont gradués à la CNCF qui represent la plus grosse organisation cloud native
{: .prompt-info }

### Ce que je pense personnellement :
J'ai commencé à apprendre le concept avec `FluxCD` et je l'utilise tout les jours dans mon emplois actuelle.
Argo je l'utilise beaucoup dans mes recherches, homelab et projet perso...

