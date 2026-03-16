// SPDX-License-Identifier: MIT
// Table of Contents - right sidebar with heading anchors
(function () {
  var tocList = document.getElementById("toc-list");
  var tocSidebar = document.getElementById("toc-sidebar");
  if (!tocList || !tocSidebar) return;

  var main = document.querySelector(".main-content");
  if (!main) return;

  var headings = main.querySelectorAll("h2, h3");
  if (headings.length < 2) {
    tocSidebar.style.display = "none";
    return;
  }

  // Build ToC entries and assign IDs to headings
  var items = [];
  headings.forEach(function (h) {
    if (!h.id) {
      h.id = h.textContent
        .trim()
        .toLowerCase()
        .replace(/[^\w\s-]/g, "")
        .replace(/\s+/g, "-")
        .replace(/-+/g, "-")
        .replace(/^-|-$/g, "");
    }

    var li = document.createElement("li");
    li.className = "toc-item" + (h.tagName === "H3" ? " toc-sub" : "");

    var a = document.createElement("a");
    a.href = "#" + h.id;
    a.textContent = h.textContent.trim();
    a.className = "toc-link";

    li.appendChild(a);
    tocList.appendChild(li);
    items.push({ el: h, link: a, li: li });
  });

  // Intersection Observer for active state
  var currentActive = null;

  var observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          if (currentActive) currentActive.classList.remove("active");
          var match = items.find(function (item) {
            return item.el === entry.target;
          });
          if (match) {
            match.link.classList.add("active");
            currentActive = match.link;
          }
        }
      });
    },
    {
      rootMargin: "-80px 0px -70% 0px",
      threshold: 0
    }
  );

  items.forEach(function (item) {
    observer.observe(item.el);
  });

  // Smooth scroll on click
  tocList.addEventListener("click", function (e) {
    var link = e.target.closest(".toc-link");
    if (!link) return;
    e.preventDefault();
    var id = link.getAttribute("href").slice(1);
    var target = document.getElementById(id);
    if (target) {
      target.scrollIntoView({ behavior: "smooth", block: "start" });
      history.replaceState(null, "", "#" + id);
    }
  });
})();
