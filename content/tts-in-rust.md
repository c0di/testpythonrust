+++
title = "Alarm clock part II - text to speech"
date = 2024-06-21
+++

I tweaked [my alarm clock app](/play-alarm-from-command-line) today to add text-to-speech (TTS).

I started with the obvious choice: [tts crate](https://crates.io/crates/tts), but it did not work on my Mac, no audio.

So I got a bit creative and ended up with this function:

```rust
pub fn speak_message(message: &str) -> Result<(), Box<dyn std::error::Error>> {
    if cfg!(target_os = "macos") {
        Command::new("say")
            .arg(message)
            .output()
            .expect("Failed to execute say command on macOS");
    } else if cfg!(target_os = "windows") {
        Command::new("powershell")
            .arg("-Command")
            .arg(&format!("Add-Type –TypeDefinition \"using System.Speech; var synth = new Speech.Synthesis.SpeechSynthesizer(); synth.Speak('{}');\"", message))
            .output()
            .expect("Failed to execute PowerShell TTS on Windows");
    } else if cfg!(target_os = "linux") {
        Command::new("espeak")
            .arg(message)
            .output()
            .expect("Failed to execute espeak on Linux");
    } else {
        eprintln!("Unsupported operating system for TTS");
    }
    Ok(())
}
```

- On macOS, it uses the `say` command (built-in / ships by default with macOS). For Windows, it uses PowerShell to speak the message. And on Linux, it uses `espeak`. Note that I mostly care about a Mac solution right now, so I have not tested the Windows + Linux ones yet ...

- `cfg!(target_os = "...")` is a Rust macro that checks the target operating system (similar how you can use the `platform` module in Python). It is a compile-time check, so the code for other operating systems will not be included in the binary.

- The `expect` method is used to panic if the command fails. I probably should handle the error more gracefully, I will improve this later.

- `println!` prints to standard output. To print to standard error, you can use `eprintln!` and it's good practice to use it for error messages.

- The return type is `Result<(), Box<dyn std::error::Error>>` to indicate that the function can return an error. The `Box<dyn std::error::Error>` is a trait object that can hold any type that implements the `Error` trait. I am seeing this pattern quite a bit in Rust code.

The message to speak is a new (Clap) command-line argument:

```rust
const DEFAULT_MESSAGE: &str = "You set an alarm, time is up!";
...

/// Message to speak instead of playing an audio file
#[arg(short = 'M', long, required = true, default_value = DEFAULT_MESSAGE)]
message: String,
```

And I play it a couple of times, another new command-line argument:

```rust
const TIMES_TO_PLAY: usize = 3;
...

/// Times to play the alarm sound
#[arg(short, long, default_value_t = TIMES_TO_PLAY)]
times: usize,
```

I added this loop to play the message multiple times:

```rust
for _ in 0..args.times {
    speak_message(&args.message).unwrap();
}
```

The nice thing about `usize` (and typing in general) is that it excludes invalid options.

For example, if the user enters a negative number, the program will not compile. The `usize` type is an unsigned integer, meaning that it cannot be negative.

The `0..N` construct is similar to `range` in Python, where the upper bound is also exclusive. Also in both languages, the lower bound is inclusive. To make the upper bound inclusive, you can use `0..=N` in Rust. So I could also write `1..=args.times` to play the message `args.times` times.

You can also use `std::iter::repeat` here I learned:

```rust
std::iter::repeat(()).take(args.times).for_each(|_| {
    speak_message(&args.message).unwrap();
});
```

But that seems more verbose and complicated than the more concise and readable `for` loop so I stuck with that.

So running the program like this it will say "Wake up" 3 times after 3 seconds:

```bash
$ cargo run -- -M "Wake up" -s 3
# says "Wake up" three times
```

Why 3 times? By not specifying the number of times, it will default to 3 (see the `TIMES_TO_PLAY` constant).

## Conclusion

I like the current 0.3.0 (available on crates.io) better than the previous ones, where I was playing an alarm file. This had the added complexity of downloading and playing an audio file.

The text-to-speech feature is less code relatively and actually tells the user what the alarm is about. The only thing is compatibility, I need to test it on Windows and Linux still ...

As usual, by building things I've learned more about interesting Rust features and idioms. I am also getting more comfortable with the language and its ecosystem. 😍 📈

I will probably use this project to write some more posts about 1. code structuring (modularizing your code), 2. testing and 3. documentation. Stay tuned! 🚀
