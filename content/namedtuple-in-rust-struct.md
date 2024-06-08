+++
title = "Does Rust have a similar NamedTuple type?"
date = 2024-06-08
+++

When exploring a new language after Python, one of the first things you might look for is a similar Python types, and one of my favorite ones is the `namedtuple`.

It's a simple way to create a class with named fields, and it's very useful when you want to create a simple data structure.

## Python named tuples

```python
# old way
from collections import namedtuple
Person = namedtuple('Person', ['name', 'age', 'email'])
p = Person('John', 30, 'john@example.com')
print(p.name, p.age, p.email)

# more modern way with type hints I prefer:
from typing import NamedTuple

class Person(NamedTuple):
    name: str
    age: int
    email: str

p = Person('John', 30, 'john@example.com')
print(p.name, p.age, p.email)
# p.name = 'John Doe'  # AttributeError... -> named tuples are immutable
```

## Named tuples are more readable

I am such a big fan of named tuples because unlike regular tuples they let you access the fields by name, which makes your code more readable and less error-prone.

```python
# regular tuple
person = ('John', 30, 'john@example.com')
# what field is at what index?
print(person[0], person[1], person[2])

# named tuple
Person = namedtuple('Person', ['name', 'age', 'email'])
person = Person('John', 30, 'john@example.com')
# instantly readable
print(person.name, person.age, person.email)
```

## Named tuples are immutable

Named tuples are also immutable, which is a good thing because it makes the code safer (you can't accidentally change the values).

This is a core concept in Rust I learned, where data structures are immutable by default. If you want mutability, you have to explicitly make them mutable. We'll see how to do that in the Rust in a bit ...

## Rust offers structs

In Rust, you can use a `struct` with named fields to create the same Person type as before. Here's how you can do it:

```rust
struct Person {
    name: String,
    age: u32,
    email: String,
}

fn main() {
    let person = Person {
        name: String::from("John"),
        age: 30,
        email: String::from("john@example.com"),
    };

    // struct is immutable by default
    // person.age = 31;

    println!("Name: {}, Age: {}, Email: {}", person.name, person.age, person.email);
}
```

This prints:

```bash
$ cargo run
...
Name: John, Age: 30, Email: john@example.com
```

(Ommitting the cargo run command from here on.)

Notice that if I uncomment the line `person.age = 31;` the Rust compiler will complain. I am really impressed by with how helpful the Rust compiler is. It gives you very helpful and specific error messages. Here's what it says in this case:

```bash
...
  --> src/main.rs:15:5
   |
15 |     person.age = 31;
   |     ^^^^^^^^^^^^^^^ cannot assign
   |
help: consider changing this to be mutable
   |
8  |     let mut person = Person {
   |         +++

...
```

So as per the error message, you can make the `struct` mutable by adding the `mut` keyword before the variable name:

```rust
fn main() {
    let mut person = Person {
        name: String::from("John"),
        age: 30,
        email: String::from("john@example.com"),
    };

    // This is allowed because `person` is mutable.
    person.age = 31;

    println!("Name: {}, Age: {}, Email: {}", person.name, person.age, person.email);
}
```

This works and prints:

```bash
Name: John, Age: 31, Email: john@example.com
```

## Implement methods

Optionally you can implement methods on the `struct` to make it more powerful. Here's an example:

```rust
struct Person {
    name: String,
    age: u32,
    email: String,
}

impl Person {
    // Method to create a new Person
    fn new(name: &str, age: u32, email: &str) -> Person {
        Person {
            name: String::from(name),
            age,
            email: String::from(email),
        }
    }

    // Method to display a greeting
    fn greet(&self) {
        println!("Hello, my name is {} and I am {} years old. You can contact me at {}", self.name, self.age, self.email);
    }
}

fn main() {
    let person = Person::new("John", 30, "john@example.com");
    person.greet();
}
```

Which prints:

```bash
Hello, my name is John and I am 30 years old. You can contact me at john@example.com
```

`greet(&self)` means that this method takes a reference to the `struct` as an argument. This is similar to the `self` parameter in Python methods.

_Ownership_ and _borrowing_ are big and important concepts in Rust, and I'll cover them here more in detail when I have a better understanding of them ...

## Conclusion

In Rust, you can use a `struct` with named fields to achieve the same thing as a Python `namedtuple`.

Structs are immutable by default, but you can make them mutable by adding the `mut` keyword before the variable name.

Optionally, you can implement methods on the `struct` using the `impl` block. 🦀😎

I find the Rust compiler very helpful with its detailed and specific error messages. It helps a lot, specially when you're learning the language. 😍💡📈
