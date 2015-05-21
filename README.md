# Driveshaft

> Driveshaft is a [Sinatra](http://www.sinatrarb.com/) application built to turn Google Spreadsheets and Google Documents into JSON with the click of a button.

* [Quickstart](#quickstart)
* [Documentation](#documentation)
* [Contribute](#contribute)

## Quickstart

For the full user guide, please refer to the [documentation](https://newsdev.github.io/driveshaft/). Or, if you're somewhat familiar with Ruby applications and Google Authentication / S3, use this quickstart guide to get up and running.

### Dependencies

Be sure to have the following system dependencies installed:

``` bash
# Git, Ruby, Node
$ brew install git node ruby

# Bower
$ npm install -g bower

# Bundler
$ gem install bundler
```

### Clone the repository and resolve app dependencies

``` bash
$ git clone git@github.com:newsdev/driveshaft.git
$ cd driveshaft
$ bower install
$ bundle install
```

### Environmental Variables

Driveshaft uses environmental variables for configuration. Set the following variables either at runtime on the commandline, or in your `/~.bash_profile`.

Set **at least one**, or several, of the following to authenticate against the Google API. You will need to set up a [Google Developers Project](https://console.developers.google.com/project) with the Drive API enabled. Then create a set of credentials. Public API Keys, and any of the three OAuth2 mechanisms, are supported.

To use an API Key, set `GOOGLE_APICLIENT_KEY` to the key. For any type of OAuth certificate, set the variable to a path to the certificate file, or the contents of the certificate itself.

``` bash
# Public API Key
GOOGLE_APICLIENT_KEY="***"

# Native Application Client
GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED="***"

# Web Application Client
GOOGLE_APICLIENT_CLIENTSECRETS_WEB="***"

# Service Account
GOOGLE_APICLIENT_CLIENTSECRETS_SERVICEACCOUNT="***"
```

Required for S3 access. Use credentials that have access to any S3 buckets you wish to use.

``` bash
AWS_ACCESS_KEY_ID="****"
AWS_SECRET_ACCESS_KEY="****"
AWS_REGION="us-east-1"
```

Driveshaft settings:

``` bash
DRIVESHAFT_SETTINGS_AUTH_REQUIRED="false" # true to require client-side login
DRIVESHAFT_SETTINGS_AUTH_DOMAIN="nytimes.com" # restrict login to a single domain
```

Optional drive key and s3 destination for a Google Spreadsheet to use to power the index page. It should follow the format of [this spreadhseet](https://docs.google.com/spreadsheets/d/16NZKPy_kyWb_c0jBLo_sTvyoGUrs-ISG7uMDHBMgM5U/edit#gid=0) (you can copy the spreadsheet into a new one to start).

``` bash
DRIVESHAFT_SETTINGS_INDEX_DESTINATION="s3://BUCKET/PATH.json"
DRIVESHAFT_SETTINGS_INDEX_KEY="DRIVE_KEY"
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
