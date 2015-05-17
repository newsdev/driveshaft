---
layout: page
title: Driveshaft on Heroku
sections: [
  ['Dependencies', 'dependencies']
]
---

Driveshaft was built to deploy on PaaS (or "Platform as a Service") architecture like [Heroku](https://www.heroku.com/).

Heroku has a great [Getting Started with Ruby on Heroku](https://devcenter.heroku.com/articles/getting-started-with-ruby) guide you can follow to deploy Driveshaft. A default Procfile is already included.

You'll have to set the same [environmental variables]({{ site.basepath }}/reference#environmental-variables) you set locally in order to access the Google Drive API and publish your files to S3.

