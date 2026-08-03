---
title: "Présentation de mon Homelab : le script vidéo complet 🎬"
description: "Le script voix off (~13 min) de ma présentation Homelab, structuré autour du dashboard Homepage : Infrastructure, Réseau & Sécurité, Dev & AI, Monitoring, Multimédia et services externes."
categories: [homelab]
tags: [homelab, homepage, kubernetes, talos, proxmox, fluxcd, gitops, selfhosted, video]
author: "mombe090"
image:
  path: /assets/img/header/homelab-presentation.webp
alternate_url: /en/posts/homelab-presentation/
---

## Contexte

Quand on passe des années à construire un Homelab, on finit par l'oublier : personne ne voit le travail en coulisses. Ce qui est pour moi un environnement quotidien reste invisible pour les autres, et pourtant, chaque service a sa raison d'être.

J'ai décidé de poser une caméra sur mon dashboard **Homepage** et d'en faire une visite guidée en ~13 minutes. L'objectif : montrer que ce n'est pas une collection de services empilés au hasard, mais une **infrastructure cohérente**, proche de ce que l'on trouve en entreprise.

> Ce script est volontairement orienté démo : chaque section correspond à un onglet réel de mon dashboard Homepage, déployé en Kubernetes via Flux CD.
> {: .prompt-info }

## Objectif

À la fin de cette vidéo, le spectateur saura :

- Pourquoi **Homepage** est mon point d'entrée unique (widgets, onglets, recherche)
- Comment s'organise la couche infrastructure : `Proxmox`, `Talos`, `Kubernetes`, `Flux CD`
- Quels services réseau, sécurité et dev j'ai auto-hébergés, et dans quel but
- Que chaque brique (monitoring, secrets, stockage) répond à un vrai besoin

## Le script

### 1. Accroche & intro — [0:00 → 0:40]

*(Plan d'ouverture sur le dashboard, puis coupe sur l'auteur face caméra)*

« Bienvenue dans cette vidéo où je vais vous présenter mon Homelab.
Ce n'est pas un simple serveur de stockage au fond d'un placard : c'est un vrai environnement d'infrastructure, le plus proche possible de ce que j'utilise au travail.
Et pour vous le faire visiter, je vais partir de mon point d'entrée unique : le dashboard **Homepage**. »

### 2. Homepage, le point d'entrée — [0:40 → 1:30]

*(Défilement lent du dashboard, widgets en surbrillance)*

« Ici, tout est centralisé et organisé en onglets : Infrastructure, Réseau & Sécurité, Dev & AI, Monitoring, Multimédia, et des raccourcis vers mes services externes.
On retrouve en haut les widgets de ressources — CPU, mémoire, disque —, une barre de recherche, et surtout un accès en un clic à chaque service.
L'idée n'est pas seulement d'héberger des applications, mais de construire un environnement **cohérent, pratique et professionnel**. »

### 3. Infrastructure — l'hyperviseur et la plateforme — [1:30 → 4:30]

*(Onglet Infrastructure, section "proxmox-prod")*

« Commençons par les fondations.
Au cœur de ce Homelab, un cluster **Proxmox VE** à trois nœuds — PVE1, PVE2, PVE3 —, avec un **Proxmox Backup Server** dédié aux sauvegardes.
Tout le provisioning des machines virtuelles est fait en Infrastructure as Code, avec **Terraform/OpenTofu**, et la configuration avec **Ansible**.

Au-dessus de Proxmox, j'ai déployé un cluster **Kubernetes sous Talos Linux**. Talos est un OS immuable, pensé exclusivement pour Kubernetes : ça simplifie énormément la sécurité et la maintenance. »

*(Section "platform")*

« Pour la gestion du cluster, j'utilise le **GitOps** : **Flux CD** et **Argo CD** appliquent automatiquement ce qui est déclaré dans mes dépôts git. La suite GitOps est visible directement ici, avec **Flux Web** et **Argo CD**.
Côté interfaces, **Headlamp** me donne une vue claire sur les workloads, et **Argo Workflows** orchestre mes pipelines de tâches.
Vous avez aussi **AKHQ** pour piloter le cluster Kafka qui sert à mon architecture événementielle. »

*(Section "storage")*

« Côté stockage, trois niveaux complémentaires :

- **TrueNAS** pour le stockage réseau
- **Longhorn** comme stockage Kubernetes distribué
- **RustFS**, un stockage objet compatible S3, décliné en deux pools — rapide et lent — selon l'usage

Et **PgAdmin** pour l'administration des bases PostgreSQL. »

### 4. Réseau & Sécurité — [4:30 → 7:00]

*(Onglet "Network & Security")*

« En basse couche, le réseau est protégé par un pare-feu **OPNsense**, deux routeurs, et **Traefik** fait office de reverse proxy et load balancer pour exposer tous les services.
Le DNS est géré par **Pi-hole** — je l'utilise aussi comme bloqueur de publicités, à la fois sur le serveur de production et sur mon MacBook. »

*(Section "security")*

« La sécurité est une couche transversale de ce projet :

- **Authentik** est mon Identity Provider et centralise le SSO de tous les services
- **Vaultwarden** gère mes mots de passe en self-hosting
- **OpenBao**, le fork open source de Vault, gère les secrets dynamiques
- **Infisical** complète la gestion des secrets au niveau des applications

L'accès au dashboard lui-même passe par Authentik via un proxy OAuth — tout est authentifié, même chez moi. »

### 5. Dev & AI — [7:00 → 9:30]

*(Onglet "Dev & AI", section "devtools")*

« Place à l'environnement de développement.
**Forgejo** héberge mes dépôts git et mes pipelines CI/CD — c'est lui qui contient toute la config du Homelab, y compris celle de Homepage.
**Backstage**, mon developer portal, sert de catalogue de services.
J'ai aussi un lecteur RSS auto-hébergé avec **FreshRSS**, et un site de documentation généré avec **MkDocs** — documenter par le code fait partie intégrante de ma démarche. »

*(Section "ai-tools")*

« Et bien sûr, la partie la plus amusante : les outils d'IA.

- **n8n** automatise mes workflows
- **Kagent** est un agent IA intégré à Kubernetes
- **OpenCode** est mon assistant de codage
- **OpenClaw**, un agent client

Ce sont de vrais outils du quotidien, pas des jouets de démonstration. »

### 6. Monitoring & observabilité — [9:30 → 10:45]

*(Onglet "Monitoring")*

« Rien de tout ça ne tiendrait sans observabilité.
La stack est classique mais complète : **Prometheus** collecte les métriques, **Grafana** les visualise, **Alertmanager** route les alertes, et **Uptime Kuma** surveille la disponibilité de tous les services.
C'est exactement la même approche qu'en entreprise : sans métriques ni alertes, on opère à l'aveugle. »

### 7. Multimédia — [10:45 → 11:30]

*(Onglet "Multimedia")*

« Pour terminer, le côté plus loisir du Homelab :

- **Navidrome** pour le streaming musical
- **Immich** comme galerie photos — l'alternative Google Photos
- **Audiobookshelf** pour ma bibliothèque d'audiolivres »

### 8. Services externes & conclusion — [11:30 → 13:30]

*(Onglet "External Services", puis retour face caméra)*

« Enfin, un onglet regroupe mes services cloud et externes : GitHub, Azure DevOps pour le travail, ou encore les outils d'IA comme ChatGPT, Claude et Perplexity. Tout est accessible depuis un seul endroit, sans ouvrir dix onglets. »

*(Retour face caméra)*

« Ce Homelab est avant tout une salle de laboratoire : c'est là que j'expérimente, que je casse, et que je répare. Tout est versionné dans mon monorepo **CraftArc**, et chaque commit représente une leçon apprise.
J'espère que cette visite vous a plu et qu'elle vous donnera envie de vous lancer.
N'hésitez pas à poser vos questions en commentaire — on se retrouve dans une prochaine vidéo. À bientôt ! »

## Notes de production

- **~13:30** de narration (~150 mots/min, ≈2 000 mots), laissant la marge pour atteindre 15 min avec les démos et transitions.
- Chaque section correspond à un onglet réel du dashboard (`Infrastructure` / `Network & Security` / `Dev & AI` / `Monitoring` / `Multimedia` / `External Services`).
- On peut couper les sections *Réseau & Sécurité* ou *Dev & AI* en deux pour laisser plus de place aux démos en direct.

> Pour la voix off, le rythme idéal se situe entre 140 et 160 mots par minute. Les indications `[timestamp]` servent de repères de montage, pas de contraintes strictes.
> {: .prompt-tip }

## Ressources utiles

- [Homepage — Dashboard self-hosted](https://gethomepage.dev)
- [Homepage — GitHub](https://github.com/gethomepage/homepage)
- [Talos Linux — Documentation](https://www.talos.dev/)
- [Flux CD — Documentation](https://fluxcd.io/flux/)
- [Proxmox VE](https://www.proxmox.com/)
- [CraftArc — mon monorepo Homelab](https://github.com/mombe090)

## Conclusion

Ce script reflète une conviction simple : un Homelab, ce n'est pas une liste de services, c'est une architecture. En présentant chaque onglet comme une brique d'un ensemble, la vidéo devient une vraie visite guidée plutôt qu'un simple catalogue.

Et vous, par quel outil présentez-vous votre Homelab ? Avez-vous aussi choisi un dashboard comme porte d'entrée ? Partagez votre expérience en commentaires !
