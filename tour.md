---
layout: page
title: Tour
sections: [
  ['Index Page', 'index-page'],
  ['File Page', 'file-page']
]
---

You can try out our [demo deploy](https://gentle-caverns-1193.herokuapp.com/index) of Driveshaft on Heroku.

<div class="highlight">
  <p class="info">Driveshaft uses <strong>Adcom</strong>, an open source set of styles and jQuery plugins created for admin sites at the New York Times.  For more information, check out the <a href="https://newsdev.github.io/adcom/">documentation</a> and the <a href="https://github.com/newsdev/adcom">code</a>.</p>
</div>

## [Index Page](https://gentle-caverns-1193.herokuapp.com/index)

There are two sections:

* **Convert a file by url**. Enter a URL or Drive ID to go to a convert page for that file. Optionally list one or more S3 destinations you would like to publish to.
* **Curated list of Drive Files**. Powered by a Google Spreadsheet you can [specify in the settings](#TKTK).

## [File Page](https://gentle-caverns-1193.herokuapp.com/1tnOVclrcAEVaDSlWPHgIZ7l9rSZMB6OideHeYf3QFpk)

* **Edit, Convert, Download**. The top of the file page links to the source file, and lets you convert + download it using any of the available formats.
* **Publish to S3**. Each S3 destination [configured](#TKTK) is listed and can be pubished to. There's a list of previous versions, each of which can be viewed or reverted to.
