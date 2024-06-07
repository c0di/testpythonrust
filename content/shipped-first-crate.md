+++
title = "How to ship code to crates.io and automate it with GitHub Actions"
date = 2024-06-06
+++

In the previous post, I made a little Rust script to search Pybites content. In this post I share how I deployed this _crate_ (the Rust term for a package) to crates.io (the Rust package index). 🎉

Next I will show you how I streamlined it using GitHub Actions. 🚀

## Setup

First you need to make an account on [crates.io](https://crates.io/), confirm your email, and create an API token. You can find this under your account settings.

Next you login from the command line:

```bash
$ cargo login your_token
```

## Publishing

Then you can publish your crate, from your project directory:

```bash
$ cargo publish
   Uploading pybites-search v0.1.0 (/Users/bbelderbos/code/rust/pybites-search)
    Uploaded pybites-search v0.1.0 to registry `crates-io`
note: waiting for `pybites-search v0.1.0` to be available at registry `crates-io`.
You may press ctrl-c to skip waiting; the crate should be available shortly.
   Published pybites-search v0.1.0 at registry `crates-io`
...

It takes the version from your `Cargo.toml` file. If you want to publish a new version, you need to update this file.

## Installing the crate

As a user you can now install your crate:

```bash
$ cargo install pybites-search
    Updating crates.io index
  Downloaded pybites-search v0.1.0
...
...
  Installing /Users/bbelderbos/.cargo/bin/psearch
   Installed package `pybites-search v0.1.0` (executable `psearch`)
```

I added a `[[bin]]` section to my `Cargo.toml` file, so the binary is installed as `psearch`:

```toml
[[bin]]
name = "psearch"
path = "src/main.rs"
```

Now when people install the crate, they can run `psearch` from the command line. 🏃

```bash
$ psearch
Usage: search <search_term> [<content_type>] [--title-only]
```

## Automating with GitHub Actions

Of course manually pushing to crates.io is not ideal. You can automate this with GitHub Actions. Here is the workflow I use:

```yaml
name: Release to crates.io

on:
  push:
    tags:
      - 'v*.*.*'  # Matches tags like v1.0.0, v2.1.3, etc.

jobs:
  release:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
          override: true

      - name: Cache Cargo registry
        uses: actions/cache@v2
        with:
          path: ~/.cargo/registry
          key: ${{ runner.os }}-cargo-registry
          restore-keys: |
            ${{ runner.os }}-cargo-registry

      - name: Cache Cargo index
        uses: actions/cache@v2
        with:
          path: ~/.cargo/git
          key: ${{ runner.os }}-cargo-index
          restore-keys: |
            ${{ runner.os }}-cargo-index

      - name: Build the project
        run: cargo build --release

      - name: Publish to crates.io
        env:
          CARGO_REGISTRY_TOKEN: ${{ secrets.CARGO_REGISTRY_TOKEN }}
        run: cargo publish
```

This workflow triggers on a tag push, so you can tag your releases with `vX.Y.Z` and it will automatically publish your crate to crates.io (when you do a `git push --tags`) 🏷️

2 simple steps to publish your crate:
- Update your `Cargo.toml` file with the new version.
- Tag your release with `vX.Y.Z` and push it to GitHub: `git tag v0.2.0 && git push --tags`

Also note that you'll need the `CARGO_REGISTRY_TOKEN` secret for this workflow to work. You can add this in your GitHub repository settings under `Settings` -> `Secrets` -> `New repository secret`. 🤫

---

That's it! Now you can easily share your Rust projects with the world. 🚀

And if you happen to follow my Python work, next time install the `pybites-search` crate and run `psearch` from the command line. 🐍 📈
