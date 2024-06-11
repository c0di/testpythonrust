+++
title = "Building a nice command-line interface with Clap"
date = 2024-06-11
+++

Yesterday I wanted to improve the command-line of Pybites Search that which was pretty primitive:

```bash
# new code is in v0.5.0
$ git checkout v0.4.0
$ cargo build --release
   Compiling pybites-search v0.4.0 (/Users/bbelderbos/code/rust/pybites-search)
   ...

# old usage message

√ pybites-search (tags/v0.4.0) $ ./target/release/psearch
Usage: search <search_term> [<content_type>] [--title-only]

# no help

?127 pybites-search (tags/v0.4.0) $ ./target/release/psearch --help
[bite] Using argparse to interface with a grocery cart
https://codechalleng.es/bites/58
...

# no version

√ pybites-search (tags/v0.4.0) $ ./target/release/psearch --version

# no multiple search terms

√ pybites-search (tags/v0.4.0) $ ./target/release/psearch grocery cart

# no short options

√ pybites-search (tags/v0.4.0) $ ./target/release/psearch grocery -t

# not clear that the 2nd arg here is the content type

√ pybites-search (tags/v0.4.0) $ ./target/release/psearch fastapi video
Pybites podcast 151 - Mastering Open Source: The Journey to FastAPI Expertise, One Issue at a Time
https://www.youtube.com/watch?v=pz2gzSgw7y8
...
```

I just read about [Clap](https://docs.rs/clap/latest/clap/) in the [Command-line Rust book](https://www.oreilly.com/library/view/command-line-rust/9781098109424/) and decided to give it a go.

Here is the new version:

```bash
√ pybites-search (main) $ cargo install pybites-search
...
     Ignored package `pybites-search v0.5.0` is already installed, use --force to override

# using the installed binary

√ pybites-search (main) $ which psearch
/Users/bbelderbos/.cargo/bin/psearch

# version and help are supported now

?1 pybites-search (main) $ psearch --version
psearch 0.5.0

√ pybites-search (main) $ psearch --help
A command-line search tool for Pybites content

Usage: psearch [OPTIONS] [SEARCH_TERMS]...

Arguments:
  [SEARCH_TERMS]...

Options:
  -c, --content-type <CONTENT_TYPE>
  -t, --title-only
  -h, --help                         Print help
  -V, --version                      Print version

# required search term argument

√ pybites-search (main) $ psearch
Error: At least one search term should be given.
A command-line search tool for Pybites content

Usage: psearch [OPTIONS] [SEARCH_TERMS]...

Arguments:
  [SEARCH_TERMS]...

Options:
  -c, --content-type <CONTENT_TYPE>
  -t, --title-only
  -h, --help                         Print help
  -V, --version                      Print version
```

The Error message actually renders red in the terminal for which I used the `colored` crate.

Continuing with the new version:

```bash
√ pybites-search (main) $ psearch fastapi
[article] Using Python (and FastAPI) to support PFAS research
https://pybit.es/articles/using-python-and-fastapi-to-support-pfas-research/
...

# search for podcasts only

√ pybites-search (main) $ psearch fastapi -c podcast
#160 - Unpacking Pydantic's Growth and the Launch of Logfire with Samuel Colvin
https://www.pybitespodcast.com/14997890/14997890-160-unpacking-pydantic-s-growth-and-the-launch-of-logfire-with-samuel-colvin
...

# search title only

√ pybites-search (main) $ psearch fastapi -t
[article] Using Python (and FastAPI) to support PFAS research
https://pybit.es/articles/using-python-and-fastapi-to-support-pfas-research/
...

# multiple search terms (joined and regex compiled)

√ pybites-search (main) $ psearch fastapi pfas -t
[article] Using Python (and FastAPI) to support PFAS research
https://pybit.es/articles/using-python-and-fastapi-to-support-pfas-research/
...

# short options combined: search only in titles and content type == video

√ pybites-search (main) $ psearch fastapi pfas -t -c video
Pybites podcast 122 - Using Python (and FastAPI) to support PFAS research
https://www.youtube.com/watch?v=c5EtLNhrnH0
```

## Clap code

The code change was [relatively small](https://github.com/bbelderbos/pybites-search/commit/78cff36be5be028d19484349a8771a859e9daf81):

```rust
#[derive(Parser)]
#[command(name = "psearch", version, about)]
struct Cli {
    search_terms: Vec<String>,

    #[arg(short = 'c', long = "content-type")]
    content_type: Option<String>,

    #[arg(short = 't', long = "title-only")]
    title_only: bool,
}

...
...

#[tokio::main]
 async fn main() -> Result<(), Box<dyn std::error::Error>> {
     let cli = Cli::parse();

     if cli.search_terms.is_empty() {
         eprintln!("{}", "Error: At least one search term should be given.".red());
         Cli::command().print_help()?;
         std::process::exit(1);
     }

     let search_term = cli.search_terms.iter().map(|term| regex::escape(term)).collect::<Vec<_>>().join(".*");
     let content_type = cli.content_type.as_deref();
     let title_only = cli.title_only;

     ...
     ...

     search_items(&items, &search_term, content_type, title_only);
```

- I defined a struct `Cli` with the fields I needed ([related article](/namedtuple-in-rust-struct)).
- I used the `#[arg]` attribute to define the short and long options.
- I used the `#[command]` attribute to define the name, version, and about, which are inferred from the `Cargo.toml` file.
- In the main function, I used `Cli::parse()` to parse the command-line arguments.
- I checked if the search terms are empty and printed an error message if they are. It's best practice to print the error message to `stderr` (using `eprintln`) and exit the script with a non-zero status code (Unix convention).
- I used the `regex` crate to make a regex pattern from the search terms. I had to escape the search terms because they could contain special characters. I used the `regex::escape` function for this.
- I needed the `as_deref` method to convert the `Option<String>` to an `Option<&str>`. This is useful because I wanted to pass the content type to the `search_items` function, which accepts an `Option<&str>`. I still need to get used to the ownership and borrowing rules in Rust, but [I am getting there](/ownership-and-borrowing). It will become more intuitive with more practice ...
- Lastly I passed the parsed arguments to the `search_items` function.

This looks pretty clean and the pleasant way of defining CLI interfaces this way reminds me of Python's `Typer` library.

Typer also uses type annotations (and other beautiful abstractions) to make it easy to define CLI interfaces.

Here is an example for comparison:

```python
import typer  # pip install typer

app = typer.Typer()

@app.command()
def psearch(
    search_terms: list[str],
    content_type: str = typer.Option(None, "--content-type", "-c", help="The type of content to search for"),
    title_only: bool = typer.Option(False, "--title-only", "-t", help="Search only in titles")
):
    search_term = ".*".join(search_terms)
    # ... rest of the implementation ...
```

## Conclusion

I am happy with the new 0.5.0 version of Pybites Search, which thanks to Clap has a much nicer command-line interface.

Clap reminds me of Typer in Python, which makes it easy to define CLI interfaces using type annotations.

I will surely use Clap in future command-line apps, it's a great library to work with.
