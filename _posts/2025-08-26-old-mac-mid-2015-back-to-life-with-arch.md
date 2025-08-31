---
layout: post
title: "Comment j’ai ressuscité mon MacBook Pro 2015 avec Omarchy : une seconde vie sous Arch Linux"
categories: [os, linux, open-source]
tags: [omarchy, hyperland, archlinux, macbook, linux, phoenix]
author: "mombe090"
image:
  path: /assets/img/header/omarchy.webp
---

# Introduction

Le [macbook PRO mid-2015](https://www.apple.com/fr/shop/buy-mac/macbook-pro/13-pouces) était à sa sortie l'un des meilleurs ordinateurs portables de sa génération, bref celui qu'il fallait avoir quoi.

Aujourd'hui âgé de 10 ans, Apple a arrêté officiellement de le supporter et n'autorise pas de mise à jour vers les dernières versions à partir de 13 (Ventura) depuis 2022 car le matériel ne supporterait pas ces OS modernes qui en demandent beaucoup plus aussi il voudrait oublier les puces Intel pour aller vers son propre processeur ARM.

Cependant, grâce à des projets open-source comme [Linux](https://linux.org/) et [Arch](https://archlinux.org), il est possible de rédonner vie à ces anciens appareils en installant des systèmes d'exploitation légers et personnalisables qui supportent très bien encore le matériel.

## Pourquoi [Omarchy](https://omarchy.org) ?

Sur la galaxie de distributions Linux qui existent, la plupart supporteraient encore ce matériel (Linux tourne sur tout ce qui s'allume **Joke**), peu sont celles qui le mentionnent sur leur site officiel comme [archlinux](https://wiki.archlinux.org/title/Laptop/Apple).

[Omarchy](https://omarchy.org/) est un ensemble de script de configurations basé sur [Arch Linux](https://archlinux.org/) qui vise à fournir une expérience développeur presque parfait mieux que ce peux offrir des systèmes fermé comme OSx ou Windows.

> Note: Même si beaucoup le considère comme une distribution linux, Omarchy n'en est pas une en soit, mais un ensemble de configuration qui s'installe sur une base Arch Linux.

Cet ensemble de configuration est en train de donner naissance doucement à une nouvelle distribution linux sous Arch comme tant d'autres sont nées et sont devenues des mastodontes comme Ubuntu sous Debian.

### Alors qui est derrière ce projet ?

The one and only **DAVID HEINEMEIER HANSSON** a.k.a (DHH) qui entend le mettre comme OS par défaut pour les techs de [37signals](https://37signals.com).

Il est connue pour avoir créer le très populaire framework de développement web [ruby on rails]() et CEO de 37signals.

> Voici le lien de son [blog](https://world.hey.com/dhh), **attention** typescripter/pythonista etc.. ([âmes sensibles]), il a des opinions des très fortes sur beaucoup de sujets Techs.

C'est un fervant défenseur de [ruby](https://www.ruby-lang.org/fr/) et très critique à l'égard de language comme Rust, Java et Typescript pour citer que ceux-la.

Il est devenu un nouveau linuxien après une vingtaine d'années à utiliser les de la marque à la Pomme et quelques conflits avec Apple principalement sur la manière dont il gère le store, il a décidé d'aller voir ce qui se fait mieux ailleurs.

Il commença très naturellement par **Windows**, mais très vite il se rendit compte que c'était pas fait pour lui, puis il essaya **Ubuntu** étant la distribution la plus populaire et la plus user-friendly, il l'utilisa pendant une année et finit par rassembler ses script de customization sous le nom, d'[Omakube](https://omakube.org/).

Après avoir suivi quelques youtubeurs comme **typecraft**, **Theprimegeon** utiliser des environnements de bureau comme **hyperland**, il décida de refaire une version plus aboutie et plus simple d'installation qu'Omakube et la nomma [Omarchy](https://omarchy.org/) mais cette fois-ci sous Arch Linux qui est une distribution plus légère avec presque aucun logiciel, environnements de bureau préinstallé et qui permet de tout configurer à sa guise.

### Prérequis

Pour installer [Omarchy](https://omarchy.org) sur un MacBook Pro mid-2015, vous aurez besoin des élements suivants :

- Une clé USB >= 4Go pour créer un support d'installation bootable

- Un ordinateur avec un processeur x86, dans cet article, j'utilise mon vieux MacBook Pro mid-2015 (Mais d'autres versions plus anciennes peuvent fonctionner) voir le wiki d'[Arch Linux](https://wiki.archlinux.org/title/Laptop/Apple) pour les autres Macbook compatibles.

- Une bonne connexion internet pour télécharger l'ISO d'[Omarchy](https://omarchy.org) qui a été publiée tout récemment:
  > Lors de mon installation l'ISO n'était pas encore disponible, j'avais utiliser l'ISO d'[Arch Linux](https://archlinux.org/download/) pour l'installation initiale avant de configurer Omarchy via le script d'installation.

### Création d'une clé USB bootable

Pour flasher l'ISO sur votre USB et la rendre bootable, plusieurs choix s'offrent à vous :

- [Rufus](https://rufus.ie/) sur (Windows)
- [balenaEtcher](https://www.balena.io/etcher/) (Windows, macOS, Linux)
- ou [Ventoy](https://www.ventoy.net/en/index.html) que j'utilise personnelement, il permet de copier plusieurs ISO sur une même clé USB et de choisir au démarrage laquelle lancer.

### Démarrage sur la clé USB

Insérez la clé dans un port USB, puis redémarrez l'ordinateur en maintenant la touche `Alt` enfoncée jusqu'à ce que le gestionnaire de démarrage apparaisse et choisissez la clé USB pour démarrer à partir de celle-ci.

> [NOTE] : Vous pouvez rencontrer un problème lié au secure boot, pour le désactiver, rédemarrez en maintenant `Cmd + R` pour acceder au mode recovery, puis allez dans Utilitaire de sécurité au demarrage et selectionner "Aucune securité" et "Autoriser le demarrage a partir de support externe".

### Installation d'Omarchy

Choisisez l'iso d'[Omarchy](https://omarchy.org/) qui est plus s'imple que celle d'[Arch Linux](https://archlinux.org/download/) ou vous devez vous occuper de tout.

Sélectionnez ensuite la clé USB pour démarrer à partir de celle-ci :

- Arch Linux Install Medium (x86_64, UEFI)
- Remplissez les informations comme (langue, clavier, nom d'utilisateur, mot de passe, etc.)

> Note: Si vous avez un adaptateur ethernet, branchez-le pour une connexion internet plus stable pendant l'installation ou sinon le wifi aussi marche mais vous devrez le configurer manuellement via la ligne de commande [iwctl](https://man.archlinux.org/man/extra/iwd/iwctl.1.en).
> Btw, le wifi de mon mac a fonctionné sans problème tout le long de l'installation.
> Omarchy viens avec un script qui instal beaucoup d'outils et ils doit télécharger pendant l'installation (+2Go), actuellement l'ISO n'est pas encore hors ligne comme des distributions comme Ubuntu ou Fedora.

Alors ça peut prendre un certain temps en fonction de votre connexion internet.

### Post-installation

Une fois l'installation terminée, redémarrez votre MacBook Pro et retirez la clé USB.
Vous devriez maintenant atterir sur [Hyperland](https://hyperland.org/), un gestionnaire de fenêtres moderne et léger qui fait partie de l'ensemble de configurations d'Omarchy.

> Oui il faut encore passer la page d'authentification, comme tout OS qui se respecte.

![omarch-login](./assets/img/omarch-login.webp)
_Ecrivez votre mot de passe et appuyez sur Entrée_

### Bienvenue dans Omarchy!

[Omarchy](https://omarchy.org/) vous ouvre un univers jusque-là peux accessible sauf à ceux qui dédie leurs vie à un terminal **_Joke_** 🤣

![welcom-page-omarch](./assets/img/omarchy-tokyo-theme.webp)
_Vous pouvez ouvrir un terminal en appuyant sur `Super + Enter` (la touche Super est généralement la touche Windows ou Commande sur Mac)._

### problème rencontré lors de mon utilisation

Après plus d'une semaine d'utilistion, j'ai rencontré deux problèmes majeurs avec Mac + Omarchy :

Lorsque j'ai fini mon installation, tout les péripheries à part la webcam fonctionnaient parfaitement, wifi, bluetooth, son, usb etc.

1. La caméra ne fonctionnait pas, mais après quelques recherches, j'ai trouvé une solution en installant les drivers qui manquent via AUR (Arch User Repository).

```bash
# Note Omarchy installe yay par défaut
yay -S bcwc-pcie-dkms
yay -S facetimehd-firmware-git

# Charger le module
sudo modprobe facetimehd

# S'assurer que le module est chargé au demarrage
echo facetimehd | sudo tee /etc/modules-load.d/facetimehd.conf
```

2. Après un redémarrage, ma souris (logitech Mx Master 3s) et clavier( Logitech MX Keys) connectés via bluetooth ont arrêter de fonctionner, j'ai dû les supprimer et les réapparier pour que ça remarche à nouveau. Le problème persiste car ils continuaient à se déconnecter de temps en temps.

Après quelques lecture, sur des forums #ArchLinux sans succès (je suis certain que c'est un pb de driver), mais je laisse aller pour le moment et continue ma décourte du monde de l'arch de Noé qui a ressuscité mon mac 2015 redevenu mon ordi principal dépuis.

J'ai repris mon vieux clavier mécanique [keychron k10](https://www.keychron.com/products/keychron-k10-wireless-mechanical-keyboard) que j'avais acheter en 2022, qui contrairement au Logitech Mx keys permet la connexion filaire via USB et une souris Logitech sans file mais avec connecteur usb qui fonctionne parfaitement.

> Note: Le trackpad du mac fonctionne parfaitement, mais j'ai une configuration avec deux ecrans externes et je n'utilise pas le clavier du mac qui reste fermé.

3. Pour raison inconnue, le mac n'arrive plus à se connecter au wifi principal (1.5Go) de la maison qui utilise du wifi 6 je crois, mais se connecte sans problème à un autre wifi ainsi qu'au hotspot de mon téléphone.

Alors j'ai acheter sur [amazon](https://www.amazon.ca/-/fr/dp/B00MYTSN18?ref=ppx_yo2ov_dt_b_fed_asin_title) un adaptateur USB vers Ethernet, ce qui me donne une connexion internet stable plus rapide.
![wifi-interface](./assets/img/wifi-interface.webp).

### Qu'est-ce qui fait qu'Omarchy est le parfait environnement pour moi ?

Pour moi voici quelques avantage qui font que je bascule sur Omarchy sur mon vieux mac:

1. Le projet est open-source (voir les scripts sur [github](https://github.com/basecamp/omarchy)), maintenu par une compagnie [basecamp](htttps://basecamp.com) et un individu qui a fait ses preuves avec Ruby-On-Rails **DHH**

2. Basé sur une distrubition Linux très populaire pour entre autres le nombre de packets disponible (officiellent mais aussi sur l'arch user registy AUR publier par monsieur madame tout le monde dont **_attention_**) avec toujours la dernières grâce au choix de rollingrelease.

3. Hyperland, cet environnement de bureau qui n'a rien a envie a mon avis a OSx ou Windows qui vous permet de le personnaliser vraiment a votre gout.

Attention tous se fait via des fichiers de config et la courbe d'apprentissage est un peux haute, mais Omarchy nous permet de plonger dedans et qu'on prennne le temps de bien l'apprendre.

> J'avoue avoir ete seduit par hyperland depuis un moment avec une autre distrubition NixOs mais l'entree demandais tellement de notion et j'avais peux de temps a consacre, finalement j'ai abandonne.

4. C'est un environnement axé sur l'utilisation du clavier en premier et très rarement la souris, toutes les apps sont configurable via des binding qui vous permet en une combinaisons d'avoir acces a tout.

### Voici une belle introduction a Omarchy 2.0 par DHH

{% include embed/youtube.html id='TcHY0AEd2Uw' %}
📺 [Regarder la vidéo de présentation de la 2.0 par DHH](https://www.youtube.com/watch?v=TcHY0AEd2Uw)

### Synchronisation de ma configuration personnelle sur ma nouvelle monture

J'utlise des fichiers configurations communement appelés [dotfiles](https://github.com/mombe090/.files) dont voici la version [publique](https://github.com/mombe090/.files) pour synchroniser ma configuration sur l'ensemble des machines que j'utilise.

Maintenant que le vieux Mac redevient ma machine principale, j'ai synchronisé mes dotfiles pour retrouver mon environnement de travail habituel. Il viens avec une documentation complète pour vous aider à personnaliser votre environnement selon vos préférences ajuster-le à votre guise.
