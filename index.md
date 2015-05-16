---
layout: index
title: Home
---

## What is Driveshaft?

> Driveshaft is a [Sinatra](http://www.sinatrarb.com/) application built to turn Google Spreadsheets and Google Documents into JSON with the click of a button.

We use it at The New York Times to edit data for stories and interactives from within Google Drive files, letting multiple editors collaborate in a familiar environment.

Driveshaft was built to accomodate the following needs:

* Publishing should be a one-step process
* In addition to each Drive file's version history, all published JSON versions should be kept and be restorable
* Unlimited "destinations" can exist for any file, such as for staging and production environments
* Google Drive authentication should be invisible when possible (within a firewall) but explicit when necessary (let users authenticate with their own accounts)
* Made to deploy on Platform as a Service frameworks like Heroku
* It should work as a standalone application for users, and expose an API for automated publishing

<h2 id="getting-started">Getting started</h2>

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

4. You should now have everything needed to start up Driveshaft.

        puma

  This should start Driveshaft running on [`http://localhost:9292`](http://localhost:9292).

<h2 id="authentication">Authentication</h2>

For Driveshaft to have access to Google Drive documents, you must enable at least one type of authentication.

These types range from a simple API Key to more complex sets of [OAuth2](http://oauth.net/2/) credentials. Whichever you choose, you must first have a Google account and create a "Project" in the Google Developers Console.

To configure Driveshaft to use authentication, you'll need to set **environmental variables** on your system. There are many ways to do this, but here are two examples. If you need to set the variable MY_VARIABLE to "my value", you can do so in either of these ways:

1. When running Driveshaft with `puma`, add the variable and value before the `puma` command. You can do this with multiple variables in a row.

    ``` bash
    MY_VARIABLE="my value" puma
    ```

2. Create or modify a file called `~/.bash_profile` and "export" the variables, one on each line. When you open a new Terminal window, the variables will have their values set automatically.

    ``` bash
    export MY_VARIABLE="my value"
    ```

### Create a Project for Google API Access

Go to the [Google Developers Console](https://console.developers.google.com) and click on "Create Project."

![Click on Create Project]({{ site.baseurl }}public/img/auth_01.png)

Create a name and Project ID (the default is fine), and click on **Create**.

![Enter a name and click Create]({{ site.baseurl }}public/img/auth_02.png)

Wait for the project to initialize, at which point you should be redirected to the Project's home screen.

On the navigation on the left, click on **APIs & auth**, and then **APIs** in the submenu that opens up. This will take you to the list of Google APIs that are available.

![Click on APIs & auth, then API]({{ site.baseurl }}public/img/auth_03.png)

Click on **Drive API** under **Google Apps APIs**, or search for **Drive API** in the search bar and click on **Enable**.

You'll be taken to the Drive API page, where you can enable that API for your new project. Click **Enable API**.

![Click on Enable API]({{ site.baseurl }}public/img/auth_04.png)

Once the API has been enabled, API keys and credentials associated with your project will be able to use the Drive API.

To finish configuring your project, click on **Consent screen** underneath APIs & auth, and enter a name for your project / product.

![Click on Consent screen]({{ site.baseurl }}public/img/auth_05.png)

To create your first set of keys, go back to the navigation on the left and click on **Credentials** under the APIs & auth section.

![Click on Credentials]({{ site.baseurl }}public/img/auth_06.png)

There are several types of keys you can use, and you only have to enable one for Driveshaft to work.

### Types of API Credentials

#### 1. Public API Key

An API Key is the easiest method. If this is your first time using OAuth, start with this. It will allow you to access public Google Drive files.

On the **Credentials** page, click on **Create new Key**. Select **Server key**.

![Click on Enable API]({{ site.baseurl }}public/img/auth_07.png)

You'll be presented with the opportunity to restrict access to these credentials to a list of IP addresses. For example, you could enter the IP address of your server, or your company's firewall. Or you can leave this blank to allow access from anywhere.

![Click on Enable API]({{ site.baseurl }}public/img/auth_08.png)

Click **Create**, and your new API Key will appear on the page.

![Click on Enable API]({{ site.baseurl }}public/img/auth_09.png)

Using one of the methods above, set the environmental variable `GOOGLE_APICLIENT_KEY` to this string of characters. For example, you could run Driveshaft with the following:

``` bash
GOOGLE_APICLIENT_KEY="AIzaSyC9HbVP3r2_ER0x8qZTW7DZnq1cnFNkpsI" puma
```

---

The last three options use OAuth2. This gives you more flexibility in the types of documents you can access. While the API Key above only lets you read public documents, these methods let you read private documents shared either with a special account for Driveshaft or the user.

To create OAuth credentials, click on **Create new Client ID** on the **Credentials** page, and select one of the following.

#### 2. OAuth: Web application

This type of credential will allow users to sign into Driveshaft, and authorize it to read their Google Drive files. Pick this if you want users to be able to convert any of their files.

![Create a web application Client ID]({{ site.baseurl }}public/img/auth_10.png)

You will need to add lines to **Authorized JavaScript origins** and **Authorized redirect URIs** for each hostname you plan to run Driveshaft on. If you're running Driveshaft locally on port `9292`, you should enter what's in the screenshot: `http://localhost:9292` and `http://localhost:9292/auth/callback` respectively. Then click **Create Client ID**.

You can enter lines for multiple hostnames if you plan to run Driveshaft on, say, your own laptop and on a server with the url `http://nytdriveshaft.example.com`.

![Enter authorized hostnames]({{ site.baseurl }}public/img/auth_10.png)

Finally, click on **Download JSON** to save the credentials to your computer.

![Click on Download JSON]({{ site.baseurl }}public/img/auth_11.png)

To use them in Driveshaft, you can set the `GOOGLE_APICLIENT_CLIENTSECRETS_WEB` environmental variable to either the path on your filesystem where they are saved, or to crendential string itself.

``` bash
GOOGLE_APICLIENT_CLIENTSECRETS_WEB="~/client_secret_102...json"
GOOGLE_APICLIENT_CLIENTSECRETS_WEB="{\"web\":{\"auth_uri\":\"h..."
```

Users will then be able to click on "sign in" in Driveshaft's navigation, and authorize Driveshaft.

#### 3. OAuth: Service account

Service accounts are different in that instead of reading files from a user's account, they are authorized to read files that are explicitly shared with the service account.

Each service account gets its **own email address**. If you **share a file with that email**, and use the account's credentials in Driveshaft, all users will be able to convert those files, regardless of whether their personal account has access to them.

At The New York Times, we use this by creating a "shared folder" that we save documents into, and we give the service account permission to read all documents within that folder. This prevents users from having to authenticate against their own accounts.

![Create a service account Client ID]({{ site.baseurl }}public/img/auth_12.png)

Be sure that **JSON Key** is selected for "Key type", then click **Create Client ID**.

A `.json` file should automatically. This contains your service account credentials. Or, you can always click on **Generate new JSON key** to create a new set of credentials.

![Click on Generate new JSON key]({{ site.baseurl }}public/img/auth_13.png)

Just like the web application credentials, set the `GOOGLE_APICLIENT_SERVICEACCOUNT` environmental variable to their path on the filesystem, or the credential string itself.

``` bash
GOOGLE_APICLIENT_SERVICEACCOUNT="~/NYT_Driveshaft-2142...json"
GOOGLE_APICLIENT_SERVICEACCOUNT="{\"private_key_id\":\"2142..."
```

#### 4. OAuth: Installed application

This type of credential is made for applications running locally on a device, as opposed to users accessing an application running on a server. This is essentially what you're doing when you run Driveshaft locally on your computer.

Be sure to select **Other** for **Installed application type** (unless you come up with an awesome way to run Driveshaft on a PlayStation).

![Create an installed application Client ID]({{ site.baseurl }}public/img/auth_14.png)

Click on **Download JSON** to get your credentials.

![Create an installed application Client ID]({{ site.baseurl }}public/img/auth_15.png)

Once again, set the `GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED` environmental variable to their path on the filesystem, or the credential string itself.

``` bash
GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED="~/client_secret_102...json"
GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED="{\"installed\":{\"auth..."
```

Users will be prompted to authorize their account against Driveshaft.

---

You can use any of the four authentication types simultaneously by setting multiple environmental variables (with the exception of "native" and "web" application client IDs, for which only one can be active at once).

Once at least one authentication method is enabled, you should be able to view [this public spreadsheet](https://docs.google.com/spreadsheets/d/16NZKPy_kyWb_c0jBLo_sTvyoGUrs-ISG7uMDHBMgM5U/view#gid=0) within Driveshaft: [Driveshaft Test Spreadsheet](http://localhost:9292/16NZKPy_kyWb_c0jBLo_sTvyoGUrs-ISG7uMDHBMgM5U). Try clicking on **Download spreadsheet** to try out the conversion.

<h2 id="s3">Publishing to S3</h2>

Now that you can access your files and convert them into JSON, the next step is to publish them to S3.

To start, you'll need to have or sign up for an [Amazon Web Services](https://aws.amazon.com/) account.

### Create or select an S3 bucket.

Log in to the [AWS console](https://console.aws.amazon.com), go to the [S3 home](https://console.aws.amazon.com/s3/home). (S3 stands for for Simple Storage Service. You can think of it as a filesystem in the cloud).

Create an **S3 Bucket** by clicking on **Create Bucket**. This bucket needs to have a globally unique name. It's common to name buckets after a domain name you control, for example, `assets.nytimes.com`.

![Click on Create Bucket]({{ site.baseurl }}public/img/s3_01.png)

### Create an IAM user for Driveshaft

Go to the [IAM > Users](https://console.aws.amazon.com/iam/home#users) section of the console (short for "Identity and Access Management"). Click on **Create New Users**.

![Click on Create New Users]({{ site.baseurl }}public/img/s3_02.png)

Give your Driveshaft user a name, and click **Create**. Then click on your new account name on the Users page.

Click on **Manage Access Keys**, and then **Create Access Key**.

![Click on Manage Access Keys]({{ site.baseurl }}public/img/s3_05.png)

You will be presented with two variables: an access key and a secret access key. Store these in a safe place.

![Note your IAM credentials]({{ site.baseurl }}public/img/s3_06.png)

Enter these in the following environmental variables:

``` bash
AWS_ACCESS_KEY_ID="*********"
AWS_SECRET_ACCESS_KEY="*********"
AWS_REGION="us-east-1" # or another region
```

### Authorize the user to access your S3 bucket

![Enter a user id]({{ site.baseurl }}public/img/s3_03.png)

Click on the **Create User Policy** button.

![Click on Create User Policy]({{ site.baseurl }}public/img/s3_04.png)

This will let you give this user specific S3 buckets and API actions it is allowed to access. This is essential for protecting the rest of your AWS account, should your credentials ever be compromised.

The syntax for these rules (or "policies") is [extremely esoteric](http://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies.html). So we have an sample policy here that you can enter in the **Custom Policy** section that gives access to a single S3 bucket.

``` json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Put*",
        "s3:List*",
        "s3:Get*",
        "s3:Delete*"
      ],
      "Resource": [
        "arn:aws:s3:::assets.nytimes.com/*",
        "arn:aws:s3:::assets.nytimes.com"
      ]
    }
  ]
}
```

### Try out S3

You should now be able to publish to your S3 bucket from Driveshaft. Try publishing this publish spreadsheet to a destination on your S3 bucket. Enter the following into the form on the [main page](http://localhost:9292/index) and hit **Submit**:

* **key**: `16NZKPy_kyWb_c0jBLo_sTvyoGUrs-ISG7uMDHBMgM5U`
* **destination**: `s3://assets.nytimes.com/spreadsheet.json`

![Enter an S3 destination]({{ site.baseurl }}public/img/s3_07.png)

Next, click on **Publish to assets.nytimes.com** (but with the name of your bucket).

![Enter an S3 destination]({{ site.baseurl }}public/img/s3_08.png)

If the publish is successful, you'll see a log of the published versions below.

![Enter an S3 destination]({{ site.baseurl }}public/img/s3_09.png)

You can use the **Restore** button next to any previous timestamp to revert to that version of the json.

On S3, the canonical or latest version of a file is stored at the destination you specify (like `s3://assets.nytimes.com/spreadsheet.json`). But a second timestamped file is kept for every version, for example:

`s3://assets.nytimes.com/spreadsheet-20150515-120000.json`

When you **publish** a file, the canonical version is updated, and a new timestamped version is created. When you **restore** a version, the canonical version is replaced with the version you specify.

<h2 id="heroku">Heroku</h2>

Driveshaft was built to deploy on PaaS (or "Platform as a Service") architecture like [Heroku](https://www.heroku.com/).

Heroku has a great [Getting Started with Ruby on Heroku](https://devcenter.heroku.com/articles/getting-started-with-ruby) guide you can follow to deploy Driveshaft. A default Procfile is already included.

You'll have to set the same [environmental variables](#reference-environmental-variables) you set locally in order to access the Google Drive API and publish your files to S3.

<h2 id="reference">Reference</h2>

<h3 id="reference-api-endpoits">API endpoints</h3>

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

<h3 id="reference-environmental-variables">Environmental variables</h3>

None of these is required, but enabling each section adds a category of functionality.

#### Amazon Web Services (AWS)

*Required to save and serve versioned files to S3*. More information in Amazon's [documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingCredentials.html#Using_CreateAccessKey).

* `AWS_ACCESS_KEY_ID` The access key of your user or [IAM](http://aws.amazon.com/iam/) accont.
* `AWS_SECRET_ACCESS_KEY` The secret key corresponding to your access key.
* `AWS_REGION` The AWS region to use for S3 (e.g., `us-east-1`).

#### Google Authentication

*Required to enable access to non-public files*

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
