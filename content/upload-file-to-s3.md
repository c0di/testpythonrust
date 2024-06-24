+++
title = "Using rusoto to upload a file to S3"
date = 2024-06-24
+++

A while ago I made a Python script to upload files to an S3 bucket. It's a simple script that uses the `boto3` library to interact with the AWS API. Check it out [here](https://github.com/PyBites-Open-Source/pybites-tools/blob/main/pybites_tools/aws.py).

Let's see how to do this with Rust and the `rusoto` crate.

First, I added the following dependencies to my `Cargo.toml` file:

```toml
...
[dependencies]
clap = { version = "4.5.7", features = ["derive", "env"] }
rusoto_core = "0.48.0"
rusoto_s3 = "0.48.0"
tokio = { version = "1.38.0", features = ["full"] }
```

This is what I came up with for the first iteration:

```rust
use rusoto_core::{Region, credential::EnvironmentProvider, HttpClient};
use rusoto_s3::{S3Client, S3, PutObjectRequest};
use tokio::fs::File;
use tokio::io::AsyncReadExt;
use std::error::Error;
use clap::Parser;
use std::path::Path;

#[derive(Parser, Debug)]
#[clap(about, version, author)]
struct Args {
    #[clap(short, long, env = "S3_BUCKET_NAME")]
    bucket: String,
    #[clap(short, long, env = "AWS_REGION")]
    region: String,
    #[clap(short, long)]
    file: String,
}

async fn upload_image_to_s3(bucket: &str, key: &str, file: &str, region: Region) -> Result<(), Box<dyn Error>> {
    let s3_client = S3Client::new_with(HttpClient::new()?, EnvironmentProvider::default(), region);

    let mut file = File::open(file).await?;
    let mut buffer = Vec::new();
    file.read_to_end(&mut buffer).await?;

    let put_request = PutObjectRequest {
        bucket: bucket.to_string(),
        key: key.to_string(),
        body: Some(buffer.into()),
        ..Default::default()
    };

    s3_client.put_object(put_request).await?;

    println!("File uploaded successfully to {}/{}", bucket, key);
    Ok(())
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let args = Args::parse();

    let key = Path::new(&args.file)
        .file_name()
        .and_then(|name| name.to_str())
        .ok_or("Invalid file path")?;

    let region = args.region.parse::<Region>()?;

    upload_image_to_s3(&args.bucket, key, &args.file, region).await?;

    Ok(())
}
```

- I use Clap ([as usual](/command-line-apps-with-clap)) for handling command-line arguments.
- I use the `rusoto_core` and `rusoto_s3` crates to interact with the AWS API.
- I use the `tokio` crate to make it asynchronous.
- The `upload_image_to_s3` function reads the file, creates a `PutObjectRequest`, and uploads the file to the specified S3 bucket.
- The `main` function parses the command-line arguments, extracts the file name, and uploads the file to S3.

To run the program, you need to set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables:

```bash
$ export AWS_ACCESS_KEY_ID=your_access_key_id
$ export AWS_SECRET_ACCESS_KEY=your_secret_access_key
```

And either specify region and bucket from the command line or set the `S3_BUCKET_NAME` and `AWS_REGION` environment variables if you always want to use the same bucket and region:

```bash
$ export S3_BUCKET_NAME=example-bucket
$ export AWS_REGION=us-east-2
```

With all this set you only need to give the file you want to upload:

```bash
$ cargo run -- -f ~/Desktop/cat.png
...
File uploaded successfully to example-bucket/cat.png
```

## Conclusion

And that's it, a Rust utitlity to upload files to S3. 🦀 🚀

I extended the program a bit to allow multiple files to be uploaded and list the images, including with pagination so I can use it later with HTMX' infinite scroll. I will write about that in a future post ...

The repo is [here](https://github.com/bbelderbos/s3_file_manager), I also pushed it to crates.io so you can install it with `cargo install s3_file_manager`. In a next post I will refactor the code to make it more modular so that it can be used as a library as well. Stay tuned! 🚀🦀
