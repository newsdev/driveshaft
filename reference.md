---
layout: page
title: Reference
sections: [
  ['API Endpoints', 'api-endpoints'],
  ['Environmental Variables', 'environmental-variables']
]
---

<h2 id="api-endpoints">API Endpoints</h2>

The API endpoints can be used in webhooks or bookmarkets to automate publishing.

In the following endpoints:

* `key` a Google Drive file ID
* `format` the export format, by default either `spreadsheet` for spreadsheets or `archieml` for documents
* `version` a version timestamp for a file in `YYYYMMDD-HHMMSS` format
* `destination` a URL-formatted S3 destination. Examples:
  * `s3://BUCKET/KEY`
  * `http://BUCKET/KEY`
  * `http://BUCKET.s3.amazonaws.com/KEY`
  * `http://s3.amazonaws.com/BUCKET/KEY`

#### GET `/:key/download[?format=:format]`

Returns the file converted into the requested format.

#### GET `/:key/refresh[/:destination]`

Publishes the file to either all endpoints configured for a given key, or just to a specific destination.

#### GET `/:key/restore/:version`

Restores the published JSON to the specified version.

#### GET `/:key/versions/:destination.json`

An array of all published versions of this file.

Example response:

``` json
[
  {
    "bucket": "assets.nytimes.com",
    "key": "spreadsheet.json",
    "url": "[published url]",
    "presigned_url": "[published url]",
    "etag": "30be746b74321851db5f9050e7e569cc",
    "timestamp": "20150514-232304",
    "copy": false,
    "display": "Thu May 14 04:23 PM PDT"
  }
]
```

<h2 id="environmental-variables">Environmental Variables</h2>

None of these is required, but enabling each section adds a category of functionality.

#### Amazon Web Services (AWS)

*Required to save and serve versioned files to S3*. More information in Amazon's [documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingCredentials.html#Using_CreateAccessKey).

* `AWS_ACCESS_KEY_ID` The access key of your user or [IAM](http://aws.amazon.com/iam/) accont.
* `AWS_SECRET_ACCESS_KEY` The secret key corresponding to your access key.
* `AWS_REGION` The AWS region to use for S3 (e.g., `us-east-1`).

#### Google Authentication

*Required to enable access to non-public files*

* Public API Key (server-side)
  * `GOOGLE_APICLIENT_KEY` A public API.
* Service account (server-side)
  * `GOOGLE_APICLIENT_SERVICEACCOUNT` A path to, or JSON representation of, a "service account" JSON key.
* Installed application (client-side)
  * `GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED` A path to, or JSON representation of, a "native application" / "installed" client secret JSON.
  * `GOOGLE_APICLIENT_FILESTORAGE` (defaults to `~/.google_drive_oauth2.json`)
* Web application (client-side)
  * `GOOGLE_APICLIENT_CLIENTSECRETS_WEB` A path to, or JSON representation of, a "web application" client secret JSON.

#### Driveshaft Settings

* `DRIVESHAFT_SETTINGS_AUTH_REQUIRED` (default: `false`) If `true`, then successful client-side authentication will be required to access any page. Useful for deploys on Heroku or other natively public platforms.
* `DRIVESHAFT_SETTINGS_AUTH_DOMAIN` (default: none) If specified, allows client-side authentication for users within the specified domain only.

*Required to use a Google Spreadsheet to configure S3 destinations and have an index page listing of all available files.* Using [this spreadsheet](https://docs.google.com/spreadsheets/d/16NZKPy_kyWb_c0jBLo_sTvyoGUrs-ISG7uMDHBMgM5U/view) as a base, create a spreadsheet with information of what documents should be included on your index page.

* `DRIVESHAFT_SETTINGS_INDEX_DESTINATION` A url-formatted destination on S3 to which the configuration will be built (e.g., s3://BUCKET/PATH).
* `DRIVESHAFT_SETTINGS_INDEX_KEY` The Google Drive key of this spreadsheet.
