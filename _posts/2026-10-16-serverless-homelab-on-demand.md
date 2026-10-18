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

L'important : éteindre et rallumer les 3 serveurs **ne change jamais la liste des membres** du cluster.

### Réveiller un serveur : Wake-on-LAN

Un serveur qui hiberne n'est pas vraiment mort, sa carte réseau reste à l'écoute. Le [Wake-on-LAN](https://fr.wikipedia.org/wiki/Wake-on-LAN) consiste à lui envoyer un
**paquet magique** : un message réseau spécial contenant 16 fois son adresse MAC, et il se rallume.

En version la plus simple possible, sans rien d'autre que la lib standard Python :

```python
import socket

MAC = bytes.fromhex("e4b97afb0abf")  # l'adresse MAC du serveur endormi
packet = b"\xff" * 6 + MAC * 16  # 6 octets 0xFF, puis la MAC 16 fois

with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    s.sendto(packet, ("192.168.x.255", 9))  # broadcast du VLAN, port 9 (discard)
```

Lancé depuis mon laptop, qui est branché sur le même switch que les serveurs : ça marche. La carte réseau voit son adresse MAC, réveille la carte mère, et quelques dizaines de secondes plus tard le serveur rejoint le cluster tout seul.

### Pourquoi passer par l'API Proxmox depuis Kubernetes ?

Deux contraintes entrent en collision :

1. **Une carte réseau en veille n'a pas d'adresse IP** : elle ne parle ni TCP ni TLS, elle attend un broadcast qui circule sur son câble. Impossible de la « contacter » directement depuis l'extérieur du VLAN.
2. **Un pod Kubernetes ne vit pas sur ce même câble** : il est dans le réseau du cluster (Cilium, VLAN dédié, overlay). Ses broadcasts ne sont pas propagés sur le VLAN des serveurs — et c'est très bien comme ça, d'un point de vue sécurité : un broadcast WoL qui traverserait tout le réseau permettrait de réveiller des serveurs d'autres VLAN.

Résultat : mon cronjob s'exécute, le paquet « part », mais la carte réseau endormie ne reçoit rien. C'est exactement le point 3 des pièges ci-dessous : **le paquet magique ne traverse pas les réseaux**.

La solution n'a rien de compliqué : `pve1`, un nœud du cluster Proxmox, est déjà allumé 24/7 et branché sur le même switch que les dormeurs. Je lui transmets donc l'ordre d'envoyer lui-même le broadcast, via son API REST, voir plus de détails dans la documentation Proxmox : [Wake-on-LAN via l'API](https://pve.proxmox.com/wiki/Proxmox_Node_Management).

```bash
curl -sk -H "Authorization: PVE $PROXMOX_API_TOKEN" \
  https://<pve1>:8006/api2/json/nodes/pve3/wakeonlan \
  -X POST
```

Dans mon cas, c'est un petit CLI Python qui fait ce curl pour moi : `homelab-automation proxmox wol --target-node pve3`.

Proxmox construit le paquet magique et l'envoie depuis sa propre carte réseau (lui est physiquement branché au bon endroit), et quelques dizaines de secondes plus tard le serveur réveillé rejoint le cluster tout seul.

## II: Utiliser KEDA pour scaler à zéro sur Kubernetes

> Pour le context j'ai cluster kubernetes qui tournes sous la distribution **Talos Linux**.
> Il est composé de 5 vm, et tourne sur 3 serveurs Proxmox.
> {: .prompt-tip }

Keda est un projet open source qui permet d'autoscaler des applications basées sur des événements. Il est particulièrement utile pour les applications qui ne sont pas utilisées en permanence, car il peut réduire le nombre de réplicas à zéro lorsqu'il n'y a pas de trafic, et les augmenter à nouveau lorsqu'il y a des demandes, nous utiliserons son extension [HTTP add-on](https://keda.sh/http-add-on/0.16/).

### Choix des applications à hiberner

Sur mon cluster Kubernetes tournent des outils que j'ouvre rarement : controlleur k8s, operateurs ainsi que des dashboards ou application qui ne sont pas utilisés tous les jours.

L'idéal serait de les éteindre complètement... mais de base, Kubernetes ne sait pas les rallumer tout seul quand quelqu'un veut les utiliser. D'où **KEDA**.

### Fonctionnement :
Le mécanisme ressemble à l'accueil d'un magasin fermé :

1. Vous arrivez devant la porte (vous ouvrez l'adresse monapp01).
2. Le **receptionniste** (un petit proxy appelé *interceptor*) vous accueille et vous demande de patienter.
3. Il appelle le vendeur : KEDA scale up l'application.
4. Quand elle est prête, le gardien vous fait entrer : votre page s'affiche.

Votre première visite met donc quelques secondes de plus (le cold start), mais elle **réussit**.

### Une règle simple, répétée partout

Chaque application qui hiberne suit le même modèle, simplement : « zéro pod au repos, une seule suffit quand il y a du monde, et on rendort après 15 minutes sans visite » :

```yaml
spec:
  scaledownPeriod: 900 # 15 minutes sans visite -> on rendort
  replicas:
    min: 0 # zéro pod quand personne ne vient
    max: 1 # une seule pod suffit pour un usage familial
```

Vous pouvez ajuster le temps de sommeil à votre convenance, mais 15 minutes est un bon compromis : ça laisse le temps de naviguer dans l'application, et ça ne consomme pas de ressources quand on ne l'utilise pas.

## III : Comment appliquer le même principe aux conteneurs classiques (Podman/Docker)

### Le même gardien, pour les petits services qui tournent dans des conteneurs docker.

À côté de Kubernetes, j'ai aussi des services simples qui tournent en conteneurs. C'est souvent des applications web, des dashboards, ou des outils de monitoring.

Ils tournaient en permanence, mais je ne les utilise pas tous les jours. Je veux donc qu'ils hibernent eux aussi, et se réveillent à la demande.
C'est là qu'intervient la solution [DockerWakeUp](https://github.com/jelliott2021/DockerWakeUp), qui joue exactement le même rôle que le gardien KEDA, mais pour les conteneurs classiques.

### Fonctionnement :

Techniquement, le mécanisme est simple :

- **NPM** (Nginx Proxy Manager) reçoit les visites chiffrées (HTTPS grace a let's encrypt) et les
  transmet au proxy de réveil en gardant le nom demandé.
- Le **proxy DockerWakeUp** regarde le nom : `audiobookshelf..., ` →
  il lance `podman compose up -d` dans `/opt/audiobookshelf`, puis transmet la visite.
- Après 15 minutes sans visite (`idle_threshold: 900`), il arrête le service avec `podman compose stop`.

Chaque service est déclaré simplement avec son nom, adresse locale, ordre de démarrage, ordre d'arrêt :

```yaml
- route: 'audiobookshelf'
  target: 'http://127.0.0.1:8080'
  startCommand: 'cd /opt/audiobookshelf && podman compose up -d'
  stopCommand: 'cd /opt/audiobookshelf && podman compose stop'
```

## Ce que ça fait gagner, honnêtement

Ce que je gagne :

- **3 serveurs éteints** la plupart du temps : moins de bruit, moins de chaleur, une facture d'électricité allégée.
- **La mémoire/cpu du cluster Kubernetes** libérée par plusieurs applications endormies.
- **services docker** qui ne consomment plus rien quand je ne m'en sers pas.

Ce que ça coûte :

- **Quelques secondes d'attente** au premier appel (cold start), à chaque
  étage : ~1 minute pour un serveur, quelques secondes pour un pod ou un conteneur. Mais soyons honnêtes : c'est lun `homelab` dont je suis le principal utilisateur, pas un service critique pour des millions d'utilisateurs.
- **De la complexité** : trois gardiens à maintenir, un Mac qui ne doit jamais dormir (mais moins energivore), des réglages BIOS à ne pas oublier.
- **Des paris assumés** : QDevice forcé non supporté officiellement.

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
