# Les Chroniques du Versionneur / The Git Chronicles

> **🚧 En cours de construction** Le contenu des quêtes est globalement terminé, mais le site web, les traductions et les scripts de vérification sont encore en cours de finalisation. Les retours et contributions sont les bienvenus !

Un cours Git interactif et gamifié avec un récit heroic fantasy, bilingue (FR/EN).

An interactive, gamified Git course with a fantasy narrative, bilingual (FR/EN).

**[git.learning.dxscloud.fr](https://git.learning.dxscloud.fr)** | [English version](README.md)

## Pourquoi ce projet existe

J'enseigne Git à des amis et collègues qui apprennent l'informatique. Très vite, je me suis rendu compte que leur dire « tiens, lis la doc » ne suffisait pas. Il me fallait quelque chose qui explique vraiment le *pourquoi* des choses, pas juste le *comment*.

Le problème avec la plupart des tutoriels Git, c'est qu'ils te disent de lancer des commandes sans expliquer ce qui se passe en dessous. Pourquoi c'est important, comment tout s'articule… on survole. Moi je voulais un cours qui rentre dans les détails tout en restant agréable à lire, le genre de contenu dont tu te souviens encore des semaines plus tard.

Le thème fantasy (guildes, quêtes, parchemins) n'est pas juste décoratif. Il structure le parcours et aide à retenir des concepts qui, soyons honnêtes, peuvent être assez arides. « Les Trois Salles du Savoir », ça reste en tête plus facilement que « chapitre 2 : la zone de staging ».

À la base ce cours, c'est pour mes amis. Mais vu le boulot que ça représente de rendre tout ça pédagogique et engageant, autant en faire profiter tout le monde. Il est tout à fait possible que j'aie oublié des choses ou que certaines parties ne soient pas assez approfondies. Si tu repères un manque ou une imprécision, n'hésite pas à [contribuer](#contribuer).

## Contenu

Le cours contient **29 quêtes** réparties en 5 arcs narratifs, de `git init` jusqu'au CI/CD et Radicle. Il y a aussi **6 quêtes bonus** appelées « Les Sentiers Oubliés » qui couvrent des domaines spécifiques : LFS, Data Science, Monorepos, Hardware, GitOps et Design.

En complément, tu trouveras **4 aide-mémoire** imprimables (Git Essentiel, Git Avancé, Git LFS, Radicle) ainsi que des **scripts de vérification** pour chaque quête, disponibles en Bash et PowerShell avec le support `--lang fr/en`.

## Télécharger et vérifier

Les exercices et les scripts de vérification sont publiés sous forme d'archive signée à chaque push sur `main` :

```bash
curl -LO https://github.com/Dxsk/git-chronicles/releases/latest/download/git-chronicles.zip
curl -LO https://github.com/Dxsk/git-chronicles/releases/latest/download/git-chronicles.zip.sha256
sha256sum -c git-chronicles.zip.sha256
```

L'archive contient un fichier `BUILD_INFO` à sa racine qui identifie le commit exact ayant servi à la construire. Voir [docs/RELEASING.md](docs/RELEASING.md) pour les détails sur la génération et la vérification.

## Structure

```
src/
  fr/quetes/        # Contenu des quêtes en français
  en/quests/        # Contenu des quêtes en anglais
  fr/cheatsheets/   # Aide-mémoire en français
  en/cheatsheets/   # Aide-mémoire en anglais
  assets/           # CSS, JS (vanilla, aucune dépendance)
exercises/
  */verifier.sh     # Scripts de vérification Bash
  */verifier.ps1    # Scripts de vérification PowerShell
lib/                # Bibliothèque partagée pour les scripts
themes/fantasy/     # Messages thématiques (i18n)
```

## Développement

Le site est généré avec [Eleventy (11ty)](https://www.11ty.dev/), un générateur de sites statiques. Les templates utilisent Nunjucks. Côté front, c'est du vanilla JS et CSS, aucune dépendance externe. La coloration syntaxique et la navigation sont gérées par des scripts maison.

```bash
npm install
npm run dev        # Serveur local avec rechargement automatique
npm run build      # Build de production dans _site/
```

Nécessite Node.js 18+. Le déploiement se fait via GitHub Actions sur GitHub Pages.

## Approche pédagogique

On apprend en manipulant. Chaque quête s'appuie sur les précédentes et te fait pratiquer avant d'expliquer la théorie.

Les quêtes 01 à 14 (arcs 1 à 3) sont 100 % locales, aucun compte en ligne requis. À partir de l'arc 4 (quêtes 15 à 19), un compte GitHub est nécessaire pour la partie CI/CD. L'arc 5 (quêtes 20 à 23) explore Radicle et la décentralisation.

## Contribuer

Tu as repéré une faute ? Une commande qui mériterait une meilleure explication ? Un concept qui mériterait sa propre quête ? Les contributions sont les bienvenues, que ce soit pour corriger une phrase ou écrire une quête entière.

Le contenu est sous licence CC BY-SA 4.0, n'hésite donc pas à l'adapter pour tes propres cours, ateliers ou formations. Si tu améliores quelque chose, pense à ouvrir une PR pour que tout le monde en profite.

Consulte les [modèles d'issues](https://github.com/Dxsk/git-chronicles/issues/new/choose) pour commencer.

## Licences

Le **code** (scripts, CSS, JS, templates) est sous licence [MIT](LICENSE-MIT). Le **contenu** (textes des quêtes, aide-mémoire, récits) est sous licence [CC BY-SA 4.0](LICENSE-CC-BY-SA).
