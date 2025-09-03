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

Le [MacBook Pro mid-2015](https://www.apple.com/fr/shop/buy-mac/macbook-pro/13-pouces) était à sa sortie l'un des meilleurs ordinateurs portables de sa génération, bref celui qu'il fallait avoir.

Aujourd'hui âgé de 10 ans, Apple a officiellement arrêté de le supporter et n'autorise pas de mise à jour vers les dernières versions à partir de macOS 13 (Ventura) depuis 2022, car le matériel ne supporterait pas ces OS modernes qui en demandent beaucoup plus. Apple souhaite également abandonner les puces Intel pour migrer vers son propre processeur ARM.

Cependant, grâce à des projets open-source comme [Linux](https://linux.org/) et [Arch](https://archlinux.org), il est possible de rédonner vie à ces anciens appareils en installant des systèmes d'exploitation légers et personnalisables qui supportent très bien encore le matériel.

## Pourquoi [Omarchy](https://omarchy.org) ?

Parmi la galaxie de distributions Linux qui existent, la plupart supporteraient encore ce matériel (Linux tourne sur tout ce qui s'allume **Joke**), mais peu sont celles qui le mentionnent sur leur site officiel comme [Arch Linux](https://wiki.archlinux.org/title/Laptop/Apple).

[Omarchy](https://omarchy.org/) est un ensemble de scripts bash basé sur [Arch Linux](https://archlinux.org/) qui vise à fournir une expérience développeur presque parfaite, bien meilleure que ce que peuvent offrir des systèmes fermés comme macOS ou Windows.

> Note : Même si beaucoup le considèrent comme une distribution Linux, Omarchy n'en est pas une en soi, mais est en train de donner naissance doucement à une sous Arch, comme tant d'autres sont nées et sont devenues des mastodontes comme Ubuntu sous Debian ou encore CentOS sous RedHat.
{: .prompt-info }

### Alors qui est derrière ce projet ?


The one and only **DAVID HEINEMEIER HANSSON** a.k.a (_DHH_) qui entend le mettre comme OS par défaut pour les développeurs de [37signals](https://37signals.com).

Il est connu pour avoir créé le très populaire framework de développement web [Ruby on Rails](http://rubyonrails.org) et aussi CEO de 37signals.

> Voici le lien de son [blog](https://world.hey.com/dhh), **attention** TypeScripters/pythonistas etc. ([âmes sensibles]), il a des opinions très fortes sur beaucoup de sujets tech.
{: .prompt-info }

C'est un fervent défenseur de [Ruby](https://www.ruby-lang.org/fr/) et très critique à l'égard de langages comme Rust, Java et TypeScript pour ne citer que ceux-là.
Il est devenu un nouveau linuxien il y a peu de temps après une vingtaine d'années à utiliser les ordinateurs de la marque à la Pomme. Suite à quelques conflits avec Apple, principalement sur la manière dont Apple gère le store, il a décidé d'aller voir ce qui se fait de mieux ailleurs.

Il commença très naturellement par **Windows**, mais très vite il se rendit compte que ce n'était pas fait pour lui, puis il essaya **Ubuntu** étant la distribution la plus populaire et la plus user-friendly et accueillante pour débutants. Il l'utilisa pendant une année et finit par rassembler ses scripts de customisation sous le nom d'[Omakube](https://omakube.org/).

Après avoir suivi quelques **tech-tubeurs** comme [typecraft](https://www.youtube.com/@typecraft_dev), [Theprimeagon](https://www.youtube.com/@ThePrimeTimeagen) utilisant des environnements de bureau comme [Hyprland](https://hypr.land/), il décida de refaire une version plus aboutie qu'Omakube et la nomma [Omarchy](https://omarchy.org/), cette fois-ci sous [Arch Linux](https://archlinux.org) _une distribution plus légère_ avec presque aucun paquet additionnel ou environnement de bureau préinstallé, ce qui permet de tout configurer à sa guise.

### Prérequis

Pour installer [Omarchy](https://omarchy.org) sur un MacBook Pro mid-2015, vous aurez besoin des éléments suivants :

- Une clé USB >= 4 Go pour créer un support d'installation bootable.

- Un ordinateur avec un processeur x86. Dans cet article, j'utilise mon vieux MacBook Pro Intel i7 mid-2015 (mais d'autres versions plus anciennes peuvent fonctionner). Voir le wiki d'[Arch Linux](https://wiki.archlinux.org/title/Laptop/Apple) pour les autres MacBook compatibles.

- Une bonne connexion internet pour télécharger l'ISO d'[Omarchy](https://omarchy.org) qui a été publiée tout récemment.

> Lors de mon installation, l'ISO n'était pas encore disponible, j'avais utilisé l'ISO d'[Arch Linux](https://archlinux.org/download/) pour l'installation initiale avant de configurer Omarchy via le script d'installation.
{: .prompt-warning }

### Création d'une clé USB bootable

Pour flasher l'ISO sur votre USB et la rendre bootable, plusieurs choix s'offrent à vous :

- [Rufus](https://rufus.ie/) (Windows)
- [balenaEtcher](https://www.balena.io/etcher/) (Windows, macOS, Linux)
- ou [Ventoy](https://www.ventoy.net/en/index.html) que j'utilise personnellement, il permet de copier plusieurs ISO sur une même clé USB et de choisir au démarrage laquelle lancer.

### Démarrage sur la clé USB

Insérez la clé dans un port USB, puis redémarrez l'ordinateur en maintenant la touche `Alt` enfoncée jusqu'à ce que le gestionnaire de démarrage apparaisse et choisissez la clé USB pour démarrer à partir de celle-ci.

> Vous pouvez rencontrer un problème lié au secure boot. Pour le désactiver, redémarrez en maintenant `Cmd + R` pour accéder au mode recovery, puis allez dans Utilitaire de sécurité au démarrage et sélectionnez "Aucune sécurité" et "Autoriser le démarrage à partir de support externe".
{: .prompt-tip }

### Installation d'Omarchy

Choisissez l'ISO d'[Omarchy](https://omarchy.org/) qui est plus simple que celle d'[Arch Linux](https://archlinux.org/download/) où vous devez vous occuper de tout.

Sélectionnez ensuite la clé USB pour démarrer à partir de celle-ci :

- Arch Linux Install Medium (x86_64, UEFI)
- Remplissez les informations comme (langue, clavier, nom d'utilisateur, mot de passe, etc.)

> Si vous avez un adaptateur ethernet, branchez-le pour une connexion internet plus stable pendant l'installation, sinon le wifi fonctionne aussi mais vous devrez le configurer manuellement via la ligne de commande [iwctl](https://man.archlinux.org/man/extra/iwd/iwctl.1.en).
> Au fait, le wifi de mon Mac a fonctionné sans problème tout au long de l'installation.
> Omarchy vient avec un script qui installe beaucoup d'outils et il doit télécharger pendant l'installation (+2 Go). Actuellement, l'ISO n'est pas encore hors ligne comme des distributions comme Ubuntu ou Fedora.
{: .prompt-info }

Alors ça peut prendre un certain temps en fonction de votre connexion internet.

### Post-installation

Une fois l'installation terminée, redémarrez votre MacBook Pro et retirez la clé USB.
Vous devriez maintenant atterrir sur [Hyprland](https://hyprland.org/), un gestionnaire de fenêtres moderne et léger qui fait partie de l'ensemble de configurations d'Omarchy.

> Oui, il faut encore passer par la page d'authentification, comme tout OS qui se respecte.
{: .prompt-warning }

![omarch-login](./assets/img/omarch-login.webp)
_Écrivez votre mot de passe et appuyez sur Entrée_

### Bienvenue dans Omarchy !

[Omarchy](https://omarchy.org/) vous ouvre un univers jusque-là peu accessible sauf à ceux qui dédient leur vie à un terminal **_Joke_** 🤣

![welcom-page-omarch](./assets/img/omarchy-tokyo-theme.webp)
_Vous pouvez ouvrir un terminal en appuyant sur `Super + Enter` (la touche Super est généralement la touche Windows ou Commande sur Mac)._

### Problèmes rencontrés lors de mon utilisation

Après plus d'une semaine d'utilisation, j'ai rencontré trois problèmes majeurs avec Mac + Omarchy :

Lorsque j'ai fini mon installation, tous les périphériques à part la webcam fonctionnaient parfaitement : wifi, bluetooth, son, USB, etc.

1. La caméra ne fonctionnait pas, mais après quelques recherches, j'ai trouvé une solution en installant les drivers qui manquent via AUR (Arch User Repository).

```bash
# Note Omarchy installe yay par défaut
yay -S bcwc-pcie-dkms
yay -S facetimehd-firmware-git

# Charger le module
sudo modprobe facetimehd

# S'assurer que le module est chargé au démarrage
echo facetimehd | sudo tee /etc/modules-load.d/facetimehd.conf
```

2. Après un redémarrage, ma souris (Logitech MX Master 3s) et mon clavier (Logitech MX Keys) connectés via Bluetooth ont arrêté de fonctionner. J'ai dû les supprimer et les réappairer pour que ça remarche à nouveau. Le problème persiste car ils continuaient à se déconnecter de temps en temps.

Après quelques lectures sur des forums #ArchLinux sans succès (je suis certain que c'est un problème de driver), je laisse aller pour le moment et continue ma découverte du monde de l'Arch de Noé qui a ressuscité mon Mac 2015 redevenu mon ordi principal depuis.

J'ai repris mon vieux clavier mécanique [Keychron K10](https://www.keychron.com/products/keychron-k10-wireless-mechanical-keyboard) que j'avais acheté en 2022, qui contrairement au Logitech MX Keys permet la connexion filaire via USB et une souris Logitech sans fil mais avec connecteur USB qui fonctionne parfaitement.

> Le trackpad de mon Mac fonctionne parfaitement, mais j'ai une configuration avec deux ecrans externes et je n'utilise pas le clavier du mac qui reste fermé.
{: .prompt-info }

1. Pour une raison inconnue, le Mac n'arrive plus à se connecter au wifi principal (1.5 Go) de la maison qui utilise du wifi 6 je crois, mais se connecte sans problème à un autre wifi ainsi qu'au hotspot de mon téléphone.

Alors j'ai acheté sur [Amazon](https://www.amazon.ca/-/fr/dp/B00MYTSN18?ref=ppx_yo2ov_dt_b_fed_asin_title) un adaptateur USB vers Ethernet, ce qui me donne une connexion internet stable et plus rapide.
![wifi-interface](./assets/img/wifi-interface.webp)

### Qu'est-ce qui fait qu'Omarchy est le parfait environnement pour moi ?

Pour moi voici quelques avantages qui font que je bascule sur Omarchy sur mon vieux Mac :

1. Le projet est open-source (voir les scripts sur [GitHub](https://github.com/basecamp/omarchy)), maintenu par une compagnie [Basecamp](https://basecamp.com) et un individu qui a fait ses preuves avec Ruby-On-Rails **DHH**

2. Basé sur une distribution Linux très populaire pour entre autres le nombre de paquets disponibles (officiellement mais aussi sur l'Arch User Repository AUR publié par monsieur madame tout le monde dont **_attention_**) avec toujours la dernière version grâce au choix de rolling release.

3. Hyprland, cet environnement de bureau qui n'a rien à envier à mon avis à macOS ou Windows qui vous permet de le personnaliser vraiment à votre goût.

Attention, tout se fait via des fichiers de config et la courbe d'apprentissage est un peu haute, mais Omarchy nous permet de plonger dedans et qu'on prenne le temps de bien l'apprendre.

> J'avoue avoir été séduit par Hyprland depuis un moment, notamment avec NixOS qui propose une approche déclarative pour la gestion des paquets, mais qui reste assez complexe. Avec Omarchy, DHH a réussi à simplifier cette expérience de manière remarquable.
{: .prompt-info }

1. C'est un environnement axé sur l'utilisation du clavier en premier et très rarement la souris. Toutes les apps sont configurables via des bindings qui vous permettent en une combinaison d'avoir accès à tout.

### Voici une belle introduction à Omarchy 2.0 par DHH

{% include embed/youtube.html id='TcHY0AEd2Uw' %}
📺 [Regarder la vidéo de présentation de la 2.0 par DHH](https://www.youtube.com/watch?v=TcHY0AEd2Uw)

### Synchronisation de ma configuration personnelle sur ma nouvelle monture

J'utilise des fichiers de configuration communément appelés [dotfiles](https://github.com/mombe090/.files) dont voici la version [publique](https://github.com/mombe090/.files) pour synchroniser ma configuration sur l'ensemble des machines que j'utilise.

Maintenant que le vieux Mac redevient ma machine principale, j'ai synchronisé mes dotfiles pour retrouver mon environnement de travail habituel. Il vient avec une documentation complète pour vous aider à personnaliser votre environnement selon vos préférences et l'ajuster à votre guise.

### Conclusion

Parti d'un podcast que j'écoute souvent [Lex Fridman Podcast](https://www.youtube.com/watch?v=TcHY0AEd2Uw), j'ai découvert Omarchy et décidé de suivre un peu son évolution et l'installer sur mon vieux MacBook Pro mid-2015. Après avoir surmonté quelques défis liés au matériel et aux drivers, j'ai réussi à redonner vie à cette machine avec un système d'exploitation moderne et performant. Je suis maintenant enthousiaste à l'idée d'explorer davantage cet environnement et de continuer à personnaliser ma configuration pour une expérience utilisateur optimale.
