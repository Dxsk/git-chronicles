// SPDX-License-Identifier: MIT
// Sidebar navigation and prev/next for Git Chronicles
// Reads quest data from window.__quests (injected by Eleventy layout)

(function() {
  'use strict';

  var lang = window.__lang || 'fr';

  // Quest data - will be populated by Eleventy templates or fetched
  var QUESTS = [
    { arc: 1, title: { fr: "Arc 1 - Les Fondations de l'Archive", en: "Arc 1 - Archive Foundations" }, quests: [
      { id: "01", name: { fr: "La Guilde des Archivistes", en: "The Archivists' Guild" }, slug: { fr: "01-la-guilde-des-archivistes", en: "01-the-archivists-guild" }, available: true },
      { id: "02", name: { fr: "Les Trois Salles du Savoir", en: "The Three Halls of Knowledge" }, slug: { fr: "02-les-trois-salles-du-savoir", en: "02-the-three-halls-of-knowledge" }, available: true },
      { id: "03", name: { fr: "Le Premier Parchemin", en: "The First Scroll" }, slug: { fr: "03-le-premier-parchemin", en: "03-the-first-scroll" }, available: true },
      { id: "04", name: { fr: "L'Archive est Partout", en: "The Archive is Everywhere" }, slug: { fr: "04-larchive-est-partout", en: "04-the-archive-is-everywhere" }, available: true },
      { id: "05", name: { fr: "Les Lignes du Temps", en: "The Lines of Time" }, slug: { fr: "05-les-lignes-du-temps", en: "05-the-lines-of-time" }, available: true }
    ]},
    { arc: 2, title: { fr: "Arc 2 - Les Branches du Destin", en: "Arc 2 - Branches of Destiny" }, quests: [
      { id: "06", name: { fr: "L'Arbre des Possibles", en: "The Tree of Possibilities" }, slug: { fr: "06-larbre-des-possibles", en: "06-the-tree-of-possibilities" }, available: true },
      { id: "07", name: { fr: "Le Conflit des Royaumes", en: "The Conflict of Kingdoms" }, slug: { fr: "07-le-conflit-des-royaumes", en: "07-the-conflict-of-kingdoms" }, available: true },
      { id: "08", name: { fr: "Réécrire l'Histoire", en: "Rewriting History" }, slug: { fr: "08-reecrire-lhistoire", en: "08-rewriting-history" }, available: true },
      { id: "09", name: { fr: "Les Portails Distants", en: "The Distant Portals" }, slug: { fr: "09-les-portails-distants", en: "09-the-distant-portals" }, available: true },
      { id: "10", name: { fr: "Le Protocole des Guildes", en: "The Guild Protocol" }, slug: { fr: "10-le-protocole-des-guildes", en: "10-the-guild-protocol" }, available: true }
    ]},
    { arc: 3, title: { fr: "Arc 3 - Les Arts Anciens", en: "Arc 3 - The Ancient Arts" }, quests: [
      { id: "11", name: { fr: "Le Tisseur de Temps", en: "The Time Weaver" }, slug: { fr: "11-le-tisseur-de-temps", en: "11-the-time-weaver" }, available: true },
      { id: "12", name: { fr: "L'Oracle du Code", en: "The Code Oracle" }, slug: { fr: "12-loracle-du-code", en: "12-the-code-oracle" }, available: true },
      { id: "13", name: { fr: "Les Sceaux Magiques", en: "The Magic Seals" }, slug: { fr: "13-les-sceaux-magiques", en: "13-the-magic-seals" }, available: true },
      { id: "14", name: { fr: "Les Outils de l'Archiviste", en: "The Archivist's Tools" }, slug: { fr: "14-les-outils-de-larchiviste", en: "14-the-archivists-tools" }, available: true }
    ]},
    { arc: 4, title: { fr: "Arc 4 - Les Forges Automatiques", en: "Arc 4 - The Automated Forges" }, quests: [
      { id: "15", name: { fr: "Les Forges Éternelles", en: "The Eternal Forges" }, slug: { fr: "15-les-forges-eternelles", en: "15-the-eternal-forges" }, available: true },
      { id: "16", name: { fr: "Les Actions du Royaume", en: "The Kingdom's Actions" }, slug: { fr: "16-les-actions-du-royaume", en: "16-the-kingdoms-actions" }, available: true },
      { id: "17", name: { fr: "Les Épreuves Automatiques", en: "The Automated Trials" }, slug: { fr: "17-les-epreuves-automatiques", en: "17-the-automated-trials" }, available: true },
      { id: "18", name: { fr: "Le Déploiement Sacré", en: "The Sacred Deployment" }, slug: { fr: "18-le-deploiement-sacre", en: "18-the-sacred-deployment" }, available: true },
      { id: "19", name: { fr: "Les Autres Forges", en: "The Other Forges" }, slug: { fr: "19-les-autres-forges", en: "19-the-other-forges" }, available: true }
    ]},
    { arc: 5, title: { fr: "Arc 5 - Au-delà des Guildes", en: "Arc 5 - Beyond the Guilds" }, quests: [
      { id: "20", name: { fr: "Les Chemins Libres", en: "The Free Paths" }, slug: { fr: "20-les-chemins-libres", en: "20-the-free-paths" }, available: true },
      { id: "21", name: { fr: "Le Disciple de Radicle", en: "The Radicle Disciple" }, slug: { fr: "21-le-disciple-de-radicle", en: "21-the-radicle-disciple" }, available: true },
      { id: "22", name: { fr: "La Tour de Guet", en: "The Watchtower" }, slug: { fr: "22-la-tour-de-guet", en: "22-the-watchtower" }, available: true },
      { id: "23", name: { fr: "Le Grand Rituel", en: "The Grand Ritual" }, slug: { fr: "23-le-grand-rituel", en: "23-the-grand-ritual" }, available: true }
    ]},
    { arc: 6, title: { fr: "Arc 6 - Les Sentiers Oubliés", en: "Arc 6 - The Forgotten Paths" }, quests: [
      { id: "A1", name: { fr: "Les Forges du Titan", en: "The Titan's Forges" }, slug: { fr: "A1-les-forges-du-titan", en: "A1-the-titans-forges" }, available: true },
      { id: "A2", name: { fr: "Les Archives Infinies", en: "The Infinite Archives" }, slug: { fr: "A2-les-archives-infinies", en: "A2-the-infinite-archives" }, available: true },
      { id: "A3", name: { fr: "La Cité-Monde", en: "The World City" }, slug: { fr: "A3-la-cite-monde", en: "A3-the-world-city" }, available: true },
      { id: "A3a", name: { fr: "La Cité-Monde, le Choix du Bâtisseur", en: "The World City, The Builder's Choice" }, slug: { fr: "A3a-la-cite-monde", en: "A3a-the-world-city" }, available: true },
      { id: "A3b", name: { fr: "Les Arcanes de la Cité", en: "The City Arcana" }, slug: { fr: "A3b-les-arcanes-de-la-cite", en: "A3b-the-city-arcana" }, available: true },
      { id: "A4", name: { fr: "Les Plans de l'Artificier", en: "The Artificer's Plans" }, slug: { fr: "A4-les-plans-de-lartificier", en: "A4-the-artificers-plans" }, available: true },
      { id: "A5", name: { fr: "Les Courants du Destin", en: "The Currents of Destiny" }, slug: { fr: "A5-les-courants-du-destin", en: "A5-the-currents-of-destiny" }, available: true },
      { id: "A6", name: { fr: "L'Atelier des Enlumineurs", en: "The Illuminators' Workshop" }, slug: { fr: "A6-latelier-des-enlumineurs", en: "A6-the-illuminators-workshop" }, available: true }
    ]}
  ];

  var CHEATSHEETS = [
    { id: "cs1", name: { fr: "Git Essentiel", en: "Git Essentials" }, slug: { fr: "git-essentiel", en: "git-essentials" } },
    { id: "cs2", name: { fr: "Git Avancé", en: "Advanced Git" }, slug: { fr: "git-avance", en: "advanced-git" } },
    { id: "cs3", name: { fr: "Git LFS", en: "Git LFS" }, slug: { fr: "git-lfs", en: "git-lfs" } },
    { id: "cs4", name: { fr: "Radicle", en: "Radicle" }, slug: { fr: "radicle", en: "radicle" } }
  ];

  var CODEX = [
    { id: "cx-idx", name: { fr: "Le Codex", en: "The Codex" }, slug: { fr: "index", en: "index" }, isIndex: true },
    { id: "cx-ma", name: { fr: "Maitre Archiviste", en: "Master Archivist" }, slug: { fr: "maitre-archiviste", en: "master-archivist" } },
    { id: "cx-al", name: { fr: "Aldric le Scribe", en: "Aldric the Scribe" }, slug: { fr: "aldric-le-scribe", en: "aldric-the-scribe" } },
    { id: "cx-be", name: { fr: "Berenice", en: "Berenice" }, slug: { fr: "berenice", en: "berenice" } },
    { id: "cx-el", name: { fr: "Elara la Sage", en: "Elara the Wise" }, slug: { fr: "elara-la-sage", en: "elara-the-wise" } },
    { id: "cx-cs", name: { fr: "Citadelle du Savoir", en: "Citadel of Knowledge" }, slug: { fr: "citadelle-du-savoir", en: "citadel-of-knowledge" } },
    { id: "cx-ga", name: { fr: "Guilde des Archivistes", en: "Archivists' Guild" }, slug: { fr: "guilde-des-archivistes", en: "archivists-guild" } },
    { id: "cx-ts", name: { fr: "Les Trois Salles", en: "The Three Halls" }, slug: { fr: "les-trois-salles", en: "the-three-halls" } },
    { id: "cx-fs", name: { fr: "Foret de Sombrebois", en: "Darkwood Forest" }, slug: { fr: "foret-de-sombrebois", en: "darkwood-forest" } },
    { id: "cx-at", name: { fr: "Atelier du Tisseur", en: "Time Weaver's Workshop" }, slug: { fr: "atelier-du-tisseur-de-temps", en: "time-weavers-workshop" } },
    { id: "cx-ss", name: { fr: "Salle des Sceaux", en: "Hall of Seals" }, slug: { fr: "salle-des-sceaux", en: "hall-of-seals" } },
    { id: "cx-vf", name: { fr: "Vallee des Forges", en: "Valley of Forges" }, slug: { fr: "vallee-des-forges-eternelles", en: "valley-of-eternal-forges" } },
    { id: "cx-pd", name: { fr: "Portails Distants", en: "Distant Portals" }, slug: { fr: "les-portails-distants", en: "the-distant-portals" } }
  ];

  // Flatten all quests into a single array
  function getAllQuests() {
    var all = [];
    QUESTS.forEach(function(arc) {
      arc.quests.forEach(function(q) {
        all.push(q);
      });
    });
    return all;
  }

  // Get quest path prefix for current language
  function getQuestPathPrefix() {
    return lang === 'fr' ? '/fr/quetes/' : '/en/quests/';
  }

  function getCheatsheetPathPrefix() {
    return lang === 'fr' ? '/fr/cheatsheets/' : '/en/cheatsheets/';
  }

  function getCodexPathPrefix() {
    return lang === 'fr' ? '/fr/codex/' : '/en/codex/';
  }

  // Detect current context from URL
  function detectContext() {
    var path = window.location.pathname;
    var allQuests = getAllQuests();

    // Check if we're on a quest page
    for (var i = 0; i < allQuests.length; i++) {
      if (path.indexOf(allQuests[i].slug[lang]) !== -1) {
        return { type: 'quest', index: i, quest: allQuests[i] };
      }
    }

    // Check if we're on a cheatsheet page
    for (var j = 0; j < CHEATSHEETS.length; j++) {
      if (path.indexOf(CHEATSHEETS[j].slug[lang]) !== -1) {
        return { type: 'cheatsheet', index: j, cheatsheet: CHEATSHEETS[j] };
      }
    }

    // Check if we're on the glossary page
    var glossarySlug = lang === 'fr' ? '/fr/glossaire/' : '/en/glossary/';
    if (path === glossarySlug) {
      return { type: 'glossary' };
    }

    // Check if we're on a codex page
    var codexPrefix = getCodexPathPrefix();
    if (path.indexOf(codexPrefix) !== -1) {
      for (var k = 0; k < CODEX.length; k++) {
        var codexSlug = CODEX[k].slug[lang];
        if (CODEX[k].isIndex && path === codexPrefix) {
          return { type: 'codex', index: k, codex: CODEX[k] };
        }
        if (!CODEX[k].isIndex && path.indexOf(codexSlug) !== -1) {
          return { type: 'codex', index: k, codex: CODEX[k] };
        }
      }
      return { type: 'codex', index: 0, codex: CODEX[0] };
    }

    // Homepage or unknown
    return { type: 'home' };
  }

  // Build sidebar navigation
  function buildSidebar() {
    var nav = document.getElementById('nav-container');
    if (!nav) return;

    var context = detectContext();
    var questPrefix = getQuestPathPrefix();
    var csPrefix = getCheatsheetPathPrefix();
    var html = '';

    // Home link
    html += '<div class="arc-group">';
    html += '<a href="/' + lang + '/" class="quest-link' + (context.type === 'home' ? ' active' : '') + '">';
    html += (lang === 'fr' ? 'Accueil' : 'Home');
    html += '</a></div>';

    // Quest arcs
    QUESTS.forEach(function(arc) {
      html += '<div class="arc-group">';
      html += '<h3 class="arc-title">' + arc.title[lang] + '</h3>';
      arc.quests.forEach(function(q) {
        var isActive = context.type === 'quest' && context.quest && context.quest.id === q.id;
        var questLabel = (lang === 'fr' ? 'Quête' : 'Quest');
        html += '<a href="' + questPrefix + q.slug[lang] + '/" class="quest-link' + (isActive ? ' active' : '') + '">';
        html += questLabel + ' ' + q.id + ' - ' + q.name[lang];
        html += '</a>';
      });
      html += '</div>';
    });

    // Cheatsheets
    html += '<div class="arc-group">';
    html += '<h3 class="arc-title">' + (lang === 'fr' ? 'Aide-mémoire' : 'Cheatsheets') + '</h3>';
    CHEATSHEETS.forEach(function(cs) {
      var isActive = context.type === 'cheatsheet' && context.cheatsheet && context.cheatsheet.id === cs.id;
      html += '<a href="' + csPrefix + cs.slug[lang] + '/" class="quest-link' + (isActive ? ' active' : '') + '">';
      html += cs.name[lang];
      html += '</a>';
    });
    html += '</div>';

    // Codex
    var cxPrefix = getCodexPathPrefix();
    html += '<div class="arc-group">';
    html += '<h3 class="arc-title">' + (lang === 'fr' ? 'Codex' : 'Codex') + '</h3>';
    CODEX.forEach(function(cx) {
      var isActive = context.type === 'codex' && context.codex && context.codex.id === cx.id;
      var href = cx.isIndex ? cxPrefix : cxPrefix + cx.slug[lang] + '/';
      html += '<a href="' + href + '" class="quest-link' + (isActive ? ' active' : '') + '">';
      html += cx.name[lang];
      html += '</a>';
    });
    html += '</div>';

    // Glossary
    var glossaryHref = lang === 'fr' ? '/fr/glossaire/' : '/en/glossary/';
    var glossaryLabel = lang === 'fr' ? 'Glossaire' : 'Glossary';
    html += '<div class="arc-group">';
    html += '<a href="' + glossaryHref + '" class="quest-link' + (context.type === 'glossary' ? ' active' : '') + '">';
    html += glossaryLabel;
    html += '</a></div>';

    nav.innerHTML = html;
  }

  // Build prev/next footer navigation
  function buildFooterNav() {
    var footer = document.getElementById('nav-footer');
    if (!footer) return;

    var context = detectContext();
    if (context.type !== 'quest') return;

    var allQuests = getAllQuests();
    var idx = context.index;
    var questPrefix = getQuestPathPrefix();
    var prevLabel = lang === 'fr' ? 'Précédent' : 'Previous';
    var nextLabel = lang === 'fr' ? 'Suivant' : 'Next';
    var html = '';

    if (idx > 0) {
      var prev = allQuests[idx - 1];
      html += '<a href="' + questPrefix + prev.slug[lang] + '/" class="nav-prev">';
      html += '<span class="nav-label">&larr; ' + prevLabel + '</span>';
      html += '<span class="nav-title">' + prev.name[lang] + '</span>';
      html += '</a>';
    } else {
      html += '<span></span>';
    }

    if (idx < allQuests.length - 1) {
      var next = allQuests[idx + 1];
      html += '<a href="' + questPrefix + next.slug[lang] + '/" class="nav-next">';
      html += '<span class="nav-label">' + nextLabel + ' &rarr;</span>';
      html += '<span class="nav-title">' + next.name[lang] + '</span>';
      html += '</a>';
    } else {
      html += '<span></span>';
    }

    footer.innerHTML = html;
  }

  // Toggle sidebar on mobile
  function setupNavToggle() {
    var toggle = document.querySelector('.nav-toggle');
    var sidebar = document.getElementById('nav-container');
    if (!toggle || !sidebar) return;

    toggle.addEventListener('click', function() {
      var expanded = toggle.getAttribute('aria-expanded') === 'true';
      toggle.setAttribute('aria-expanded', !expanded);
      sidebar.classList.toggle('open');
    });
  }

  // Initialize on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  function init() {
    buildSidebar();
    buildFooterNav();
    setupNavToggle();
  }
})();
