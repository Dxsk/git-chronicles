#!/usr/bin/env node
/**
 * Check that every `git <subcommand>` shown inside a code context of the
 * source .njk files uses a real git subcommand. Catches typos like
 * `git comit`, `git cehckout`, `git brnach` before they hit learners.
 *
 * Scope: subcommand-level validation only. Flags are NOT validated.
 *
 * Why not flags: `git <sub> -h` is not an exhaustive source of truth.
 * `git log -h` only prints minimal usage and omits --oneline, --graph,
 * --all, etc. `git config -h` prints the modern subcommand form and
 * hides --global/--local behind a <file-option> placeholder. Validating
 * flags against `-h` output produces massive false positives on real,
 * well-known flags. There is no off-the-shelf tool that maps a git
 * command line to "is this real". Parsing upstream's Documentation/*.txt
 * would be a project of its own. Subcommand-only validation is the
 * stable, zero-false-positive layer that actually catches typos.
 *
 * Prose mentions of "git ..." are ignored by only scanning code contexts.
 *
 * Code contexts scanned:
 *   <pre ...><code>...</code></pre>   (multi-line blocks)
 *   <code>...</code>                   (inline)
 *   <span class="git-cmd">...</span>   (inline, course-specific)
 *
 * Runs on src/, no build required.
 */

const fs = require("fs");
const path = require("path");

const SRC = path.resolve(__dirname, "../../src");

// Real git subcommands (porcelain + common plumbing). Kept explicit so
// typos in this list are as loud as typos in the course.
const GIT_SUBCOMMANDS = new Set([
  "add", "am", "annotate", "apply", "archive",
  "bisect", "blame", "branch", "bundle",
  "check-ignore", "checkout", "cherry", "cherry-pick", "clean", "clone",
  "commit", "config", "count-objects",
  "describe", "diff", "difftool",
  "fetch", "format-patch", "fsck",
  "gc", "grep", "gui",
  "help",
  "init", "instaweb",
  "log", "ls-files", "ls-remote", "ls-tree",
  "maintenance", "merge", "merge-base", "mergetool", "mv",
  "notes",
  "pack-refs", "prune", "pull", "push",
  "range-diff", "rebase", "receive-pack", "reflog", "remote", "repack", "replace",
  "request-pull", "rerere", "reset", "restore", "rev-list", "rev-parse", "revert", "rm",
  "send-email", "shortlog", "show", "show-ref", "sparse-checkout", "stash", "status",
  "submodule", "switch", "symbolic-ref",
  "tag",
  "update-index", "update-ref",
  "verify-commit", "verify-tag",
  "whatchanged", "worktree",
  // built-in ish / extensions commonly taught
  "lfs", "annex",
]);

// Aliases that the course itself defines and then uses. Every entry is
// a promise that the course sets it up before using it.
const COURSE_ALIASES = new Set([
  "co", "ci", "st", "br", "lg", "push-all",
]);

const ALLOWED = new Set([...GIT_SUBCOMMANDS, ...COURSE_ALIASES]);

function walk(dir) {
  const out = [];
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) out.push(...walk(p));
    else if (e.name.endsWith(".njk")) out.push(p);
  }
  return out;
}

function extractCodeSegments(content) {
  const segments = [];
  const patterns = [
    /<pre[^>]*>\s*<code[^>]*>([\s\S]*?)<\/code>\s*<\/pre>/g,
    /<code[^>]*>([\s\S]*?)<\/code>/g,
    /<span class="git-cmd"[^>]*>([\s\S]*?)<\/span>/g,
  ];
  for (const re of patterns) {
    let m;
    while ((m = re.exec(content)) !== null) {
      const startLine = content.slice(0, m.index).split("\n").length;
      segments.push({ text: m[1], startLine });
    }
  }
  return segments;
}

function findGitCommands(text) {
  const results = [];
  const lines = text.split("\n");
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const line = raw.replace(/^\s+/, "");
    if (line.startsWith("#")) continue;
    const re = /(?:^|[\s;&|`(\$])git\s+([a-z][a-z-]*)/g;
    let m;
    while ((m = re.exec(line)) !== null) {
      results.push({ sub: m[1], lineOffset: i });
    }
  }
  return results;
}

let errors = 0;
let checked = 0;
const unknownByFile = new Map();

const files = walk(SRC);
for (const file of files) {
  const content = fs.readFileSync(file, "utf8");
  const segments = extractCodeSegments(content);
  for (const seg of segments) {
    const cmds = findGitCommands(seg.text);
    for (const { sub, lineOffset } of cmds) {
      checked++;
      if (!ALLOWED.has(sub)) {
        const line = seg.startLine + lineOffset;
        const rel = path.relative(path.resolve(__dirname, "../.."), file);
        const key = `${rel}:${line}`;
        if (!unknownByFile.has(key)) unknownByFile.set(key, new Set());
        unknownByFile.get(key).add(sub);
        errors++;
      }
    }
  }
}

if (errors > 0) {
  console.error("Unknown git subcommands found in code contexts:");
  for (const [loc, subs] of unknownByFile) {
    console.error(`  ${loc}  git ${[...subs].join(", git ")}`);
  }
  console.error(`\nGit commands: ${errors} unknown subcommand(s) found (${checked} checked)`);
  console.error("If a subcommand is legitimate (new git feature, course alias), add it to ALLOWED in check-git-commands.js.");
  process.exit(1);
} else {
  console.log(`Git commands: ${checked} subcommand uses OK`);
}
