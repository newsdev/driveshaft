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

There are several types of keys you can use, and you only have to enable one for Driveshaft to work.

<h2 id="credentials">Types of API Credentials</h2>

### 1. Public API Key

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

### 2. OAuth: Web application

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

### 3. OAuth: Service account

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

### 4. OAuth: Installed application

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
