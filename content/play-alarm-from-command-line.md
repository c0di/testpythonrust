+++
title = "A little alarm clock CLI app in Rust"
date = 2024-06-19
+++

The other day I pushed my second crate to crates.io. It's called [cli-alarm](https://crates.io/crates/cli-alarm) and it's a simple command line tool to play an alarm sound after a specified amount of time. It has an option to repeat the alarm at regular intervals as well.

## Why this project?

I created it because I wanted to play an alarm sound from the terminal as a reminder to take a break from the computer every hour, we progammers tend to sit for too long without moving which is really bad!

I had built this with Python before, but I wanted to try it with Rust this time. And that's actually a good way to learn a new language: by building something you've already built with another language. You already know what you want to build, so you can focus on the new language.

## How to use it?

Here's how you can use it:

```bash
cargo install cli-alarm

$ alarm -m 1
Alarm set to go off in 1 minutes.
...
plays sound once after 1 minute
...

$ alarm -m 1 -r
Recurring alarm set for every 1 minutes.
...
plays sound every minute
...
```

Curious how it got this alias? It's because of the `[[bin]]` section in the `Cargo.toml` file:

```toml
[[bin]]
name = "alarm"
path = "src/main.rs"
```

## Learnings

Code so far [here](https://github.com/bbelderbos/cli_alarm).

A couple of cool things I learned while building this:

- I used [clap](https://crates.io/crates/clap)  again for the CLI, great library, see also [this article](/command-line-apps-with-clap).

Like last time I am using attributes (derive macros) to define the CLI interface which is pretty concise:

```rust
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[arg(short = 'm', long, required = true)]
    minutes: u64,
    #[arg(short = 'r', long, default_value_t = false)]
    repeat: bool,
    #[arg(short, long, env = "ALARM_FILE")]
    file: Option<String>,
}
```

This time around I learned that clap also supports environment variables. Here I use it to set the alarm sound file if not provided as an argument.

- I used the [rodio](https://crates.io/crates/rodio) crate to play the alarm sound. It's a simple and easy-to-use audio library. Next step is to figure out how to play an audio message in addition to the alarm sound.

```rust
use rodio::{Decoder, OutputStream, source::Source};
...
let (_stream, stream_handle) = OutputStream::try_default().unwrap();
let file = File::open(audio_file).unwrap();
let source = Decoder::new(BufReader::new(file)).unwrap();
stream_handle.play_raw(source.convert_samples()).unwrap();
```

That's a lot of unwrapping, I should probably handle the errors more gracefully, still a lot to learn ...

- I used the [chrono](https://crates.io/crates/chrono) crate to print the current time in the log messages:

```rust
use chrono::Local;
...
println!("Playing alarm at {}", Local::now().format("%Y-%m-%d %H:%M:%S"));
```

Unlike Python's `datetime`, Rust doesn't have a built-in way to format dates and times, so you need to use a crate for that. This is a common pattern in Rust: the standard library is kept small and you use crates for additional functionality.

Other notable Python Standard Library packages you'll miss as a Pythonista for example are: `random`, `re`, `csv`, and `json`, but once you get used to just `cargo add`ing the crates you need, you hardly notice the difference.

- I used the [reqwest](https://crates.io/crates/reqwest) crate to download the default alarm sound. It's a simple and easy-to-use HTTP client, which I had already used for my _Pybites Search_ app, see [here](/pybites-search-in-rust).

- Where in Python you use `while True:` to create an infinite loop, in Rust you use `loop { ... }`.

- You can use `thread::sleep` to pause the execution of the program for a specified amount of time, which seems a fit for this app.

- Like Python, Rust has a `Path` struct (object) to work with file paths in a platform-independent way. I like structs in Rust, see also [here](/namedtuple-in-rust-struct).

- I use `cfg!(target_os = "windows")` to check if the OS is Windows. This is a built-in macro in Rust (in Python you'd use `sys.platform` or the `platform` module).

## Improvement ideas / next steps

Although this is not very good Rust code yet, I'm happy with the progress so far, specially having a working program that does something useful.

Some things to improve:

- Play an audio message as mentioned.

- Download the default alarm file to a sensible location or maybe a temp dir to not clutter the user's filesystem.

- Handle errors more gracefully, e.g. using `Result` instead of `unwrap` to better propagate errors.

- Modularize the code more to learn how to work with multiple files / modules.

- Linting and formatting (and automate this with a pre-commit hook as I tend to do with Python, see [here](https://www.youtube.com/watch?v=XFyLzr5Ehf0)).

- Add documentation (and host it somewhere, e.g. GitHub Pages).

- Add tests (although this app being heavy on IO and time-based, probably not the best app to start to learn about testing in Rust lol).

So good for a couple of more articles here ...

## Conclusion

The best way to learn is to build small projects! This way you learn to put things together which is an important skill in programming. You can also gradually increase the complexity of the projects you build.

I'm happy with the progress so far and how this way of learning Rust constantly challenges me to learn more about the language and tooling. I'm looking forward to diving into more advanced topics like error handling, testing, modularization, and more ...
