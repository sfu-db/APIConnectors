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
<details>
  <summary>How to get a list of cryptocurrencies and their exchanges</summary>
  
```python
import pandas as pd
from dataprep.connector import connect

# You can get ”finnhub_access_token“ by following https://finnhub.io/
conn_finnhub = connect("finnhub", _auth={"access_token":finnhub_access_token}, update=True)

df = await conn_finnhub.query('crypto_exchange')
exchanges = df['exchange'].to_list()
symbols = []
for ex in exchanges:
    data = await df.query('crypto_symbols', exchange=ex)
    symbols.append(data)
df_symbols = pd.concat(symbols)
df_symbols
```

| id     | description       | displaySymbol	              | symbol           |
| ------ | ----------------- | ------------------------------ | ---------------  |
| 0      | Binance FRONT/ETH | FRONT/ETH	                  | BINANCE:FRONTETH | 
| 1      | Binance ATOM/BUSD | ATOM/BUSD	                  | BINANCE:ATOMBUSD |
| ...    | ...           	 | ...   	                      | ...              |
| 281    | Poloniex AKRO/BTC | AKRO/BTC                       | POLONIEX:BTC_AKRO|
</details>

<details>
  <summary>Which ipo in the current month has the highest total share values?</summary>
  
```python
import calendar
from datetime import datetime
from dataprep.connector import connect

# You can get ”finnhub_access_token“ by following https://finnhub.io/
conn_finnhub = connect("finnhub", _auth={"access_token":finnhub_access_token}, update=True)

today = datetime.today()
days_in_month = calendar.monthrange(today.year, today.month)[1]
date_from = today.replace(day=1).strftime('%Y-%m-%d')
date_to = today.replace(day=days_in_month).strftime('%Y-%m-%d')
ipo_df = await conn_finnhub.query('ipo_calender', from_=date_from, to=date_to)
ipo_df[ipo_df['totalSharesValue'] == ipo_df['totalSharesValue'].max()]
```
| id | date        | exchange    | name                            | numberOfShares | ...  | totalSharesValue  |
|--- | ----------- | ----------- | ------------------------------- | -------------- | ---  | ----------------- |
|  5 | 2021-02-03  | NYSE        | TELUS International (Cda) Inc.  | 33333333       | ...  | 9.58333e+08       |
</details>

<details>
  <summary>What are the average acutal earnings from the last 4 seasons of a list of 10 popular stocks?</summary>
  
```python
import asyncio
import pandas as pd
from dataprep.connector import connect

# You can get ”finnhub_access_token“ by following https://finnhub.io/
conn_finnhub = connect("finnhub", _auth={"access_token":finnhub_access_token}, update=True)

stock_list = ['TSLA', 'AAPL', 'WMT', 'GOOGL', 'FB', 'MSFT', 'COST', 'NVDA', 'JPM', 'AMZN']
query_list = [conn_finnhub.query('earnings', symbol=symbol) for symbol in stock_list]
query_results = asyncio.gather(*query_list)
stocks_df = pd.concat(await query_results)
stocks_df = stocks_df.groupby('symbol', as_index=False).agg({'actual': ['mean']})
stocks_df.columns = stocks_df.columns.get_level_values(0)
stocks_df = stocks_df.sort_values(by='actual', ascending=False).rename(columns={'actual': 'avg_actual'})
stocks_df.reset_index(drop=True)
```

| id | symbol   | avg_actual    |
|--- | ---------| ------------- |
|  0 | GOOGL    | 12.9375       |
|  1 | AMZN     | 8.5375        |
|  2 | FB       | 2.4475        |
| .. | ...      | ...           |
|  9 | TSLA     | 0.556         |
</details>

<details>
  <summary>What is the earnings of last 4 quarters of a given company? (e.g. TSLA)</summary>
  
```python
from dataprep.connector import connect
from datetime import datetime, timedelta, timezone

# You can get ”finnhub_access_token“ by following https://finnhub.io/
conn_finnhub = connect("finnhub", _auth={"access_token":finnhub_access_token}, update=True)

today = datetime.now(tz=timezone.utc)
oneyear = today - timedelta(days = 365)
start = int(round(oneyear.timestamp()))

result = await conn_finnhub.query('earnings_calender', symbol='TSLA', from_=start, to=today)
result = result.set_index('date')
result
```
| id | date       |   epsActual |   epsEstimate | hour   |   quarter | ... | symbol   |   year |
|:---|:-----------|------------:|--------------:|:-------|----------:| --- |:---------|-------:|
| 0  | 2021-01-27 |       0.8   |     1.37675   | amc    |         4 | ... | TSLA     |   2020 |
| 1  | 2020-10-21 |       0.76  |     0.600301  | amc    |         3 | ... | TSLA     |   2020 |
| 2  | 2020-07-22 |       0.436 |    -0.0267036 | amc    |         2 | ... | TSLA     |   2020 |
| .. | ...        | ...         | ...           | ...    | ...       | ... | ...      | ...    |
| 3  | 2011-02-15 |      -0.094 |    -0.101592  | amc    |         4 | ... | TSLA     |   2010 |

</details>


### Geocoding

#### [MapQuest](./mapquest) -- Collect Driving Directions, Maps, Traffic Data
<details>
  <summary>Where is the Simon Fraser University? Give all the places if there is more than one campus.</summary>
  
```python
from dataprep.connector import connect

# You can get ”mapquest_access_token“ by following https://developer.mapquest.com/
conn_map = connect("mapquest", _auth={"access_token": mapquest_access_token}, _concurrency = 10)

BC_BBOX = "-139.06,48.30,-114.03,60.00"
campus = await conn_map.query("place", q = "Simon Fraser University", sort = "relevance", bbox = BC_BBOX, _count = 50)
campus = campus[campus["name"] == "Simon Fraser University"].reset_index()
```

| id |   index | name                    | country   | state   | city      | address                 | postalCode   | coordinates              | details                                                               |
|---:|--------:|:------------------------|:----------|:--------|:----------|:------------------------|:-------------|:-------------------------|:----------------------------------------------------------------------|
|  0 |       0 | Simon Fraser University | CA        | BC      | Burnaby   | 8888 University Drive E | V5A 1S6      | [-122.90416, 49.27647]   | ... |
|  1 |       2 | Simon Fraser University | CA        | BC      | Vancouver | 602 Hastings St W       | V6B 1P2      | [-123.113431, 49.284626] | ... |
</details>

<details>
  <summary>How many KFC are there in Burnaby? What are their address?</summary>
  
```python
from dataprep.connector import connect

# You can get ”mapquest_access_token“ by following https://developer.mapquest.com/
conn_map = connect("mapquest", _auth={"access_token": mapquest_access_token}, _concurrency = 10)

BC_BBOX = "-139.06,48.30,-114.03,60.00"
kfc = await conn_map.query("place", q = "KFC", sort = "relevance", bbox = BC_BBOX, _count = 500)
kfc = kfc[(kfc["name"] == "KFC") & (kfc["city"] == "Burnaby")].reset_index()
print("There are %d KFCs in Burnaby" % len(kfc))
print("Their addresses are:")
kfc['address']
```
There are 1 KFCs in Burnaby

Their addresses are:

| id | address      |
|---:|-------------:|
| 0  | 5094 Kingsway|

</details>

<details>
  <summary>The ratio of Starbucks to Tim Hortons in Vancouver?</summary>
  
```python
from dataprep.connector import connect

# You can get ”mapquest_access_token“ by following https://developer.mapquest.com/
conn_map = connect("mapquest", _auth={"access_token": mapquest_access_token}, _concurrency = 10)
VAN_BBOX = '-123.27,49.195,-123.020,49.315'
starbucks = await conn_map.query('place', q='starbucks', sort='relevance', bbox=VAN_BBOX, page='1', pageSize = '50', _count=200)
timmys = await conn_map.query('place', q='Tim Hortons', sort='relevance', bbox=VAN_BBOX, page='1', pageSize = '50', _count=200)

is_vancouver_sb = starbucks['city'] == 'Vancouver'
is_vancouver_tim = timmys['city'] == 'Vancouver'
sb_in_van = starbucks[is_vancouver_sb]
tim_in_van = timmys[is_vancouver_tim]
print('The ratio of Starbucks:Tim Hortons in Vancouver is %d:%d' % (len(sb_in_van), len(tim_in_van)))
```

The ratio of Starbucks:Tim Hortons in Vancouver is 188:120

</details>

<details>
  <summary>What is the closest gas station from Metropolist and how far is it?</summary>
  
```python
from dataprep.connector import connect
from numpy import radians, sin, cos, arctan2, sqrt

def distance_in_km(cord1, cord2):
    R = 6373.0

    lat1 = radians(cord1[1])
    lon1 = radians(cord1[0])
    lat2 = radians(cord2[1])
    lon2 = radians(cord2[0])

    dlon = lon2 - lon1
    dlat = lat2 - lat1

    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * arctan2(sqrt(a), sqrt(1 - a))
    distance = R * c

    return(distance)

# You can get ”mapquest_access_token“ by following https://developer.mapquest.com/
conn_map = connect("mapquest", _auth={"access_token": mapquest_access_token}, _concurrency = 10)
METRO_TOWN = [-122.9987, 49.2250]
METRO_TOWN_string = '%f,%f' % (METRO_TOWN[0], METRO_TOWN[1])
nearest_petro = await conn_map.query('place', q='gas station', sort='distance', location=METRO_TOWN_string, page='1', pageSize = '1')
print('Metropolist is %fkm from the nearest gas station' % distance_in_km(METRO_TOWN, nearest_petro['coordinates'][0]))
print('The gas station is %s at %s' % (nearest_petro['name'][0], nearest_petro['address'][0]))
```
Metropolist is 0.376580km from the nearest gas station

The gas station is Chevron at 4692 Imperial St
</details>

<details>
  <summary>In BC, which city has the most amount of shopping centers?</summary>
  
```python
from dataprep.connector import connect

# You can get ”mapquest_access_token“ by following https://developer.mapquest.com/
conn_map = connect("mapquest", _auth={"access_token": mapquest_access_token}, _concurrency = 10)
BC_BBOX = "-139.06,48.30,-114.03,60.00"
GROCERY = 'sic:541105'
shop_list = await conn_map.query("place", sort="relevance", bbox=BC_BBOX, category=GROCERY, _count=500)
shop_list = shop_list[shop_list["state"] == "BC"]
shop_list.groupby('city')['name'].count().sort_values(ascending=False).head(10)
```

| city            | count     |
|----------------:|----------:|
| Vancouver       | 42        |
| Victoria        | 24        |
| Surrey          | 15        |
| Burnaby         | 14        |
| ...             | ...       |
| North Vancouver | 8         |

</details>

<details>
  <summary>Where is the nearest grocery of SFU? How many miles far? And how much time estimated for driving?</summary>
  
```python
from dataprep.connector import connect

# You can get ”mapquest_access_token“ by following https://developer.mapquest.com/
conn_map = connect("mapquest", _auth={"access_token": mapquest_access_token}, _concurrency = 10)
SFU_LOC = '-122.90416, 49.27647'
GROCERY = 'sic:541105'
nearest_grocery = await conn_map.query("place", location=SFU_LOC, sort="distance", category=GROCERY)
destination = nearest_grocery.iloc[0]['details']
name = nearest_grocery.iloc[0]['name']
route = await conn_map.query("route", from_='8888 University Drive E, Burnaby', to=destination)
total_distance = sum([float(i)for i in route.iloc[:]['distance']])
total_time = sum([int(i)for i in route.iloc[:]['time']])
print('The nearest grocery of SFU is ' + name + '. It is ' + str(total_distance) + ' miles far, and It is expected to take ' + str(total_time // 60) + 'm' + str(total_time % 60)+'s of driving.')
route
```
The nearest grocery of SFU is Nesters Market. It is 1.234 miles far, and It is expected to take 3m21s of driving.

| id |   index | narrative                                                            |   distance |   time |
|---:|--------:|:---------------------------------------------------------------------|-----------:|-------:|
|  0 |       0 | Start out going east on University Dr toward Arts Rd.                |      0.348 |     57 |
|  1 |       1 | Turn left to stay on University Dr.                                  |      0.606 |     84 |
|  2 |       2 | Enter next roundabout and take the 1st exit onto University High St. |      0.28  |     60 |
|  3 |       3 | 9000 UNIVERSITY HIGH STREET is on the left.                          |      0     |      0 |

</details>

### Lifestyle

#### [Spoonacular](./spoonacular) -- Collect Recipe, Food, and Nutritional Information Data


### Music

#### [MusixMatch](./musicmatch) -- Collect Music Lyrics Data



#### [Spotify](./spotify) -- Collect Albums, Artists, and Tracks Metadata





### News


#### [Guardian](./guardian) -- Collect Guardian News Data 

#### [Times](./times) -- Collect New York Times Data
<details>
  <summary>Who is the author of article 'Yellen Outlines Economic Priorities, and Republicans Draw Battle Lines'</summary>
  
```python
from dataprep.connector import connect

# You can get ”times_access_token“ by following https://developer.nytimes.com/apis
conn_times = connect("times", _auth={"access_token":times_access_token})
df = await conn_times.query('ac',q='Yellen Outlines Economic Priorities, and Republicans Draw Battle Lines')
df[["authors"]]
```
| id | authors           |
|---:|:------------------|
|  0 | By Alan Rappeport |
</details>

<details>
  <summary>What is the newest news from Ottawa</summary>
  
```python
from dataprep.connector import connect

# You can get ”times_access_token“ by following https://developer.nytimes.com/apis
conn_times = connect("times", _auth={"access_token":times_access_token})
df = await conn_times.query('ac',q="ottawa",sort='newest')
df[['headline','authors','abstract','url','pub_date']].head(1)
```
|    | headline                                                      | ... | pub_date                 |
|---:|:--------------------------------------------------------------|:----|:-------------------------|
|  0 | 21 Men Accuse Lincoln Project Co-Founder of Online Harassment | ... | 2021-01-31T14:48:35+0000 |
</details>

<details>
  <summary>What are Headlines of articles where Trump was mentioned in the last 6 months of 2020 in the technology news section</summary>
  
```python
from dataprep.connector import connect

# You can get ”times_access_token“ by following https://developer.nytimes.com/apis
conn_times = connect("times", _auth={"access_token":times_access_token})
df = await conn_times.query('ac',q="Trump",fq='section_name:("technology")',begin_date='20200630',end_date='20201231',sort='newest', _count=50)

print(df['headline'])
print("Trump was mentioned in " + str(len(df)) + " articles")
```
| id | headline                                                                                   |
|---:|:-------------------------------------------------------------------------------------------|
|  0 | No, Trump cannot win Georgia’s electoral votes through a write-in Senate campaign.         |
|  1 | How Misinformation ‘Superspreaders’ Seed False Election Theories                           |
|  2 | No, Trump’s sister did not publicly back him. He was duped by a fake account.              |
| .. | ...                                                                                        |
| 49 | Trump Official’s Tweet, and Its Removal, Set Off Flurry of Anti-Mask Posts                 |

Trump was mentioned in 50 articles
</details>

<details>
  <summary>What is the ranking of times a celebrity is mentioned in a headline in latter half of 2020?</summary>
  
```python
from dataprep.connector import connect
import pandas as pd
# You can get ”times_access_token“ by following https://developer.nytimes.com/apis
conn_times = connect("times", _auth={"access_token":times_access_token})
celeb_list = ['Katy Perry', 'Taylor Swift', 'Lady Gaga', 'BTS', 'Rihanna', 'Kim Kardashian']
number_of_mentions = []
for i in celeb_list:
    df1 = await conn_times.query('ac',q=i,begin_date='20200630',end_date='20201231')
    df1 = df1[df1['headline'].str.contains(i)]
    a = len(df1['headline'])
    number_of_mentions.append(a)

print(number_of_mentions)
    
ranking_df = pd.DataFrame({'name': celeb_list, 'number of mentions': number_of_mentions})
ranking_df = ranking_df.sort_values(by=['number of mentions'], ascending=False)
ranking_df
```
[2, 6, 3, 6, 1, 0]

|    | name           |   number of mentions |
|---:|:---------------|---------------------:|
|  1 | Taylor Swift   |                    6 |
|  3 | BTS            |                    6 |
|  2 | Lady Gaga      |                    3 |
|  0 | Katy Perry     |                    2 |
|  4 | Rihanna        |                    1 |
|  5 | Kim Kardashian |                    0 |
</details>

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


 | id  | title                                             | authors                                           | venue            | year |
 | --- | ------------------------------------------------- | ------------------------------------------------- | ---------------- | ---- |
 | 0   | The 1st Agriculture-Vision Challenge - Methods... | [Mang Tik Chiu, Xingqian Xu, Kai Wang, Jennife... | [CVPR Workshops] | 2020 |
 | ... | ...                                               | ...                                               | ...              | ...  |
 | 242 | An Experimental and Theoretical Comparison of ... | [Michael J. Kearns, Yishay Mansour, Andrew Y. ... | [COLT]           | 1995 |
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
