# Driveshaft Changelog

## v0.1.6 - 2916-07-22

* Fix for bug #28 around incorrectly convert Google Doc links to HTML.

## v0.1.5 - 2016-06-20

* Fixed Dockerfile reference to newsdev/kubernetes-secret-env.

## v0.1.4 - 2016-06-20

* Upgraded the archieml gem to support freeform arrays.

## v0.1.3 - 2015-12-09

* Updated Dockerfile to use a new base image from The New York Times.

## v0.1.2 - 2015-10-22

### Bugs

* Google OAuth2 settings should enable the "Google+ API", to enable accessing users' email addresses for identification.
* Added a [Troubleshooting guide](https://github.io/newsdev/driveshaft/reference/#troubleshooting) to the documentation.
* Force encoding of Google Spreadsheets to UTF-8 to avoid encoding errors from characters not in US-ASCII.

## v0.1.1 - 2015-05-28

### Features

* Added [app.json](https://devcenter.heroku.com/articles/app-json-schema) file for use with a Heroku Deploy Button

### Bugs

* #12: Gem upgrades: `rack v0.6.1` and `sinatra v1.4.6`

## v0.1.0 - 2015-05-27

Initial release.
