---
layout: index
title: Home
sections: [
  ['Goals', 'goals'],
  ['Supported Formats', 'formats'],
  ['Getting Started', 'getting-started']
]
---

# What is Driveshaft?

> Driveshaft is a [Sinatra](http://www.sinatrarb.com/) application built to turn Google Spreadsheets and Google Documents into JSON with the click of a button.

We use it at The New York Times to edit data for stories and interactives from within Google Drive files, letting multiple editors collaborate in a familiar environment.

<h2 id="goals">Goals</h2>

Driveshaft was built to accomodate the following needs:

* Publishing should be a one-step process
* In addition to each Drive file's version history, all published JSON versions should be kept and be restorable
* Unlimited "destinations" can exist for any file, such as for staging and production environments
* Google Drive authentication should be invisible when possible (within a firewall) but explicit when necessary (let users authenticate with their own accounts)
* Made to deploy on Platform as a Service frameworks like Heroku
* It should work as a standalone application for users, and expose an API for automated publishing

<h2 id="formats">Supported Formats</h2>

Driveshaft supports multiple ways of converting source data from a file into JSON, and ships with two.

### Spreadsheet

The default for Google Spreadsheets.

Every Sheet in the spreadsheet becomes a top-level object in the output, keyed by sheet name. Each sheet's rows become an array of objects, with keys set from the first row of the spreadsheet.

You can **hide** entire sheets or columns from the output by appending `:hide` to the sheet name, or column title in the first row.

### ArchieML

The default for Google Documents.

Uses the [ArchieML](http://archieml.org/) format for creating a JSON object from the text of a Google Document.

Links in the document are converted to HTML `<a>` tags.

### Adding formats

Per-MIME Type defaults are set in `lib/driveshaft/exports.rb`.

Additional formats can be added by creating additional files in the `lib/driveshaft/exports` directory, and exposing a class method on `Driveshaft::Exports` that accepts the Drive file and a Google APIClient for making API calls.

It should return an object that can be passed directly to the AWS gems [S3::Object.put method](http://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Object.html#put-instance_method), letting you set custom permissions and metadata on the file if you wish.

<h2 id="getting-started">Getting started</h2>

The instructions below will help you get Driveshaft up and running on your computer.  If you'd prefer to test out Driveshaft by installing it first on Heroku, you can skip to step ____ and then _____.

#### Dependencies

To begin, you'll need to have a few programs installed on your computer:

* [git](http://git-scm.com/) to download and update the source code

        brew install git

* [Node.js](https://nodejs.org/), [npm](https://docs.npmjs.com/getting-started/installing-node) and [bower](http://bower.io/) for JavaScript and CSS package management

        brew install node
        npm install -g bower

* [Ruby](https://www.ruby-lang.org/en/documentation/installation/), if your system doesn't already have it

        brew install ruby

* [Bundler]() for ruby package management

        gem install bundler

#### Start Driveshaft

1. Clone this repository using git, and move into its directory.

        git clone git@github.com:newsdev/driveshaft.git
        cd driveshaft

2. Install the JavaScript and CSS dependencies.

        bower install

3. Install the Ruby gem dependencies.

        bundle install

4. Start the server.

        puma

By default, puma will run Driveshaft on [`http://localhost:9292`](http://localhost:9292).  Before you can use the app, however, you will need to enable Driveshaft to access Google Drive documents.




