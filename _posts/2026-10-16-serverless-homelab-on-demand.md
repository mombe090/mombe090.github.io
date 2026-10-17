---
title: "Serverless dans mon homelab, consommation à la demande"
description: "Mon homelab compte un macmini m4 et 5 mini pcs dont 2 allumés H24. Les autres hibernent et se réveillent à la demande"

categories: [homelab, selfhosted]
tags: [homelab, proxmox, wol, qdevice, lima, keda, scale-to-zero, docker, dockerwakeup, gitops]
author: "mombe090"
image:
  path: /assets/img/header/serverless-homelab.webp
---

## Contexte

Dans un **homelab**, souvent, on veut tout faire tourner en permanence : un cluster Proxmox avec x nodes, un cluster Kubernetes, des conteneurs pour les petits services.
On se retrouve avec du bruit, de la chaleur, et une facture d'électricité qui grimpe rapidement pour des services qu'on utilise rarement après tout.

Dans une maison, pour réduire la facture d'électricité et adopter un comportement plus économe, genéralement les occupants éteignent les lumières, debranchent les appareils qui necessitent pas lénergie 7j/7, et surtout **ils ne chauffent pas (pour les pays froids) ou climatise pas (pour les pays chauds) une pièce vide**.

Et bien pour **homelab** on peut appliquer la même idée : **les services non essentiels hibernent par défaut, et se réveille uniquement quand on en a besoin**.

## Objectif

Après cet article, vous saurez :

- Pourquoi un cluster Proxmox a besoin d'un **quorum** (un vote à la majorité) pour rester en vie, et comment une microVM remplace 3 serveurs pour maintenir ce quorum.
- Comment **rallumer un serveur éteint** depuis votre application telegram grace au **Wake-on-LAN, un agent IA hermess et un job kubernetes**.
- Comment **KEDA** scale down vos applications Kubernetes et les scale up lorsqu'il recoit une requête HTTP comme les functions serverless du cloud.
- Comment **DockerWakeUp** fait pareil pour des conteneurs classiques (Podman ou Docker).
- Ce que ça fait gagner, et ce que ça coûte (parce qu'il y a un prix : l'attente).

## L'image d'ensemble : trois étages qui dorment

![Schéma du homelab serverless](/assets/img/content/homelab-serverless/hibernation-stages.jpeg)

Le point commun : **le visiteur ne voit aucune différence**, à part quelques
secondes d'attente au premier appel. C'est ce délai qu'on appelle le **cold start** (démarrage à froid), comme une voiture un bon matin d'hiver frette `Tokébakicitte`.

## Prérequis

- Wake-on-LAN activé sur les serveurs Proxmox (dans le BIOS et dans l'OS).
- Un cluster Proxmox ou machine physiques (le mien en compte 5 nœuds, mais le principe marche dès 2).
- Un cluster Kubernetes avec un gateway (Talos Linux + Cilium Gateway).
- Un hôte serveurs physique ou vm linux (Docker ou Podman) avec un reverse proxy (Nginx Proxy Manager + DockerWakeUp).
- Un controlleur KEDA avec le add-on `http` installé sur le cluster Kubernetes.,
- VM/Physique QDevice : une microVM Linux (chez moi : Lima sur Macmini  ) qui fait tourner le QDevice Proxmox.

## I: Le Wake-on-LAN, 2 serveurs allumés (24/7) sur 5 avec un QDevice

### Election : le quorum, c'est la majorité

Les serveurs Proxmox d'un cluster se surveillent entre eux en permanence. Pour
prendre une décision (démarrer une machine virtuelle, par exemple), il faut
**plus de la moitié des voix** : c'est le **quorum**. Pensez à un conseil de
famille : à 5 autour de la table, il faut 3 voix pour décider.

Si j'éteins 3 serveurs sur 5, il n'en reste que 2 : 2 voix sur 5, pas de
majorité, le cluster se fige pour se protéger (en mode lecture). Impossible de créer de nouvelles machines virtuelles, impossible de démarrer celles qui étaient éteintes.

### Pourquoi a-t-on besoin d'un QDevice ?

Proxmox permet d'ajouter un **QDevice** : un tout petit programme qui vote à la
place des absents. Avec un réglage un peu particulier, mon QDevice apporte
4 voix. Faisons le calcul :

| Situation               | Voix    | Verdict                      |
| ----------------------- | ------- | ---------------------------- |
| 5 serveurs + QDevice    | 9 sur 9 | Le cluster décide            |
| 2 serveurs + QDevice    | 6 sur 9 | Le cluster décide quand même |
| 2 serveurs sans QDevice | 2 sur 5 | Le cluster se fige           |

Le QDevice tourne dans une **toute petite microVM** (`qdevice-vm`)
hébergée sur mon Mac mini grâce à **Lima** (un outil qui fait tourner des
machines virtuelles Linux sur Mac). 
Elle a une vraie adresse sur mon réseau local binder au port ethernet de son hote et ne fait qu'une seule chose : voter. Elle consomme à peine 200m de CPU et 200Mo de RAM le macmini est peu energivore. 

> Monter un QDevice sur un cluster de 5 nœuds n'est pas officiellement supporté
> par Proxmox : il faut forcer l'installation avec `pvecm qdevice setup
> --force`. Ça marche, mais le Mac mini devient critique : s'il s'endort, les
> 2 serveurs restants perdent leur majorité et tout se fige. Mon Mac ne dort
> donc jamais grâce à un outils comme **Amphetamine**.
> {: .prompt-tip }

L'important : éteindre et rallumer les 3 serveurs **ne change jamais la liste
des membres** du cluster. 

### Réveiller un serveur depuis son canapé : Wake-on-LAN

Un serveur éteint n'est pas vraiment mort : sa carte réseau reste à l'écoute,
comme quelqu'un qui dort d'un œil. Le **Wake-on-LAN** consiste à lui envoyer un
**paquet magique** — un message réseau spécial contenant 16 fois son adresse
matérielle (adresse MAC) — et il se rallume.

Concrètement, pour réveiller mon serveur `pve2-prod`, j'envoie depuis un
serveur resté allumé :

```bash
homelab-automation proxmox wol --target-node pve2-prod
```

Le serveur allumé relaie l'ordre via l'API Proxmox, le paquet magique part sur
le câble, et quelques dizaines de secondes plus tard le serveur rejoint le
cluster tout seul.

Trois pièges à connaître si vous essayez (je les ai tous rencontrés) :

1. **Le BIOS doit autoriser le réveil** : option « Wake on LAN » activée, et
   surtout **« Deep Sleep » désactivé** (sur les Dell Optiplex, sinon la carte
   réseau s'éteint vraiment et rien ne peut la réveiller).
2. **Le voyant de la prise réseau doit rester allumé** quand le serveur est
   éteint. Voyant éteint = réveil impossible, retour au point 1.
3. **Le paquet magique ne traverse pas les réseaux** : l'expéditeur doit être
   sur le même câble (le même « L2 ») que le dormeur.

## Étage 2 : des applications Kubernetes qui dorment à zéro

### Le problème des tableaux de bord que personne ne regarde

Sur mon cluster Kubernetes tournent des outils que j'ouvre rarement : la page
d'accueil Homepage, l'interface de GitOps, les graphiques Grafana, la console
de stockage Longhorn. Chacun gardait en permanence un petit programme allumé
« au cas où ». Mis bout à bout, c'est beaucoup de mémoire immobilisée pour
rien sur un petit cluster.

L'idéal serait de les éteindre complètement... mais Kubernetes ne sait pas les
rallumer tout seul quand quelqu'un arrive. D'où **KEDA**.

### KEDA : le gardien qui ouvre la boutique quand un client frappe

**KEDA** est un programme qui surveille et ajuste le nombre de copies d'une
application. Son extension **HTTP add-on** ajoute un super-pouvoir : descendre
à **zéro copie** quand personne ne vient, et remonter dès qu'une visite web
arrive.

Le mécanisme ressemble à l'accueil d'un magasin fermé :

1. Vous arrivez devant la porte (vous ouvrez l'adresse Grafana).
2. Le **gardien** (un petit proxy appelé *interceptor*) vous accueille et vous
   demande de patienter.
3. Il appelle le vendeur : KEDA démarre l'application.
4. Quand elle est prête, le gardien vous fait entrer : votre page s'affiche.

Votre première visite met donc quelques secondes de plus (le cold start), mais
elle **réussit** — vous ne tombez jamais sur une erreur.

### Une règle simple, répétée partout

Chaque application endormie suit le même modèle, qui dit en substance :
« zéro copie au repos, une seule suffit quand il y a du monde, et on rendort
après 20 minutes sans visite » :

```yaml
spec:
  scaledownPeriod: 1200 # 20 minutes sans visite -> on rendort
  replicas:
    min: 0 # zéro copie quand personne ne vient
    max: 1 # une seule copie suffit pour un usage familial
```

Pourquoi 20 minutes ? Trop court, l'application s'endort pendant que vous
cliquez encore (et vous reprenez un cold start). Trop long, elle garde de la
mémoire pour rien. 20 minutes couvre une session normale de consultation.

Aujourd'hui, quatre applications dorment ainsi : **Homepage**, **l'interface
Flux**, **Grafana + Prometheus** et **Longhorn**. Tout est décrit dans des
fichiers gérés par **Flux** (mon outil de GitOps : l'état du cluster est écrit
dans des dépôts git, et chaque `git push` met le cluster à jour).

> Petit détail technique pour les curieux : la page de connexion (`/oauth2`)
> contourne le gardien et va directement à l'application, sinon le retour de
> connexion risquerait d'arriver pendant le réveil et d'échouer.
> {: .prompt-info }

## Étage 3 : des conteneurs réveillés par leur adresse web

### Le même gardien, pour les petits services

À côté de Kubernetes, j'ai aussi des services simples qui tournent en
conteneurs (think « une application = une boîte ») avec **Podman** : Dozzle
(voir les journaux), Arcane, Karakeep (garder des liens), Audiobookshelf
(livres audio), un portail de développement.

Eux aussi dormaient... enfin non, eux tournaient H24 pour rien. C'est là
qu'intervient **DockerWakeUp**, qui joue exactement le même rôle que le gardien
KEDA, mais pour les conteneurs classiques.

### Le standard téléphonique

Imaginez un standard téléphonique : vous demandez « Dozzle », la standardiste
voit que le poste dort, elle le réveille, vous fait patienter quelques
secondes, puis vous passe la communication. Quand vous raccrochez et que plus
personne n'appelle pendant 15 minutes, elle ré-éteint le poste.

Techniquement :

- **NPM** (Nginx Proxy Manager) reçoit les visites chiffrées (HTTPS) et les
  transmet au proxy de réveil en gardant le nom demandé.
- Le **proxy DockerWakeUp** (port `8099`) regarde le nom : `dozzle...` →
  il lance `podman compose up -d` dans `/opt/dozzle`, puis transmet la visite.
- Après 15 minutes sans visite (`idle_threshold: 900`), il arrête le service
  avec `podman compose stop`.

Chaque service est déclaré simplement — nom, adresse locale, ordre de
démarrage, ordre d'arrêt :

```yaml
- route: 'dozzle'
  target: 'http://127.0.0.1:8081'
  startCommand: 'cd /opt/dozzle && podman compose up -d'
  stopCommand: 'cd /opt/dozzle && podman compose stop'
```

Le tout est installé automatiquement par un **rôle Ansible** (une recette
d'installation réutilisable), en mode « natif » : le proxy tourne directement
sur l'hôte pour pouvoir piloter Podman sans détour.

## Ce que ça fait gagner, honnêtement

Ce que je gagne :

- **3 serveurs éteints** la plupart du temps : moins de bruit, moins de chaleur,
  une facture d'électricité allégée.
- **La mémoire du cluster Kubernetes** libérée par 4 applications endormies.
- **5 petits services** qui ne consomment plus rien quand je ne m'en sers pas.

Ce que ça coûte :

- **Quelques secondes d'attente** au premier appel (cold start), à chaque
  étage : ~1 minute pour un serveur, quelques secondes pour un pod ou un
  conteneur.
- **De la complexité** : trois gardiens à maintenir, un Mac qui ne doit jamais
  dormir, des réglages BIOS à ne pas oublier.
- **Des paris assumés** : QDevice forcé non supporté officiellement, logiciel
  DockerWakeUp suivi sur sa branche principale.

Pour un homelab, le calcul est largement positif : mes services personnels
n'ont pas besoin d'une ambulance à chaque seconde, ils ont besoin d'être là
quand je les appelle.

## Ressources utiles

- [Proxmox : quorum avec QDevice](https://pve.proxmox.com/wiki/Cluster_Manager)
- [KEDA HTTP add-on](https://kedahttp.dev/)
- [DockerWakeUp](https://github.com/jelliott2021/DockerWakeUp)
- [Lima (VM Linux sur Mac)](https://lima-vm.io/)
- [KEDA ScaledObject vs HTTPScaledObject](https://kedahttp.dev/concepts/)
- Les autres articles du blog : la visite continuera en vidéo.

## Conclusion

Le serverless n'est pas une magie réservée au cloud : c'est une discipline —
**ne rien laisser allumé sans raison, et savoir réveiller vite**. Dans mon
homelab, elle s'applique à trois échelles : les serveurs se réveillent par
paquet magique, les pods par visite HTTP, les conteneurs par leur nom de
domaine. Le socle H24 tient sur 2 serveurs, une mini VM qui vote, et trois
petits gardiens.

Et vous, qu'est-ce qui tourne chez vous pour personne ? Par quel étage
commenceriez-vous : éteindre un serveur, endormir une application, ou mettre un
conteneur en veille ? Racontez-moi en commentaire — et on se retrouve dans la
vidéo, où je réveille tout ça en direct.
