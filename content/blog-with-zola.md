+++
title = "How to blog with Zola, a Rust-based static site generator"
date = 2024-06-02
+++

Here is how I am running this blog using Zola.

## What is Zola?

> Zola is a static site generator (SSG), similar to Hugo, Pelican, and Jekyll (for a comprehensive list of SSGs, please see Jamstack). It is written in Rust and uses the Tera template engine, which is similar to Jinja2, Django templates, Liquid, and Twig. [source](https://www.getzola.org/documentation/getting-started/overview/#markdown-content)

## Installation

```bash
brew install zola  # cargo would not work for me
zola init .  # I had a repo, else: zola init myblog
# follow the instructions
# add a theme (https://www.getzola.org/themes/)
git submodule add https://github.com/pawroman/zola-theme-terminimal themes/terminimal
zola create post "My First Post"
```

Maybe something more but these were the main steps.

## Configuration

This is my `config.toml` so far:

```toml
base_url = "https://bobbelderbos.com/rust-blog"
title = "A Pythonista Learning Rust"
description = "Documenting the journey of a Pythonista learning Rust with bite-sized posts."
theme = "terminimal"
compile_sass = true
build_search_index = false

[markdown]
highlight_code = true

[extra]
logo_text = "A Pythonista Learning Rust"
logo_home_link = "/rust-blog"
```

- `base_url` is important for the theme to work correctly (I had https://example.com before and the theme styles were not applied)
- `theme` is the name of the theme folder in `themes/`
- I think `compile_sass` needs to be `true` for the theme to work
- the `logo_text` and `logo_home_link` are specific to the theme I use

## Writing

For each new post, you create a new markdown file in the `content` folder. The file name should be the title of the post with dashes instead of spaces.

The file should start with a TOML front matter block, which is the metadata for the post. Here is an example:

```markdown
+++
title = "How to set up Zola"
date = 2024-06-02
+++
```

Later I can add tags, categories, etc.

Then write the content in markdown below this front matter block.

To make a new post I made a quick shell script:

```bash
$ cat new_post.sh
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

echo "New post created at $file_path"
```

## Building

```bash
zola build
```

This will generate the static site in the `public` folder.

Then run a local server to preview the site:

```bash
zola serve
```

For convenience I made a Makefile with some aliases including a combined `dev` command:

```makefile
.PHONY: build serve dev clean

build:
	zola build

serve:
	zola serve

dev:
	zola build && zola serve

clean:
	rm -rf public
```

## Deployment

I use GitHub Actions to build and deploy the site (so nice!)

Here is the workflow file (`.github/workflows/deploy.yml`):

```yaml
# On every push this script is executed
on: push
name: Build and deploy GH Pages
jobs:
  build:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout main
        uses: actions/checkout@v4
      - name: Build and deploy
        uses: shalzz/zola-deploy-action@v0.18.0
        env:
          PAGES_BRANCH: gh-pages
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This workflow will build the site and push the changes to the `gh-pages` branch upon every push to the `main` branch.

- Interestingly ChatGPT overcomplicated this, but I found in Zola's docs that you can actually use shalzz/zola-deploy-action. I only had to update from 0.17.x to 0.18.x to make it work.

- You don't have to setup the `secrets.GITHUB_TOKEN` as it is a default secret provided by GitHub if you use your action for the same repository.

- I did have to update the "Workflow permissions" under GitHub's repo Settings > Actions, to enable "Read and write permissions" (_Workflows have read and write permissions in the repository for all scopes._), otherwise the action would fail.

- I also had to set "Build and deployment" to "Deploy form a branch" (under Settings > Pages) and set the branch to `gh-pages` + `/ (root)`.

## Custom domain

I found out that my main GitHub pages username site was already using a custom domain, so this new blog redirects to a subfolder on that domain, see setting:

```toml
base_url = "https://bobbelderbos.com/rust-blog"
```

I need to figure out how to use a custom domain for this blog but that's for later concern.

One thing you'd need to do to make your site work with a custom domain is to set up a `CNAME` file in the `public` folder with the domain name.

## Conclusion

Zola is a great SSG so far, I am happy with the setup. I like the simplicity of the tool and the speed of the generated site (Rust 📈 -> `zola build` -> `Done in 91ms.` for me) and automatic deployment with GitHub Actions. 😍

If you're looking for a Rust based SSG solution I hope this post will help you with the setup.

If you have any questions, reach out to me on X [@bbelderbos](https://x.com/bbelderbos).
