+++
title = "Rustlings 😍 - Small exercises to get you used to reading + writing Rust 🦀"
date = 2024-06-10
+++

I have been going through the [Rustlings exercises](https://github.com/rust-lang/rustlings) and I have found them to be a great way to practice Rust. 🔥

As I said in [a previous post](/pybites-search-in-rust), it's all about pratice. 💡

Rust is also a language that requires some time to get used to, specially when coming from a dynamic language like Python. All of a sudden you have to get used to the strictness of the compiler and the ownership system.

Reading books like [The Rust Programming Language](https://doc.rust-lang.org/book/) and [Programming Rust 2nd ed](https://www.oreilly.com/library/view/programming-rust-2nd/9781492052586/) (both fantastic!), a lot might not stick until you put it into practice, there is a lot to take in!

That's where Rustlings comes in. It's a set of small exercises that you can work through to reinforce what you've learned.

Not only will you write and fix code, you'll also read a lot of code forcing yourself to understand what it does.

And you'll get to see a lot of compiler error messages in the process. Rust is strict and unforgiving so the sooner you get used to that the better.

## How it works

Just follow [the README](https://github.com/rust-lang/rustlings), the only thing I had to do on my Mac was:

```bash
curl -L https://raw.githubusercontent.com/rust-lang/rustlings/main/install.sh | bash
```

And then `cd` into the `rustlings` directory.

## Watch mode

There are various ways you can do the exercises, but I really liked this workflow:

- In the first terminal window, run `rustlings watch`.

- In the second terminal window, open the `exercises` directory in your favorite editor (in my case Vim + fzf for quick file search) and start coding, as soon as you save a file, `watch` will pick it up and the corresponding tests will run.

Toggling between the two terminal windows writing code + seeing the tests run + reading the error messages, felt like learning on steroids. 💪

## Conclusion

I'm through ~80% of the 96 exercises and I can say that I've learned a lot: ownership, borrowing, lifetimes, pattern matching, enums, structs, traits, generics, iterators, error handling, writing tests, it's all there! 🚀

I highly recommend giving it a go, it's a great tool to really solidify what you've learned from reading books and watching videos. You might be surprised how little actually has stuck from any passive learning you've done. 🤯

This effective learning also happens when you try to build smaller projects, but _Rustlings_ is a great way to reinforce the basics and fundamental concepts. 📈
