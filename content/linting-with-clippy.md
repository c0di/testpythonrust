+++
title = "Linting your Rust code with Clippy"
date = 2024-06-22
+++

In Python you often use flake8, pyflakes and/or ruff to lint your code. In Rust, you can use Clippy.

Clippy is a collection of lints to catch common mistakes and improve your Rust code. Let's try it out on [Pybites Search](/pybites-search-in-rust).

## Installing and running Clippy

First make sure you install Clippy:

```bash
$ rustup component add clippy
```

Next you can invoke it in any project through Cargo:

```bash
$ cargo clippy
```

Running this in the Pybites search project we get:

```bash
√ search (main) $ cargo clippy
    Checking pybites-search v0.6.0 (/Users/pybob/code/rust/search)
warning: writing `&Vec` instead of `&[_]` involves a new object where a slice will do
   --> src/main.rs:108:25
    |
108 | fn save_to_cache(items: &Vec<Item>) -> Result<(), Box<dyn std::error::Error>> {
    |                         ^^^^^^^^^^
    |
    = help: for further information visit https://rust-lang.github.io/rust-clippy/master/index.html#ptr_arg
    = note: `#[warn(clippy::ptr_arg)]` on by default
help: change this to
    |
108 ~ fn save_to_cache(items: &[Item]) -> Result<(), Box<dyn std::error::Error>> {
109 |     let cache_path = get_cache_file_path();
110 |     let cache_data = CacheData {
111 |         timestamp: SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs(),
112 ~         items: items.to_owned(),
    |

warning: `pybites-search` (bin "psearch") generated 1 warning
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.16s
```

The warning is about using `&Vec` instead of `&[_]`. The fix is to change the function signature to `fn save_to_cache(items: &[Item]) -> Result<(), Box<dyn std::error::Error>> {` (and `items.clone()` to `items.to_vec()` in the function body).

It's useful to check out [the associated link](https://rust-lang.github.io/rust-clippy/master/index.html#/ptr_arg) where we can read about the why:

> Requiring the argument to be of the specific size makes the function less useful for no benefit; slices in the form of &[T] or &str usually suffice and can be obtained from other types, too.

And a suggested fix:

```
fn foo(&Vec<u32>) { .. }

// use instead:

fn foo(&[u32]) { .. }
```

Note this is a warning, not an error, you can still compile and run your code.

But it's good practice to fix these warnings to improve the quality of your code. 🦀 🧹

## Running Clippy on another project

Let's run it on [the resize-images project](/resizing-images):

```bash
warning: the borrowed expression implements the required traits
  --> src/main.rs:54:105
   |
54 |                 let output_path = Path::new(&output_dir).join(path.file_stem().unwrap()).with_extension(&extension);
   |                                                                                                         ^^^^^^^^^^ help: change this to: `extension`
   |
   = help: for further information visit https://rust-lang.github.io/rust-clippy/master/index.html#needless_borrows_for_generic_args
   = note: `#[warn(clippy::needless_borrows_for_generic_args)]` on by default

warning: `resize-images` (bin "resize-images") generated 1 warning (run `cargo clippy --fix --bin "resize-images"` to apply 1 suggestion)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 6.81s
```

This time it's about a needless borrow for generic args. The fix is to remove the `&` from `with_extension(&extension)`.

Again [the help link](https://rust-lang.github.io/rust-clippy/master/index.html#/needless_borrows_for_generic_args) explains why:

> Suggests that the receiver of the expression borrows the expression.

And shows an example + fix:

```rust
fn f(_: impl AsRef<str>) {}

let x = "foo";
f(&x);

// use instead:
fn f(_: impl AsRef<str>) {}

let x = "foo";
f(x);
```

## Auto-fixing Clippy warnings

You can also auto-fix Clippy warnings with `cargo clippy --fix`. This will apply the suggestions it has for you. It's a great way to quickly clean up your code.

```bash
$ cargo clippy --fix
```

{{ image(src="/images/clippy-autofix.png", alt="Example of clippy autofixing an error", style="border-radius: 8px;") }}

## Running Clippy as part of pre-commit

You can run Clippy as part of your pre-commit hooks. This way you can't commit code with Clippy warnings.

_If you're new to pre-commit, check out my video [here](https://www.youtube.com/watch?v=XFyLzr5Ehf0)_

To do this, install the [pre-commit](https://pre-commit.com/) tool and add the following to a `.pre-commit-config.yaml` file in your project (taken from [here](https://raw.githubusercontent.com/doublify/pre-commit-rust/master/.pre-commit-hooks.yaml)):

```yaml
repos:
  - repo: https://github.com/doublify/pre-commit-rust
    rev: v1.0
    hooks:
    - id: fmt
      name: fmt
      description: Format files with cargo fmt.
      entry: cargo fmt
      language: system
      types: [rust]
      args: ["--"]
    - id: cargo-check
      name: cargo check
      description: Check the package for errors.
      entry: cargo check
      language: system
      types: [rust]
      pass_filenames: false
    - id: clippy
      name: clippy
      description: Lint rust sources
      entry: cargo clippy
      language: system
      args: ["--", "-D", "warnings"]
      types: [rust]
      pass_filenames: false
```

Apart from clippy, this also includes `fmt` and `cargo check` hooks.

Then install the pre-commit hooks:

```bash
$ pre-commit install
```

Now every time you commit code, Clippy + friends will run and you can't commit code with warnings. 🚫

To run it on all files retroactively in your project:

```bash
$ pre-commit run --all-files
```

I just did that and [see here the result](https://github.com/bbelderbos/pybites-search/commit/96193766a101dd592fabe0d959167c21e6f9cec5).

Imports are nicely ordered and the code is better formatted. This reminds me a lot of `isort` and `black` in Python, where Clippy is more like `flake8` and `pyflakes` 🦀 🐍 😍

## Conclusion

Clippy is a great tool to help you write better Rust code. It's easy to install and run. You can even auto-fix warnings. 💪 📈

There are many more configuration options, check out the [Clippy lints](https://rust-lang.github.io/rust-clippy/master/index.html) and [its GitHub repo](https://github.com/rust-lang/rust-clippy) for more info.

It's also convenient to run it as part of pre-commit. This way you can't commit code with warnings. It's a great way to keep your code clean and readable. 🦀 🧹
