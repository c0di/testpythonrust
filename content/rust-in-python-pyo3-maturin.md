+++
title = "How to run Rust in Python with PyO3 and Maturin"
date = 2024-06-04
+++

In this article I will show you how to run Rust code in Python using PyO3 + Maturin.

PyO3 is a Rust library for building Python bindings and Maturin is a tool for building and publishing Python packages built with PyO3.

Here is a quick overview of the steps we will follow:

{{ image(src="/rust-in-python.png", alt="overview mind map of how PyO3 and Maturin work to run Rust code in Python",
         style="border-radius: 8px;") }}

Let's do a quick demo to see how it works.

## Create a new library

First, let's create a new Rust library using Cargo:

```bash
cargo new --lib sum_squares
```

This will create a new directory called `sum_squares` with the following structure:

```bash
√ pyo3  $ tree
.
└── sum_squares
    ├── Cargo.toml
    └── src
        └── lib.rs

3 directories, 2 files
```

Next we update the `Cargo.toml` file to include the `pyo3` dependency:

```toml
[package]
name = "sum_squares"
version = "0.1.0"
edition = "2021"

[lib]
name = "sum_squares"
crate-type = ["cdylib"]

[dependencies]
pyo3 = { version = "0.21", features = ["extension-module"] }
```

We also need the `cdylib` crate type to create a shared library that can be loaded by Python (so/.dylib/.dll files, `.so` for Unix, `.dll` for Windows).

Next, we update the `src/lib.rs` file to include a simple function that sums the squares of two numbers:

```rust
use pyo3::prelude::*;

#[pyfunction]
fn sum_of_squares(n: u64) -> u64 {
    (1..=n).map(|x| x * x).sum()
}

#[pymodule]
fn sum_squares(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(sum_of_squares, m)?)?;
    Ok(())
}
```

At a high level:

- The `#[pyfunction]` attribute is used to mark the function as a Python function.
- The `#[pymodule]` attribute is used to mark the module as a Python module.
- The `m.add_function` method is used to add the `sum_of_squares` function to the module.
- The `wrap_pyfunction!` macro is used to wrap the Rust function in a Python function.
- The `Python` and `PyModule` types are used to interact with the Python runtime.

Some Rust syntax I am learning about:

- We use the `use` statement to import the `pyo3::prelude` module, which contains common types and traits used in PyO3.
- The `sum_of_squares` function calculates the sum of squares of numbers from 1 to `n` using the `..=` operator (`=` is including the upper bound) to create a range and the `map` and `sum` methods to calculate the sum of squares,
- The function receives a single argument `n` of type `u64` and returns a single value of type `u64`. Unlike Python's optional type hints, Rust's type hints are mandatory.
- The `PyResult` in the `sum_squares` function signature is the return type of functions that can return errors. This is needed because the `add_function` method can return an error. The `?` operator is used to propagate the error if it occurs.
- The `Ok(())` expression is used to return a successful result. () is the unit type, which is similar to void in other languages.

## Create a Python package

First make a virtual environment, enable it, and install the `maturin` package:

```bash
python -m venv venv
source venv/bin/activate
pip install maturin
```

Normally you would run `maturin init` to create a new Python package, but in this case we already have a Cargo project, so we can skip this step.

Let's build the Python package using Maturin:

```bash
maturin develop
```

It worked but I did get this warning:

```bash
warning: use of deprecated method `pyo3::deprecations::GilRefs::<T>::function_arg`: use `&Bound<'_, T>` instead for this function argument
```

To fix this error, I updated the function signature to use `&Bound<'_, PyModule>` instead of `&PyModule`:

```rust
...
fn sum_squares(m: &Bound<'_, PyModule>) -> PyResult<()> {
...
```

After that change, I ran `maturin develop` again and the warning was gone:

```bash
$ maturin develop

🔗 Found pyo3 bindings
🐍 Found CPython 3.11 at /Users/bbelderbos/code/rust/pyo3/sum_squares/venv/bin/python
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.07s
📦 Built wheel for CPython 3.11 to /var/folders/jl/cfhvw0nj11n1496hk7vqhw_r0000gn/T/.tmp5qSsw8/sum_squares-0.1.0-cp311-cp311-macosx_10_12_x86_64.whl
✏️  Setting installed package as editable
🛠 Installed sum_squares-0.1.0
```

I can now see the shared library (.so file) in my virtual environment:

```bash
$ ls -lrth venv/lib/python3.11/site-packages/sum_squares
total 1936
-rw-r--r--@ 1 bbelderbos  staff   127B Jun  4 12:59 __init__.py
-rwxr-xr-x@ 1 bbelderbos  staff   961K Jun  4 12:59 sum_squares.cpython-311-darwin.so
drwxr-xr-x@ 3 bbelderbos  staff    96B Jun  4 12:59 __pycache__
```

And I can import it in the Python REPL:

```python
>>> import sum_squares
>>> sum_squares.sum_of_squares(5)
55
```

That's it! We have successfully built a Python package with Rust code using PyO3 and Maturin.

I have not pushed one to PyPI, but you can do that by running `maturin publish`. I will blog here when I have done that for a real project ...

Lastly, to see how it performs vs some Python code, I created a `test.py` file:

```python
import time

from sum_squares import sum_of_squares


def sum_of_squares_py(n):
    return sum(x * x for x in range(1, n + 1))


if __name__ == "__main__":
    n = 10**6

    start_time = time.time()
    result = sum_of_squares_py(n)
    end_time = time.time()
    print(f"Python result: {result}")
    print(f"Python execution time: {end_time - start_time:.6f} seconds")

    start_time = time.time()
    result = sum_of_squares(n)
    end_time = time.time()
    print(f"Rust result: {result}")
    print(f"Rust execution time: {end_time - start_time:.6f} seconds")
```

Running it:

```bash
$ python test.py
Python result: 333333833333500000
Python execution time: 0.066308 seconds
Rust result: 333333833333500000
Rust execution time: 0.023685 seconds
```

Nice, the Rust implementation is about 3x faster than the Python implementation. But that's not the point of this article, the point is to show you how to run Rust code in Python which opens up exciting new opportunities for performance improvements in your Python code. 😍 📈

This is how Pydantic, the data validation library, is speeding up its codebase I believe. 😎

## Conclusion

In this article, we learned how to run Rust code in Python using PyO3 and Maturin. We created a new Rust library with a simple function that sums the squares of two numbers, built a Python package using Maturin, and tested the performance of the Rust implementation against a Python implementation.

There is a lot more to learn about PyO3 and Maturin, and Rust in general.

Check out the [PyO3 documentation](https://pyo3.rs/v0.21.2/) and the [Maturin documentation](https://github.com/PyO3/maturin) for more information.

What Python code do you want to speed up with Rust?
