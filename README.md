# The Git Chronicles / Les Chroniques du Versionneur

> **🚧 Work in progress** The course content is mostly complete, but the website, translations and verification scripts are still being polished. Contributions and feedback are welcome!

An interactive, gamified Git course with a fantasy narrative, bilingual (FR/EN).

Un cours Git interactif et gamifié avec un récit heroic fantasy, bilingue (FR/EN).

**[git.learning.dxscloud.fr](https://git.learning.dxscloud.fr)** | [Version française](README.fr.md)

## Why this exists

This project started because I teach Git to friends and colleagues who are learning tech. I wanted something better than "here, read the docs". Something that actually explains the *why* behind things, not just the *how*.

Most Git tutorials tell you to run commands. Few explain what happens under the hood, why it matters, or how it all fits together. I wanted a course that goes into the details while staying fun to read. Something you'd actually remember weeks later.

The fantasy theme (guilds, quests, scrolls) isn't just decoration. It gives structure to the learning path and makes dry concepts stick. "The Three Halls of Knowledge" is easier to remember than "chapter 2: staging area".

This course was originally made for my friends. But given the work it takes to make it pedagogical and engaging, I figured I might as well share it with everyone. Some parts might not go deep enough, and I may have missed things. If you spot a gap or something that could be better, feel free to [contribute](#contributing).

## Content

The course contains **29 quests** across 5 narrative arcs, from `git init` to CI/CD and Radicle. There are also **6 bonus quests** called "The Forgotten Paths" covering specialized domains: LFS, Data Science, Monorepos, Hardware, GitOps and Design.

On top of that, **4 printable cheatsheets** (Git Essentials, Advanced Git, Git LFS, Radicle) and **verification scripts** for each quest in Bash and PowerShell, with `--lang fr/en` support.

## Download and verify

The exercises and verification scripts are published as a signed zip on every push to `main`:

```bash
curl -LO https://github.com/Dxsk/git-chronicles/releases/latest/download/git-chronicles.zip
curl -LO https://github.com/Dxsk/git-chronicles/releases/latest/download/git-chronicles.zip.sha256
sha256sum -c git-chronicles.zip.sha256
```

The zip contains a `BUILD_INFO` file at its root identifying the exact commit it was built from. See [docs/RELEASING.md](docs/RELEASING.md) for details on how the release is produced and verified.

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

The site is built with [Eleventy (11ty)](https://www.11ty.dev/), a static site generator. Templates use Nunjucks. The frontend is vanilla JS and CSS, no external dependencies. Syntax highlighting and navigation are handled by custom scripts.

```bash
npm install
npm run dev        # Local server with hot reload
npm run build      # Production build to _site/
```

Requires Node.js 18+. Deployment is handled via GitHub Actions to GitHub Pages.

## Pedagogical approach

You learn by doing. Each quest builds on the previous one and gets you practicing before explaining the theory.

Quests 01 to 14 (arcs 1 to 3) are 100% local, no online account needed. Starting from arc 4 (quests 15 to 19), a GitHub account is required for CI/CD. Arc 5 (quests 20 to 23) explores Radicle and decentralization.

## Contributing

Found a typo? A command that could be explained better? A concept that deserves its own quest? Contributions are welcome, whether it's fixing a single sentence or writing a whole new quest.

The content is licensed under CC BY-SA 4.0, so feel free to adapt it for your own courses, workshops, or training sessions. If you improve something, consider opening a PR so everyone benefits.

Check the [issue templates](https://github.com/Dxsk/git-chronicles/issues/new/choose) to get started.

## Licenses

**Code** (scripts, CSS, JS, templates) is licensed under [MIT](LICENSE-MIT). **Content** (quest texts, cheatsheets, narratives) is licensed under [CC BY-SA 4.0](LICENSE-CC-BY-SA).
