+++
title = "Use rust-analyzer + ALE to show errors as you code in Rust"
date = 2024-06-16
+++

The more advanced you become as a developer the more you realize that the speed of coding is not just about language syntax or typing, it's as much about the tools and techniques you use.

One of my best Python coding setup tweaks has been showing errors upon saving files, for which I use [this plugin](https://gist.github.com/kyokley/0d7bb03eede831bea3fa). This speeds up development significantly! 😍 📈

I wanted to do the same for Rust coding, specially because there is, compared to Python, an extra compilation step in Rust.

In this article I'll show you how I have set it up ...

_Note that I use Vim as my text editor and Mac as my operating system. I hope most of the setup is easily transferable to other text editors and operating systems. Or that at least it gets you thinking about how you can speed up your coding workflow._ 💡

## Install rust-analyzer

First, you need to install `rust-analyzer`. I did this with `brew`:

```bash
brew install rust-analyzer
```

## Install ALE, the Asynchronous Lint Engine

I use [Vundle](https://github.com/VundleVim/Vundle.vim) as my Vim plugin manager so I added this plugin to my `.vimrc`:

```vim
Plugin 'dense-analysis/ale'
```

And installed it with:

```vim
:PluginInstall
```

## Setup in `.vimrc`

I added the following code to my `.vimrc`. I learned I can use ALE for Python as well in one go :)

```vim
" ALE Configuration
" Enable ALE for Rust and Python
let g:ale_linters = {
    \   'rust': ['analyzer'],
    \   'python': ['pyflakes'],
    \}

" Only lint on save, not on text changed or insert leave
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 1

" Ensure rust-analyzer is installed and in your PATH
let g:ale_rust_analyzer_executable = 'rust-analyzer'
```

1. The `ale_linters` variable is set to use `rust-analyzer` for Rust files and `pyflakes` for Python files. I installed `pyflakes` with [`pipx`](https://www.youtube.com/watch?v=xvCShK1Bqxk). By the way, this might become a replacement for the Python plugin I mentioned in the beginning, not sure yet ...

2. The `ale_lint_on_save` variable is set to `1` to check the syntax on save.

3. The `ale_rust_analyzer_executable` variable is set to `rust-analyzer` to ensure that `rust-analyzer` is installed and in your PATH.

4. The `ale_lint_on_text_changed`, `ale_lint_on_insert_leave`, and `ale_lint_on_enter` variables are set to `never`, `0`, and `0` respectively to prevent linting on text changed, insert leave, and enter. Tweak these settings as you see fit.

Playing around with this plugin I added some more settings to my `.vimrc`:

```vim
" Enable ALE's virtual text feature for inline messages
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_prefix = '⚠ '

" Customize the ALE sign column for better readability
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'

" Enable ALE to use the quickfix list
let g:ale_open_list = 1
let g:ale_set_quickfix = 1

" Enable line wrapping only in quickfix and loclist buffers
autocmd FileType qf setlocal wrap linebreak
autocmd FileType loclist setlocal wrap linebreak

" Enable ALE's floating window preview feature to show detailed error messages
let g:ale_detail_to_floating_preview = 1
```

Specially the _quickfix_ list is useful when errors are not fully visible in the editor window. It also keeps them all in one place so it's easier to see them all at once.

## See it in action

Here is some code to try this on:

```rust
mod data;

use tokio;
use crate::data::fetch_data;

#[tokio::main]
async fn main() {
    let data = fetch_data().await.unwrap();
    println!("{:#?}", data);
}
```

Let's make a couple of errors and see the ALE checker in action 💡 🚀

1. changing `mod data;` to `mod data`

```rust
E mod data // E: Syntax Error: expected `;` or `{`
```

2. `data` to `data2` which is not defined

```rust
E     println!("{:#?}", data2); // E: cannot find value `data2` in this scope
```

3. removing a `use` statement

```rust
W use tokio; // W: consider importing this function: `use crate::data::fetch_data; `
...
E     let data = fetch_data().await.unwrap(); // E: cannot find function `fetch_data` in this scope not found in this sc
```

4. removing the `#[tokio::main]` attribute

```rust
W use tokio; // W: remove the whole `use` item
E async fn main() { // E: `main` function is not allowed to be `async` `main` function is not allowed to be `async`
```

5. removing the `async` keyword

```rust
E fn main() { // E: the `async` keyword is missing from the function declaration
```

It also works well in Python 😎 🎉

```python
...
E print(c) # E: undefined name 'c'
```

And:

```python
E print(a # E: '(' was never closed
```

## Complementing with GitHub Copilot

If an error is not 100% you can always add a "question comment" like this to get more suggestions. Here for example I purposely removed the `await` method from the `fetch_data` function:

```rust
...
async fn main() {
    E     let data = fetch_data().unwrap(); // E: no method named `unwrap` found for opaque type `impl Future<Output = Resul…
    println!("{:#?}", data);
}

# q: why does the above fail?
```

GitHub Copilot will suggest the following answer right below the question:

```rust
# a: the fetch_data function is async, so it returns a Future, not the data itself
```

This is a useful technique and faster, because I can stay in Vim rather than making the round trip to ChatGPT. 🤖 🚀

---
Hope this helps you speed up your Rust coding! 🦀

Either as a Vim user or not, you can use the same principle to speed up your coding in your favorite text editor.

Or at least get into the mindset of speeding up your coding through efficient tools and techniques. 💪 📈

If you want to learn more about my Vim setup overall, check out this video: [Supercharge Your Vim Workflow: Essential Tips and Plugins for Efficiency](https://www.youtube.com/watch?v=B9tZyFXr1Yw). 🎥 🚀
