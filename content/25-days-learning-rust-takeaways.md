+++
title = "25 days of learning Rust: what worked + takeaways"
date = 2024-06-25
+++

I have been having a blast learning Rust, now 25 days in a row! 🎉

## What has worked

### 1. Start Building Early

Do a bit of initial study, but leave the theory soon and start building from day one (_fake it before you make it_).

Back up your practical experience with reading. What kept it fun for me was converting Pybites tools, written in Python, to Rust.

### 2. Use AI Tools

Use AI for both coding and explaining concepts.

It's like having a dedicated research assistant and is much faster than googling or using Stack Overflow. Combined with the first strategy, you are knee-deep in code quickly, which boosts your learning.

### 3. Blog About Your Journey

Blogging forces you to understand concepts better and share your insights. The first strategy ensures you always have content to talk about, and using AI tools (2) you can do this faster (and better).

I prefer to use:
- ChatGPT for research
- Co-pilot to write faster

And I have been consistent: 25 days in, 25 posts on this blog. 🎉

By the way, by blogging regularly you force yourself to put content out there, which also helps with the impostor syndrome that comes with learning anything new. 💡

### 4. Find an Accountability Partner

Find someone who is further along with the language to guide and encourage you.

A special shout-out to [Jim Hodapp](https://x.com/jhodapp?lang=en), who has been instrumental in clarifying doubts and supporting my journey.

## Some wins / takeaways

### 1. Re-thinking things in Python

Rust’s emphasis on safety and correctness through its strict compiler checks and ownership system has highlighted the areas where Python’s flexibility could potentially lead to bugs and less maintainable code.

For example, with the Rust learning experience so far, I am even more eager to use type hints in Python or add stricter validation with Pydantic. These tools add a layer of safety and correctness to Python code, which learning Rust made me more aware of and appreciate more.

Similarly when it comes to mutability, Rust's default immutability makes you reflect what that can mean for your Python code.

So a side effect of learning Rust is that I will become a better Python programmer. 🐍

### 2. Learning Rust is a journey: it's hard, but rewarding

Rust is a complex language, and the learning curve is steep. But the challenge is what makes it fun and rewarding. 🚀

I think the most important thing is to not take it all in at once. Break it down into small, manageable chunks, and build something at every step, even if it's small. 💡

Then gradually expose yourself to more advanced concepts, but be realistic with your timelines.

I have been mostly doing scripting so far and that's fine, at least I got quite some code written, [and even shipped](/shipped-first-crate).

And there is something special about the compiler. 😍 It's strict and unforgiving, but it also becomes your best friend.

The feeling of accomplishment when you get the code to compile and run is awesome, specially knowing that that code is probably safe and performant. 🎉

### 3. I've added an amazing tool to my toolbox

Rust's performance capabilities are impressive. Even though I haven't delved deeply into this aspect yet, [I did learn how to integrate Rust into Python](/rust-in-python-pyo3-maturin).

So when I need to write performance-critical code, I can now try to use Rust and integrate it with Python.

### 4. Reaffirming the Pybites trifecta

The combination of "building - JIT learning - putting content out" works beyond Python. It turns out to be an effective _template_ to learn any new language or technology. 😎

## Conclusion

Learning Rust has been useful on many levels, but it's easy to get into _[tutorial paralysis](https://pybit.es/articles/are-you-overwhelmed-by-tutorial-paralysis/)_ when learning a new language.

So by building concrete tools, using AI, blogging, and finding an accountability partner, I have been able to keep the learning fun and productive. 🚀

I am only 25 days in, and I have a long way to go. But I am excited to see where this journey takes me over time ... 📈
