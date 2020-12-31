# Contributing to DataConnectorConfigs

[Pull requests](#pull-request) are welcome. 

* [Add Example Code](#add-example-code)
* [Add Configuration Files](#add-configuration-files)


# Add Example Code
Demonstrate what data can be collected from each Web API through interesting and diverse examples.

An example consists of three parts:
1. An interesting question
2. Code (with comments)
3. A result table

Here is an example of the Yelp API:

1. **Question**: What's the phone number of Capilano Suspension Bridge Park?
2. **Code**:
```python
from dataprep.connector import Connector

# You can get ”yelp_access_token“ by following https://www.yelp.com/developers/documentation/v3/authentication
conn_yelp = Connector("yelp", _auth={"access_token": yelp_access_token}, _concurrency = 5)

df = await conn_yelp.query("businesses", term = "Capilano Suspension Bridge Park", location = "Vancouver", _count = 1)

df[["name","display_phone"]]
```

3. **A result table**:

   | id  | name                            | display_phone   |
   | --- | ------------------------------- | --------------- |
   | 0   | Capilano Suspension Bridge Park | +1 604-985-7474 |


# Add Configuration Files

We will go over how to make a configuration file using Yelp's API as an example.  

We recommend you read through the Yelp API documentation and review what the available endpoints are at this [link](https://www.yelp.com/developers/documentation/v3/get_started). 

- [Contributing to DataConnectorConfigs](#contributing-to-dataconnectorconfigs)
- [Add Example Code](#add-example-code)
- [Add Configuration Files](#add-configuration-files)
  - [What is the config file?](#what-is-the-config-file)
  - [Getting started](#getting-started)
    - [Understanding API Authorization](#understanding-api-authorization)
    - [Obtaining your Auth method](#obtaining-your-auth-method)
  - [Creating the config files](#creating-the-config-files)
    - [Create the meta.json file](#create-the-metajson-file)
    - [Create the [table].json file](#create-the-tablejson-file)
      - [Request:](#request)
      - [Response:](#response)
  - [That's all for now!](#thats-all-for-now)
- [Pull Request](#pull-request)

## What is the config file?

DataPrep.Connector enables users who wish to include APIs in their code to do so without worrying about the overhead of learning how to work with each API. 

A **config file** is what DataPrep.Connector needs in order to make these APIs available for users. Contributors like you create these config files (one per API). They include all the nitty-gritty details on the API like the auth methods, parameters, schema, and more, so that the tool can handle them. This is what allows users to not have to worry about figuring out too many of the specifics of the API when using our tool.

## Getting started

### Understanding API Authorization

Many APIs require **authentication** and **authorization** (often abbreviated as auth). These are how the APIs can 1) track who is invoking API calls and 2) allow them to invoke said API calls. Often, in order to obtain the instructions, credentials and/or access tokens for these, you have to register a developer account or app with an API. This is usually the first thing you see on the API's documentation.

For example, on the [Yelp API's documentation](https://www.yelp.com/developers/documentation/v3), you can see the Authentication guide linked under the "Introduction" section.



<img src=".assets/Yelp_Authentication.png" width="600"/>

### Obtaining your Auth method

As you can see, for the Yelp API, we must first create and register an app with Yelp. Don't worry, this doesn't mean you need to create an app first. It's just registering a future application. 

Once we do this, we will obtain an **API Key**. It's like your own personal login. Sometimes this will be called a token, or a secret, or something different. **Remember that this key should be treated like a password.** 

 Next, you can see Yelp uses the Bearer auth method. There are multiple methods for auth, and DataPrep.Connector supports the following:

1. OAuth
2. Query Parameter
3. Bearer
4. Header

*Note*: The auth method is how the API chooses to authenticate and authorize its users. An API key, access token, client secret & client ID, or whatever else it may be called, is the login you use for this method. For example, for Yelp, we use the Bearer method with an API key.

## Creating the config files
The data connector requires two files to run, meta.json and table.json.

### Create the meta.json file

The meta.json file tells DataPrep.Connector tool how many tables are in the data source and which tables to access. It contains the names of these tables. The meta.json file needs to be manually written.

<img src=".assets/Yelp_meta.png"  width="600"/>

### Create the [table].json file

Depending on how many tables of data the API provides, you can decide which and how many tables to create. Each of these tables maps to a [table].json file. This [table].json file includes details on how to interact with the API, as well as information on what is returned and passed in.

For example, let's take a look at the Yelp API. It returns businesses with details on the businesses. So it makes sense to create a businesses.json file. Take a look at other config files to get a better sense of the [table].json files.

<img src=".assets/Yelp_rnr.png" width="600"/>

Let's break down the components of the [table].json file. 

#### Request:

<img src=".assets/Yelp_request.png" width="700"/>

Version:
- The version of the config file

URL: "https://api.yelp.com/v3/businesses/search/phone"
- Contains the URL path for invoking the API

method: "GET" 
- GET is used to request (or GET) data from a specified resource. For the Yelp's API request, leave it as GET, since we are retrieving data.

authorization: "Bearer"
- Authorization method used. For Yelp's API request, leave it as Bearer.
    - Note: For other APIs, please read how they may authorize your application. Depending on the method, different authorization may be required. 

params: {"phone": true}
- Parameters contain the requested information to make the API call. Some parameters might be required, and some may be optional. This will all be in the documentation of your respective API. Each parameter in the config file is a key-value pair where the name is the key and the value is Boolean. If you take a look at the Yelp Phone Search documentation, it shows that the phone is a required parameter.
  - A True value refers to the required parameter to query a request. 
  - A False value refers to the optional parameter to query a request. 

#### Response:

<img src=".assets/Yelp_response.png" width="700"/>

ctype: "application/json"
- The Content-Type, or ctype, is used to indicate the media type of the resource. A Content-Type header tells the client what the content type of the returned information actually is. With DataPrep.Connector, the content type is application/json. 
  
tablePath: "$.businesses[*]"
- The tablePath always starts with "$". After this, depending on what your API returns as a response to being called, you can build out the remainder. In the case of Yelp, this is what the response looks like:

<img src=".assets/Yelp_build_schema.png" width="700"/>

- it returns a total parameter with how many businesses were found, then an array of businesses, with some info for each business. So our tablePath then becomes $businesses[\*]. The [\*] indicates that it is a dynamic part of the response, and you will clarify what it is in the following schema.

schema: { }
- After finding table content, we look at the schema. Let's break down what the schema looks like for Yelp.
  
id: {"target": "$.id", "type": "string"}
- The schema will be read until all elements of the business array are received. ID is at the root of the first row of the business array, and it will access the ID attribute. 
    - The first "id" you write here is what you decide to call the returned value. You could change it to "business_id" if you felt it was more appropriate.  
    - The second "$.id" you see is what is actually returned from the API. This will also always start with a $. As you can see, if we build off of tablePath, this would become "$.businesses[*].id". The [\*] here is what will be changing (the index of the businesses array item). The .id is what is returned every time for each business.

- Build the remainder of the schema in the same way by viewing the same response section of your specific endpoint page that you looked at to create the tablePath.

<img src=".assets/Yelp_build_schema.png" width="700"/>

<img src=".assets/Yelp_single_response.png" width="700"/>

<img src=".assets/Yelp_single_resp_json.png" width="700"/>

You can test the config file by passing it to the library: 

<img src=".assets/Data_connector.png" width="700"/>

## That's all for now!

Please visit the other tutorials and have a look at the other config files that are available if you are interested in setting up a config file.

# Pull Request

Please follow this [tutorial](https://opensource.com/article/19/7/create-pull-request-github) to create a pull request. 

Please make sure you squash all commits together before opening a pull request. If your pull request requires changes upon review, please be sure to squash all additional commits as well. [This wiki page](https://github.com/todotxt/todo.txt-android/wiki/Squash-All-Commits-Related-to-a-Single-Issue-into-a-Single-Commit) outlines the squashing process.

