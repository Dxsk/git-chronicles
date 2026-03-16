# Contributing to Git Chronicles

First off, thanks for taking the time to contribute! This project started as a learning resource for friends and colleagues, and community contributions help make it better for everyone.

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to daihyxsk+coc.github@pm.me.

## How can I contribute?

### Reporting bugs

Use the [Bug Report](https://github.com/Dxsk/git-chronicles/issues/new?template=bug_report.yml) issue template. Include:
- The affected page or quest
- The language (FR/EN)
- Steps to reproduce
- Screenshots if relevant

### Suggesting improvements

Use the [Content Improvement](https://github.com/Dxsk/git-chronicles/issues/new?template=content_improvement.yml) or [Feature Request](https://github.com/Dxsk/git-chronicles/issues/new?template=feature_request.yml) issue templates.

### Submitting changes

1. **Open an issue first** to discuss the change you'd like to make.
2. Fork the repository and create a branch from `main`.
3. Make your changes.
4. Run the checks before submitting:
   ```bash
   npm run check
   ```
   This runs i18n parity checks, the build, link checking, and accessibility checks.
5. Open a Pull Request referencing the related issue.

## Development setup

```bash
git clone https://github.com/<your-fork>/git-chronicles.git
cd git-chronicles
npm install
npm run dev    # Local server with hot reload
```

Requires **Node.js 18+**.

## Project structure

```
src/
  fr/quetes/        # French quest content (Nunjucks templates)
  en/quests/        # English quest content
  assets/           # CSS, JS (vanilla, no dependencies)
exercises/
  */verifier.sh     # Bash verification scripts
  */verifier.ps1    # PowerShell verification scripts
themes/fantasy/     # Theme messages (i18n)
```

## Content guidelines

### Bilingual content

The course is bilingual (FR/EN). If you modify quest content in one language, the corresponding content in the other language should also be updated. The `npm run check:i18n` script verifies parity between both languages.

### Writing style

- Keep explanations clear and beginner-friendly.
- Use the fantasy narrative tone (guilds, quests, scrolls) to stay consistent with the rest of the course.
- Explain the *why*, not just the *how*.
- Include practical examples whenever possible.

### Verification scripts

Each quest has verification scripts in both Bash (`verifier.sh`) and PowerShell (`verifier.ps1`). If you add or modify a quest, update both scripts. They support `--lang fr` and `--lang en` flags.

## Types of welcome contributions

- Fixing typos or unclear explanations
- Improving accessibility
- Adding or improving translations
- Writing new quests or bonus quests
- Improving verification scripts
- Fixing CSS/JS issues

## Licenses

By contributing, you agree that your contributions will be licensed under:
- **[MIT](LICENSE-MIT)** for code (scripts, CSS, JS, templates)
- **[CC BY-SA 4.0](LICENSE-CC-BY-SA)** for content (quest texts, cheatsheets, narratives)
