# The Git Chronicles / Les Chroniques du Versionneur

An interactive, gamified Git course with a fantasy narrative - bilingual (FR/EN).

Un cours Git interactif et gamifie avec un recit heroic fantasy - bilingue (FR/EN).

**[git.learning.dxscloud.fr](https://git.learning.dxscloud.fr)**

## Content

- **23 quests** across 5 narrative arcs - from `git init` to CI/CD and Radicle
- **6 bonus quests** (The Forgotten Paths) - LFS, Data Science, Monorepos, Hardware, GitOps, Design
- **4 printable cheatsheets** - Git Essentials, Advanced Git, Git LFS, Radicle
- **Verification scripts** for each quest (Bash + PowerShell) with `--lang fr/en` support

## Structure

```
src/
  fr/quetes/        # French quest content
  en/quests/        # English quest content
  fr/cheatsheets/   # French cheatsheets
  en/cheatsheets/   # English cheatsheets
  assets/           # CSS, JS (vanilla, no dependencies)
exercises/
  */verifier.sh     # Bash verification scripts
  */verifier.ps1    # PowerShell verification scripts
lib/                # Shared script library
themes/fantasy/     # Theme messages (i18n)
```

## Development

```bash
npm install
npm run dev        # Local server with hot reload
npm run build      # Production build to _site/
```

Requires Node.js 18+.

## Pedagogical approach

- Hands-on first: learn by doing
- Progressive: each quest builds on the previous
- Quests 01-14 (arcs 1-3): 100% local, no online account needed
- Quests 15-19 (arc 4): GitHub account required (CI/CD)
- Quests 20-23 (arc 5): Radicle, decentralization

## Licenses

- **Code** (scripts, CSS, JS, templates): [MIT](LICENSE-MIT)
- **Content** (quest texts, cheatsheets, narratives): [CC BY-SA 4.0](LICENSE-CC-BY-SA)
