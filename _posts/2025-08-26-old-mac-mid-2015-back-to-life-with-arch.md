---
layout: post
title: "Comment j'ai ressuscité mon ancien MacBook Pro de 2015 avec Omarchy"
categories: [os, linux, open-source]
tags: [omarchy, hyperland, archlinux, macbook, linux, phoenix]
author: "mombe090"
image:
  path: /assets/img/header/kind.webp
---

# Introduction

Le [macbook PRO mid-2015](https://www.apple.com/fr/shop/buy-mac/macbook-pro/13-pouces) était à sortie l'un des meilleurs ordinateurs portables de sa génération.

Aujourd'hui agé de 10 ans, apple n'autorise pas de mise vers les dernières version a partir de 13 (Ventura) car le matériel ne supporterai pas ces OS modernes qui en demandes beaucoup plus.

Cependant, grâce à des projets open-source comme [Linux](https://linux.org/) et [Omarchy](https://omarchy.org/), il est possible de redonner vie à ces anciens appareils en installant des systèmes d'exploitation légers et personnalisables.

## Pourquoi Omarchy?

[Omarchy](https://omarchy.org/) est un ensemble de configurations basé sur [Arch Linux](https://archlinux.org/) qui vise à fournir une expérience développeur presque parfait mieux que ce peux offrir des systèmes fermé comme OSx ou Windows.

Cet ensemble de configuration est entrain de donner naissance doucement à une nouvelle distrubition linux sous Arch comme dans autres sont né et sont devenu des mastodont comme Ubuntu.

### Alors qui est derriere ce projet ?

The one and only DAVID HEINEMEIER HANSSON a.k.a (DHH) qui entend le mettre comme requis pour les techs de 37signals, le fameux monsieur derriere le tres populaire framework ruby on rails et CEO de 37signals, alez lire son blog, hmm il a des opionion des tres fort sur beaucoup de sujet technologiques, un grand fervant defenseur de ruby et tres critique a l'egard de language comme Rust et Typescript pour citer que ceux-la.

Recement apres une vingtaines d'annees avec MacBook et quelques conflits avec Apple, il a decider d'aller voir ce qui se fait mieux ailleurs.

### Prérequis

Pour pouvoir installer Omarchy sur un MacBook Pro mid-2015, vous aurez besoin de:

- Une clé USB d'au moins 8 Go pour créer un support d'installation bootable

- Un ordianteur avec un processeur x86, dans cet article, j'utilise mon vieux MacBook Pro mid-2015 (Mais d'autres version plus anciennes peuvent fonctionnier) voir la document d'[Arch Linux](https://wiki.archlinux.org/title/Laptop/Apple) pour les compatibilités matérielles

- Une bonne connexion internet pour télécharger l'ISO d'Omaarchy qui est tout recement sortie en version Beta, moi j'avais utiliser l'ISO d'[Arch Linux](https://archlinux.org/download/) pour l'installation initiale avant de configurer Omarchy via le script d'installation.

### Création d'une clé USB bootable

Pour flasher l'iso télécharger sur clé et la rendre bootable, plusieurs choix s'offrent à vous pouvez utiliser des outils comme :

- [Rufus](https://rufus.ie/) sur (Windows)
- [balenaEtcher](https://www.balena.io/etcher/) (Windows, macOS, Linux)
- ou [Ventoy](https://www.ventoy.net/en/index.html) que j'utilise personnelement, il permet de copier plusieurs ISO sur une même clé USB et de choisir au démarrage laquelle lancer.

### Démarrage sur la clé USB

Sur MacBook pour démarrer sur la clé USB, insérez la clé dans un port USB, puis redémarrez l'ordinateur en maintenant la touche `Alt` enfoncée jusqu'à ce que le gestionnaire de démarrage apparaisse voir la figure ci-dessous.

> [NOTE] : Vous pouvez rencontrer un probleme lie au secure boot, pour le desactiver, redemarrez en maintenant `Cmd + R` pour acceder au mode recovery, puis allez dans Utilitaire de sécurité au demarrage et selectionner "Aucune securité" et "Autoriser le demarrage a partir de support externe".

### Installation d'Omarchy

Choisisez l'iso d'[Omarchy](https://omarchy.org/) qui est plus s'imple que celle d'[Arch Linux](https://archlinux.org/download/) ou vous devez vous occuper de tout.

Sélectionnez ensuite la clé USB pour démarrer à partir de celle-ci :

- Arch Linux Install Medium (x86_64, UEFI)
- Remplissez les informations démandes (langue, clavier, nom d'utilisateur, mot de passe, etc.)

> Si vous avez un adaptateur ethernet, branchez-le pour une connexion internet plus stable pendant l'installation ou sinon le wifi aussi marche mais vous devrez le configurer manuellement via la ligne de commande [iwctl](https://man.archlinux.org/man/extra/iwd/iwctl.1.en), le wifi de mon mac a fonctionné sans problème.
> Omarchy viens avec un script qui instal beaucoup d'outils et ils doit télécharger pendant l'installation (+2Go), actuellement l'ISO n'est pas encore hors ligne comme des distributions comme Ubuntu ou Fedora.

Alors ça peut prendre un certain temps en fonction de votre connexion internet.

### Post-installation

Une fois l'installation terminée, redémarrez votre MacBook Pro et retirez la clé USB.
Vous devriez maintenant atterir sur [Hyperland](https://hyperland.org/), un gestionnaire de fenêtres moderne et léger qui fait partie de l'ensemble de configurations d'Omarchy.

> Oui il faut encore passer la page d'authentification, comme tout OS qui se respecte.

![omarch-login](./assets/img/omarch-login.png)

### Bienvenue dans Omarchy!

[Omarchy](https://omarchy.org/) vous ouvre un univers jusque-là peux accessible sinon à ceux qui dédie leurs vie à un terminal: :)

![welcom-page-omarch](./assets/img/omarchy-tokyo-theme.png)

### problème rencontré lors de mon utilisation

Jusque-là, j'ai rencontré deux problème majeur avec le mac :

Lorsque j'ai fini mon installation, tout les peripheries fonctionnaient parfaitement, wifi, bluetooth, son, webcam, etc.

1. Après un redémarrage, ma souris (logitech Mx Master 3s) et clavier( Logitech MX Keys) connecté via bluetooth ne fonctionnaient, j'ai du les supprimer et les réapparier pour que ça remarche mais ils continuaient à se déconnecter de temps en temps. Lus quelques postes sur des forums #ArchLinux sans succès (je suis certain que c'est un pb de driver), mais je laisse aller pour le moment et continue ma decourte du monde de l'arch de Noé qui a ressuscité mon mac 2015 qui est redevenu mon ordi principal.

- J'ai repris mon vieux clavier mecanique [keychron k10](https://www.keychron.com/products/keychron-k10-wireless-mechanical-keyboard) que j'avais acheter en 2022, qui contrairement au Logitech Mx keys permet la connexion filaire via USB et un vieux souris filaire.
  > Note: Le trackpad du mac fonctionne parfaitement, mais j'ai une configuration avec deux ecrans externes et je n'utilise pas le clavier du mac qui reste fermé.

2. Pour raison inconnue, le mac n'arrive plus à se connecter au wifi principal de la maison qui je pense utilise wifi 6 mais se connecte sans problème a un wifi secondaire secondaire fournir par mon locateur ainsi qu'au hotspot de mon téléphone.

- Alors j'ai acheter sur [amazon]() un adaptateur USB vers Ethernet, ce qui me donne une connexion internet stable plus rapide que celui commun dans l'immeuble.
  ![wifi-interface](./assets/img/wifi-interface.png).

### Les principal composant qui font qu'Omarchy est le parfait environnement pour un dev ou ops.

Pour moi voici quelques avantage qui font que je bascule sur Omarchy

1. Le projet est open-source (voir les scripts sur [github](https://github.com/basecamp/omarchy)), maintenu par une compagnie [basecamp](htttps://basecamp.com) et un individu qui a fait ses preuves avec Ruby-On-Rails **DHH**

2. Basé sur une distrubition Linux très populaire pour entre autres le nombre de packets disponible (officiellent mais aussi sur l'arch user registy AUR publier par monsieur madame tout le monde dont **_attention_**) avec toujours la dernières grâce au choix de rollingrelease.

3. Hyperland, cet environnement de bureau qui n'a rien a envie a mon avis a OSx ou Windows qui vous permet de le personnaliser vraiment a votre gout, attention tous se fait via des fichiers de config et la courbe d'apprentissage est un peux haute, mais Omarchy nous permet de plonger dedans et qu'on prennne le temps de bien l'apprendre. (J'avoue avoir ete seduit par hyperland depuis un moment avec une autre distrubition NixOs mais l'entree demandais tellement de notion et j'avais peux de temps a consacre, finalement j'ai abandonne).

4. Cette distrubition est centre sur l'utilisation du clavier et très rarement la souris, toutes les apps sont configurable via des binding qui vous permet en une combinaisons d'avoir acces a tout.

{% include embed/youtube.html id='TcHY0AEd2Uw' %}
📺 [Regarder la vidéo de présentation de la 2.0 par DHH](https://www.youtube.com/watch?v=TcHY0AEd2Uw)

### Synchronisation de ma configuration personnelle sur ma nouvelle monture

J'utlise des configuration [dotfiles](https) dont voici la version publique pour synchroniser la configuration, les outils sur l'ensemble des machines que j'utilise.

Maintenant que le vieux Mac redevient ma machine principale, j'ai synchronisé mes dotfiles pour retrouver mon environnement de travail habituel.

> J'ai ajusté quelques configurations spécifiques pour Omarchy et j'utilise gnus stow

### Installation de gnus stow avec pacman

Pacman est le gestionnaire de paquets par défaut d'Arch Linux et de ses dérivés, y compris Omarchy. Pour installer `stow`, vous pouvez utiliser la commande suivante dans le terminal :

```bash
sudo pacman -S stow
# repondre par y a la question de confirmation
```

<iframe src="https://asciinema.org/a/UnNxWpmeLJj8GtaYhkkRJ3nbN/iframe"
        id="asciicast-UnNxWpmeLJj8GtaYhkkRJ3nbN"
        frameborder="0"
        width="800"
        height="600">
</iframe>

<a href="https://asciinema.org/a/UnNxWpmeLJj8GtaYhkkRJ3nbN" target="_blank"><img src="https://asciinema.org/a/UnNxWpmeLJj8GtaYhkkRJ3nbN.svg" /></a>
