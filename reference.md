---
layout: page
title: Reference
sections: [
  ['API Endpoints', 'api-endpoints'],
  ['Environmental Variables', 'environmental-variables'],
  ['Adding Formats', 'adding-formats'],
  ['Troubleshooting', 'troubleshooting']
]
---

## API endpoints

Driveshaft provides several API endpoints for converting, publishing and updating JSON. This can be helpful when creating bookmarklets or webhook integrations.

| method | endpoint | returns |
| ------ | -------- | ------- |
| GET | `/:key/download` | Converts the given file and returns the resulting JSON. |
| POST | `/:key/refresh/:destination` | Converts the given file and saves it to the given destination on S3. Also saves a timestamped copy. |
| POST | `/:key/refresh` | Converts the given file and saves it to all S3 destinations configured in the [index document](#index-settings). Also saves timestamped copies in all destinations. |
| POST | `/:key/restore/:destination` | For a given timestamped destination, replaces the non-timestamped destination with the contents of the timestamped version. |
| GET | `/:key/versions/:destination` | Returns a list of all timestamped versioned that have been generated for a given destination. |

#### Querystring options

The `download` and `refresh` endpoints let you pass an optional `format` querystring parameter. Set this to a corresponding [export formats]({{ site.baseurl }}#formats) to change how Driveshaft generates the JSON.

Destinations can be specified in any URL-like format, such as `s3://BUCKET/KEY` or `http://BUCKET/KEY`.

#### Responses

The three `POST` endpoints will return a JSON-formatted response with the status of the request, along with any error messages.

``` bash
$ curl -XPOST /:key/refresh
{"status": "success", "error": null}

$ curl -XPOST /:key/refresh/:destination
{"status": "success", "error": null}

$ curl -XPOST /:key/restore/:destination
{"status": "error", "error": "File not found: ******"}
```

All endpoints also respond to `GET` requests, for ease of use with bookmarklets.

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

## Environmental Variables

Driveshaft uses [environmental variables](http://en.wikipedia.org/wiki/Environment_variable) for settings and authenticating with other services.  The process of setting variables differs from platform to platform.  (Instructions for [setting environmental variables in development](#env-in-development) are below.)

### Google Authentication

At least one authentication key is **required** to run Driveshaft.

* Public API Key (server-side)
  * `GOOGLE_APICLIENT_KEY` A public API key.
* Service account (server-side)
  * `GOOGLE_APICLIENT_SERVICEACCOUNT` A path to, or JSON representation of, a "service account" JSON key.
* Installed application (client-side)
  * `GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED` A path to, or JSON representation of, a "native application" / "installed" client secret JSON.
  * `GOOGLE_APICLIENT_FILESTORAGE` Optional cache location. Defaults to `~/.google_drive_oauth2.json`
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

## Adding Formats

By default, Driveshaft can convert [spreadsheets and ArchieML]({{ site.baseurl }}#formats) (the default for Google Documents) to JSON, but you can add parsers for additional formats yourself.

Per-MIME Type defaults are set in `lib/driveshaft/exports.rb`.

Additional formats can be added by creating additional files in the `lib/driveshaft/exports` directory, and exposing a class method on `Driveshaft::Exports` that accepts the Drive file and a Google APIClient for making API calls.

It should return an object that can be passed directly to the AWS gems [S3::Object.put method](http://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Object.html#put-instance_method), letting you set custom permissions and metadata on the file if you wish.

## Troubleshooting

A list of errors that people have experienced in the past, with possible solutions.

If your error isn't listed, or the solution doesn't work, please [open a new Issue](https://github.com/newsdev/driveshaft/issues/new) on Github.

### Runtime errors

You might see these errors in your application logs, or in a message within the admin.

#### Redirect URI mismatch

```
Error: redirect_uri_mismatch
The redirect URI in the request: http://example.com/auth/callback did not match a registered redirect URI
```

Make sure that the [callback url]({{ site.baseurl }}authentication/#oauth-web-application) listed in your Google Project's "Web application" OAuth2 credentials includes the correct hostname and path for your app. The host should include the port if it is not 80 or 443 (e.g., `http://localhost:3000/auth/callback`), and should always end with `/auth/callback`.

If you change any of these settings, you will need to export the OAuth2 JSON again, and update it your `GOOGLE_APICLIENT_CLIENTSECRETS_WEB` variable in Heroku if necessary.

#### Internal Server Error

If you get a screen with this message, it means something has gone wrong with the application code. Look at your local server logs for a more specific error message (or if you're using Heroku, run `heroku logs -a HEROKU-APP-ID`).

#### Authentication Error

```
Authentication Error: Google OAuth2 token did not include user's email. Make sure you Google Project settings includes access to the Google+ API.
```

Try enabling the **Google+ API** on your [Google Project's settings]({{ site.baseurl }}authentication/#create-project).

#### Invalid code / Code was already redeemed

If you see this message when logging in, it means something has gone wrong with the OAuth2 callback. In the past, this has occurred when debugging a new OAuth setup. Try creating regenerating your OAuth JSON with the same settings, and trying again.

### Errors when deploying with Heroku

You might see these errors on the Heroku dashboard when creating an app for the first time with the Deploy Button, or when pushing changes to your heroku git repository.

```
There was an issue building your app. This can mean your app.json's project is not a valid Heroku application. Please ensure your app is deployable to Heroku and try again.
```

```
-----> Fetching custom git buildpack... done
-----> Multipack app detected
=====> Downloading Buildpack: https://github.com/heroku/heroku-buildpack-nodejs.git
 !     Push rejected, failed to compile Multipack app
```

```
-----> Fetching custom git buildpack... failed
 !     Push rejected, error fetching custom buildpack
```

These tend to [happen randomly](http://stackoverflow.com/a/18965269) when using custom buildpacks, and is realted to Heroku communicating with the repositories listed in [`.buildpacks`](https://github.com/newsdev/driveshaft/blob/master/.buildpacks).

**Try your command or action again and see if it works.** (Silly, but it tends to work.)
