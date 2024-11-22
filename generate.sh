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

# Ask for the template engine
declare TEMPLATE_ENGINE

## Define the list options
echo "Template Engine: (you can change it later in the config file)"
PS3="Choose a template engine: "
template_engine_options=("nunjucks" "liquid")

## Display the select list and handle user choice
select opt in "${template_engine_options[@]}"; do
	case $opt in
		"nunjucks")
			TEMPLATE_ENGINE="nunjucks"
			break
			;;
		"liquid")
			TEMPLATE_ENGINE="liquid"
			break
			;;
		*) echo "Invalid option. Please try again." ;;
	esac
done

mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME"

# Initialize the project with the selected package manager
$PACKAGE_MANAGER init -y

echo "Installing Packages ..."
npm install --save-dev @11ty/eleventy # Install Eleventy

# Create project directories
mkdir "config"
mkdir "config/shortcodes"
mkdir "config/filters"
mkdir "config/collections"
mkdir "config/transforms"
mkdir "public"
mkdir "src"
mkdir "src/pages"
mkdir "src/assets"
mkdir "src/assets/css"
mkdir "src/assets/js"
mkdir "src/assets/images"
mkdir "src/assets/icons"
mkdir "src/assets/videos"
mkdir "src/components"
mkdir "src/components/buttons"
mkdir "src/data"
mkdir "src/layouts"

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
/** @param {import("@11ty/eleventy").UserConfig} eleventyConfig */
export default function (eleventyConfig) {
	eleventyConfig.setBrowserSyncConfig({ notify: true });

	// Reduce the verbosity of Eleventy's logs
	eleventyConfig.setQuietMode(true);

	// Copy files and directories to the output folder
	eleventyConfig.addPassthroughCopy("src/assets");

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

if [ "$TEMPLATE_ENGINE" == "nunjucks" ]; then 
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

	<!-- Styles -->
	<link rel="stylesheet" href="/assets/css/index.css">
</head>
<body>
	{{content | safe}}
</body>
</html>
EOF
fi

if [ "$TEMPLATE_ENGINE" == "nunjucks" ]; then
cat <<EOF > src/pages/index.njk
---
permalink: /
layout: base.njk
title: $PROJECT_NAME
author: AdryDev
description: Thanks for using my Eleventy project generator
---

<h1>{{title}}</h1>
EOF
fi

cat <<EOF > src/assets/css/index.css
:root {
	--font-size: 20px;
}

html, button, a, input {
	font-family: system-ui, sans-serif;
	font-size: var(--font-size);
}

@media (hover: hover) {
	button {
		cursor: pointer;
	}

	button:hover, a:hover {
		scale: 1.1;
	}
}
EOF
