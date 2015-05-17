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

* Publishing should be a one-step process
* All published JSON versions should be kept and be restorable
* Every file should be publishable to as many "destinations" as desired: to both staging and production environments, for example
* Google Drive authentication should be invisible when possible (within a firewall) but explicit when necessary (let users authenticate with their own accounts)
* It should work as a standalone application for users, and expose an API for automated publishing
* Driveshaft should be deployable on Platform as a Service frameworks like Heroku

<h2 id="formats">Supported Formats</h2>

Driveshaft can convert documents in multiple data formats into JSON.  It ships with support for two, but you can easily [add more]({{ site.basepath}}/reference#adding-formats).

### Spreadsheet

The default for Google Spreadsheets.

Every Sheet in the spreadsheet becomes a top-level object in the output, keyed by sheet name. Each sheet's rows become an array of objects, with keys set from the first row of the spreadsheet.

You can **hide** entire sheets or columns from the output by appending `:hide` to the sheet name, or column title in the first row.

<!-- TODO: example document? -->

### ArchieML

The default for Google Documents.

Uses the [ArchieML](http://archieml.org/) format for creating a JSON object from the text of a Google Document.

Links in the document are converted to HTML `<a>` tags.

<h2 id="getting-started">Getting started</h2>

The instructions below will help you get Driveshaft up and running on your computer.  If you'd prefer to test out Driveshaft by installing it first on Heroku, you'll still need to go through the first couple of steps.  We'll let you know when you can  can skip ahead to the instructions for [deploying on Heroku]({{ site.basepath }}/heroku).

### Dependencies

To begin, you'll need to have a few programs installed on your computer.

<div class="highlight">
  <p class="info">The instructions below assume you are installing on a Mac using <a href="http://brew.sh/">Homebrew</a>.  If you plan to install on another operating system, <strong>please help us out</strong> by documenting the steps and issuing a pull request to our <a href="https://github.com/newsdev/driveshaft">GitHub repository</a>.</p>
</div>

**[git](http://git-scm.com/)** to download and update the source code

    brew install git

**[Node.js](https://nodejs.org/)**, **[npm](https://docs.npmjs.com/getting-started/installing-node)** and **[bower](http://bower.io/)** for JavaScript and CSS package management

    brew install node
    npm install -g bower

**[Ruby](https://www.ruby-lang.org/en/documentation/installation/)**, if your system doesn't already have it.

    brew install ruby

<div class="highlight">
  <p class="info">Driveshaft has been tested using <strong>Ruby 2.2.x.</strong></p>
</div>

**[Bundler](http://bundler.io/)** for ruby package management

    gem install bundler

### Set Up and Run Driveshaft

1. Clone the Driveshaft repository using git, and move into its directory.

        git clone git@github.com:newsdev/driveshaft.git
        cd driveshaft

1. Install the JavaScript and CSS dependencies.

        bower install

1. Install the Ruby gem dependencies.

        bundle install

1. Start the server.

        puma

By default, puma will run Driveshaft on [`http://localhost:9292`](http://localhost:9292).

Before you can use the app, however, you will need to [enable Driveshaft to access Google Drive]({{ site.basepath }}/authentication).




