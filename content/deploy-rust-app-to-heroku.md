+++
title = "How to deploy a Rust app to Heroku"
date = 2024-06-15
+++

In [yesterday's post](/building-website-axum), I showed how to build a simple web application with Rust. Today, I'll show how to deploy this application to Heroku.

## Steps

1. Add a `Procfile` to the root of your project

For a simple web application, the `Procfile` should contain the following line, assuming `artist_portfolio` is the name of the application:

```bash
web: ./target/release/artist_portfolio
```

Note that we don't need to run a web server like Gunicorn, because the Rust application is self-contained.

No other files are needed, because the Rust buildpack (see below) will take care of the rest based on the `Cargo.toml` file.

2. Create a new Heroku application

```bash
$ heroku login
$ heroku create artist-portfolio
```

This adds a new remote to the Git repository (see `git remote -v`). You can also add the remote manually:

```bash
$ git remote add heroku https://git.heroku.com/artist-portfolio.git
```

3. Add the Rust buildpack:

```bash
$ heroku buildpacks:set emk/rust
```

This buildpack will compile the Rust application on Heroku.

4. Environment variables

You can set them either via the Heroku dashboard or the CLI:

```bash
$ heroku config:set KEY=VALUE
```

See also my post about [using environment variables in Rust](/environment-variables-rust).

5. Kick off the build

You only have to push your code to Heroku to trigger the build:

```bash
$ git push heroku main
```

---
That's it! You can now navigate to the URL provided by Heroku to see your application. If you don't know the URL, you can find it with:

```bash
$ heroku info
```

You can also open it directly from the CLI:

```bash
$ heroku open
```

If there is any issue (for example, upon first attempt I forgot to use the correct port: 8000, instead of Axum's default 3000), you can check the logs:

```bash
$ heroku logs --tail
```

## Automate the deployment

Heroku is well integrated with GitHub, so you can automate the deployment process.

Go to the Heroku dashboard, select the application, and navigate to the "Deploy" tab. Connect your GitHub repository and select the branch you want to deploy. You can also conveniently enable automatic deployments.

For more information, see the [Heroku documentation](https://devcenter.heroku.com/articles/github-integration).

You can also map a custom domain to your Heroku application and get an SSL certificate.

---
That's it! Your Rust application on Heroku in a few simple steps.

When I try other platforms and deploy options (e.g. Docker), I will share them here ...
