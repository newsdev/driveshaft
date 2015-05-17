---
layout: page
title: Authentication
sections: [
  ['Create a Google Project', 'create-project'],
  ['Types of API Credentials', 'credentials']
]
---

For Driveshaft to have access to Google Drive documents, you must enable at least one type of authentication.  Whichever you choose, you must first have a Google account and create a "Project" in the Google Developers Console.

<h2 id="create-project">Create a Project for Google API Access</h2>

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

<h2 id="credentials">Types of API Credentials</h2>

Google offers several types of keys for authentication; you only have to enable one for Driveshaft to work.

### 1. Public API Key

Using a public API Key is the easiest method, and a good starting place if you're unfamiliar with OAuth to authentication or just experimenting with Driveshaft. It will allow Driveshaft to access public Google Drive files.

On the **Credentials** page, click on **Create new Key**. Select **Server key**.

![Click on Enable API]({{ site.baseurl }}public/img/auth_07.png)

You'll be presented with the opportunity to restrict access to these credentials to a list of IP addresses. For example, you could enter the IP address of your server, or your company's firewall. Or you can leave this blank to allow access from anywhere.

![Click on Enable API]({{ site.baseurl }}public/img/auth_08.png)

Click **Create**, and your new API Key will appear on the page.

![Click on Enable API]({{ site.baseurl }}public/img/auth_09.png)

Set the environmental variable `GOOGLE_APICLIENT_KEY` to equal this string of characters. For example, you could run Driveshaft with the following:

``` bash
GOOGLE_APICLIENT_KEY="AIzaSyC9HbVP3r2_ER0x8qZTW7DZnq1cnFNkpsI" puma
```

[Click here]({{ site.basepath }}/reference#environmental-variables) for more information on Driveshaft and environmental variables.

### 2. OAuth2

Google offers three options for authenticating using [OAuth2](http://oauth.net/2/). Each will let Driveshaft access private as well as public documents, and give you more flexibility than the public API key authentication method provides.

To create OAuth credentials, click on **Create new Client ID** on the **Credentials** page, and select one of the following.

#### OAuth: Web application

This type of credential will allow Driveshaft to read a given user's private Google Drive files.  The first time a user visits Driveshaft, he will be prompted automatically to "sign in" to Google and authorize Driveshaft to have this level of access.

After clicking on **Create new Client ID** on the **Credentials** page, select "Web application" as the application type.

![Enter authorized hostnames]({{ site.baseurl }}public/img/auth_10.png)

You will need to add lines to **Authorized JavaScript origins** and **Authorized redirect URIs** for each hostname at which you plan to run Driveshaft, including your localhost. For example, if you're running Driveshaft locally on port `9292`, you should enter what's in the screenshot: `http://localhost:9292` and `http://localhost:9292/auth/callback` respectively. Then click **Create Client ID**.

You can enter additional lines for each hostnames at which you plan to run Driveshaft. If you want to run Driveshaft on `http://nytdriveshaft.example.com` as well as locally, **Authorized JavaScript origins** might look like this

    http://localhost:9292
    http://nytdriveshaft.example.com

and **Authorized redirect URIs** like this

    http://localhost:9292/auth/callback
    http://nytdriveshaft.example.com/auth/callback

Finally, click on **Download JSON** to save the credentials to your computer.

![Click on Download JSON]({{ site.baseurl }}public/img/auth_11.png)

To use the credentials in Driveshaft, set the `GOOGLE_APICLIENT_CLIENTSECRETS_WEB` environmental variable to either the path on your filesystem where they are saved, or to crendential string itself.

``` bash
GOOGLE_APICLIENT_CLIENTSECRETS_WEB="~/client_secret_102...json"
GOOGLE_APICLIENT_CLIENTSECRETS_WEB="{\"web\":{\"auth_uri\":\"h..."
```

#### OAuth: Service account

Instead of giving Driveshaft access to a particular user's account, you can configure it to read files that are explicitly shared with a **service account.**  Each service account has its own email address. If a user shares a file with that address, all Driveshaft users will be able to convert those files, regardless of whether their personal account has access to them.

At The New York Times, we created a "shared folder" that we save documents into, and granted service account permission to read all documents within that folder. This removed the need for users to authenticate against their own accounts.

After clicking on **Create new Client ID** on the **Credentials** page, select "Service account" as the application type.

![Create a service account Client ID]({{ site.baseurl }}public/img/auth_12.png)

Be sure that **JSON Key** is selected for "Key type", then click **Create Client ID**.

A `.json` file should automatically be saved to your computer. This gile contains your service account credentials. (You can always click on **Generate new JSON key** to create a new set of credentials.)

![Click on Generate new JSON key]({{ site.baseurl }}public/img/auth_13.png)

Set the `GOOGLE_APICLIENT_SERVICEACCOUNT` environmental variable to the path on the filesystem where it is saved, or the credential string itself.

``` bash
GOOGLE_APICLIENT_SERVICEACCOUNT="~/NYT_Driveshaft-2142...json"
GOOGLE_APICLIENT_SERVICEACCOUNT="{\"private_key_id\":\"2142..."
```

#### OAuth: Installed application

This type of credential is for applications running and being accessed locally on a device, rather than on a remote on server. This is essentially what you're doing when you run Driveshaft on your computer.

After clicking on **Create new Client ID** on the **Credentials** page, select "Installed application" as the application type.


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

### Using Multiple Authentication Strategies

You can use any of the four authentication types simultaneously by setting multiple environmental variables (with the exception of "native" and "web" application client IDs, for which only one can be active at once).

## Testing

When you have enabled at least one authentication method, you should be able to view [this public spreadsheet](https://docs.google.com/spreadsheets/d/16NZKPy_kyWb_c0jBLo_sTvyoGUrs-ISG7uMDHBMgM5U/view#gid=0) within Driveshaft: [Driveshaft Test Spreadsheet](http://localhost:9292/16NZKPy_kyWb_c0jBLo_sTvyoGUrs-ISG7uMDHBMgM5U). Try clicking on **Download spreadsheet** to try out the conversion.
