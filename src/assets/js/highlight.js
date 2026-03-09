/* ============================================================
   Les Chroniques du Versionneur - Coloration syntaxique legere
   Fonctionne en file:// - pas de dependances externes
   ============================================================ */

(function () {
  'use strict';

  // --- Utilitaire : echapper le HTML ---
  function esc(text) {
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  }

  // --- Utilitaire : envelopper dans un span ---
  function span(cls, content) {
    return '<span class="hl-' + cls + '">' + content + '</span>';
  }

  // --- Bash / Shell ---
  function highlightBash(code) {
    var result = [];
    var lines = code.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];

      // Ligne de commentaire
      if (/^\s*#/.test(line)) {
        result.push(span('comment', esc(line)));
        continue;
      }

      // Traitement token par token
      var highlighted = '';
      var j = 0;

      while (j < line.length) {
        // Chaines entre guillemets doubles
        if (line[j] === '"') {
          var end = line.indexOf('"', j + 1);
          if (end === -1) end = line.length - 1;
          highlighted += span('string', esc(line.substring(j, end + 1)));
          j = end + 1;
          continue;
        }

        // Chaines entre guillemets simples
        if (line[j] === "'") {
          var end2 = line.indexOf("'", j + 1);
          if (end2 === -1) end2 = line.length - 1;
          highlighted += span('string', esc(line.substring(j, end2 + 1)));
          j = end2 + 1;
          continue;
        }

        // Commentaire en milieu de ligne
        if (line[j] === '#') {
          highlighted += span('comment', esc(line.substring(j)));
          j = line.length;
          continue;
        }

        // Mots / tokens
        var match = line.substring(j).match(/^[^\s"'#]+/);
        if (match) {
          var token = match[0];

          if (/^--?\w/.test(token)) {
            // Flags (--global, -S, --version, etc.)
            highlighted += span('flag', esc(token));
          } else if (/^(sudo|cd|mkdir|cp|ls|cat|echo|touch|rm|mv|grep|bash|source|export)$/.test(token)) {
            // Commandes shell courantes
            highlighted += span('builtin', esc(token));
          } else if (/^git$/.test(token)) {
            // Commande git
            highlighted += span('cmd', esc(token));
          } else if (/^(init|status|add|commit|log|diff|clone|push|pull|fetch|merge|rebase|branch|checkout|switch|restore|remote|stash|reset|tag|config|show|bisect|blame|reflog|cherry-pick|bundle|worktree|archive)$/.test(token)) {
            // Sous-commandes git (quand elles suivent 'git')
            highlighted += span('subcmd', esc(token));
          } else if (/^(apt|dnf|pacman|brew|xcode-select)$/.test(token)) {
            // Gestionnaires de paquets
            highlighted += span('builtin', esc(token));
          } else if (/^\$\w+/.test(token) || /^\$\{/.test(token)) {
            // Variables
            highlighted += span('variable', esc(token));
          } else if (/^[.~\/]/.test(token) && /[\/.]/.test(token)) {
            // Chemins de fichiers
            highlighted += span('path', esc(token));
          } else {
            highlighted += esc(token);
          }

          j += token.length;
          continue;
        }

        // Espaces et autres caracteres
        highlighted += esc(line[j]);
        j++;
      }

      result.push(highlighted);
    }

    return result.join('\n');
  }

  // --- PowerShell ---
  function highlightPowerShell(code) {
    var result = [];
    var lines = code.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];

      // Ligne de commentaire
      if (/^\s*#/.test(line)) {
        result.push(span('comment', esc(line)));
        continue;
      }

      var highlighted = '';
      var j = 0;

      while (j < line.length) {
        // Chaines entre guillemets doubles
        if (line[j] === '"') {
          var end = line.indexOf('"', j + 1);
          if (end === -1) end = line.length - 1;
          highlighted += span('string', esc(line.substring(j, end + 1)));
          j = end + 1;
          continue;
        }

        // Chaines entre guillemets simples
        if (line[j] === "'") {
          var end2 = line.indexOf("'", j + 1);
          if (end2 === -1) end2 = line.length - 1;
          highlighted += span('string', esc(line.substring(j, end2 + 1)));
          j = end2 + 1;
          continue;
        }

        // Commentaire en milieu de ligne
        if (line[j] === '#') {
          highlighted += span('comment', esc(line.substring(j)));
          j = line.length;
          continue;
        }

        // Mots / tokens
        var match = line.substring(j).match(/^[^\s"'#]+/);
        if (match) {
          var token = match[0];

          if (/^-\w/.test(token)) {
            // Parametres PowerShell (-Force, -Path, etc.)
            highlighted += span('flag', esc(token));
          } else if (/^\$\w+/.test(token)) {
            // Variables PowerShell
            highlighted += span('variable', esc(token));
          } else if (/^(Get|Set|New|Remove|Write|Read|Test|Import|Export|Invoke|Start|Stop|Add|Copy|Move)-/i.test(token)) {
            // Cmdlets PowerShell
            highlighted += span('builtin', esc(token));
          } else if (/^git$/i.test(token)) {
            highlighted += span('cmd', esc(token));
          } else if (/^\.\\/i.test(token)) {
            // Execution locale (.\script.ps1)
            highlighted += span('path', esc(token));
          } else {
            highlighted += esc(token);
          }

          j += token.length;
          continue;
        }

        highlighted += esc(line[j]);
        j++;
      }

      result.push(highlighted);
    }

    return result.join('\n');
  }

  // --- YAML ---
  function highlightYaml(code) {
    var result = [];
    var lines = code.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];

      // Ligne de commentaire
      if (/^\s*#/.test(line)) {
        result.push(span('comment', esc(line)));
        continue;
      }

      // Ligne "---" ou "..."
      if (/^\s*---\s*$/.test(line) || /^\s*\.\.\.\s*$/.test(line)) {
        result.push(span('comment', esc(line)));
        continue;
      }

      var highlighted = '';
      // Cle: valeur
      var kvMatch = line.match(/^(\s*(?:-\s+)?)([^:#\s][^:#]*?)\s*(:)(.*)/);
      if (kvMatch) {
        highlighted += esc(kvMatch[1]);
        highlighted += span('key', esc(kvMatch[2]));
        highlighted += esc(kvMatch[3]);
        highlighted += highlightYamlValue(kvMatch[4]);
      } else {
        // Ligne de liste sans cle (- valeur)
        var listMatch = line.match(/^(\s*-\s+)(.*)/);
        if (listMatch) {
          highlighted += esc(listMatch[1]);
          highlighted += highlightYamlValue(listMatch[2]);
        } else {
          highlighted += highlightYamlValue(line);
        }
      }

      result.push(highlighted);
    }

    return result.join('\n');
  }

  function highlightYamlValue(val) {
    if (!val) return '';
    var trimmed = val.trim();

    // Commentaire en fin de ligne
    var commentIdx = -1;
    var inStr = false;
    var strChar = '';
    for (var c = 0; c < val.length; c++) {
      if (!inStr && (val[c] === '"' || val[c] === "'")) {
        inStr = true;
        strChar = val[c];
      } else if (inStr && val[c] === strChar) {
        inStr = false;
      } else if (!inStr && val[c] === '#' && c > 0 && val[c - 1] === ' ') {
        commentIdx = c;
        break;
      }
    }

    var main = commentIdx >= 0 ? val.substring(0, commentIdx) : val;
    var comment = commentIdx >= 0 ? val.substring(commentIdx) : '';
    var result = '';

    var mainTrimmed = main.trim();
    if (/^".*"$/.test(mainTrimmed) || /^'.*'$/.test(mainTrimmed)) {
      result += main.replace(mainTrimmed, span('string', esc(mainTrimmed)));
    } else if (/^(true|false|yes|no|on|off|null|~)$/i.test(mainTrimmed)) {
      result += main.replace(mainTrimmed, span('boolean', esc(mainTrimmed)));
    } else if (/^-?\d+(\.\d+)?([eE][+-]?\d+)?$/.test(mainTrimmed)) {
      result += main.replace(mainTrimmed, span('number', esc(mainTrimmed)));
    } else {
      result += esc(main);
    }

    if (comment) {
      result += span('comment', esc(comment));
    }

    return result;
  }

  // --- JSON ---
  function highlightJson(code) {
    var result = '';
    var i = 0;

    while (i < code.length) {
      // Chaines
      if (code[i] === '"') {
        var end = i + 1;
        while (end < code.length && code[end] !== '"') {
          if (code[end] === '\\') end++;
          end++;
        }
        var str = code.substring(i, end + 1);
        // Verifier si c'est une cle (suivie de ":")
        var after = code.substring(end + 1).match(/^\s*:/);
        if (after) {
          result += span('key', esc(str));
        } else {
          result += span('string', esc(str));
        }
        i = end + 1;
        continue;
      }

      // Nombres
      var numMatch = code.substring(i).match(/^-?\d+(\.\d+)?([eE][+-]?\d+)?/);
      if (numMatch && (i === 0 || /[\s:,\[\{]/.test(code[i - 1]))) {
        result += span('number', esc(numMatch[0]));
        i += numMatch[0].length;
        continue;
      }

      // Booleens et null
      var boolMatch = code.substring(i).match(/^(true|false|null)\b/);
      if (boolMatch) {
        result += span('boolean', esc(boolMatch[0]));
        i += boolMatch[0].length;
        continue;
      }

      // Commentaires (non standard mais courant dans les exemples)
      if (code[i] === '/' && code[i + 1] === '/') {
        var eol = code.indexOf('\n', i);
        if (eol === -1) eol = code.length;
        result += span('comment', esc(code.substring(i, eol)));
        i = eol;
        continue;
      }

      result += esc(code[i]);
      i++;
    }

    return result;
  }

  // --- Python ---
  function highlightPython(code) {
    var result = [];
    var lines = code.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];

      // Ligne de commentaire
      if (/^\s*#/.test(line)) {
        result.push(span('comment', esc(line)));
        continue;
      }

      var highlighted = '';
      var j = 0;

      while (j < line.length) {
        // Chaines triples
        if ((line.substring(j, j + 3) === '"""' || line.substring(j, j + 3) === "'''")) {
          var delim = line.substring(j, j + 3);
          var end = line.indexOf(delim, j + 3);
          if (end === -1) end = line.length - 3;
          highlighted += span('string', esc(line.substring(j, end + 3)));
          j = end + 3;
          continue;
        }

        // Chaines simples/doubles
        if (line[j] === '"' || line[j] === "'") {
          var q = line[j];
          var end2 = line.indexOf(q, j + 1);
          if (end2 === -1) end2 = line.length - 1;
          highlighted += span('string', esc(line.substring(j, end2 + 1)));
          j = end2 + 1;
          continue;
        }

        // Commentaire
        if (line[j] === '#') {
          highlighted += span('comment', esc(line.substring(j)));
          j = line.length;
          continue;
        }

        // Decorateurs
        if (line[j] === '@' && /^\w/.test(line[j + 1] || '')) {
          var decMatch = line.substring(j).match(/^@[\w.]+/);
          if (decMatch) {
            highlighted += span('function', esc(decMatch[0]));
            j += decMatch[0].length;
            continue;
          }
        }

        // Mots / tokens
        var match = line.substring(j).match(/^[a-zA-Z_]\w*/);
        if (match) {
          var token = match[0];

          if (/^(def|class|return|import|from|as|if|elif|else|for|while|try|except|finally|with|raise|pass|break|continue|yield|lambda|and|or|not|in|is|global|nonlocal|assert|del|async|await)$/.test(token)) {
            highlighted += span('keyword', esc(token));
          } else if (/^(True|False|None)$/.test(token)) {
            highlighted += span('boolean', esc(token));
          } else if (/^(print|len|range|int|str|float|list|dict|set|tuple|open|type|isinstance|super|enumerate|zip|map|filter|sorted|reversed|any|all|min|max|sum|abs|round|input|format|hasattr|getattr|setattr)$/.test(token)) {
            highlighted += span('builtin', esc(token));
          } else if (/^(self|cls)$/.test(token)) {
            highlighted += span('variable', esc(token));
          } else {
            highlighted += esc(token);
          }

          j += token.length;
          continue;
        }

        // Nombres
        var numMatch = line.substring(j).match(/^\d+(\.\d+)?/);
        if (numMatch) {
          highlighted += span('number', esc(numMatch[0]));
          j += numMatch[0].length;
          continue;
        }

        highlighted += esc(line[j]);
        j++;
      }

      result.push(highlighted);
    }

    return result.join('\n');
  }

  // --- JavaScript / TypeScript ---
  function highlightJavaScript(code) {
    var result = [];
    var lines = code.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];

      // Commentaire ligne
      if (/^\s*\/\//.test(line)) {
        result.push(span('comment', esc(line)));
        continue;
      }

      var highlighted = '';
      var j = 0;

      while (j < line.length) {
        // Commentaire
        if (line[j] === '/' && line[j + 1] === '/') {
          highlighted += span('comment', esc(line.substring(j)));
          j = line.length;
          continue;
        }

        // Template literal
        if (line[j] === '`') {
          var end = line.indexOf('`', j + 1);
          if (end === -1) end = line.length - 1;
          highlighted += span('string', esc(line.substring(j, end + 1)));
          j = end + 1;
          continue;
        }

        // Chaines
        if (line[j] === '"' || line[j] === "'") {
          var q = line[j];
          var end2 = line.indexOf(q, j + 1);
          if (end2 === -1) end2 = line.length - 1;
          highlighted += span('string', esc(line.substring(j, end2 + 1)));
          j = end2 + 1;
          continue;
        }

        // Mots
        var match = line.substring(j).match(/^[a-zA-Z_$]\w*/);
        if (match) {
          var token = match[0];

          if (/^(const|let|var|function|return|if|else|for|while|do|switch|case|break|continue|new|delete|typeof|instanceof|throw|try|catch|finally|class|extends|import|export|from|default|async|await|yield|of|in)$/.test(token)) {
            highlighted += span('keyword', esc(token));
          } else if (/^(true|false|null|undefined|NaN|Infinity)$/.test(token)) {
            highlighted += span('boolean', esc(token));
          } else if (/^(console|require|module|exports|process|Promise|Array|Object|String|Number|Math|JSON|Date|RegExp|Map|Set|Error)$/.test(token)) {
            highlighted += span('builtin', esc(token));
          } else if (/^(this)$/.test(token)) {
            highlighted += span('variable', esc(token));
          } else {
            highlighted += esc(token);
          }

          j += token.length;
          continue;
        }

        // Nombres
        var numMatch = line.substring(j).match(/^\d+(\.\d+)?/);
        if (numMatch) {
          highlighted += span('number', esc(numMatch[0]));
          j += numMatch[0].length;
          continue;
        }

        highlighted += esc(line[j]);
        j++;
      }

      result.push(highlighted);
    }

    return result.join('\n');
  }

  // --- INI / TOML ---
  function highlightIni(code) {
    var result = [];
    var lines = code.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];

      // Commentaire
      if (/^\s*[#;]/.test(line)) {
        result.push(span('comment', esc(line)));
        continue;
      }

      // Section [nom]
      var sectMatch = line.match(/^(\s*)(\[.+?\])(.*)/);
      if (sectMatch) {
        result.push(esc(sectMatch[1]) + span('key', esc(sectMatch[2])) + esc(sectMatch[3]));
        continue;
      }

      // Cle = valeur
      var kvMatch = line.match(/^(\s*)([^=\s]+)(\s*=\s*)(.*)/);
      if (kvMatch) {
        var val = kvMatch[4];
        var valHtml;
        if (/^".*"$/.test(val) || /^'.*'$/.test(val)) {
          valHtml = span('string', esc(val));
        } else if (/^(true|false)$/i.test(val)) {
          valHtml = span('boolean', esc(val));
        } else if (/^-?\d+(\.\d+)?$/.test(val)) {
          valHtml = span('number', esc(val));
        } else {
          valHtml = esc(val);
        }
        result.push(esc(kvMatch[1]) + span('variable', esc(kvMatch[2])) + esc(kvMatch[3]) + valHtml);
        continue;
      }

      result.push(esc(line));
    }

    return result.join('\n');
  }

  // --- Dockerfile ---
  function highlightDockerfile(code) {
    var result = [];
    var lines = code.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];

      // Commentaire
      if (/^\s*#/.test(line)) {
        result.push(span('comment', esc(line)));
        continue;
      }

      // Instruction Docker
      var instrMatch = line.match(/^(\s*)(FROM|RUN|CMD|ENTRYPOINT|COPY|ADD|WORKDIR|ENV|EXPOSE|VOLUME|USER|ARG|LABEL|STOPSIGNAL|HEALTHCHECK|SHELL|ONBUILD|MAINTAINER)\b(.*)/i);
      if (instrMatch) {
        var rest = instrMatch[3];
        // Colorer les chaines dans le reste
        rest = rest.replace(/"([^"]*)"/g, function (m) { return span('string', esc(m)); });
        result.push(esc(instrMatch[1]) + span('keyword', esc(instrMatch[2])) + rest);
        continue;
      }

      result.push(esc(line));
    }

    return result.join('\n');
  }

  // --- Gitattributes ---
  function highlightGitattributes(code) {
    var result = [];
    var lines = code.split('\n');

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];

      // Commentaire
      if (/^\s*#/.test(line)) {
        result.push(span('comment', esc(line)));
        continue;
      }

      // Pattern + attributs
      var attrMatch = line.match(/^(\S+)(.*)/);
      if (attrMatch) {
        var pattern = attrMatch[1];
        var attrs = attrMatch[2];
        var highlighted = span('string', esc(pattern));
        // Colorer les attributs
        highlighted += attrs.replace(/(\S+=\S+|\S+)/g, function (m) {
          if (/=/.test(m)) {
            return span('flag', esc(m));
          } else if (m === '-text' || m === 'text' || m === 'binary' || m === 'lockable') {
            return span('keyword', esc(m));
          } else {
            return span('flag', esc(m));
          }
        });
        result.push(highlighted);
        continue;
      }

      result.push(esc(line));
    }

    return result.join('\n');
  }

  // --- Resultat de commande (pas de data-lang) ---
  // Pas de coloration, on laisse tel quel

  // --- Application ---
  function applyHighlighting() {
    var blocks = document.querySelectorAll('pre[data-lang] code');

    for (var i = 0; i < blocks.length; i++) {
      var pre = blocks[i].parentElement;
      var lang = (pre.getAttribute('data-lang') || '').toLowerCase();
      var raw = blocks[i].textContent;

      if (lang === 'bash' || lang === 'shell' || lang === 'sh') {
        blocks[i].innerHTML = highlightBash(raw);
      } else if (lang === 'powershell' || lang === 'ps1') {
        blocks[i].innerHTML = highlightPowerShell(raw);
      } else if (lang === 'yaml' || lang === 'yml') {
        blocks[i].innerHTML = highlightYaml(raw);
      } else if (lang === 'json') {
        blocks[i].innerHTML = highlightJson(raw);
      } else if (lang === 'python' || lang === 'py') {
        blocks[i].innerHTML = highlightPython(raw);
      } else if (lang === 'javascript' || lang === 'js' || lang === 'typescript' || lang === 'ts') {
        blocks[i].innerHTML = highlightJavaScript(raw);
      } else if (lang === 'ini' || lang === 'toml' || lang === 'conf') {
        blocks[i].innerHTML = highlightIni(raw);
      } else if (lang === 'dockerfile' || lang === 'docker') {
        blocks[i].innerHTML = highlightDockerfile(raw);
      } else if (lang === 'gitattributes') {
        blocks[i].innerHTML = highlightGitattributes(raw);
      }
    }
  }

  // Lancer au chargement
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', applyHighlighting);
  } else {
    applyHighlighting();
  }
})();
