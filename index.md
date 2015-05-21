---
layout: index
title: Home
sections: [
  ['Goals', 'goals'],
  ['Supported Formats', 'formats'],
  ['Getting Started', 'getting-started'],
  ['Tour', 'tour']
]
---

# What is Driveshaft?

> Driveshaft is a [Sinatra](http://www.sinatrarb.com/) application built to turn Google Spreadsheets and Google Documents into JSON with the click of a button.

We use it at The New York Times to published structured data for interactives, widgets on NYTimes.com and configuring internal settings. Using Google Drive files lets multiple editors collaborate in a familiar environment.

## Goals

* **Publish to S3** in one step
* **Version history**, ability to restore older version
* Publish any file to multiple destinations / **environments**
* **Google Drive authentication** should be invisible when possible (within a firewall) but explicit when necessary (let users authenticate with their own accounts)
* A **website** for humans, and an **API** for automated publishing
* **Heroku** (and other Platform as a Service frameworks) deployable

<h2 id="formats">Supported Formats</h2>

Driveshaft can convert documents in multiple data formats into JSON.  It ships with support for two, but you can easily [add more]({{ site.basepath}}/reference#adding-formats).

### Spreadsheet

The default for Google Spreadsheets.

Sheets (or tabs) becomes a top-level object in the output, keyed by sheet name. Each sheet's rows become an array of objects. Column headers come from the first row of the spreadsheet.

###### Example: Spreadsheet → JSON

![Spreadsheet example]({{ site.baseurl }}public/img/format_spreadsheet.png)

``` json
{
  "people": [
    { "name": "Amanda", "age": "26" },
    { "name": "Tessa", "age": "30" }
  ]
}
```

**Hide** "sheets" (tabs) or columns from the output by appending `:hide` to its name, as with the **notes** field and **other** sheet.

### ArchieML

The default for Google Documents.

Uses the [ArchieML](http://archieml.org/) format for creating a JSON object from the text of a Google Document.

###### Example: Document → JSON

``` yaml
key: value
test: document
```

``` json
{
  "key": "value",
  "test": "document"
}
```

ArchieML is based on **key-value pairs**, but [supports](https://archieml.org/) more complex data structures as well.

<h2 id="getting-started">Getting started <small>in 3 steps</small></h2>

The instructions below will help you get Driveshaft up and running on your computer.  If you'd prefer to test out Driveshaft by installing it first on Heroku, you'll still need to go through the first couple of steps.  We'll let you know when you can  can skip ahead to the instructions for [deploying on Heroku]({{ site.basepath }}/heroku).

### Step 1: System Dependencies

To begin, you'll need to have a few programs installed on your computer.

<div class="highlight">
  <p class="info">The instructions below assume you are installing on a Mac using <a href="http://brew.sh/">Homebrew</a>.  If you plan to install on another operating system, <strong>please help us out</strong> by documenting the steps and issuing a pull request to our <a href="https://github.com/newsdev/driveshaft">GitHub repository</a>.</p>
</div>

**[Git](http://git-scm.com/)** to download and update the source code

    brew install git

**[Node.js](https://nodejs.org/)**, **[npm](https://docs.npmjs.com/getting-started/installing-node)** and **[Bower](http://bower.io/)** for JavaScript and CSS package management

    brew install node
    npm install -g bower

**[Ruby](https://www.ruby-lang.org/en/documentation/installation/)**, if your system doesn't already have it.

    brew install ruby

<div class="highlight">
  <p class="info">Driveshaft has been tested using <strong>Ruby 2.2.x.</strong></p>
</div>

**[Bundler](http://bundler.io/)** for ruby package management

    gem install bundler

### Step 2: Download and Run Driveshaft

1. Clone the Driveshaft repository using git, and move into its directory. (If you don't have git, you can [download]({{ site.github.repo }}/archive/v{{ site.version }}.zip) driveshaft instead.)

        git clone git@github.com:newsdev/driveshaft.git
        cd driveshaft

1. Install the JavaScript and CSS dependencies.

        bower install

1. Install the Ruby gem dependencies.

        bundle install

1. Start the server.

        puma

By default, puma will run Driveshaft on [`http://localhost:9292`](http://localhost:9292).

### Step 3: Enable Driveshaft to access other services

* [Google Drive API]({{ site.basepath }}/authentication/) so Driveshaft can access your files
* [Amazon S3]({{ site.basepath }}/s3/) file storage service to publish JSON to the internet and keep multiple versions around

### Step 4: Deploy <small>(optional)</small>

* Deploy to Heroku with [these instructions]({{ site.basepath }}/heroku/)
* Or deploy to whatever server architecture you already use

## Tour

You can try out our [demo deploy](https://gentle-caverns-1193.herokuapp.com/index) of Driveshaft on Heroku.

<div class="highlight">
  <p class="info">Driveshaft uses <strong>Adcom</strong>, an open source set of styles and jQuery plugins created for admin sites at the New York Times.  For more information, check out the <a href="https://newsdev.github.io/adcom/">documentation</a> and the <a href="https://github.com/newsdev/adcom">code</a>.</p>
</div>

### [Index Page](https://gentle-caverns-1193.herokuapp.com/index)

There are two sections:

* **Convert a file by url**. Enter a URL or Drive ID to go to a convert page for that file. Optionally list one or more S3 destinations you would like to publish to.
* **Curated list of Drive Files**. Powered by a Google Spreadsheet you can [specify in the settings]({{ site.basepath }}/reference#index-settings).

### [File Page](https://gentle-caverns-1193.herokuapp.com/1tnOVclrcAEVaDSlWPHgIZ7l9rSZMB6OideHeYf3QFpk)

* **Edit, Convert, Download**. The top of the file page links to the source file, and lets you convert + download it using any of the available formats.
* **Publish to S3**. Each S3 destination [configured](#TKTK) is listed and can be pubished to. There's a list of previous versions, each of which can be viewed or reverted to.

## Thanks

Released at the [OpenNews](http://opennews.org/) [Code Convening](http://opennews.org/blog/code-convening-wtd/) at the [2015 Write The Docs](http://www.writethedocs.org/conf/na/2015/) conference with the support of the [Knight Foundation](http://www.knightfoundation.org/) and [The Mozilla Foundation](https://www.mozilla.org/en-US/foundation/).
