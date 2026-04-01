// SPDX-License-Identifier: MIT
const htmlmin = require("html-minifier-terser");
const CleanCSS = require("clean-css");
const { minify: minifyJS } = require("terser");
const fs = require("fs");
const path = require("path");

const isProd = process.env.NODE_ENV === "production";

module.exports = function(eleventyConfig) {
  eleventyConfig.addPassthroughCopy("src/assets/img");
  eleventyConfig.addPassthroughCopy("src/CNAME");

  if (isProd) {
    eleventyConfig.addTransform("htmlmin", async function(content) {
      if ((this.page.outputPath || "").endsWith(".html")) {
        return await htmlmin.minify(content, {
          collapseWhitespace: true,
          conservativeCollapse: true,
          removeComments: true,
          minifyCSS: true,
          minifyJS: true,
          ignoreCustomFragments: [/<%[\s\S]*?%>/, /<pre[\s\S]*?<\/pre>/]
        });
      }
      return content;
    });

    eleventyConfig.on("eleventy.after", async () => {
      // Minify CSS
      const cssDir = path.join(__dirname, "_site", "assets", "css");
      fs.mkdirSync(cssDir, { recursive: true });
      for (const file of fs.readdirSync(path.join(__dirname, "src", "assets", "css"))) {
        if (file.endsWith(".css")) {
          const src = fs.readFileSync(path.join(__dirname, "src", "assets", "css", file), "utf8");
          const min = new CleanCSS({}).minify(src).styles;
          fs.writeFileSync(path.join(cssDir, file), min);
        }
      }

      // Minify JS
      const jsDir = path.join(__dirname, "_site", "assets", "js");
      fs.mkdirSync(jsDir, { recursive: true });
      for (const file of fs.readdirSync(path.join(__dirname, "src", "assets", "js"))) {
        if (file.endsWith(".js")) {
          const src = fs.readFileSync(path.join(__dirname, "src", "assets", "js", file), "utf8");
          const min = await minifyJS(src);
          fs.writeFileSync(path.join(jsDir, file), min.code);
        }
      }
    });
  } else {
    eleventyConfig.addPassthroughCopy("src/assets/css");
    eleventyConfig.addPassthroughCopy("src/assets/js");
  }

  return {
    dir: {
      input: "src",
      output: "_site",
      includes: "_includes",
      data: "_data"
    },
    templateFormats: ["njk", "md", "html"],
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk"
  };
};
