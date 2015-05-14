---
layout: index
title: Home
---

## What is Driveshaft?

## Setup / getting the app running

By the end of this, they should be able to access a file page and download json.


## Google Authentication

For Driveshaft to have access to your Google Drive documents, you must enable at least one of three types of authentication.

The first method ties Driveshaft's access to a "Service Account." All documents shared with this address will be accessible to all users in Driveshaft, and users will not be required to have a Google account, or authenticate themselves.

The second method is the more traditional client-side authentication, where a user with a Google Drive account can give Driveshaft access, letting them access any of their own documents within Driveshaft.

Either method, or both, can be enable by enabling the required environmental variables.

### Create a "Project" for Google API Access

### Server authentication (Service account)

### User authentication (Client-side / Javascript)

## S3 Authentication

## Environmental variable references

None of these is required, but enabling each section adds a category of functionality.

Amazon Web Services (AWS)

*Required to save and serve versioned files to S3*. More information in Amazon's [documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingCredentials.html#Using_CreateAccessKey).

* **`AWS_ACCESS_KEY_ID`** - The access key of your user or [IAM](http://aws.amazon.com/iam/) accont.
* **`AWS_SECRET_ACCESS_KEY`** - The secret key corresponding to your access key.
* **`AWS_REGION`** - The AWS region to use for S3 (e.g., `us-east-1`).

Google Authentication

*Required to enable access to non-public files*

* Service account (server-side)
  * **`GOOGLE_APICLIENT_SERVICEACCOUNT`** - A path to, or JSON representation of, a "service account" JSON key.
* Installed application (client-side)
  * **`GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED`** - A path to, or JSON representation of, a "native application" / "installed" client secret JSON.
  * **`GOOGLE_APICLIENT_FILESTORAGE`** - TKTK
* Web application (client-side)
  * **`GOOGLE_APICLIENT_CLIENTSECRETS_WEB`** - A path to, or JSON representation of, a "web application" client secret JSON.

Driveshaft

* **`DRIVESHAFT_SETTINGS_AUTH_REQUIRED`** - (default: `false`) If `true`, then successful client-side authentication will be required to access any page. Useful for deploys on Heroku or other natively public platforms.
* **`DRIVESHAFT_SETTINGS_AUTH_DOMAIN`** - (default: none) If specified, allows client-side authentication for users within the specified domain only.

*Required to use a Google Spreadsheet to configure S3 destinations and have an index page listing of all available files.* Using [this spreadsheet] as a base, create a spreadsheet with information of what documents should be included on your index page.

* **`DRIVESHAFT_SETTINGS_INDEX_DESTINATION`** - A url-formatted destination on S3 to which the configuration will be built (e.g., s3://BUCKET/PATH).
* **`DRIVESHAFT_SETTINGS_INDEX_KEY`** - The Google Drive key of this spreadsheet.
