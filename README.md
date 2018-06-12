# Driveshaft

> Driveshaft is a [Sinatra](http://www.sinatrarb.com/) application built to turn Google Spreadsheets and Google Documents into JSON with the click of a button.

* [Quickstart](#quickstart)
* [Documentation](#documentation)
* [Contribute](#contribute)

## Quickstart

For the full user guide, please refer to the [documentation](https://newsdev.github.io/driveshaft/). Or, if you're somewhat familiar with Ruby applications and Google Authentication / S3, use this quickstart guide to get up and running.

### Heroku Quickstart

[Deploy instantly](https://newsdev.github.io/driveshaft/heroku/#deploy-button) with Heroku.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

### Dependencies

Be sure to have the following system dependencies installed:

``` bash
# Git, Ruby, Node
$ brew install git node ruby

# Bundler
$ gem install bundler
```

### Clone the repository and resolve app dependencies

``` bash
$ git clone git@github.com:newsdev/driveshaft.git
$ cd driveshaft
$ npm install
$ bundle install
```

### Environmental Variables

Driveshaft uses environmental variables for configuration. Set the following variables either at runtime on the commandline, or in your `~/.bash_profile`.

Create a service account to authenticate against the Google API. You will need to set up a [Google Developers Project](https://console.developers.google.com/project) with the Drive API enabled. Then create a set of [credentials](https://console.cloud.google.com/apis/credentials). Choose a **service account key**, and download the contents as JSON.

Store the JSON file on your computer (or your deployed environment), and set `GOOGLE_APPLICATION_CREDENTIALS` to the filepath where it is stored.

``` bash
GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceaccount.json"
```

Required for S3 access. Use credentials that have access to any S3 buckets you wish to use.

``` bash
AWS_ACCESS_KEY_ID="****"
AWS_SECRET_ACCESS_KEY="****"
AWS_REGION="us-east-1"
```

Driveshaft settings:

``` bash
DRIVESHAFT_SETTINGS_MAX_VERSIONS="5" # set to a maximum number of previous file versions to keep on S3
DRIVESHAFT_SETTINGS_INDEX_FOLDER="****" # a Google Team Drive folder ID
```

### Run the app locally

``` bash
$ puma
```

[http://localhost:9292/](http://localhost:9292/)

## Documentation

Documentation is available on the `gh-pages` branch. To view or contribute to the docs, checkout that branch, and run the following to start the documentation server:

``` bash
gem install jekyll
jekyll server
```

## Contribute

Questions / comments / feature requests / concerns? Please use the [Issues](https://github.com/newsdev/driveshaft/issues) page.

## Contributors

* [Michael Strickland](https://twitter.com/moriogawa)
* [Scott Blumenthal](https://twitter.com/blumysden)

Released at the [OpenNews](http://opennews.org/) [Code Convening](http://opennews.org/blog/code-convening-wtd/) at the [2015 Write The Docs](http://www.writethedocs.org/conf/na/2015/) conference, with the support of the [Knight Foundation](http://www.knightfoundation.org/) and [The Mozilla Foundation](https://www.mozilla.org/en-US/foundation/).

## License

The documentation and code are licensed under the [Apache License, Version 2.0](https://github.com/newsdev/driveshaft/blob/master/LICENSE).

Copyright 2015 The New York Times Company.
