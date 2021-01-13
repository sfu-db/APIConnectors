# Data Collection From Web APIs

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-5-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

A curated list of example code to collect data from Web APIs using DataPrep.Connector.

## How to Contribute?
You can contribute to this project in two ways. Please check the [contributing guide](CONTRIBUTING.md).
1. Add your example code on this page
2. Add a new configuration file to this repo

## Why Contribute?
* Your contribution will benefit [~100K DataPrep users](https://github.com/sfu-db/dataprep).
* Your contribution will be recoginized on [Contributors](#contributors-).

## Index

* [Business](#business)
* [Finance](#finance)
* [Geocoding](#geocoding)
* [Lifestyle](#lifestyle)
* [Music](#music)
* [News](#news)
* [Science](#science)
* [Shopping](#shopping)
* [Social](#social)
* [Video](#video)
* [Weather](#weather)

### Business

#### [Yelp](./yelp) -- Collect Local Business Data
<details>
  <summary>What's the phone number of Capilano Suspension Bridge Park?</summary>
  
```python
from dataprep.connector import connect

# You can get ”yelp_access_token“ by following https://www.yelp.com/developers/documentation/v3/authentication
conn_yelp = connect("yelp", _auth={"access_token":yelp_access_token}, _concurrency = 5)

df = await conn_yelp.query("businesses", term = "Capilano Suspension Bridge Park", location = "Vancouver", _count = 1)

df[["name","phone"]]
```

| id  | name                            | phone           |
| --- | ------------------------------- | --------------- |
| 0   | Capilano Suspension Bridge Park | +1 604-985-7474 |

  </details>
<details>
  <summary>Which yoga store has the highest review count in Vancouver?</summary>
  
```python
from dataprep.connector import connect

# You can get ”yelp_access_token“ by following https://www.yelp.com/developers/documentation/v3/authentication
conn_yelp = connect("yelp", _auth={"access_token":yelp_access_token}, _concurrency = 1)

  # Check all supported categories: https://www.yelp.ca/developers/documentation/v3/all_category_list
df = await conn_yelp.query("businesses", categories = "yoga", location = "Vancouver", sort_by = "review_count", _count = 1)
df[["name", "review_count"]]
```

| id  | name                | review_count |
| --- | ------------------- | ------------ |
| 0   | YYOGA Downtown Flow | 107          |

  </details>  
  
<details>
  <summary>How many Starbucks stores in Seattle and where are they?</summary>
  
  ```python
  from dataprep.connector import connect

  # You can get ”yelp_access_token“ by following https://www.yelp.com/developers/documentation/v3/authentication
  conn_yelp = connect("yelp", _auth={"access_token":yelp_access_token}, _concurrency = 5)
  df = await conn_yelp.query("businesses", term = "Starbucks", location = "Seattle", _count = 1000)

  # Remove irrelevant data
  df = df[(df['city'] == 'Seattle') & (df['name'] == 'Starbucks')]
  df[['name', 'address1', 'city', 'state', 'country', 'zip_code']].reset_index(drop=True)
  ```
| id  | name      | address1                 | city    | state | country | zip_code |
| --- | --------- | ------------------------ | ------- | ----- | ------- | -------- |
| 0   | Starbucks | 515 Westlake Ave N       | Seattle | WA    | US      | 98109    |
| 1   | Starbucks | 442 Terry Avenue N       | Seattle | WA    | US      | 98109    |
| ... | .......   | .......                  | ......  | ..    | ..      | ....     |
| 126 | Starbucks | 17801 International Blvd | Seattle | WA    | US      | 98158    |

</details>
<details>
  <summary>What are the ratings for a list of resturants?</summary>
  
  ```python
  from dataprep.connector import connect
  import pandas as pd
  import asyncio
  # You can get ”yelp_access_token“ by following https://www.yelp.com/developers/documentation/v3/authentication
  conn_yelp = connect("yelp", _auth={"access_token":yelp_access_token}, _concurrency = 5)

  names = ["Miku", "Boulevard", "NOTCH 8", "Chambar", "VIJ’S", "Fable", "Kirin Restaurant", "Cafe Medina", \
   "Ask for Luigi", "Savio Volpe", "Nicli Pizzeria", "Annalena", "Edible Canada", "Nuba", "The Acorn", \
   "Lee's Donuts", "Le Crocodile", "Cioppinos", "Six Acres", "St. Lawrence", "Hokkaido Santouka Ramen"]

  query_list = [conn_yelp.query("businesses", term=name, location = "Vancouver", _count=1) for name in names]
  results = asyncio.gather(*query_list)
  df = pd.concat(await results)
  df[["name", "rating", "city"]].reset_index(drop=True)
  ```
  | ID  | Name                           | Rating | City      |
  | --- | ------------------------------ | ------ | --------- |
  | 0   | Miku                           | 4.5    | Vancouver |
  | 1   | Boulevard Kitchen & Oyster Bar | 4.0    | Vancouver |
  | ... | ...                            | ...    | ...       |
  | 20  | Hokkaido Ramen Santouka        | 4.0    | Vancouver |
</details>



### Finance

#### [Finnhub](./finnhub) -- Collect Financial, Market, Economic Data




### Geocoding

#### [MapQuest](./mapquest) -- Collect Driving Directions, Maps, Traffic Data




### Lifestyle

#### [Spoonacular](./spoonacular) -- Collect Recipe, Food, and Nutritional Information Data


### Music

#### [MusixMatch](./musicmatch) -- Collect Music Lyrics Data



#### [Spotify](./spotify) -- Collect Albums, Artists, and Tracks Metadata





### News


#### [Guardian](./guardian) -- Collect Guardian News Data 

#### [Times](./times) -- Collect New York Times Data





### Science

#### [DBLP](./dblp) -- Collect Computer Science Publication Data

<details>
  <summary>Who wrote this paper?</summary>
  
  ```python
  from dataprep.connector import connect
  conn_dblp = connect("dblp")
  df = await conn_dblp.query("publication", q = "Scikit-learn: Machine learning in Python", _count = 1)
  df[["title", "authors", "year"]]
  ```
| id  | title                                      | authors                                           | year |
| --- | ------------------------------------------ | ------------------------------------------------- | ---- |
| 0   | Scikit-learn - Machine Learning in Python. | [Fabian Pedregosa, Gaël Varoquaux, Alexandre G... | 2011 |
 
  </details>
  
 <details>
  <summary>How to fetch all publications of Andrew Y. Ng?</summary>
  
  ```python
  from dataprep.connector import connect

  conn_dblp = connect("dblp", _concurrency = 5)
  df = await conn_dblp.query("publication", author = "Andrew Y. Ng", _count = 2000)
  df[["title", "authors", "venue", "year"]].reset_index(drop=True)
  ```


 | id  | title                                             | authors                                            | venue            | year |
 | --- | ------------------------------------------------- | -------------------------------------------------- | ---------------- | ---- |
 | 0   | The 1st Agriculture-Vision Challenge - Methods... | [Mang Tik Chiu, Xingqian Xu, Kai Wang, Jennife...  | [CVPR Workshops] | 2020 |
 | ... | ...                                               | ...                                                | ...              | ...  |  
 | 242 | An Experimental and Theoretical Comparison of ... | [Michael J. Kearns, Yishay Mansour, Andrew Y. ...  | [COLT]           | 1995 |
  </details>
  
<details>
  <summary>How to fetch all publications of NeurIPS 2020?</summary>
  
  ```python
  from dataprep.connector import connect

  conn_dblp = connect("dblp", _concurrenncy = 5)
  df = await conn_dblp.query("publication", q = "NeurIPS 2020", _count = 5000)

  # filter non-neurips-2020 papers
  mask = df.venue.apply(lambda x: 'NeurIPS' in x)
  df = df[mask]
  df = df[(df['year'] == '2020')]
  df[["title", "venue", "year"]].reset_index(drop=True)
  ```

  | id   | title                                             | venue     | year |
  | ---- | ------------------------------------------------- | --------- | ---- |
  | 0    | Towards More Practical Adversarial Attacks on ... | [NeurIPS] | 2020 |
  | ...  | ...                                               | ...       | ...  |
  | 1899 | Triple descent and the two kinds of overfittin... | [NeurIPS] | 2020 |
  </details>
  


### Shopping


#### [Etsy](./etsy) -- Colect Handmade Marketplace Data.





### Social

#### [Twitch](./twitch) -- Colect Twitch Streams and Channels Information

#### [Twitter](./twitter) -- Colect Tweets Information




### Video


#### [Youtube](./youtube) -- Colect Youtube's Content MetaData.




### Weather


#### [OpenWeatherMap](openweathermap) -- Colect Current and Historical Weather Data


**[⬆️ Back to Index](#index)**


## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://wooya.me"><img src="https://avatars1.githubusercontent.com/u/998606?v=4" width="100px;" alt=""/><br /><sub><b>Weiyuan Wu</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=dovahcrow" title="Code">💻</a> <a href="#maintenance-dovahcrow" title="Maintenance">🚧</a></td>
    <td align="center"><a href="http://www.sfu.ca/~peiw/"><img src="https://avatars0.githubusercontent.com/u/15167104?v=4" width="100px;" alt=""/><br /><sub><b>peiwangdb</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=peiwangdb" title="Code">💻</a> <a href="#maintenance-peiwangdb" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://github.com/nick-zrymiak"><img src="https://avatars0.githubusercontent.com/u/35017006?v=4" width="100px;" alt=""/><br /><sub><b>nick-zrymiak</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=nick-zrymiak" title="Code">💻</a></td>
    <td align="center"><a href="https://www.pallavibharadwaj.com"><img src="https://avatars1.githubusercontent.com/u/17384838?v=4" width="100px;" alt=""/><br /><sub><b>Pallavi Bharadwaj</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=pallavibharadwaj" title="Code">💻</a></td>
    <td align="center"><a href="https://www.linkedin.com/in/hilal-asmat/"><img src="https://avatars1.githubusercontent.com/u/28606148?v=4" width="100px;" alt=""/><br /><sub><b>Hilal Asmat</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=h-asmat" title="Documentation">📖</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->
