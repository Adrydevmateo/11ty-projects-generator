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

mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

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

# Initialize the project with the selected package manager
$PACKAGE_MANAGER init -y

# Create project directories
mkdir "config"
mkdir "public"
mkdir "src"
mkdir "src/assets"

# Create initial files
if [ "$TEMPLATE_ENGINE" == "nunjucks" ]; then
cat <<EOF > src/index.njk
---
title: $PROJECT_NAME
---

<h1>{{title}}</h1>
EOF
fi
