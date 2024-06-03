+++
title = "Rust Cargo is a lot like Python Poetry 😍"
date = 2024-06-03
+++

When you start working in Rust, you'll quickly learn about Cargo and love it!

It's a package manager and build system that helps you manage your Rust projects.

Coming from Python, I found it very similar to Poetry, [which is a great tool as well](https://www.youtube.com/watch?v=G-OAVLBFxbw)).

## Features

- Dependency management: `Cargo.toml`
- Virtual environments: `Cargo.toml` and `Cargo.lock`
- Lock files: `Cargo.lock`
- Build system: `cargo build`, `cargo run`, `cargo test`, `cargo doc`
- Publishing to crates.io: `cargo publish`

## Cargo vs Poetry Commands Cheat Sheet

Here's a quick comparison of some common commands in Cargo and Poetry. Notice how similar they are! 😎

| Action                  | Cargo Command                        | Poetry Command                         |
|-------------------------|--------------------------------------|----------------------------------------|
| Initialize a project    | `cargo new project_name`             | `poetry new project_name`              |
| Initialize in current dir | `cargo init`                       | `poetry init`                          |
| Add a dependency        | `cargo add dependency_name`          | `poetry add dependency_name`           |
| Remove a dependency     | `cargo remove dependency_name`       | `poetry remove dependency_name`        |
| Update dependencies     | `cargo update`                       | `poetry update`                        |
| List dependencies       | `cargo tree`                         | `poetry show --tree`                   |
| Build the project       | `cargo build`                        | `poetry build`                         |
| Run the project         | `cargo run`                          | `poetry run python your_script.py`     |
| Run tests               | `cargo test`                         | `poetry run pytest` (requires pytest)  |
| Generate documentation  | `cargo doc`                          | Not built-in, use a tool liked Sphinx  |
| Build release binary    | `cargo build --release`              | `poetry build` (for packaging)         |
| Run release binary      | `cargo run --release`                | Not directly supported                 |
| Format code             | `cargo fmt`                          | `poetry run black .` (requires black)  |
| Lint code               | `cargo clippy`                       | `poetry run flake8 .` (requires flake8) |

One cool thing I noticed is that generating docs and testing is built-in in Cargo, while in Python you need to use external tools like Sphinx and pytest.

## Conclusion

If you love Poetry, you'll love Cargo too! They are both great tools for managing your projects and dependencies.

Funny enough, in Python I actually stopped using `poetry` in favor of `venv` and `pip` because I felt this was faster and all I needed. But in Rust so far I feel Cargo is more integrated and I am using it more (well, don't have much choice, have I? 😅).

I think it's mainly because I don't have to deal with virtual environments in Rust, which is a big plus. Also it infers the binary name from the project name, which is nice. 📈

This post was just to quickly compare Cargo and Poetry and show you how similar they are. I hope you found it helpful! 😊

I am sure I will do more in-depth posts on Cargo in the future. Stay tuned! 🚀

Hit me up on X [@bbelderbos](https://x.com/bbelderbos) if you have any questions or feedback! 👋
