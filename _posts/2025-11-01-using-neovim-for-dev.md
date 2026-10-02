---
title: "Mon terminal, mon IDE : ma transition d'IntelliJ IDEA à Neovim avec LazyVim"
description: "Après des années passées sur les IDE de JetBrains, principalement IntelliJ IDEA, et quelques aventures dans VSCode, j'ai décidé de me tourner vers le terminal avec Neovim."
categories: [development, productivity]
tags: [neovim, lazyvim, ide, vim, developer-tools, copilot, ai, zellij, opencode]
author: "mombe090"
image:
  path: /assets/img/header/coding-inside-terminal-neovim.webp
alternate_url: /en/posts/using-neovim-for-dev/
---

## Contexte

Pendant plus d'une dizaine d'années, [IntelliJ IDEA](https://www.jetbrains.com/idea/) a été mon compagnon de route quotidien pour mes activités de développement et de sysadmin.

Que ce soit pour du `Java` (mon langage de prédilection), `Kotlin`, `Python`, `Terraform`, ou toutes sortes de langages de configuration (`YAML`, `JSON`, `TOML`, `HCL`, `KCL`, etc.), l'IDE de `JetBrains` m'a toujours offert une expérience utilisateur exceptionnelle : intellisense performant, indexation robuste, refactorings puissants, et un écosystème de plugins officiels et communautaires très riche.

Pendant tout ce temps, j'ai aussi eu l'occasion de tester d'autres éditeurs comme `Sublime Text`, `Atom` et, ces dernières années, [Visual Studio Code](https://code.visualstudio.com/), un excellent éditeur (surtout gratuit). Cependant, rien ne m'égalait l'expérience complète d'un IDE comme IntelliJ, auquel j'avais développé une excellente maîtrise.

Mais voilà, IntelliJ est un gros IDE propriétaire, développé par une entreprise à but lucratif (`JetBrains`), avec un coût de licence élevé. Voici les quelques raisons qui m'ont poussé à essayer `Neovim` :

- **J'adore le terminal** : je passe la plupart de mon temps dans des terminaux `bash` ou `zsh` sur mes machines locales ou distantes.

- **Performance** : la consommation de ressources peut être excessive (RAM et CPU). Lors du développement en `Java` ou `Terraform` (HCL) avec de nombreux modules, l'IDE devient très lent.

- **Coût** : même si IntelliJ Community est gratuit, certains plugins et fonctionnalités avancées nécessitent la version Ultimate.

- **Productivité** : j'ai récemment testé [Omarchy](https://mombe090.github.io/posts/old-mac-mid-2015-back-to-life-with-arch/), une distribution Linux basée sur Arch, très orientée clavier. J'aime ce concept : moins de dépendance à la souris.

- **Intégration avec l'IA** : l'émergence d'outils IA pour l'autocomplétion et le coding agentic (GitHub Copilot, ClaudeCode, Google Gemini, OpenCode, etc.) qui privilégient une approche basée sur le terminal.

- **Flexibilité et portabilité** : configuration basée sur des fichiers texte versionnnés avec Git. Consultez mes [dotfiles publics](https://github.com/mombe090/.files/tree/initial/nvim/.config/nvim).

## Objectif

Dans cet article, je vais partager mon expérience de transition d'`IntelliJ IDEA` vers `Neovim avec LazyVim`. Je vais vous expliquer :

- Ce qu'est Neovim et LazyVim
- Ma motivation pour ce changement
- Comment installer et configurer LazyVim
- L'intégration de l'IA avec GitHub Copilot et OpenCode
- Les défis rencontrés et comment je les ai surmontés
- Mon avis après plusieurs mois d'utilisation

## C'est quoi Neovim ?

[Neovim](https://neovim.io/) est un fork moderne de [Vim](https://www.vim.org/), l'éditeur de texte légendaire des années 90, toujours très populaire parmi les sysadmins.

Lancé en 2014, Neovim modernise Vim en :

- Améliorant son architecture interne
- Ajoutant le support natif du protocole LSP (Language Server Protocol)
- Permettant une configuration en `Lua` (plus moderne que VimScript, avec lequel Vim est configuré historiquement)
- Offrant une meilleure extensibilité via des milliers de plugins
- Supportant une interface utilisateur asynchrone

> Neovim préserve l'efficacité et la philosophie de Vim tout en apportant les améliorations substantielles nécessaires pour le développement moderne, notamment l'intégration du Language Server Protocol et des outils d'IA.
> {: .prompt-info }

## C'est quoi LazyVim ?

[LazyVim](https://www.lazyvim.org/) est une distribution Neovim préconfigurée, créée par [folke](https://github.com/folke), une légende vivante de Vim et auteur de plusieurs plugins populaires très actifs dans la communauté Neovim.

### Pourquoi utiliser LazyVim plutôt que de configurer Neovim soi-même ?

- **Configuration initiale complexe** : bien que Neovim soit très flexible, configurer tous les plugins nécessaires pour en faire un IDE complet peut prendre des heures, voire des jours. Ce n'est pas très accessible aux débutants.

- **Version prête à l'emploi** : LazyVim offre une configuration prête à l'emploi qui transforme Neovim en IDE moderne en quelques minutes.

- **Configuration par défaut fonctionnelle** : vous pouvez commencer à développer immédiatement au lieu de passer du temps à configurer.

- **Plugins soigneusement sélectionnés** : offrant une expérience fluide et productive.

- **Gestionnaire de plugins moderne** : [lazy.nvim](https://github.com/folke/lazy.nvim) charge les plugins à la demande (lazy loading), contrairement à IntelliJ qui charge tout au démarrage.

- **Keymaps intuitifs** : raccourcis clavier cohérents et logiques.

- **Support de plusieurs langages** : installation de serveurs LSP via le plugin [mason.nvim](https://github.com/williamboman/mason.nvim).

- **Interface moderne** : icônes, thèmes élégants et statusline via [Nerd Fonts](https://www.nerdfonts.com/).

> LazyVim transforme Neovim en IDE moderne en quelques minutes, sans des heures de configuration.
> {: .prompt-tip }

## Pourquoi j'ai fait ce choix ?

### 1. Maîtrise de quelques motions Vim et aisance dans le terminal

- En tant que sysadmin et développeur, je passe déjà beaucoup de temps en SSH sur des serveurs distants.
- Bien que ma maîtrise de Vim soit basique au départ, j'ai voulu l'approfondir pour être plus efficace.
- Les commandes modales de Neovim sont identiques à Vim, donc apprendre l'un améliore les compétences avec l'autre.

> **Note** : La courbe d'apprentissage de Vim est raide initialement, mais une fois maîtrisée, elle offre une efficacité inégalée.
> {: .prompt-warning }

### 2. Performance et légèreté

- Démarrage en quelques millisecondes (vs plusieurs secondes pour IntelliJ)
- Consommation RAM minimale (~50-100 MB vs 8-16 GB pour IntelliJ)
- Idéal pour les machines avec ressources limitées

### 3. Efficacité au clavier

- Mouvements modaux reconnus comme les plus efficaces une fois maîtrisés
- Réduction drastique de l'utilisation de la souris
- Productivité accrue après avoir passé la courbe d'apprentissage
- Lire cet excellent article : [Hacker News sur les modes de vim](https://news.ycombinator.com/item?id=43780682)

### 4. Flexibilité et portabilité

- Configuration en fichiers texte facilement versionnables avec Git (voir mes [dotfiles publics](https://github.com/mombe090/.files))
- Même environnement sur toutes les machines (laptop, serveurs distants, VMs, etc.)
- Fonctionne parfaitement en SSH sur des serveurs distants

### 5. Communauté et écosystème

- Communauté très active et passionnée
- Des milliers de plugins disponibles
- Documentation exhaustive et nombreuses ressources d'apprentissage
- **Attention** : éviter le "plugin hell" en sélectionnant vos plugins avec soin !

### 6. Gratuit, open source et ressources d'apprentissage abondantes

- 100% gratuit avec toutes les fonctionnalités
- Code source ouvert et transparent
- Nombreux tutoriels, vidéos et articles. Voici quelques ressources utiles :

**YouTube** :

- [TypeCraft](https://www.youtube.com/watch?v=zHTeCSVAFNY&list=PLsz00TDipIffreIaUNk64KxTIkQaGguqn) : excellente série sur Neovim sans distribution
- [Josean Martinez](https://www.youtube.com/@joseanmartinez) : excellent créateur de contenu sur Neovim et LazyVim
- [DevopsToolbox](https://www.youtube.com/playlist?list=PLmcTCfaoOo_grgVqU7UbOx7_RG9kXPgEr) : playlist complète sur Neovim, LazyVim et productivité
- [ThePrimeagen](https://www.youtube.com/@ThePrimeagen) : amoureux de Vim/Neovim avec vidéos instructives (style un peu agressif)
- [TJ DeVries](https://www.youtube.com/watch?v=m8C0Cq9Uv9o) : co-mainteneur de Neovim, excellents tutoriels et [Nvim Kickstart](https://github.com/nvim-lua/kickstart.nvim)

**Articles et ressources** :

- [Documentation officielle de LazyVim](https://www.lazyvim.org/) : point de départ idéal
- [Apprendre Vim en Y minutes](https://learnxinyminutes.com/fr/vim/) : guide rapide des bases

## Installation de LazyVim

L'installation de LazyVim est remarquablement simple. Voici les étapes que j'ai suivies :

### Prérequis

Avant d'installer LazyVim, assurez-vous d'avoir :

- Neovim >= 0.9.0 (je recommande la dernière version stable)
- Git >= 2.19.0
- Une police d'écriture [Nerd Font](https://www.nerdfonts.com/) pour les icônes dans le terminal (j'utilise `Cascadia Code Nerd Font`)
- Un terminal moderne avec support des couleurs 24-bit (j'utilise [Alacritty](https://alacritty.org/))

- Pour plus de détails sur l'installation, consultez la [doc officielle](https://www.lazyvim.org/#%EF%B8%8F-requirements).

> Le premier démarrage peut prendre quelques minutes selon votre connexion internet. Les lancements suivants seront quasi-instantanés ! Assurez-vous d'avoir installé tous les prérequis avant de commencer, sinon l'installation peut échouer.
> {: .prompt-warning }

## Configuration de base

LazyVim est déjà très bien configuré par défaut. J'ai personnalisé quelques aspects selon mes besoins. Consultez ma configuration dans mes [dotfiles](https://github.com/mombe090/.files/tree/initial/nvim/.config/nvim).

## Intégration de l'IA avec GitHub Copilot et OpenCode

L'un des grands avantages de Neovim est sa capacité à intégrer les outils d'IA modernes pour l'autocomplétion et le coding agentic.

> Depuis la sortie de `ClaudeCode`, la tendance est au passage d'agents IA s'exécutant dans le terminal plutôt que simples autocomplétions. Tous les acteurs majeurs proposent des solutions : `Google Gemini`, `Anthropic ClaudeCode`, `OpenAI`, `Microsoft Copilot CLI`, etc.
> {: .prompt-tip }

### GitHub Copilot

[GitHub Copilot](https://github.com/features/copilot) fonctionne parfaitement avec LazyVim via le plugin [copilot.lua](https://github.com/zbirenbaum/copilot.lua) et supporte aussi d'autres fournisseurs comme `Claude` (voir [extras IA de LazyVim](https://www.lazyvim.org/extras/ai/claudecode)).

> La licence GitHub Copilot offre un modèle de tarification flexible et transparent : **à partir de 10 $ par mois ou 100 $ par an**, vous accédez aux meilleurs modèles du marché (Claude Sonnet 4.5, GPT-5, Gemini 2.5 Pro, etc.).
>
> Ce qui rend Copilot compétitif : **vous ne payez que pour ce que vous utilisez**. Les modèles premium s'ajoutent optionnellement selon vos besoins. Consultez la [page officielle de tarification](https://github.com/features/copilot/plans).
> {: .prompt-info }

C'est actuellement le meilleur rapport **qualité/prix du marché** pour l'autocomplétion et le mode agent.

#### Installation de GitHub Copilot

Suivez la [documentation LazyVim](https://www.lazyvim.org/extras/ai/copilot).

#### Première utilisation

Au premier lancement après installation :

```bash
# Lancer Neovim
nvim

# Dans Neovim, exécuter
:Copilot auth
```

![copilot-auth](/assets/img/content/neovim-copilot-auth.png)
_Une fenêtre navigateur s'ouvrira pour vous connecter à GitHub et autoriser Copilot._

Après authentification, redémarrez Neovim. Vous pouvez spécifier les langages prioritaires pour optimiser les suggestions (voir ma [configuration personnelle](https://github.com/mombe090/.files/blob/initial/nvim/.config/nvim/lua/plugins/copilot.lua#L18)).

### OpenCode

[OpenCode](https://opencode.ai) est un outil de coding agentic open source et gratuit, inspiré de [ClaudeCode](https://claudecode.ai/).

Contrairement à Copilot (autocomplétion), OpenCode est un agent IA capable de :

- Lire et comprendre votre codebase complète
- Effectuer des modifications multi-fichiers
- Exécuter des commandes dans le terminal
- Déboguer et corriger des erreurs
- Créer des pull requests
- Et bien plus !

#### Installation d'OpenCode

```bash
# Via npm
npm install -g opencode-ai

# Ou via curl (Linux/macOS)
curl -fsSL https://opencode.ai/install.sh | sh
```

#### Choix du provider IA

````shell
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

Suivez le processus d'authentification selon le provider.

#### Configuration avec Neovim

OpenCode fonctionne avec Neovim au niveau terminal (voir [opencode.nvim](https://github.com/NickvanDyke/opencode.nvim)). [DevopsToolbox](https://www.youtube.com/watch?v=EJ1k2bX4o0A) a aussi fait une excellente vidéo sur le sujet.

Personnellement, je préfère l'utiliser dans un terminal séparé avec [Zellij](https://zellij.dev/), un multiplexeur moderne et agréable.

**Workflow typique** :

1. **Zellij** : multiplexeur de terminal
2. **Neovim** : dans un tab Zellij par projet
3. **OpenCode** : dans un autre tab Zellij

```bash
# Lancer Zellij
zellij

# Nouveau tab pour Neovim (ctrl+t n)
# Renommer le tab (ctrl+t r)
nvim .

# Nouveau tab pour OpenCode
opencode

# Exemples de commandes
> /init # Initialiser OpenCode avec un fichier AGENTS.md contenant les instructions
> Génère moi une documentation complète en MkDocs style Diataxis
````

![open-code-init](/assets/img/content/neovim-opencode-init.png)

#### Intégration Zellij + Neovim + OpenCode

Avec un multiplexeur comme Zellij, vous pouvez basculer entre Neovim et OpenCode sans perdre le contexte du projet, ce qui se rapproche d'un IDE complet.

> Verrouillez votre session Zellij avec `Ctrl+G` pour éviter les conflits avec les raccourcis de LazyVim.
> **Avantages de Zellij** :

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

**Workflow idéal** :

1. 🔵 **Neovim** : édition manuelle et navigation
2. 🟢 **GitHub Copilot** : autocomplétion en temps réel
3. 🟣 **OpenCode** : modifications complexes, refactoring, tests

> Cette combinaison me rend très productif : code critique écrit manuellement avec l'aide de Copilot, tâches répétitives/complexes déléguées à OpenCode.
> {: .prompt-tip }

## Les défis rencontrés

La transition n'a pas été sans difficulté. Voici les principaux :

### 1. La courbe d'apprentissage est très haute

**C'est le défi principal.** Les mouvements modaux et les combinaisons de touches de Vim sont très différents de ceux d'IntelliJ.

- `hjkl` pour se déplacer au lieu des flèches
- Les modes Normal, Insert, Visual
- Les commandes comme `ciw` (change inner word), `dap` (delete a paragraph), etc.
- Les buffers, tabs, splits, etc.

> Pour résumer, tout est différent et on se sent un peu perdu au début mais avec de la pratique, on finit par maîtriser ces mouvements qui deviennent très naturels.
> Après quelques semaines, j'ai constaté une amélioration significative de ma vitesse de navigation dans le code.
> Mais je garde toujours un cheat sheet à portée de main pour les commandes moins fréquentes.
> {: .prompt-info }

### 2. Trouver les équivalents de certaines fonctionnalités IntelliJ

IntelliJ possède des fonctionnalités extraordinaires (refactoring avancé, débogueur visuel, bases de données intégrées, etc.).

Je garde donc IntelliJ et VSCode pour certaines tâches spécifiques où je reste plus productif avec ces IDEs.

## Mon avis après plusieurs mois

Après plus de 2 mois d'utilisation intensive :

### Ce que j'adore ✅

- **Vitesse** : démarrage et réactivité incomparables
- **Efficacité** : mains toujours sur le clavier, code beaucoup plus vite
- **Légèreté** : 10 instances de Neovim vs RAM d'une seule IntelliJ
- **Portabilité** : même configuration partout
- **Customisation** : contrôle total, comprends chaque aspect
- **Satisfaction** : profondément satisfaisant à maîtriser
- **IA intégrée** : GitHub Copilot et OpenCode fonctionnent parfaitement

### Ce qui me manque ❌

- **Débogueur visuel** : nvim-dap existe mais moins intuitif qu'IntelliJ
- **Refactoring complexe** : certains refactorings IntelliJ n'ont pas d'équivalent parfait
- **Intégration base de données** : nécessite des outils externes pour SQL
- **Git avancé** : Lazygit est puissant mais moins fluide qu'IntelliJ

### Est-ce que je recommande ?

**OUI, mais** avec quelques nuances :

- **Développeur full-stack/DevOps/SRE** : foncez ! Neovim est parfait
- **Travail principalement Java/C# avec frameworks lourds** : IntelliJ/Visual Studio reste plus adapté
- **Débutant en programmation** : commencez par VSCode, puis explorez Neovim

> **Approche actuelle** : Neovim pour 80% du travail (web, scripts, DevOps, config). IntelliJ pour tâches spécifiques. Zellij comme multiplexeur unificateur.
> {: .prompt-info }

## Ressources utiles

- [Documentation officielle de LazyVim](https://www.lazyvim.org/)
- [Documentation Neovim](https://neovim.io/doc/)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [copilot.lua Plugin](https://github.com/zbirenbaum/copilot.lua)
- [OpenCode Documentation](https://opencode.ai/docs)
- [Zellij Documentation](https://zellij.dev/)
- [Mon article sur Ollama + Continue](https://mombe090.github.io/posts/ollama-continue-free-copilot/)

## Conclusion

Le passage d'IntelliJ à Neovim avec LazyVim est un grand changement, mais c'était le bon choix pour moi.

Certes, la courbe d'apprentissage est raide au début, mais l'investissement en vaut la peine. La vitesse, la légèreté et surtout le **contrôle total** de mon environnement m'ont convaincu.

Ajouter GitHub Copilot et OpenCode a complété ce setup pour en faire un environnement moderne, puissant et efficace.

Si vous êtes curieux et prêt à investir du temps dans l'apprentissage, je vous encourage vivement à essayer.

> "L'outil ne fait pas le développeur, mais un bon outil peut le rendre plus heureux et plus productif."
> {: .prompt-tip }

Et vous, avez-vous déjà essayé Neovim ? Partagez votre expérience en commentaires !
