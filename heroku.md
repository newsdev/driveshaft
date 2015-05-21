---
layout: page
title: Driveshaft on Heroku
---

Once you've set up Driveshaft on your own computer, we try to make it quick to deploy in the wild.

Driveshaft was built to deploy on PaaS (or "Platform as a Service") architecture like [Heroku](https://www.heroku.com/). Heroku lets you host websites using just an account, a git repo, and the ilst of [environmental variables]({{ site.basepath}}/reference#environmental-variables) we've been configuring.

Heroku has a great [Getting Started with Ruby on Heroku](https://devcenter.heroku.com/articles/getting-started-with-ruby) guide you can follow to deploy Driveshaft. The **Procfile** it needs is already in the application.

Set the same environmental variables you've been using locally, as well as one additional variable called `BUILDPACK_URL`.

This makes Driveshaft use a custom [buildpack](https://devcenter.heroku.com/articles/buildpacks), so that `bundle install` and `bower install` are run automatically when you update the Driveshaft.

``` bash
heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi
```
