+++
title = "How to resize images in Rust"
date = 2024-06-17
+++

The other day [I built a simple website](building-website-axum.md) and needed to resize some images so I decided to figure out how to do this in Rust.

I found a crate called `image` that made this easy. Here's how I did it.

Full code [in this repo](https://github.com/bbelderbos/resize-images).

After adding `image` to your `Cargo.toml` or doing a `cargo add image` you can use it like this.

First you make an `image` object:

```rust
use std::path::Path;

let input_path = Path::new("workshop.jpg");
let img = image::open(input_path)?;
```

Here is the original image:

{{ image(src="/images/workshop_original.jpg", alt="Image to make a thumb of", style="border-radius: 8px;") }}

The `?` operator is a concise way to handle errors, if `image::open` fails it will return an error and the function will return early.

Next we can use the `resize_exact` method to resize the image to the desired width and height:

```rust
let thumbnail = img.resize_exact(200, 200, image::imageops::FilterType::Lanczos3);
```

The `FilterType` is optional, it defaults to `Lanczos3` which is a high-quality resampling filter.

Finally we can save the resized image to disk:

```rust
let output_path = Path::new("workshop_thumbnail.jpg");
thumbnail.save(output_path)?;
```

{{ image(src="/images/workshop_thumbnail_exact.jpg", alt="200 x 200 thumbnail image", style="border-radius: 8px;") }}

That's a bit skewed though, because the original image was 800x600 and we resized it to 200x200. If you want to keep the aspect ratio you can use the `resize` method instead of `resize_exact`:

```rust
let thumbnail = img.resize(200, 200, image::imageops::FilterType::Lanczos3);
```

That leads to an image of 200x150 in my case which looks better:

{{ image(src="/images/workshop_thumbnail.jpg", alt="200 x 150 thumbnail image", style="border-radius: 8px;") }}

Putting it all together:

```rust
use image::ImageError;
use std::path::Path;

fn main() -> Result<(), ImageError> {
    let input_path = Path::new("workshop.jpg");
    let img = image::open(input_path)?;

    // Resize image to fit within 200x200 while maintaining aspect ratio
    let thumbnail = img.resize(200, 200, image::imageops::FilterType::Lanczos3);

    let output_path = Path::new("workshop_thumbnail.jpg");
    thumbnail.save(output_path)?;

    Ok(())
}
```

Note that because we're using the `?` operator we need to update the return type of our function to `Result<(), ImageError>`.

The repo has some other interesting things:

- I use `clap` to parse command line arguments, see also [this article](mcommand-line-apps-with-clap).

- I use `img.save_with_format(output_path, ImageFormat::Png)?;` to save the image in a different format (ChatGPT gave me `webp` fake images so I converted them to `png`).

- It uses `glob` (similar to Python's `glob`) with a pattern (`"{}/*{}"`) to find all files in a directory with a certain extension, which can be provided as an argument to the program.

- I use the `match` statement to handle errors and print messages to the console in various places.

## Conclusion

There you go, a quick way to resize images in Rust.

The `image` crate is powerful and easy to use, similar to `Pillow` in Python. 😍 📈

You can use the `resize` method to keep the aspect ratio or `resize_exact` to resize to an exact width and height.

Again, the full code of this mini project is [here](https://github.com/bbelderbos/resize-images).
