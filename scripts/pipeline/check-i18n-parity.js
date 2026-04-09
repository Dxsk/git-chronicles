#!/usr/bin/env node
/**
 * Check FR/EN parity: every French quest/cheatsheet must have
 * an English equivalent, and vice versa. Also checks that
 * frontmatter keys match between paired files.
 */

const fs = require("fs");
const path = require("path");

const SRC = path.resolve(__dirname, "../../src");
const PAIRS = [
  { fr: "fr/quetes", en: "en/quests" },
  { fr: "fr/cheatsheets", en: "en/cheatsheets" },
  { fr: "fr/codex", en: "en/codex", byFilename: true },
];

// Standalone pages that must exist in both languages
const STANDALONE_PAGES = [
  { fr: "fr/glossaire.njk", en: "en/glossary.njk" },
];

let errors = 0;
let matched = 0;

function getFrontmatter(filePath) {
  const content = fs.readFileSync(filePath, "utf8");
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return {};
  const fm = {};
  for (const line of match[1].split("\n")) {
    const kv = line.match(/^(\w[\w_]*)\s*:/);
    if (kv) fm[kv[1]] = true;
  }
  return fm;
}

function getSlugMap(dir) {
  if (!fs.existsSync(dir)) return new Map();
  const map = new Map();
  for (const file of fs.readdirSync(dir)) {
    if (!file.endsWith(".njk") || file === "index.njk") continue;
    const fm = getFrontmatter(path.join(dir, file));
    const questNum = file.match(/^(\d+|A\d+[a-z]?)-/);
    if (questNum) {
      map.set(questNum[1], { file, keys: Object.keys(fm) });
    }
  }
  return map;
}

function getFileSet(dir) {
  if (!fs.existsSync(dir)) return new Set();
  const files = new Set();
  for (const file of fs.readdirSync(dir)) {
    if (file.endsWith(".njk") && file !== "index.njk") files.add(file);
  }
  return files;
}

for (const pair of PAIRS) {
  const frDir = path.join(SRC, pair.fr);
  const enDir = path.join(SRC, pair.en);

  if (pair.byFilename) {
    // Compare by file count (codex files have different names across languages)
    const frFiles = getFileSet(frDir);
    const enFiles = getFileSet(enDir);
    if (frFiles.size !== enFiles.size) {
      console.error(`COUNT MISMATCH: ${pair.fr}/ has ${frFiles.size} files, ${pair.en}/ has ${enFiles.size} files`);
      errors++;
    } else {
      matched += frFiles.size;
    }
    continue;
  }

  const frMap = getSlugMap(frDir);
  const enMap = getSlugMap(enDir);

  // Check FR files have EN equivalent
  for (const [num, info] of frMap) {
    if (!enMap.has(num)) {
      console.error(`MISSING EN: ${pair.fr}/${info.file} has no English equivalent (quest ${num})`);
      errors++;
    }
  }

  // Check EN files have FR equivalent
  for (const [num, info] of enMap) {
    if (!frMap.has(num)) {
      console.error(`MISSING FR: ${pair.en}/${info.file} has no French equivalent (quest ${num})`);
      errors++;
    }
  }

  // Check frontmatter key parity for matched pairs
  for (const [num, frInfo] of frMap) {
    const enInfo = enMap.get(num);
    if (!enInfo) continue;

    const frKeys = new Set(frInfo.keys);
    const enKeys = new Set(enInfo.keys);
    const requiredKeys = ["layout", "lang", "title", "arc", "quest_number", "permalink"];

    for (const key of requiredKeys) {
      if (frKeys.has(key) && !enKeys.has(key)) {
        console.error(`KEY MISMATCH: quest ${num} - "${key}" in FR but missing in EN`);
        errors++;
      }
      if (enKeys.has(key) && !frKeys.has(key)) {
        console.error(`KEY MISMATCH: quest ${num} - "${key}" in EN but missing in FR`);
        errors++;
      }
    }
  }
}

// Check standalone pages
for (const sp of STANDALONE_PAGES) {
  const frExists = fs.existsSync(path.join(SRC, sp.fr));
  const enExists = fs.existsSync(path.join(SRC, sp.en));
  if (frExists && !enExists) {
    console.error(`MISSING EN: ${sp.fr} exists but ${sp.en} is missing`);
    errors++;
  } else if (!frExists && enExists) {
    console.error(`MISSING FR: ${sp.en} exists but ${sp.fr} is missing`);
    errors++;
  } else if (frExists && enExists) {
    matched++;
  }
}

if (errors > 0) {
  console.error(`\ni18n parity: ${errors} issue(s) found`);
  process.exit(1);
} else {
  const questPairs = PAIRS.filter(p => !p.byFilename).map(p => getSlugMap(path.join(SRC, p.fr)).size).reduce((a, b) => a + b, 0);
  console.log(`i18n parity: all ${questPairs + matched} pairs matched`);
}
