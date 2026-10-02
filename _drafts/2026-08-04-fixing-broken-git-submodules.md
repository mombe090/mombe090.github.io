---
title: "Fixing Broken Git Submodules in CI/CD Pipelines"
description: "How I diagnosed and fixed a broken git submodule reference that was causing Cloudflare Pages builds to fail with 'error occurred while updating repository submodules'."
categories: [homelab, gitops, troubleshooting]
tags: [git, submodule, cloudflare, cicd, troubleshooting]
author: "mombe090"
published: false
---

## Le problème

Ce matin, mon build Cloudflare Pages a échoué avec ce message cryptique :

```
Failed: error occurred while updating repository submodules
```

Le problème ? Le repo contenait une référence de submodule cassée — un répertoire traqué en mode `160000` (submodule) dans l'index git, mais sans fichier `.gitmodules` pour dire à git d'où le cloner.

## Diagnostic

Pour vérifier si votre repo a des submodules cassés :

```bash
# Liste les submodules connus
git submodule status

# Cherche les entrées submodule dans l'index
git ls-files --stage | grep '^160000'

# Vérifie la présence de .gitmodules
cat .gitmodules
```

Dans mon cas, `.agents/skills/humanizer` était traqué comme submodule mais `.gitmodules` n'existait pas.

## La solution

### 1. Supprimer la référence du submodule

```bash
git rm --cached .agents/skills/humanizer
rm -rf .agents/skills/humanizer
git commit -m "fix: remove broken submodule .agents/skills/humanizer"
```

### 2. Nettoyer l'historique git (optionnel mais recommandé)

Si le submodule a été commité dans l'historique, il faut le retirer de tous les commits passés pour éviter que les clones initiaux ne traquent encore la référence :

```bash
# Installer git-filter-repo
pip install git-filter-repo

# Supprimer le submodule de tout l'historique
/Users/mombe090/.local/share/mise/installs/python/3.14.6/bin/git-filter-repo \
  --path .agents/skills/humanizer --invert-paths --force
```

⚠️ **Attention** : `git-filter-repo` réécrit l'historique et supprime les remotes par sécurité. Il faudra les ré-ajouter et force-push.

### 3. Ré-ajouter le remote et pousser

```bash
git remote add origin <url>
git push origin main --force-with-lease
```

## Résultat

Après le force-push, le clone Cloudflare Pages a fonctionné sans erreur de submodule. Le build est repassé au vert.

## Leçon apprise

- Ne jamais laisser un submodule sans `.gitmodules`
- Vérifier `git ls-files --stage | grep '^160000'` après toute manipulation de submodule
- `git-filter-repo` est plus rapide et sûr que `git filter-branch` pour nettoyer l'historique

---

*Draft en cours — retour d'expérience d'un vrai incident de production homelab.*
