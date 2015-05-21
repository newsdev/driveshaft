---
layout: page
title: Authentication
sections: [
  ['Create a Google Project', 'create-project'],
  ['Types of API Credentials', 'credentials'],
  ['Check that it works', 'check-that-it-works']
]
---

For Driveshaft to have access to Google Drive documents, you must create a set of **credentials** it can use. You must first have a Google account.

<h2 id="create-project">Step 1: Create a Project</h2>

If you already have a project, skip to [step 2](#credentials).

Go to the [Google Developers Console](https://console.developers.google.com) and click on **Create Project**.

![Click on Create Project]({{ site.baseurl }}public/img/auth_01.png)

Create a name and Project ID (the default is fine), then click on **Create**.

![Enter a name and click Create]({{ site.baseurl }}public/img/auth_02.png)

Wait for the project to initialize, and you'll be redirected to the project's home screen.

Click on **APIs & auth** on the left, and then **APIs** underneath. This will take you to the list of Google APIs that are available.

![Click on APIs & auth, then API]({{ site.baseurl }}public/img/auth_03.png)

Under **Google Apps APIs**, click on **Drive APIs**, or search for **Drive API** in the search bar.

You'll be taken to the Drive API page, where you can enable that API for your new project. Click **Enable API**.

![Click on Enable API]({{ site.baseurl }}public/img/auth_04.png)

To finish configuring your project, click on **Consent screen** underneath APIs & auth, and enter a name for your project / product.

![Click on Consent screen]({{ site.baseurl }}public/img/auth_05.png)

To create your first set of keys, go back to the navigation on the left and click on **Credentials** under the APIs & auth section.

![Click on Credentials]({{ site.baseurl }}public/img/auth_06.png)

<h2 id="credentials">Step 2: Create credentials for your project</h2>

Google offers several types of credentials. You only have to enable one for Driveshaft to access documents.

Pick a type below, and follow the instructions to create the credentials.

### 1. Public API Key

An API Key will let Driveshaft access public Google Drive files.

It's a good starting place if you're unfamiliar with OAuth, or are just experimenting with Driveshaft.

On the **Credentials** page, click on **Create new Key**. Select **Server key**.

![Click on Enable API]({{ site.baseurl }}public/img/auth_07.png)

Optional: Enter a whitelist of IP addresses. If you enter any, the key will only allow requests from computers with those addresses.

![Click on Enable API]({{ site.baseurl }}public/img/auth_08.png)

Click **Create**, and your new API Key will appear on the page.

![Click on Enable API]({{ site.baseurl }}public/img/auth_09.png)

Set the environmental variable `GOOGLE_APICLIENT_KEY` to this string of characters. For example, you could run Driveshaft with the following:

``` bash
GOOGLE_APICLIENT_KEY="AIzaSyC9HbVP3r2_ER0x8qZTW7DZnq1cnFNkpsI" puma
```

[Click here]({{ site.basepath }}/reference#environmental-variables) for more information on Driveshaft and environmental variables.

### 2. OAuth2

Google offers three options for authenticating using [OAuth2](http://oauth.net/2/). Each lets Driveshaft access public and certain private files, and give you more flexibility than public API keys.

To create OAuth credentials, go to the **Credentials** page and click on **Create new Client ID**. Then, select one of the following:

#### Type 1: Web application

This type of credential will add a "sign in" link to Driveshaft. Users can click it and give Driveshaft permission to read Google Drives they have access to.

Select **Web application**.

![Enter authorized hostnames]({{ site.baseurl }}public/img/auth_10.png)

Google requries a whitelist of hostnames that it will allow sign ins from. You should enter each hostname you'll run Driveshaft on.

By default, Driveshaft runs on `localhost` on port `9292`, so you should enter `http://localhost:9292` and `http://localhost:9292/auth/callback` respectively. Then click **Create Client ID**.

If you run Driveshaft on multiple hostnames, enter one per line. For example:

**Authorized JavaScript origins**

    http://localhost:9292
    http://nytdriveshaft.example.com

**Authorized redirect URIs**

    http://localhost:9292/auth/callback
    http://nytdriveshaft.example.com/auth/callback

Finally, click on **Download JSON** to save the credentials to your computer.

![Click on Download JSON]({{ site.baseurl }}public/img/auth_11.png)

Set the `GOOGLE_APICLIENT_CLIENTSECRETS_WEB` environmental variable to either the path to the JSON on your filesystem, or the crendential string itself.

``` bash
GOOGLE_APICLIENT_CLIENTSECRETS_WEB="~/client_secret_102...json"
GOOGLE_APICLIENT_CLIENTSECRETS_WEB="{\"web\":{\"auth_uri\":\"h..."
```

#### Type 2: Service account

Creating a service account creates a special email address that you can share files with. Driveshaft can use the service account credentials to read those files, without the user having to log in.

Since the email address is very long, you can also create a **shared folder** and grant the service account permission to read that folder. Then you can share documents with the folder.

Select **Service account**.

![Create a service account Client ID]({{ site.baseurl }}public/img/auth_12.png)

Set **Key type** to **JSON Key**, then click **Create Client ID**.

A `.json` file should start downloading, containing your service account credentials. (Create new credentials by clicking on **Generate new JSON key**.)

![Click on Generate new JSON key]({{ site.baseurl }}public/img/auth_13.png)

Set the `GOOGLE_APICLIENT_SERVICEACCOUNT` environmental variable to the path on the filesystem where it is saved, or the credential string itself.

``` bash
GOOGLE_APICLIENT_SERVICEACCOUNT="~/NYT_Driveshaft-2142...json"
GOOGLE_APICLIENT_SERVICEACCOUNT="{\"private_key_id\":\"2142..."
```

#### Type 3: Installed application

This type is for applications where the server and the user are on the same device. This is essentially what you're doing when you run Driveshaft on your computer.

Select **Installed application**.

![Create an installed application Client ID]({{ site.baseurl }}public/img/auth_14.png)

Set **Installed application type** to **Other**. (Unless you come up with an awesome way to run Driveshaft on a PlayStation.)

Click on **Download JSON** to get your credentials.

![Create an installed application Client ID]({{ site.baseurl }}public/img/auth_15.png)

Set the `GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED` environmental variable to the path on the filesystem, or the credential string itself.

``` bash
GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED="~/client_secret_102...json"
GOOGLE_APICLIENT_CLIENTSECRETS_INSTALLED="{\"installed\":{\"auth..."
```

Users will be prompted to authorize their account against Driveshaft when the server begins.

### Using Multiple Authentication Strategies

You can use any of the four authentication types simultaneously by setting multiple environmental variables (with the exception of "native" and "web" application client IDs, for which only one can be active at once).

## Check that it works

When you have enabled at least one authentication method, you should be able to view [this public spreadsheet](https://docs.google.com/spreadsheets/d/16NZKPy_kyWb_c0jBLo_sTvyoGUrs-ISG7uMDHBMgM5U/view#gid=0) within Driveshaft: [Driveshaft Test Spreadsheet](http://localhost:9292/16NZKPy_kyWb_c0jBLo_sTvyoGUrs-ISG7uMDHBMgM5U). Try clicking on **Download spreadsheet** to try out the conversion.
