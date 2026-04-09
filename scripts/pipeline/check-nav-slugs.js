#!/usr/bin/env node
/**
 * Check that every slug referenced in src/assets/js/nav.js (QUESTS,
 * CHEATSHEETS, CODEX arrays) corresponds to a real .njk file on disk.
 *
 * This catches stale entries like a quest renamed in the filesystem but
 * not updated in the hardcoded navigation table, which would otherwise
 * silently produce dead links injected at runtime by the client-side
 * sidebar and prev/next navigation. Lychee cannot see these because they
 * are added to the DOM by JavaScript after the static HTML is built.
 *
 * Scope: slug existence only. Does not validate display names.
 */

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "../..");
const NAV_PATH = path.join(ROOT, "src/assets/js/nav.js");

const PATHS = {
  QUESTS:      { fr: "src/fr/quetes",      en: "src/en/quests" },
  CHEATSHEETS: { fr: "src/fr/cheatsheets", en: "src/en/cheatsheets" },
  CODEX:       { fr: "src/fr/codex",       en: "src/en/codex" },
};

const content = fs.readFileSync(NAV_PATH, "utf8");
const lines = content.split("\n");

const slugRegex = /slug:\s*\{\s*fr:\s*"([^"]+)"\s*,\s*en:\s*"([^"]+)"/;
const sectionRegex = /^\s*var\s+(QUESTS|CHEATSHEETS|CODEX)\s*=/;
const isIndexRegex = /isIndex:\s*true/;

let currentSection = null;
let errors = 0;
let checked = 0;

for (const line of lines) {
  const sectionMatch = line.match(sectionRegex);
  if (sectionMatch) {
    currentSection = sectionMatch[1];
    continue;
  }
  if (!currentSection) continue;

  const slugMatch = line.match(slugRegex);
  if (!slugMatch) continue;

  const [, frSlug, enSlug] = slugMatch;
  const isIndex = isIndexRegex.test(line);
  const dirs = PATHS[currentSection];

  for (const [lang, slug] of [["fr", frSlug], ["en", enSlug]]) {
    const filename = isIndex ? "index.njk" : `${slug}.njk`;
    const filePath = path.join(ROOT, dirs[lang], filename);
    checked++;
    if (!fs.existsSync(filePath)) {
      console.error(
        `MISSING ${currentSection} ${lang}: ${dirs[lang]}/${filename} (referenced in nav.js)`
      );
      errors++;
    }
  }
}

if (errors > 0) {
  console.error(`\n${errors} dead nav slug(s) found out of ${checked} checked.`);
  process.exit(1);
}

console.log(`OK: ${checked} nav slug(s) verified.`);
