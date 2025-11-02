---
title: "Mon terminal, mon IDE : Utiliser Neovim avec LazyVim"
description: "Après des années passées sur les IDE de jetbrains principalement IntelliJ IDEA, quelques aventures dans VSCODE, j'ai decide de me tourner vers le terminal avec Neovim."
categories: [development, productivity]
tags:
  [neovim, lazyvim, ide, vim, developer-tools, copilot, ai, zellij, opencode]
author): "mombe090"
image:
  path: /assets/img/header/neovim-lazyvim.webp
---

## Contexte :

Pendant plus d'une dizaines d'années, [IntelliJ IDEA](https://www.jetbrains.com/idea/) a été mon compagnon de route quotidien pour mes activitivite de development et de sysadmin.

Que ce soit pour du `Java` mon langage de prédilection, `Kotlin`, `Python`, `terraform`, ou toute sortes de langages de configuration
`yaml`, `json`, `toml`, `hcl`, `kcl` etc, l'IDE de `JetBrains` m'a toujours offert une expérience de utilisateur exceptionnelle avec son intellisense, ses indexations et refactorings puissants mais aussi le nombre de pluggins officiels et communautaires disponibles pour étendre ses fonctionnalités.

Alors pendant tout ce temps, j'ai eu la chance aussi de m'essayer à d'autres éditeurs tel que `sublime text`, `atom` et dans les dernière années [Visual Studio Code](https://code.visualstudio.com/) qui est un excellent éditeur de texte (surtout grattuit), mais pour moi, rien ne valait l'expérience complète d'un IDE comme IntelliJ avec lequel j'ai parfaitement développé des automatismes.

Mais voilà, IntelliJ est un gros IDE propriétaire développé par une firme à but lucrative `JetBrains` avec un coût de licence élevé, voici les quelques raisons qui m'ont pousser à m'essayer à `NeoVim` :

- J'adore le terminal, et je passe la plupart de mon temps dans des terminaux `bash` ou `zsh` sur mes machines locales ou distantes.

- La consommation de ressources parfois excessive (RAM et CPU), pour du développement avec les langages comme `Java` ou `terraform(hcl)` avec beaucoup de modules, l'IDE peut devenir très lent.

- Le coût de la licence (même si IntelliJ Community est gratuit, certains plugins et fonctionnalités avancées nécessitent la version Ultimate).

- J'ai récemment testé [omarchy](https://mombe090.github.io/posts/old-mac-mid-2015-back-to-life-with-arch//_posts/2025-08-26-old-mac-mid-2015-back-to-life-with-arch.md) une distribution Linux basée sur Arch qui est `keyboard centric` et j'aime ce concept. Moins de dépendance à la souris pour certaines opérations courantes.

- La montée en puissance des outils basés sur l'IA pour l'autocomplétion et le coding agentic (GitHub Copilot, ClaudeCode, Google Geminie, OpenCode, etc) qui pronnent une approche basée sur le terminal.

- La flexibilité et la portabilité d'une configuration basée sur des fichiers texte versionnés avec Git voir mes [dotfiles](https://github.com/mombe090/.files/tree/initial/nvim/.config/nvimhttps://github.com/mombe090/.files).

## Objectif :

Dans cet article, je vais partager mon expérience de transition d'`IntelliJ IDEA` vers `Neovim avec LazyVim`. <br />
Je vais vous expliquer :

- Ce qu'est Neovim et LazyVim
- Ma motivation pour ce changement
- Comment installer et configurer LazyVim
- L'intégration de l'IA avec GitHub Copilot et OpenCode
- Les défis rencontrés et comment je les ai surmontés
- Mon avis après plusieurs mois d'utilisation

## C'est quoi Neovim ?

[Neovim](https://neovim.io/) est un fork moderne de [Vim](https://www.vim.org/), l'éditeur de texte légendaire des années 90, qui encore aujourd'hui l'un des éditeurs les plus populaires parmi les sysadmins.

Lancé en 2014, Neovim a pour objectif de moderniser Vim en : <br />

- Améliorant son architecture interne
- Ajoutant le support d'un protocole LSP (Language Server Protocol) natif
- Permettant une configuration avec le langage `Lua` (plus moderne que VimScript avec lequel Vim est historiquement configuré)
- Offrant une meilleure extensibilité via des milliers de plugins
- Supportant une interface utilisateur asynchrone

> Neovim garde l'efficacité et la philosophie de Vim tout en apportant des améliorations substantielles pour le développement moderne et l'intégration des outils actuels tels que Language Server Protocol et les outils d'IA.
{: .prompt-info }

## C'est quoi LazyVim ?

[LazyVim](https://www.lazyvim.org/) est une distribution Neovim préconfigurée créée par la légende vivante de Vim [folke](https://github.com/folke), auteur de plusieurs plugins populaires et très actif dans la communauté `Neovim`.

### Pourquoi utiliser LazyVim plutôt que de configurer Neovim soi-même ?

- Bien que `Neovim` soit flexible et vous laisse configurer à votre guise, cela peut prendre des heures, voire des jours, pour installer et configurer tous les plugins nécessaires pour en faire un IDE complet et ce n'est pas très débutant-friendly.
- LazyVim résout ce problème en fournissant une configuration prête à l'emploi qui transforme Neovim en un IDE moderne en quelques minutes.
- LazyVim fournit une configuration par défaut qui fonctionne immédiatement, ce qui permet de se concentrer sur le développement plutôt que sur la configuration.
- Des choix de plugins soigneusement sélectionnés et configurés pour offrir une expérience de développement fluide et productive.
- Un gestionnaire de plugins moderne ([lazy.nvim](https://github.com/folke/lazy.nvim)) qui charge les plugins de manière (lazy loading) contrairement à IntelliJ qui charge tout au démarrage.
- Des raccourcis clavier (keymaps) intuitifs et cohérents
- Le support LSP pour plusieurs langages de programmation via le plugin [mason.nvim](https://github.com/williamboman/mason.nvim)
- Une interface moderne avec des icônes, des thèmes et une statusline élégante voir [nerd fonts](https://www.nerdfonts.com/)

> LazyVim permet de transformer Neovim en un IDE moderne en quelques minutes, sans passer des heures à configurer chaque plugin.
{: .prompt-tip }

## Pourquoi j'ai fait ce choix ?

Plusieurs raisons m'ont poussé à franchir le pas :

### 1. Habituer à travailler dans le terminal et utiliser Vim

- En tant que sysadmin et développeur, je passe déjà beaucoup de temps dans des terminaux SSH sur des serveurs distants.
- Bien que ma maîtrise de Vim soit basique (quelques motions utilent), je voulais approfondir mes compétences en Vim pour être plus efficace dans le terminal.
- Neovim utilise les mêmes commandes modales que Vim, donc apprendre Neovim améliore aussi mes compétences Vim.

> Note : La courbe d'apprentissage de Vim est raide au début, mais une fois maîtrisée, elle offre une efficacité inégalée.
{: .prompt-warning }

### 2. Performance et légèreté


- Neovim (LazyVim) démarre en quelques millisecondes contre plusieurs secondes pour IntelliJ
- Consommation de RAM minimale (~50-100 MB contre 8-16 GB pour IntelliJ)
- Idéal pour travailler sur des machines avec des ressources limitées ou dans le terminal

### 3. Efficacité au clavier

- Les mouvements modaux de Vim sont reconnus comme les plus efficaces une fois maîtrisés
- Réduction drastique de l'utilisation de la souris
- Productivité accrue après avoir passé la courbe d'apprentissage
- Lire cet excellent article : [Hacker News sur les modes de vim](https://news.ycombinator.com/item?id=43780682)

### 3. Flexibilité et portabilité

- Configuration en fichiers texte facilement versionnable avec Git, voir mes [dotfiles](https://github.com/mombe090/.files) publiques sur github.
- Même environnement sur toutes les machines (laptop, serveurs distants, vm ...)
- Fonctionne parfaitement en SSH sur des serveurs distants, par exemple sur mes vm proxmox, j'ai la même configuration que sur mon laptop.

### 4. Communauté et écosystème

- Communauté très active et passionnée
- Des milliers de plugins disponibles
- Documentation exhaustive et de nombreuses ressources d'apprentissage
- Attention cependant a ne pas tomber dans le "plugin hell", choisissez vos plugins avec soin !

### 5. Gratuit, open source et beaucoup de ressources disponibles pour l'apprentissage

- 100% gratuit avec toutes les fonctionnalités
- Code source ouvert et transparent
- Abondance de tutoriels, vidéos et articles de blog, voici quelques ressources que j'ai trouvées utiles dans mon apprentissage :
- Youtube :
  - [TypeCraft](https://www.youtube.com/watch?v=zHTeCSVAFNY&list=PLsz00TDipIffreIaUNk64KxTIkQaGguqn) : une belle série de vidéos sur Neovim sans aucune distribution dabord.
  - [Josean Martinez](https://www.youtube.com/watch?v=6pAG3BHurdMhttps://www.youtube.com/@joseanmartinez): un excellent créateur de contenu sur Neovim et LazyVim.
  - [DevopsToolbox](https://www.youtube.com/watch?v=dN0BmTgTOWk&list=PLmcTCfaoOo_grgVqU7UbOx7_RG9kXPgErhttps://www.youtube.com/@DevopsTools) : une playlist complète sur Neovim, LazyVim et la productivité.
  - [ThePrimeagen](https://www.youtube.com/@ThePrimeagen) : un amoureux de Vim/Neovim avec des vidéos très instructives, mais attention, son style peut être un peu agressif pour les débutants.
  - [TJ DeVries](https://www.youtube.com/watch?v=m8C0Cq9Uv9o) : co-mainteneur de Neovim avec d'excellents tutoriels, il maintient aussi des distributions pour débuter avec Neovim [Nvim Kickstart](https://github.com/nvim-lua/kickstart.nvim)
- Articles de blog et autres ressources :
  - [La documentation de lazyVim](https://www.lazyvim.org/neovim-from-scratchhttps://www.lazyvim.org/) : Le point de départ officiel pour apprendre LazyVim, très bien documenté.
  - [Apprendre x en y minutes](https://learnxinyminutes.com/fr/vim/) : Un guide rapide pour apprendre les bases de Vim.

## Installation de LazyVim

L'installation de LazyVim est remarquablement simple. Voici les étapes que j'ai suivies :

### Prérequis

Avant d'installer LazyVim, assurez-vous d'avoir :

- Neovim >= 0.9.0 (je recommande la dernière version stable)
- Git >= 2.19.0
- Une police d'écriture [Nerd Font](https://www.nerdfonts.com/) pour les icônes dans le terminal (j'utilise `Cascadia Code Nerd Font`)
- Un terminal moderne avec support des couleurs 24-bit (j'utilise [Alacritty](https://alacritty.org/))

- Pour plus de détails sur l'installatation, consultez la [la doc officielle](https://www.lazyvim.org/#%EF%B8%8F-requirements).

> Le premier démarrage peut prendre quelques minutes selon votre connexion internet. Les lancements suivants seront quasi-instantanés ! Assurez-vous d'avoir installé tous les prérequis avant de commencer, sinon l'installation peut échouer.
{: .prompt-warning }

## Configuration de base

LazyVim est déjà très bien configuré par défaut, mais j'ai personnalisé quelques aspects :

Voir ma configuration personnelle dans mes [dotfiles](https://github.com/mombe090/.files/tree/initial/nvim/.config/nvim).

## Intégration de l'IA avec GitHub Copilot et OpenCode

L'un des grands avantages de `Neovim`, c'est sa capacité à intégrer les outils d'IA les plus récents pour l'autocomplétion et le coding agentic.

Dans cette section, je vais vous montrer comment configurer GitHub Copilot pour l'autocomplétion et OpenCode pour le coding agentic.

> Depuis la sortie de `ClaudeCode`, la tendance est de passer à des agents IA qui s'exécutent dans le terminal, plutôt que des simples autocomplétions dans l'éditeur.
> Tous les acteurs majeurs ont désormais des solutions dans ce sens : `Google Gemini`, `Anthropic ClaudeCode`, `OpenAI Codex`, `Microsoft Copilot cli`, etc.
{: .prompt-tip }

### GitHub Copilot

[GitHub Copilot](https://github.com/features/copilot) fonctionne parfaitement avec LazyVim via le plugin [copilot.lua](https://www.lazyvim.org/extras/ai/copilothttps://github.com/zbirenbaum/copilot.lua) mais supporte aussi d'autres fournisseurs comme `Claude` voir extras [AI dans LazyVim](https://www.lazyvim.org/extras/ai/claudecode).

> La licence GitHub Copilot offre un modèle de tarification flexible et transparent : vous commencez à partir de **10 $ par mois ou 100 $ par an** pour accéder aux meilleurs modèles disponibles sur le marché (Claude Sonnet 4.5, GPT-5, Gemini 2.5 Pro, etc.).
> Ce qui rend Copilot particulièrement intéressant, c'est que **vous ne payez que pour ce que vous utilisez**. Si vous optez pour des modèles premium plus puissants, le coût s'ajuste en conséquence, mais vous gardez le contrôle total de votre budget. Pour connaître les détails précis de la tarification en fonction de vos besoins, consultez la [page officielle de tarification de GitHub Copilot](https://github.com/features/copilot/plans).
{: .prompt-info }

C'est actuellement le rapport **qualité/prix le plus compétitif du marché** pour une autocomplétion et le mode agent.

#### Installation de GitHub Copilot

Suivre la documentation officielle de LazyVim [copilot.lua](https://www.lazyvim.org/extras/ai/copilot).

#### Première utilisation

Au premier lancement de Neovim après l'installation, vous devrez vous authentifier :

```bash
# Lancer Neovim
nvim

# Dans Neovim, exécuter la commande
:Copilot auth
```

![copilot-auth](/assets/img/content/neovim-copilot-auth.png)
_Une fenêtre de navigateur s'ouvrira pour vous connecter à votre compte GitHub et autoriser Copilot._

Une fois authentifié, redémarrez Neovim et commencez à coder, vous pouvez aussi specifier les langages que vous utilisez le plus souvent pour optimiser les suggestions, voir ma config personnelle dans mes [dotfiles](https://github.com/mombe090/.files/blob/initial/nvim/.config/nvim/lua/plugins/copilot.lua#L18)

### OpenCode

[OpenCode](https://opencode.ai) est un outil de coding agentic qui fonctionne directement dans le terminal fortement inspiré de [ClaudeCode](https://claudecode.ai/) mais open source et gratuit.

Contrairement à Copilot qui fait de l'autocomplétion, OpenCode est un agent IA capable de : 

- Lire et comprendre votre codebase complète
- Effectuer des modifications multi-fichiers
- Exécuter des commandes dans le terminal
- Déboguer et corriger des erreurs
- Créer des pull requests
- Et bien plus encore !

#### Installation d'OpenCode

OpenCode s'installe très simplement :

```bash
# Installation via npm
npm install -g opencode-ai

# Ou via curl (Linux/macOS)
curl -fsSL https://opencode.ai/install.sh | sh
```
#### Choix du provider IA

```shell
➡ opencode auth login

┌  Add credential
│
◆  Select provider

│  Search:
│  ○ OpenCode Zen
│  ○ Anthropic
│  ● GitHub Copilot
│  ○ OpenAI
│  ○ Google
│  ○ OpenRouter
│  ○ Vercel AI Gateway
│  ...
│  ↑/↓ to select • Enter: confirm • Type: to search

# Continuer le processus d'authentification selon le provider choisi
```

#### Configuration avec Neovim

OpenCode fonctionne parfaitement avec Neovim puisqu'il opère au niveau du terminal, voir le pluggins [opencode.nvim](https://github.com/NickvanDyke/opencode.nvim), [DevopsToolbox](https://www.youtube.com/watch?v=EJ1k2bX4o0A) a aussi fait une vidéo très complète sur l'intégration d'OpenCode avec Neovim et LazyVim.

Mais je préfère l'utiliser dans un terminal à côté de Neovim avec [Zellij](https://zellij.dev/) un multiplexeur de terminal moderne et très agréable à utiliser.

Voici mon workflow typique :

**1. zellij** : Multiplexeur de terminal
**2. Neovim** : dans un tab zellij pour chaque projet sur lequel je travaille
**3. OpenCode** : dans un autre tab zellij pour les tâches agentic

```bash
# Dans le terminal OpenCode
cd /mon/projet
zellij 
ctrl+t n # Nouveau tab pour Neovim
ctrl+t r # Renommer le tab avec le nom du projet
nvim .

ctrl+t n # Nouveau tab pour OpenCode
ctrl+t r # Renommer le tab en "OpenCode"

# Lancer OpenCode
opencode

# Exemples de commandes
> /init # Pour initialiser OpenCode dans le projet courant avec la creation d'un fichier AGENTS.md qui vas contenir les instructions pour l'agent, vous pouvez le customiser.
> Genere moi une documentation complète pour ce projet en utilisant mkdocs avec le style diataxis
```

![open-code-init](/assets/img/content/neovim-opencode-init.png)

#### Intégration Zellij + Neovim + OpenCode

En utilisant un multiplexeur de terminal comme Zellij, je peux facilement basculer entre Neovim et OpenCode sans quitter le contexte de mon projet et se rapprocher d'un IDE complet.

> Vous pouvez locker votre session Zellij pour éviter les conflits avec les combinaisons de touches de `LazyVim` avec `ctrl + g` et la délocker avec `ctrl + g`.
{: .prompt-tip }

**Avantages de Zellij pour ce workflow** :

- **Sessions persistantes** : Vos sessions survivent aux déconnexions SSH
- **Interface moderne** : Plus jolie que tmux out-of-the-box et beaucoup plus conviviale pour les débutants
- **Plugins** : Système de plugins extensible
- **Floating panes** : Pratique pour des commandes rapides sans quitter le contexte

### Ma recommandation

Après avoir testé les trois solutions, voici mon setup actuel :

**Pour l'autocomplétion quotidienne** :

- ✅ **GitHub Copilot** : Pour la qualité et la rapidité (je paye l'abonnement)
- Alternative : **Continue + DeepSeek Coder V2** en local (gratuit, très bon aussi, mais un peu plus lent surtout pour un hardware modeste)

**Pour les tâches complexes et le refactoring** :

- ✅ **OpenCode** : Indispensable pour les modifications multi-fichiers et les tâches complexes

**Mon workflow idéal** :

1. 🔵 **Neovim** : Édition de code manuelle et navigation
2. 🟢 **GitHub Copilot** : Autocomplétion en temps réel pendant que je code
3. 🟣 **OpenCode** : Modifications complexes, refactoring, tests automatiques

> Cette combinaison me permet d'être extrêmement productif : j'écris le code critique manuellement dans Neovim avec l'aide de Copilot, et je délègue les tâches répétitives ou complexes à OpenCode.
{: .prompt-tip }

## Les défis rencontrés

La transition n'a pas été sans embûches. Voici les principaux défis que j'ai rencontrés :

### 1. La courbe d'apprentissage est très haute

C'est `LE défi principal`. Les mouvements modaux de Vim ainsi que les nombreuses combinaitons de touches sont très différents des raccourcis habituels dans IntelliJ.

- `hjkl` pour se déplacer au lieu des flèches
- Les modes Normal, Insert, Visual
- Les commandes comme `ciw` (change inner word), `dap` (delete a paragraph), etc.
- Les buffers, tabs, splits, etc.

> Pour résumer, tout est différent et on se sent un peu perdu au début mais avec de la pratique, on finit par maîtriser ces mouvements qui deviennent très naturels.
> Après quelques semaines, j'ai constaté une amélioration significative de ma vitesse de navigation dans le code.
> Mais je garde toujours un cheat sheet à portée de main pour les commandes moins fréquentes.
{: .prompt-info }

### 2. Trouver l'équivalent de certaines fonctionnalités IntelliJ

IntelliJ a des fonctionnalités extraordinaires (refactoring, debugging visuel, bases de données intégrées, etc.).

C'est pour cette raison que je garde encore `IntelliJ` et `VSCode` pour certaines tâches spécifiques où je me sens encore plus productif avec ces IDEs.

## Mon avis après plusieurs semaines

Après plus de 2 mois d'utilisation intensive, voici mon bilan :

### Ce que j'adore ✅

- **Vitesse** : Le démarrage instantané et la réactivité sont incomparables
- **Efficacité** : Mes mains ne quittent plus le clavier, je code beaucoup plus vite
- **Légèreté** : Je peux ouvrir 10 instances de Neovim avec une seule session Zellij avec la RAM consommée par une seule instance d'IntelliJ
- **Portabilité** : Même configuration partout (laptop, serveurs, conteneurs)
- **Customisation** : Je contrôle tout, je comprends chaque aspect de ma configuration
- **Satisfaction** : Il y a quelque chose de profondément satisfaisant à maîtriser cet outil
- **IA intégrée** : GitHub Copilot et OpenCode fonctionnent parfaitement avec Neovim

### Ce qui me manque ❌

- **Débogueur visuel** : nvim-dap est bien mais moins intuitif que celui d'IntelliJ
- **Refactoring complexe** : Certains refactorings complexes d'IntelliJ n'ont pas d'équivalent parfait
- **Intégration base de données** : Pour du SQL, je dois utiliser des outils externes
- **L'intégration Git avancée** : Bien que très puissante avec `Lazygit`, elle n'est pas aussi fluide qu'IntelliJ, mais je m'y fais petit à petit avec le temps.

### Est-ce que je recommande ?

**OUI, mais** avec quelques nuances :

- Si vous êtes **développeur full-stack** ou **DevOps/SRE** : Foncez ! Neovim est parfait pour vous
- Si vous travaillez principalement en **Java/c# avec des frameworks lourds** : IntelliJ/Visual Studio reste probablement plus adapté
- Si vous êtes **débutant en programmation** : Commencez peut-être par VSCode, puis explorez Neovim quand vous serez plus à l'aise

> Mon approche actuelle : J'utilise Neovim pour 80% de mes tâches (dev web, scripts, DevOps, configuration). Je garde IntelliJ pour des tâches très spécifiques nécessitant son débogueur ou ses refactorings avancés. Ou quand je travaille sur de gros projets Java Spring.
{: .prompt-info }

## Ressources utiles

Pour aller plus loin avec Neovim et LazyVim :

- [Documentation officielle de LazyVim](https://www.lazyvim.org/)
- [Neovim documentation](https://neovim.io/doc/)
- [Mon article sur Ollama + Continue](https://mombe090.github.io/posts/ollama-continue-free-copilot/)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [copilot.lua Plugin](https://github.com/zbirenbaum/copilot.lua)
- [OpenCode Documentation](https://opencode.ai/docs)
- [Zellij Documentation](https://zellij.dev/)

## Conclusion

Le passage d'IntelliJ à Neovim avec LazyVim est brutal mais a été un bon choix.

Certes, la courbe d'apprentissage est raide au début, mais l'investissement en vaut la peine. 
La vitesse, la légèreté, et surtout le **contrôle total** sur mon environnement de développement m'ont convaincu.

L'ajout de GitHub Copilot pour l'autocomplétion et d'OpenCode pour le coding agentic a complété ce setup pour en faire un environnement de développement moderne, puissant et efficace.

Si vous êtes curieux et prêt à investir du temps dans l'apprentissage, je vous encourage vivement à essayer.

> "L'outil ne fait pas le développeur, mais un bon outil peut faire un développeur plus heureux et plus productif."
{: .prompt-tip }

Et vous, avez-vous déjà essayé Neovim ? Partagez votre expérience dans les commentaires !
