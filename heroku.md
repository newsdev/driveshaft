---
layout: page
title: Driveshaft on Heroku
---

Once you've set up Driveshaft on your own computer, we try to make it quick to deploy in the wild.

Driveshaft was built to deploy on PaaS (or "Platform as a Service") architecture like [Heroku](https://www.heroku.com/). Heroku lets you host websites using just an account, a git repo, and the list of [environmental variables]({{ site.basepath}}/reference#environmental-variables) we've been configuring.

<h3 id="deploy-button">Quickstart: Deploy Button</h3>

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/newsdev/driveshaft/tree/v{{ site.version }})

You'll be taken to a page with a bunch of empty form inputs. You can leave these blank for now, or if you already have an AWS account, S3 bucket or Google Project setup, you can enter your [configuration settings]({{ site.baseurl }}reference/#environmental-variables) there.

You can always edit these variables later within the [Heroku web dashboard](https://dashboard.heroku.com/apps). Navigate to your app, then **Settings**, and click **Edit** under **Config Variables**.

### Step by step

If the deploy button is giving you trouble, try the step by step guide by Heroku on [Getting Started with Ruby on Heroku](https://devcenter.heroku.com/articles/getting-started-with-ruby). You can follow along to deploy Driveshaft.

Set the same environmental variables you've been using locally. You can use a special command, `heroku config:add`, to set these values on the Heroku server.

Also set one additional variable `BUILDPACK_URL`. This makes Driveshaft use a custom [buildpack](https://devcenter.heroku.com/articles/buildpacks), so that `bundle install` and `bower install` are run automatically when you update the Driveshaft.
``` bash
heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi
```
