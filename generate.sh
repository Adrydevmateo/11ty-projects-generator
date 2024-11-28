#!/bin/bash

# Generates a new Eleventy project
# Author: Adry Mateo Ramon | AdryDev

# Ask for the project name
declare PROJECT_NAME
read -p "Enter your project name: " PROJECT_NAME

if [ -d "$PROJECT_NAME" ]; then
    echo "Project already exists"
    exit 1
fi

# Ask for the package manager
declare PACKAGE_MANAGER

## Define the list options
echo "Package Manager:"
PS3="Choose a package manager: "
package_manager_options=("npm" "pnpm" "yarn" "bun")

## Display the select list and handle user choice
select opt in "${package_manager_options[@]}"; do
	case $opt in
		"npm")
			PACKAGE_MANAGER="npm"
			break
			;;
		"pnpm")
			PACKAGE_MANAGER="pnpm"
			break
			;;
		"yarn")
			PACKAGE_MANAGER="yarn"
			break
			;;
		"bun")
			PACKAGE_MANAGER="bun"
			break
			;;
		*) echo "Invalid option. Please try again." ;;
	esac
done

# Ask for the type of module
declare MODULE_TYPE
echo "Module Type: (you can change it later in the config file)"
PS3="Choose a module type: "
module_type_options=("ESM" "CJS")

## Display the select list and handle user choice
select opt in "${module_type_options[@]}"; do
	case $opt in
		"ESM")
			MODULE_TYPE="ESM"
			break
			;;
		"CJS")
			MODULE_TYPE="CJS"
			break
			;;
		*) echo "Invalid option. Please try again." ;;
	esac
done

mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME"

# Initialize the project with the selected package manager
$PACKAGE_MANAGER init -y

echo "Installing Packages ..."
npm install @11ty/eleventy # Install 11ty
npm install -D clean-css # Install css minifier as dev dependency
npm install -D html-minifier-terser # Install html minifier  as dev dependency

# Create project directories
mkdir "config"
mkdir "config/shortcodes"
mkdir "config/filters"
mkdir "config/collections"
mkdir "config/transforms"
mkdir "public"
mkdir "src"
mkdir "src/pages"
mkdir "src/pages/home"
mkdir "src/assets"
mkdir "src/assets/css"
mkdir "src/assets/css/components"
mkdir "src/assets/js"
mkdir "src/assets/images"
mkdir "src/assets/icons"
mkdir "src/assets/videos"
mkdir "src/components"
mkdir "src/components/buttons"
mkdir "src/data"
mkdir "src/layouts"

echo '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32"><path fill="#f5de19" d="M2 2h28v28H2z"/><path d="M20.809 23.875a2.87 2.87 0 0 0 2.6 1.6c1.09 0 1.787-.545 1.787-1.3c0-.9-.716-1.222-1.916-1.747l-.658-.282c-1.9-.809-3.16-1.822-3.16-3.964c0-1.973 1.5-3.476 3.853-3.476a3.89 3.89 0 0 1 3.742 2.107L25 18.128A1.79 1.79 0 0 0 23.311 17a1.145 1.145 0 0 0-1.259 1.128c0 .789.489 1.109 1.618 1.6l.658.282c2.236.959 3.5 1.936 3.5 4.133c0 2.369-1.861 3.667-4.36 3.667a5.06 5.06 0 0 1-4.795-2.691Zm-9.295.228c.413.733.789 1.353 1.693 1.353c.864 0 1.41-.338 1.41-1.653v-8.947h2.631v8.982c0 2.724-1.6 3.964-3.929 3.964a4.085 4.085 0 0 1-3.947-2.4Z"/></svg>' >> public/favicon.svg

# Create initial files
if which jq >/dev/null; then
	jq '.scripts = {
			"start": "eleventy --serve",
			"dev:bash": "rm -rf _site && clear && eleventy --serve",
			"dev:cmd": "rmdir _site && cls && eleventy --serve",
			"dev:powershell": "Remove-Item -Recurse -Force _site && Clear-Host && eleventy --serve",
    		"build": "eleventy"
  		}' package.json > package.json.tmp && mv package.json.tmp package.json
fi

# Eleventy config file
cat <<EOF > eleventy.config.mjs
import CleanCSS from "clean-css";
import minifyHTML from "./config/transforms/html.transform.mjs";

/** @param {import("@11ty/eleventy").UserConfig} eleventyConfig */
export default function (eleventyConfig) {
  eleventyConfig.setBrowserSyncConfig({ notify: true });

  // Reduce the verbosity of Eleventy's logs
  eleventyConfig.setQuietMode(true);

  // Copy files and directories to the output folder
  eleventyConfig.addPassthroughCopy("src/assets");
	eleventyConfig.addPassthroughCopy("public");

  eleventyConfig.addFilter("cssmin", function (code) {
    return new CleanCSS({}).minify(code).styles;
  });
  
	eleventyConfig.addTransform("html", minifyHTML);

  return {
    dir: {
      input: "src",
      includes: "components",
      layouts: "layouts",
      data: "data",
    },
  };
}
EOF

cat <<EOF > .gitignore
node_modules
dist
_site
.cache
EOF

cat <<EOF > config/transforms/html.transform.mjs
import htmlmin from "html-minifier-terser"

export default function (content) {
	if ((this.page.outputPath || "").endsWith(".html")) {
		let minified = htmlmin.minify(content, {
			useShortDoctype: true,
			removeComments: true,
			collapseWhitespace: true,
		});

		return minified;
	}

	// If not an HTML output, return content as-is
	return content;
}
EOF

cat <<EOF > src/layouts/base.njk
<!DOCTYPE html>
<html lang="en">

<head>
	<title>{{title}}</title>

	<!-- Meta Tags -->
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="author" content="{{author}}">
	<meta name="description" content="{{description}}">
	
	<link rel="icon" type="image/svg+xml" href="public/favicon.svg">

	<!-- Styles -->
	<link rel="stylesheet" href="/assets/css/index.css">

	<!-- You can use nunjucks to import your styles -->
	{% for style in styles %}
	<link rel="stylesheet" href="{{ style }}">
	{% endfor %}

	<!-- You can minify your inline css with the cssmin filter -->
	{% set css %}
	#base-layout {
		opacity: 0;
	}

	#loading-screen-container {
    position: fixed;
    display: grid;
    place-items: center;
    inset: 0;
    animation-name: loadingScreenAnimation;
    animation-duration: 1s;
	}

	@keyframes loadingScreenAnimation {
  	0% { transform: scale(-2); }
  	50% { transform: scale(2); }
  	100% { transform: scale(1); }
	}
	{% endset %}

	<style>
		{{ css | cssmin | safe }}
	</style>

	<script defer>
		window.addEventListener("load", function () {
  		setTimeout(function () {
				document.getElementById("base-layout").style.opacity = 1;
    		document.getElementById("loading-screen-container").style.display = "none";
  		}, 2000);
		});
	</script>
</head>

<body>
	<div id="loading-screen-container">
		<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"><rect width="7.33" height="7.33" x="1" y="1" fill="currentColor"><animate id="svgSpinnersBlocksWave0" attributeName="x" begin="0;svgSpinnersBlocksWave1.end+0.2s" dur="0.6s" values="1;4;1"/><animate attributeName="y" begin="0;svgSpinnersBlocksWave1.end+0.2s" dur="0.6s" values="1;4;1"/><animate attributeName="width" begin="0;svgSpinnersBlocksWave1.end+0.2s" dur="0.6s" values="7.33;1.33;7.33"/><animate attributeName="height" begin="0;svgSpinnersBlocksWave1.end+0.2s" dur="0.6s" values="7.33;1.33;7.33"/></rect><rect width="7.33" height="7.33" x="8.33" y="1" fill="currentColor"><animate attributeName="x" begin="svgSpinnersBlocksWave0.begin+0.1s" dur="0.6s" values="8.33;11.33;8.33"/><animate attributeName="y" begin="svgSpinnersBlocksWave0.begin+0.1s" dur="0.6s" values="1;4;1"/><animate attributeName="width" begin="svgSpinnersBlocksWave0.begin+0.1s" dur="0.6s" values="7.33;1.33;7.33"/><animate attributeName="height" begin="svgSpinnersBlocksWave0.begin+0.1s" dur="0.6s" values="7.33;1.33;7.33"/></rect><rect width="7.33" height="7.33" x="1" y="8.33" fill="currentColor"><animate attributeName="x" begin="svgSpinnersBlocksWave0.begin+0.1s" dur="0.6s" values="1;4;1"/><animate attributeName="y" begin="svgSpinnersBlocksWave0.begin+0.1s" dur="0.6s" values="8.33;11.33;8.33"/><animate attributeName="width" begin="svgSpinnersBlocksWave0.begin+0.1s" dur="0.6s" values="7.33;1.33;7.33"/><animate attributeName="height" begin="svgSpinnersBlocksWave0.begin+0.1s" dur="0.6s" values="7.33;1.33;7.33"/></rect><rect width="7.33" height="7.33" x="15.66" y="1" fill="currentColor"><animate attributeName="x" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="15.66;18.66;15.66"/><animate attributeName="y" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="1;4;1"/><animate attributeName="width" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="7.33;1.33;7.33"/><animate attributeName="height" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="7.33;1.33;7.33"/></rect><rect width="7.33" height="7.33" x="8.33" y="8.33" fill="currentColor"><animate attributeName="x" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="8.33;11.33;8.33"/><animate attributeName="y" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="8.33;11.33;8.33"/><animate attributeName="width" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="7.33;1.33;7.33"/><animate attributeName="height" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="7.33;1.33;7.33"/></rect><rect width="7.33" height="7.33" x="1" y="15.66" fill="currentColor"><animate attributeName="x" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="1;4;1"/><animate attributeName="y" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="15.66;18.66;15.66"/><animate attributeName="width" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="7.33;1.33;7.33"/><animate attributeName="height" begin="svgSpinnersBlocksWave0.begin+0.2s" dur="0.6s" values="7.33;1.33;7.33"/></rect><rect width="7.33" height="7.33" x="15.66" y="8.33" fill="currentColor"><animate attributeName="x" begin="svgSpinnersBlocksWave0.begin+0.3s" dur="0.6s" values="15.66;18.66;15.66"/><animate attributeName="y" begin="svgSpinnersBlocksWave0.begin+0.3s" dur="0.6s" values="8.33;11.33;8.33"/><animate attributeName="width" begin="svgSpinnersBlocksWave0.begin+0.3s" dur="0.6s" values="7.33;1.33;7.33"/><animate attributeName="height" begin="svgSpinnersBlocksWave0.begin+0.3s" dur="0.6s" values="7.33;1.33;7.33"/></rect><rect width="7.33" height="7.33" x="8.33" y="15.66" fill="currentColor"><animate attributeName="x" begin="svgSpinnersBlocksWave0.begin+0.3s" dur="0.6s" values="8.33;11.33;8.33"/><animate attributeName="y" begin="svgSpinnersBlocksWave0.begin+0.3s" dur="0.6s" values="15.66;18.66;15.66"/><animate attributeName="width" begin="svgSpinnersBlocksWave0.begin+0.3s" dur="0.6s" values="7.33;1.33;7.33"/><animate attributeName="height" begin="svgSpinnersBlocksWave0.begin+0.3s" dur="0.6s" values="7.33;1.33;7.33"/></rect><rect width="7.33" height="7.33" x="15.66" y="15.66" fill="currentColor"><animate id="svgSpinnersBlocksWave1" attributeName="x" begin="svgSpinnersBlocksWave0.begin+0.4s" dur="0.6s" values="15.66;18.66;15.66"/><animate attributeName="y" begin="svgSpinnersBlocksWave0.begin+0.4s" dur="0.6s" values="15.66;18.66;15.66"/><animate attributeName="width" begin="svgSpinnersBlocksWave0.begin+0.4s" dur="0.6s" values="7.33;1.33;7.33"/><animate attributeName="height" begin="svgSpinnersBlocksWave0.begin+0.4s" dur="0.6s" values="7.33;1.33;7.33"/></rect></svg>
	</div>
	<div id="base-layout">
		{{content | safe}}
	</div>
</body>

</html>
EOF

cat <<EOF > src/pages/home/home.page.njk
---
permalink: /index.html
layout: base.njk
title: 11ty Projects Generator | AdryDev
author: AdryDev
description: Thanks for using my Eleventy project generator
---

<div class="home-page">
	{% from "hero.component.njk" import Hero %}
	{{ Hero(hero) }}
</div>
EOF

cat <<EOF > src/pages/home/home.json
{
	"styles": ["assets/css/components/hero.css", "assets/css/components/link.css"],
	"hero": {
		"title": "11ty Projects Generator",
		"description": "Please leave a ⭐ on the repo",
		"button": {
			"text": "Check the repository",
			"url": "https://github.com/Adrydevmateo/11ty-projects-generator"
		}
	}
}
EOF

cat <<EOF > src/components/hero.component.njk
{% macro Hero(data) %}
<div class="hero">
	<div class="hero__content">
		<h1 class="hero__title">{{ data.title }}</h1>
		<p class="hero__description">{{ data.description }}</p>
		{% from "buttons/link.component.njk" import Link %}
		{% set link = {	text: data.button.text, url: data.button.url, type: "button", isExternal: true } %}
		{{ Link(link) }}
	</div>
</div>
{% endmacro %}
EOF

cat <<EOF > src/components/buttons/link.component.njk
{% macro Link(data) %}
{% set type = data.type %}

{% if not type %}
	{% set type = "link" %}
{% endif %}

<a href="{{ data.url }}" class="link__{{type}}" {% if data.isExternal %} target="_blank" {% endif %}>
{% if data.icon %}
 {{ data.icon | safe }}
{% else %}
 {{ data.text }}
{% endif %}
</a>
{% endmacro %}
EOF

cat <<EOF > src/assets/css/index.css
html { overflow-y: hidden; }
html, button, a, input {
	font-family: system-ui, sans-serif;
	font-size: 20px;
	word-break: break-word;
	font-weight: 600;
}
body { color: #fff; background-color: #222; }
p { line-height: 1.5; }
.section {
	padding-top: 10vh;
	min-height: 90vh;
	margin-bottom: 10vh;
	animation-name: fadeIn;
	animation-duration: 1s;
}
#base-layout { margin: auto; max-width: 800px; }
@keyframes fadeIn {
	from { opacity: 0; }
	to { opacity: 1; }
}
EOF

cat <<EOF > src/assets/css/components/hero.css
.hero {
	text-align: center;
	display: grid;
	place-items: center;
	min-height: 90vh;
	margin-bottom: 10vh;
}
.hero__title { font-size: 2em; margin-bottom: .3em; }
.hero__content { display: grid; place-items: center; }
EOF

cat <<EOF > src/assets/css/components/link.css
.link__button {
	background: linear-gradient(to bottom right, #00b0ff, #3b82f6);
	color: white;
	padding: 10px 20px;
	text-decoration: none;
	font-size: 16px;
	border-radius: 3px;
}
@media (hover: hover) {
	.link__button { cursor: pointer; }
	.link__button {
		transition: scale 0.2s ease-in-out, opacity 0.2s ease-in-out;
		opacity: 0.9;
	}
	.link__button:hover { scale: 1.1; opacity: 1; }
}
EOF
