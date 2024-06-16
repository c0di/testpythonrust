#!/bin/bash

# Prompt for the slug and title
read -p "Enter the slug (e.g., my-new-post): " slug
read -p "Enter the title: " title

# Get today's date
date=$(date +"%Y-%m-%d")

# Define the file path
file_path="content/${slug}.md"

# Create the new markdown file with front matter
cat <<EOL > $file_path
+++
title = "${title}"
date = ${date}
+++

EOL

echo "New post created at $file_path, opening in vim..."
vim $file_path
