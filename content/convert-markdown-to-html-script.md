+++
title = "Converting markdown files to HTML in Rust"
date = 2024-06-12
draft = true
+++

In my journey of learning Rust, I decided to pick a small Python program that converts markdown files to html + makes an index page for those files, and rewrite it in Rust.

To learn the syntax and also see if I could speed it up.

In this post, I’ll walk you through the script and how I run it in a GitHub Action to automatically generate a zip file of the HTML files and upload it as an artifact.

This is in the context of a new set of Python exercises I’m working on called Newbie Bites Part II. I wanted to convert the markdown files to HTML to make it easier to read and navigate for test users.

## The Rust script

```rust
use std::fs::{self, File};
use std::io::{self, Write};
use std::path::Path;
use std::ffi::OsStr;
use pulldown_cmark::{Parser, Options, html};
use clap::{App, Arg};
use glob::glob;

fn convert_md_to_html(md_files: Vec<String>, output_dir: &str) -> io::Result<()> {
    if !Path::new(output_dir).exists() {
        fs::create_dir(output_dir)?;
    }

    let mut index_content = String::from(
        "<html><head><title>Index of Newbies Bites Part II</title></head><body><h1>Index of Newbie Bites Part II</h1><ul>"
    );

    for md_file in md_files {
        let subdir_name = Path::new(&md_file)
            .parent()
            .and_then(Path::file_name)
            .and_then(OsStr::to_str)
            .unwrap_or("");

        if !subdir_name.chars().next().unwrap_or(' ').is_digit(10) {
            continue;
        }

        let html_file_name = format!("{}.html", subdir_name);
        let html_file_path = Path::new(output_dir).join(&html_file_name);

        let md_content = fs::read_to_string(&md_file)?;
        let mut html_content = String::new();
        let parser = Parser::new_ext(&md_content, Options::empty());
        html::push_html(&mut html_content, parser);

        let mut html_file = File::create(html_file_path)?;
        write!(
            html_file,
            "<html><head><title>{}</title></head><body>{}</body></html>",
            subdir_name, html_content
        )?;

        index_content.push_str(&format!(
            "<li><a href=\"{}\">{}</a></li>\n",
            html_file_name, subdir_name
        ));
    }

    index_content.push_str("</ul></body></html>");

    let index_file_path = Path::new(output_dir).join("index.html");
    let mut index_file = File::create(index_file_path)?;
    write!(index_file, "{}", index_content)?;

    println!("HTML pages and index generated in {}", output_dir);

    Ok(())
}

fn main() -> io::Result<()> {
    let matches = App::new("Markdown to HTML Converter")
        .version("1.0")
        .author("Your Name <your.email@example.com>")
        .about("Converts Markdown files to HTML and generates an index")
        .arg(
            Arg::new("directory")
                .short('d')
                .long("directory")
                .value_name("DIRECTORY")
                .help("Specifies the directory to search for Markdown files")
                .takes_value(true)
                .required(true),
        )
        .get_matches();

    let directory = matches.value_of("directory").unwrap();
    let pattern = format!("{}/[0-9][0-9]_*/*.md", directory);

    let md_files: Vec<String> = glob(&pattern)
        .expect("Failed to read glob pattern")
        .filter_map(Result::ok)
        .filter_map(|path| path.to_str().map(String::from))
        .collect();

    let output_dir = "html_pages";
    fs::create_dir_all(output_dir)?;

    convert_md_to_html(md_files, output_dir)
}
```

- The script uses `glob` to find all markdown files in a directory.
- It then converts each markdown file to HTML using `pulldown-cmark`.
- It creates an index page with links to each HTML file.
- The HTML files and index page are saved in an `html_pages` directory.
- The script uses `clap` for command-line argument parsing, which I showed in [my previous post](/).

## Running the script in a GitHub Action

I ended up using this script as part of another repo where I was working on mentioned Python exercises. I wanted to run this script in a GitHub Action to automatically generate the HTML files and upload them as an artifact.

Here’s the GitHub Action workflow file:

```yaml
name: Build and Upload HTML Pages and Exercise Zip

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable

      - name: Install dependencies
        run: sudo apt-get install -y zip unzip

      - name: Build and run Rust md to html script
        working-directory: ./md_to_html
        run: cargo run --release

      - name: Run zip_bites.sh script to zip up exercises
        run: ./zip_bites.sh

      - name: Extract both zip files
        run: |
          mkdir newbies2
          unzip md_to_html/bite_descriptions.zip -d newbies2/
          unzip newbies-partII.zip -d newbies2/

      - name: Create combined zip file
        run: |
          cd newbies2
          zip -r ../newbies_part2.zip .

      - name: Upload artifact
        uses: actions/upload-artifact@v2
        with:
          name: newbies-part2
          path: newbies_part2.zip
```

There are some additional steps in the workflow file to zip up the exercises and combine them with the HTML files, but the main part is running the Rust script using `cargo run --release` after setting up the Rust toolchain.

The script generates the HTML files and index page, which are then zipped up and uploaded as an artifact.

## Conclusion

I enjoyed rewriting the Python script in Rust and running it in a GitHub Action. The Rust script is concise and easy to understand. I also learned about release builds in Rust and how they can improve performance:

```bash
$ time cargo run -- --directory /Users/pybob/code/newbies-part2
...
cargo run -- --directory /Users/pybob/code/newbies-part2  0.04s user 0.03s system 26% cpu 0.292 total

$ cargo build --release

$ time ./target/release/md_to_html --directory /Users/pybob/code/newbies-part2
...
./target/release/md_to_html --directory /Users/pybob/code/newbies-part2  0.00s user 0.01s system 79% cpu 0.020 total
```

Although this is a small script, it taught me a lot about Rust. As I always say, the most you learn by building concrete things.

And usually you learn a thing or two more than you expected, in this case I also learned about GitHub Actions, how to run Rust scripts in them, and how to generate and upload artifacts.

I hope this post was helpful if you’re looking to convert markdown files to HTML in Rust or run Rust scripts in a GitHub Action. Let me know if you have any questions or suggestions!
