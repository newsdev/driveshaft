---
layout: page
title: Reference
sections: [
  ['API Endpoints', 'api-endpoints'],
  ['Environmental Variables', 'environmental-variables'],
  ['Adding Formats', 'adding-formats']
]
---

<h2 id="api-endpoints">API Endpoints</h2>

| method | endpoint | returns |
| ------ | -------- | ------- |
| GET | `/:key/download` | Converts the given file and returns the resulting JSON. |
| POST | `/:key/refresh/:destination` | Converts the given file and saves it to the given destination on S3. Also saves a timestamped copy. |
| POST | `/:key/refresh` | Converts the given file and saves it to all S3 destinations configured in the [index document](#index-settings). Also saves timestamped copies in all destinations. |
| POST | `/:key/restore/:destination` | For a given timestamped destination, replaces the non-timestamped destination with the contents of the timestamped version. |
| GET | `/:key/versions/:destination` | Returns a list of all timestamped versioned that have been generated for a given destination. |

#### Querystring options

The `download` and `refresh` endpoints accept an optional `format` querystring parameter, corresponding to one of the [export formats]({{ site.baseurl }}#formats).

Destinations can be specified in any URL-like format, such as `s3://BUCKET/KEY` or `http://BUCKET/KEY`.

#### Responses

The three `POST` endpoints will return a JSON-formatted response with the status of the request along with any error messages.

``` bash
$ curl -XPOST /:key/refresh
{"status": "success", "error": null}

$ curl -XPOST /:key/refresh/:destination
{"status": "success", "error": null}

$ curl -XPOST /:key/restore/:destination
{"status": "error", "error": "File not found: ******"}
```

All endpoints also respond to `GET` requests, for use with bookmarklets.

The `versions` endpoint returns an array of objects in the following format:

``` ruby
[
  {
    "bucket": "assets.nytimes.com",
    "key": "spreadsheet.json",
    "url": "[published url]",
    "presigned_url": "[presigned published url]",
    "etag": "30be746b74321851db5f9050e7e569cc",
    "timestamp": "20150514-232304",
    "display": "Thu May 14 04:23 PM PDT",

    # Whether this file is a dup of an earlier version
    "copy": false
  }
]
```

<h2 id="environmental-variables">Environmental Variables</h2>

Driveshaft relies on [environmental variables](http://en.wikipedia.org/wiki/Environment_variable) for configuration and authentication.  The process of setting variables differs from platform to platform.  (Instructions for [setting environmental variables in development](#env-in-development) are below.)

Most of the variables listed here are not required to run Driveshaft; each category of variable, however, enables additional functionality.

### Google Authentication

One or more of the following four authentication keys is **required to run Driveshaft**:

* Public API Key (server-side)
  * `GOOGLE_APICLIENT_KEY` A public API key.
* Service account (server-side)
  * `GOOGLE_APICLIENT_SERVICEACCOUNT` A path to, or JSON representation of, a "service account" JSON key.
* Installed application (client-side)
  * `GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED` A path to, or JSON representation of, a "native application" / "installed" client secret JSON.
  * `GOOGLE_APICLIENT_FILESTORAGE` Optional. Defaults to `~/.google_drive_oauth2.json`
* Web application (client-side)
  * `GOOGLE_APICLIENT_CLIENTSECRETS_WEB` A path to, or JSON representation of, a "web application" client secret JSON.

<div class="highlight">
  <p class="info">Most users will choose only a single authentication strategy.  Some, however, may choose to use a combination of strategies.  For example, setting authentication variables for both service account and web application would allow all users to access files shared with the service account's email address as well as to their own files.</p>
</div>

### Amazon Web Services (AWS)

**Required to save and serve versioned files to S3**. More information in Amazon's [documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingCredentials.html#Using_CreateAccessKey).

* `AWS_ACCESS_KEY_ID` The access key of your user or [IAM](http://aws.amazon.com/iam/) accont.
* `AWS_SECRET_ACCESS_KEY` The secret key corresponding to your access key.
* `AWS_REGION` The AWS region to use for S3 (e.g., `us-east-1`).

### Driveshaft Settings

* `DRIVESHAFT_SETTINGS_AUTH_REQUIRED` (default: `false`) If `true`, then successful client-side authentication will be required to access any page. Useful for deploys on Heroku or other natively public platforms.
* `DRIVESHAFT_SETTINGS_AUTH_DOMAIN` (default: none) If specified, allows client-side authentication for users within the specified domain only.
* `DRIVESHAFT_SETTINGS_MAX_VERSIONS` If set, only this number of versions of a file will be kept. Older versions will be removed.

<span id="index-settings"></span>
The following variables are **required to list available files and their S3 destinations** on the Driveshaft index page.

* `DRIVESHAFT_SETTINGS_INDEX_KEY` The Google Drive key of a Google Spreadsheet that lists files and their destinations.  The spreadsheet should use [this format](https://docs.google.com/spreadsheets/d/16NZKPy_kyWb_c0jBLo_sTvyoGUrs-ISG7uMDHBMgM5U/view).
* `DRIVESHAFT_SETTINGS_INDEX_DESTINATION` A url-formatted destination on S3 to which the configuration will be built (e.g., s3://BUCKET/PATH).

<h3 id="env-in-development">Using Environmental Variables in Development</h3>

There are two common methods for running Driveshaft with environmental variables on your your own computer:

1. Adding one or more variable name/value pairs at the beginning of the command that runs the server:

    ``` bash
    VAR_A="value a" VAR_B="value b" puma
    ```

2. "Exporting" the variables from your `~/.bash_profile` file.  Name/value pairs should be added one per line.

    ``` bash
    export VAR_A="value a"
    export VAR_B="value b"
    ```

Restart your terminal window after editing this file for the variables to be available next time you run Driveshaft.

<h2 id="adding-formats">Adding Formats</h2>

By default, Driveshaft can convert [spreadsheets and ArchieML]({{ site.basepath}}/#formats) (the default for Google Documents) to JSON, but you can add parsers for additional formats yourself.

Per-MIME Type defaults are set in `lib/driveshaft/exports.rb`.

Additional formats can be added by creating additional files in the `lib/driveshaft/exports` directory, and exposing a class method on `Driveshaft::Exports` that accepts the Drive file and a Google APIClient for making API calls.

It should return an object that can be passed directly to the AWS gems [S3::Object.put method](http://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Object.html#put-instance_method), letting you set custom permissions and metadata on the file if you wish.
