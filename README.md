# Data Collection From Web APIs

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-6-orange.svg?style=flat-square)](#contributors-)
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

<details>
  <summary>Which foods are unhealthy, i.e.,have high carbs and high fat content?</summary>

  ```python
from dataprep.connector import connect
import pandas as pd

dc = connect('spoonacular', _auth={'access_token': API_key}, concurrency=3, update=True)

df = await dc.query('recipes_by_nutrients', minFat=65, maxFat=100, minCarbs=75, maxCarbs=100, _count=20)

df["calories"] = pd.to_numeric(df["calories"]) # convert string type to numeric
df = df[df['calories']>1100] # considering foods with more than 1100 calories per serving to be unhealthy

df[["title","calories","fat","carbs"]].sort_values(by=['calories'], ascending=False)
  ```

| id   | title                             | calories | fat  | carbs |
| ---- | --------------------------------- | -------- | ---- | ----- |
| 2    | Brownie Chocolate Chip Cheesecake | 1210     | 92g  | 79g   |
| 8    | Potato-Cheese Pie                 | 1208     | 80g  | 96g   |
| 0    | Stuffed Shells with Beef and Broc | 1192     | 72g  | 81g   |
| 3    | Coconut Crusted Rockfish          | 1187     | 72g  | 92g   |
| 4    | Grilled Ratatouille               | 1143     | 82g  | 88g   |
| 7    | Pecan Bars                        | 1121     | 84g  | 91g   |

</details>

<details>
  <summary>Which meat dishes are rich in proteins?</summary>

  ```python
from dataprep.connector import connect

dc = connect('spoonacular', _auth={'access_token': API_key}, concurrency=3, update=True)

df = await dc.query('recipes', query='beef', diet='keto', minProtein=25, maxProtein=60, _count=5)
df = df[["title","nutrients"]]

# Output of 'nutrients' column : [{'title': 'Protein', 'amount': 22.3768, 'unit': 'g'}]
g = [] # to extract the exact amount of Proteins in grams and store as list
for i in df["nutrients"]:
    z = i[0]
    g.append(z['amount'])
    
df.insert(1,'Protein(g)',g)
df[["title","Protein(g)"]].sort_values(by='Protein(g)',ascending=False)
  ```

| id   | title                                             | Protein(g) |
| ---- | ------------------------------------------------- | ---------- |
| 3    | Strip steak with roasted cherry tomatoes and v... | 56.2915    |
| 0    | Low Carb Brunch Burger                            | 53.7958    |
| 2    | Entrecote Steak with Asparagus                    | 41.6676    |
| 1    | Italian Style Meatballs                           | 35.9293    |

</details>

<details>
  <summary>Which Italian Vegan dishes are popular?</summary>

  ```python
from dataprep.connector import connect

dc = connect('spoonacular', _auth={'access_token': API_key}, concurrency=3, update=True)

df = await dc.query('recipes', query='popular veg dishes', cuisine='italian', diet='vegan', _count=20)
df[["title"]]
  ```

| id   | Title                                             |
| ---- | ------------------------------------------------- |
| 0    | Vegan Pea and Mint Pesto Bruschetta               |
| 1    | Gluten Free Vegan Gnocchi                         |
| 2    | Fresh Tomato Risotto with Grilled Green Vegeta... |

</details>

<details>
  <summary>What are the top 5 liked chicken recipes with common ingredients?</summary>

  ```python
from dataprep.connector import connect
import pandas as pd

dc = connect('spoonacular', _auth={'access_token': API_key}, concurrency=3, update=True)

df= await dc.query('recipes_by_ingredients', ingredients='chicken,buttermilk,salt,pepper')
df['likes'] = pd.to_numeric(df['likes'])

df[['title', 'likes']].sort_values(by=['likes'], ascending=False).head(5)
  ```

| id   | title                                             | likes |
| ---- | ------------------------------------------------- | ----- |
| 9    | Oven-Fried Ranch Chicken                          | 561   |
| 1    | Fried Chicken and Wild Rice Waffles with Pink ... | 78    |
| 6    | CCC: Carla Hall’s Fried Chicken                   | 47    |
| 2    | Buttermilk Fried Chicken                          | 12    |
| 0    | My Pantry Shelf                                   | 10    |

</details>

<details>
  <summary>What is the average calories for high calorie Korean foods?</summary>

  ```python
from dataprep.connector import connect
from statistics import mean 

dc = connect('spoonacular', _auth={'access_token': API_key}, concurrency=3, update=True)

df = await dc.query('recipes', query='korean', minCalories = 500)
nutri = df['nutrients'].tolist()

calories = []
for i in range(len(nutri)):
    calories.append(nutri[i][0]['amount'])

print('Average calories for high calorie Korean foods:', mean(calories),'kcal')
  ```

Average calories for high calorie Korean foods: 644.765 kcal

</details>




### Music

#### [MusixMatch](./musicmatch) -- Collect Music Lyrics Data
<details>
  <summary>What is Katy Perry's Twitter URL?</summary>
  
```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token})

df = await conn_musixmatch.query("artist_info", artist_mbid = "122d63fc-8671-43e4-9752-34e846d62a9c")

df[['name', 'twitter_url']]
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>name</th>
      <th>twitter_url</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Katy Perry</td>
      <td>https://twitter.com/katyperry</td>
    </tr>
  </tbody>
</table>
</div>

  </details>
  
<details>
  <summary>What album is the song "Gone, Gone, Gone" in?</summary>
  
```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token})

df = await conn_musixmatch.query("track_matches", q_track = "Gone, Gone, Gone")

df[['name', 'album_name']]
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>name</th>
      <th>album_name</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Gone, Gone, Gone</td>
      <td>The World From the Side of the Moon</td>
    </tr>
  </tbody>
</table>
</div>


</details>
<details>
  <summary>Which artist/artists group is most popular in Canada?</summary>
  
```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token})

df = await conn_musixmatch.query("top_artists", country = "Canada")

df['name'][0]
```




    'BTS'
</details>
<details>
  <summary>How many genres are in the Musixmatch database?</summary>
  
```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token})

df = await conn_musixmatch.query("genres")

len(df)
```




    362

  </details>  
<details>
  <summary>Who is the most popular American artist named Michael?</summary>
  
```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token}, _concurrency = 5)

df = await conn_musixmatch.query("artists", q_artist = "Michael")
df = df[df['country'] == "US"].sort_values('rating', ascending=False)

df['name'].iloc[0]
```




    'Michael Jackson'

  </details>  
<details>
  <summary>What is the genre of the album "Atlas"?</summary>
  
```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token})

album = await conn_musixmatch.query("album_info", album_id = 11339785)
genres = await conn_musixmatch.query("genres")
album_genre = genres[genres['id'] == album['genre_id'][0][0]]['name']

album_genre.iloc[0]
```




    'Soundtrack'

  </details>  
<details>
  <summary>What is the link to lyrics of the most popular song in the album "Yellow"?</summary>
  
```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token}, _concurrency = 5)

df = await conn_musixmatch.query("album_tracks", album_id = 10266231)
df = df.sort_values('rating', ascending=False)

df['track_share_url'].iloc[0]
```




    'https://www.musixmatch.com/lyrics/Coldplay/Yellow?utm_source=application&utm_campaign=api&utm_medium=SFU%3A1409620992740'

  </details>  
<details>
  <summary>What are Lady Gaga's albums from most to least recent?</summary>
  
```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token}, update = True)

df = await conn_musixmatch.query("artist_albums", artist_mbid = "650e7db6-b795-4eb5-a702-5ea2fc46c848", s_release_date = "desc")

df.name.unique()
```




    array(['Chromatica', 'Stupid Love',
           'A Star Is Born (Original Motion Picture Soundtrack)', 'Your Song'],
          dtype=object)

  </details>  
<details>
  <summary>Which artists are similar to Lady Gaga?</summary>
  
```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token})

df = await conn_musixmatch.query("related_artists", artist_mbid = "650e7db6-b795-4eb5-a702-5ea2fc46c848")

df
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>name</th>
      <th>rating</th>
      <th>country</th>
      <th>twitter_url</th>
      <th>updated_time</th>
      <th>artist_alias_list</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>6985</td>
      <td>Cast</td>
      <td>41</td>
      <td></td>
      <td></td>
      <td>2015-03-29T03:32:49Z</td>
      <td>[キャスト]</td>
    </tr>
    <tr>
      <th>1</th>
      <td>7014</td>
      <td>black eyed peas</td>
      <td>77</td>
      <td>US</td>
      <td>https://twitter.com/bep</td>
      <td>2016-06-30T10:07:05Z</td>
      <td>[The Black Eyed Peas, ブラック・アイド・ピーズ, heiyandoud...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>269346</td>
      <td>OneRepublic</td>
      <td>74</td>
      <td>US</td>
      <td>https://twitter.com/OneRepublic</td>
      <td>2015-01-07T08:21:52Z</td>
      <td>[ワンリパブリツク, Gong He Shi Dai, Timbaland presents...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>276451</td>
      <td>Taio Cruz</td>
      <td>60</td>
      <td>GB</td>
      <td></td>
      <td>2016-06-30T10:32:58Z</td>
      <td>[タイオ クルーズ, tai ou ke lu zi, Trio Cruz, Jacob M...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>409736</td>
      <td>Inna</td>
      <td>54</td>
      <td>RO</td>
      <td>https://twitter.com/inna_ro</td>
      <td>2014-11-13T03:37:43Z</td>
      <td>[インナ]</td>
    </tr>
    <tr>
      <th>5</th>
      <td>475281</td>
      <td>Skrillex</td>
      <td>62</td>
      <td>US</td>
      <td>https://twitter.com/Skrillex</td>
      <td>2013-11-05T11:28:57Z</td>
      <td>[スクリレックス, shi qi lei ke si, Sonny, Skillrex]</td>
    </tr>
    <tr>
      <th>6</th>
      <td>13895270</td>
      <td>Imagine Dragons</td>
      <td>82</td>
      <td>US</td>
      <td>https://twitter.com/Imaginedragons</td>
      <td>2013-11-05T11:30:28Z</td>
      <td>[イマジン・ドラゴンズ, IMAGINE DRAGONS]</td>
    </tr>
    <tr>
      <th>7</th>
      <td>27846837</td>
      <td>Shawn Mendes</td>
      <td>80</td>
      <td>CA</td>
      <td></td>
      <td>2015-02-17T10:33:56Z</td>
      <td>[ショーン・メンデス, xiaoenmengdezi]</td>
    </tr>
    <tr>
      <th>8</th>
      <td>33491890</td>
      <td>Rihanna</td>
      <td>81</td>
      <td>GB</td>
      <td>https://twitter.com/rihanna</td>
      <td>2018-10-15T20:32:58Z</td>
      <td>[りあーな, Rihanna, 蕾哈娜, Rhianna, Riannah, Robyn R...</td>
    </tr>
    <tr>
      <th>9</th>
      <td>33491981</td>
      <td>Avicii</td>
      <td>74</td>
      <td>SE</td>
      <td>https://twitter.com/avicii</td>
      <td>2018-04-20T18:27:01Z</td>
      <td>[アヴィーチー, ai wei qi, Avicci]</td>
    </tr>
  </tbody>
</table>
</div>

</details>

<details>
<summary>What are the highest rated songs in Canada from highest to lowest popularity?</summary>

```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token}, _concurrency = 5)

df = await conn_musixmatch.query("top_tracks", country = 'CA')

df[df['is_explicit'] == 0].sort_values('rating', ascending = False).reset_index()
```




<div>
<table border="1" class="dataframe">
<thead>
<tr style="text-align: right;">
<th></th>
<th>index</th>
<th>id</th>
<th>name</th>
<th>rating</th>
<th>commontrack_id</th>
<th>has_instrumental</th>
<th>is_explicit</th>
<th>has_lyrics</th>
<th>has_subtitles</th>
<th>album_id</th>
<th>album_name</th>
<th>artist_id</th>
<th>artist_name</th>
<th>track_share_url</th>
<th>updated_time</th>
<th>genres</th>
</tr>
</thead>
<tbody>
<tr>
<th>0</th>
<td>5</td>
<td>201621042</td>
<td>Dynamite</td>
<td>99</td>
<td>114947355</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>39721115</td>
<td>Dynamite - Single</td>
<td>24410130</td>
<td>BTS</td>
<td>https://www.musixmatch.com/lyrics/BTS/Dynamite...</td>
<td>2021-01-15T16:40:48Z</td>
<td>[Pop]</td>
</tr>
<tr>
<th>1</th>
<td>9</td>
<td>187880919</td>
<td>Before You Go</td>
<td>99</td>
<td>103153140</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2019-11-20T08:44:05Z</td>
<td>[Pop, Alternative]</td>
</tr>
<tr>
<th>2</th>
<td>7</td>
<td>189704353</td>
<td>Breaking Me</td>
<td>98</td>
<td>105304416</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>34892017</td>
<td>Keep On Loving</td>
<td>42930474</td>
<td>Topic feat. A7S</td>
<td>https://www.musixmatch.com/lyrics/Topic-8/Brea...</td>
<td>2021-01-19T16:57:29Z</td>
<td>[House, Dance]</td>
</tr>
<tr>
<th>3</th>
<td>3</td>
<td>189626475</td>
<td>Watermelon Sugar</td>
<td>95</td>
<td>103096346</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>36101498</td>
<td>Fine Line</td>
<td>24505463</td>
<td>Harry Styles</td>
<td>https://www.musixmatch.com/lyrics/Harry-Styles...</td>
<td>2020-02-14T08:07:12Z</td>
<td>[Music]</td>
</tr>
</tbody>
</table>
</div>

</details>  
<details>
<summary>What are other songs in the same album as the song "Before You Go"?</summary>

```python
from dataprep.connector import connect

# You can get ”musixmatch_access_token“ by registering as a developer https://developer.musixmatch.com/signup
conn_musixmatch = connect("musixmatch", _auth={"access_token":musixmatch_access_token})

song = await conn_musixmatch.query("track_info", commontrack_id = 103153140)
album = await conn_musixmatch.query("album_tracks", album_id = song["album_id"][0])

album
```




<div>
<table border="1" class="dataframe">
<thead>
<tr style="text-align: right;">
<th></th>
<th>id</th>
<th>name</th>
<th>rating</th>
<th>commontrack_id</th>
<th>has_instrumental</th>
<th>is_explicit</th>
<th>has_lyrics</th>
<th>has_subtitles</th>
<th>album_id</th>
<th>album_name</th>
<th>artist_id</th>
<th>artist_name</th>
<th>track_share_url</th>
<th>updated_time</th>
<th>genres</th>
</tr>
</thead>
<tbody>
<tr>
<th>0</th>
<td>186884178</td>
<td>Grace</td>
<td>31</td>
<td>87857108</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2019-04-09T10:21:29Z</td>
<td>[Folk-Rock]</td>
</tr>
<tr>
<th>1</th>
<td>186884184</td>
<td>Bruises</td>
<td>68</td>
<td>70395936</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2020-07-31T12:58:04Z</td>
<td>[Music, Alternative]</td>
</tr>
<tr>
<th>2</th>
<td>186884187</td>
<td>Hold Me While You Wait</td>
<td>89</td>
<td>95176135</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2020-08-02T07:23:21Z</td>
<td>[Music]</td>
</tr>
<tr>
<th>3</th>
<td>186884189</td>
<td>Someone You Loved</td>
<td>95</td>
<td>89461086</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2020-06-22T15:34:07Z</td>
<td>[Pop, Alternative]</td>
</tr>
<tr>
<th>4</th>
<td>186884190</td>
<td>Maybe</td>
<td>31</td>
<td>95541701</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2019-05-20T11:41:00Z</td>
<td>[Music]</td>
</tr>
<tr>
<th>5</th>
<td>186884191</td>
<td>Forever</td>
<td>67</td>
<td>95541702</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2019-11-18T10:46:36Z</td>
<td>[Music]</td>
</tr>
<tr>
<th>6</th>
<td>186884192</td>
<td>One</td>
<td>31</td>
<td>95541699</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2019-05-19T04:08:23Z</td>
<td>[Music]</td>
</tr>
<tr>
<th>7</th>
<td>186884193</td>
<td>Don't Get Me Wrong</td>
<td>31</td>
<td>95541698</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2019-12-20T08:25:26Z</td>
<td>[Music]</td>
</tr>
<tr>
<th>8</th>
<td>186884194</td>
<td>Hollywood</td>
<td>31</td>
<td>95541700</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2019-05-21T08:00:54Z</td>
<td>[Music]</td>
</tr>
<tr>
<th>9</th>
<td>186884195</td>
<td>Lost on You</td>
<td>31</td>
<td>73530089</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>35611759</td>
<td>Divinely Uninspired To A Hellish Extent (Exten...</td>
<td>33258132</td>
<td>Lewis Capaldi</td>
<td>https://www.musixmatch.com/lyrics/Lewis-Capald...</td>
<td>2020-03-17T08:35:18Z</td>
<td>[Alternative]</td>
</tr>
</tbody>
</table>
</div>
</details>  

#### [Spotify](./spotify) -- Collect Albums, Artists, and Tracks Metadata

<details>
  <summary>How many followers does Eminem have?</summary>
  
```python
from dataprep.connector import connect

# You can get ”spotify_client_id“ and "spotify_client_secret" by registering as a developer https://developer.spotify.com/dashboard/#
conn_spotify = connect("spotify", _auth={"client_id":spotify_client_id, "client_secret":spotify_client_secret}, _concurrency=3)

df = await conn_spotify.query("artist", q="Eminem", _count=500)

df.loc[df['# followers'].idxmax(), '# followers']
```




    41157398

  </details>  
<details>
  <summary>How many singles does Pink Floyd have that are available in Canada?</summary>
  
```python
from dataprep.connector import connect

# You can get ”spotify_client_id“ and "spotify_client_secret" by registering as a developer https://developer.spotify.com/dashboard/#
conn_spotify = connect("spotify", _auth={"client_id":spotify_client_id, "client_secret":spotify_client_secret}, _concurrency=3)

artist_name = "Pink Floyd"
df = await conn_spotify.query("album", q = artist_name, _count = 500)

df = df.loc[[(artist_name in x) for x in df['artist']]]
df = df.loc[[('CA' in x) for x in df['available_markets']]]
df = df.loc[df['total_tracks'] == '1']
df.shape[0]
```

    12
  </details>  

<details>
  <summary>In the last quarter of 2020, which artist released the album with the most tracks?</summary>
  
```python
from dataprep.connector import connect
import pandas as pd

# You can get ”spotify_client_id“ and "spotify_client_secret" by registering as a developer https://developer.spotify.com/dashboard/#
conn_spotify = connect("spotify", _auth={"client_id":spotify_client_id, "client_secret":spotify_client_secret}, _concurrency=3)

df = await conn_spotify.query("album", q = "2020", _count = 500)

df['date'] = pd.to_datetime(df['release_date'])
df = df[df['date'] > '2020-10-01'].drop(columns = ['image url', 'external urls', 'release_date'])
df['total_tracks'] = df['total_tracks'].astype(int)
df = df.loc[df['total_tracks'].idxmax()]
print(df['album_name'] + ", by " + df['artist'][0] + ", tracks: " + str(df['total_tracks']))
```

    ASOT 996 - A State Of Trance Episode 996 (Top 50 Of 2020 Special), by Armin van Buuren ASOT Radio, tracks: 172

  </details>  
<details>
  <summary>Who is the most popular artist: Eminem, Beyonce, Pink Floyd and Led Zeppelin</summary>
  
```python
# and what are their popularity ratings?
from dataprep.connector import connect

# You can get ”spotify_client_id“ and "spotify_client_secret" by registering as a developer https://developer.spotify.com/dashboard/#
conn_spotify = connect("spotify", _auth={"client_id":spotify_client_id, "client_secret":spotify_client_secret}, _concurrency=3)

artists_and_num_followers = []
for artist in ['Beyonce', 'Pink Floyd', 'Eminem', 'Led Zeppelin']:
    df = await conn_spotify.query("artist", q = artist, _count = 500) 
    num_followers = df.loc[df['# followers'].idxmax(), 'popularity']
    artists_and_num_followers.append((artist, num_followers))

print(sorted(artists_and_num_followers, key=lambda x: x[1], reverse=True))
```

    [('Eminem', 94.0), ('Beyonce', 88.0), ('Pink Floyd', 83.0), ('Led Zeppelin', 81.0)]```python
    
</details> 
<details>
  <summary>Who are the top 5 artists with the most followers from the current Billboard top 100 artists?</summary>
  
```python
from dataprep.connector import connect
from bs4 import BeautifulSoup
import requests

# You can get ”spotify_client_id“ and "spotify_client_secret" by registering as a developer https://developer.spotify.com/dashboard/#
conn_spotify = connect("spotify", _auth={"client_id":spotify_client_id, "client_secret":spotify_client_secret}, _concurrency=3)

web_page = requests.get("https://www.billboard.com/charts/artist-100")
html_soup = BeautifulSoup(web_page.text, 'html.parser')
artist_100 = html_soup.find_all('span', class_ = 'chart-list-item__title-text')

artists = {}
artists_top5 = []
for artist in artist_100:
    df_temp = await conn_spotify.query("artist", q = artist.text.strip(), _count = 10)
    df_temp = df_temp.loc[df_temp['popularity'].idxmax()]
    artists[df_temp['name']] = df_temp['# followers']
artists_top5 = sorted(artists, key = artists.get, reverse = True)[:5]
artists_top5
```




    ['Ed Sheeran', 'Ariana Grande', 'Drake', 'Justin Bieber', 'Eminem']
    
</details> 
<details>
  <summary>For a list of top 10 most popular albums from rollingstone.com which album has most selling markets (countries) around the world in 2020?</summary>
  
```python
from dataprep.connector import connect
import asyncio

# You can get ”spotify_client_id“ and "spotify_client_secret" by registering as a developer https://developer.spotify.com/dashboard/#
conn_spotify = connect("spotify", _auth={"client_id":spotify_client_id, "client_secret":spotify_client_secret}, _concurrency=3)

def count_markets(text):
    lst = text.split(',')
    return len(lst)

album_artists = ["Folklore", "Fetch the Bolt Cutters", "YHLQMDLG", "Rough and Rowdy Ways", "Future Nostalgia",
                 "RTJ4", "Saint Cloud", "Eternal Atake", "What’s Your Pleasure", "Punisher"]

album_list = [conn_spotify.query("album", q = name, _count = 1) for name in album_artists]
combined = asyncio.gather(*album_list)
df = pd.concat(await combined).reset_index()
df = df.drop(columns = ['image url', 'external urls', 'index'])
df['market_count'] = df['available_markets'].apply(lambda x: count_markets(x))
df = df.loc[df['market_count'].idxmax()]
print(df['album_name'] + ", by " + df['artist'][0] + ", with " + str(df['market_count']) + " avalible countries")
```


    folklore, by Taylor Swift, with 92 avalible countries

    
</details> 

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


#### [Etsy](./etsy) -- Collect Handmade Marketplace Data.

<details>
  <summary>What are the products I can get when I search for "winter jackets"?</summary>

```python
from dataprep.connector import connect

# You can get ”etsy_access_key“ by following https://www.etsy.com/developers/documentation/getting_started/oauth
conn_etsy = connect("etsy", _auth={'access_token': etsy_access_key}, _concurrency = 5)
# Item search
df = await conn_etsy.query("items", keywords = "winter jackets")
df[['title',"url","description","price","currency"]]
```

| id   | title                                             | url                                               | description                                         | price  | currency | quantity |
| ---- | ------------------------------------------------- | ------------------------------------------------- | --------------------------------------------------- | ------ | -------- | -------- |
| 0    | White coat,cashmere coat,wool jacket with belt... | https://www.etsy.com/listing/646692584/white-c... | ★Please leave your phone number to me while yo...   | 183.00 | USD      | 1        |
| 1    | Vintage 90&#39;s Nike ACG Parka Jacket Large N... | https://www.etsy.com/listing/937300597/vintage... | Vintage 90&#39;s Nike ACG Parka Jacket Large N...   | 110.00 | USD      | 1        |
| ...  | ... ...                                           | ... ...                                           | ... ...                                             | ...    | ....     | ..       |
| 24   | Miss yo 2018 Vintage Checker Jacket for Blythe... | https://www.etsy.com/listing/613790308/miss-yo... | ~~ Welcome to our shop ~~\n\nSet include:\n1 Vin... | 52.00  | SGD      | 1        |

</details>

<details>
  <summary>What's the favorites for the shop “CrazedGaming”?</summary>

```python
from dataprep.connector import connect

# You can get ”etsy_access_key“ by following https://www.etsy.com/developers/documentation/getting_started/oauth
conn_etsy = connect("etsy", _auth={'access_token': etsy_access_key}, _concurrency = 5)

# Shop search
df = await conn_etsy.query("shops", shop_name = "CrazedGaming",  _count = 1)
df[["name", "url", "favorites"]]
```

| id   | Name         | Url                                               | Favorites |
| ---- | ------------ | ------------------------------------------------- | --------- |
| 0    | CrazedGaming | https://www.etsy.com/shop/CrazedGaming?utm_sou... | 265       |

</details>

<details>
  <summary>What are the top 10 custom photo pillows ranked by number of favorites?</summary>

```python
from dataprep.connector import connect

# You can get ”etsy_access_key“ by following https://www.etsy.com/developers/documentation/getting_started/oauth
conn_etsy = connect("etsy", _auth = {"access_token": etsy_access_key}, _concurrency = 5)

# Item search sort by favorites
df_cp_pillow = await conn_etsy.query("items", keywords = "custom photo pillow", _count = 7000)
df_cp_pillow = df_cp_pillow.sort_values(by = ['favorites'], ascending = False)
df_top10_cp_pillow = df_cp_pillow.iloc[:10]
df_top10_cp_pillow[['title', 'price', 'currency', 'favorites', 'quantity']]
```

| id   | title                                              | price | currency | favorites | quantity |
| ---- | -------------------------------------------------- | ----- | -------- | --------- | -------- |
| 68   | Custom Pet Photo Pillow, Valentines Day Gift, ...  | 29.99 | USD      | 9619.0    | 320.0    |
| 193  | Custom Shaped Dog Photo Pillow Personalized Mo...  | 29.99 | USD      | 5523.0    | 941.0    |
| 374  | Custom PILLOW Pet Portrait - Pet Portrait Pill...  | 49.95 | USD      | 5007.0    | 74.0     |
| 196  | Personalized Cat Pillow Mothers Day Gift for M...  | 29.99 | USD      | 3839.0    | 939.0    |
| 69   | Photo Sequin Pillow Case, Personalized Sequin ...  | 25.49 | USD      | 3662.0    | 675.0    |
| 637  | Family photo sequin pillow \| custom image reve... | 28.50 | USD      | 3272.0    | 540.0    |
| 44   | Custom Pet Pillow Custom Cat Pillow best cat l...  | 20.95 | USD      | 2886.0    | 14.0     |
| 646  | Sequin Pillow with Photo Personalized Photo Re...  | 32.00 | USD      | 2823.0    | 1432.0   |
| 633  | Personalized Name Pillow, Baby shower gift, Ba...  | 16.00 | USD      | 2511.0    | 6.0      |
| 4416 | Letter C pillow Custom letter Alphabet pillow ...  | 24.00 | USD      | 2284.0    | 4.0      |

</details>



<details>
  <summary>What are the prices of active products for quantities (>10) for a particular searched keyword "blue 2021 weekly spiral planner"?</summary>

```python
from dataprep.connector import connect

# You can get ”etsy_access_key“ by following https://www.etsy.com/developers/documentation/getting_started/oauth
conn_etsy = connect("etsy", _auth={'access_token': etsy_access_key}, _concurrency = 5)

# Item search and filters
planner_df = await conn_etsy.query("items", keywords = "blue 2021 weekly spiral planner", _count = 100)

result_df = planner_df[((planner_df['state'] == 'active') & (planner_df['quantity'] > 10))]
result_df
```

| id   | title                                             | state  | url                                               | description                                       | price | currency | quantity | views | favorites |
| ---- | ------------------------------------------------- | ------ | ------------------------------------------------- | ------------------------------------------------- | ----- | -------- | -------- | ----- | --------- |
| 1    | 2021 Plaid About You Medium Daily Weekly Month... | active | https://www.etsy.com/listing/789842329/2021-pl... | Planning and organizing life is a snap with th... | 15.99 | USD      | 496      | 100   | 11        |
| 2    | 2021 Undated Diary Planner , Notebook Weekly D... | active | https://www.etsy.com/listing/917640414/2021-un... | A6 2021 Yearly Monthly Weekly Agenda Planner ,... | 12.00 | GBP      | 792      | 3433  | 168       |
| .    | ... ...                                           | ...    | ... ...                                           | ... ...                                           | ...   | ..       | ...      | ...   | ...       |
| 85   | July 2020-June 2021 Big Blue Year Large Daily ... | active | https://www.etsy.com/listing/776300099/july-20... | This 12-month academic year planner offers a c... | 6.95  | USD      | 493      | 454   | 31        |

</details>



<details>
  <summary>What's the average price for blue denim frayed jacket on Etsy selling in USD currency?</summary>

  ```python
from dataprep.connector import connect

# You can get ”etsy_access_key“ by following https://www.etsy.com/developers/documentation/getting_started/oauth
conn_etsy = connect("etsy", _auth = {"access_token": etsy_access_key}, _concurrency = 5)

# Item search and filters 
df_dbfjacket = await conn_etsy.query("items", keywords = "blue denim frayed jacket", _count = 500)
df_dbfjacket = df_dbfjacket[df_dbfjacket['currency'] == 'USD'].astype(float)

# Calculate average price
average_price = round(df_dbfjacket['price'].mean(), 2)
print("The average price for blue denim frayed jacket is: $", average_price)
  ```

The average price for blue denim frayed jacket is: $ 58.82

</details>



<details>
  <summary>What are the top 10 viewed  for keyword “ceramic wind chimes” with a given word “handmade” present in the description?</summary>

  ```python
from dataprep.connector import connect

# You can get ”etsy_access_key“ by following https://www.etsy.com/developers/documentation/getting_started/oauth
conn_etsy = connect("etsy", _auth = {"access_token": etsy_access_key}, _concurrency = 5)

# Item search
df = await conn_etsy.query("items", keywords = "ceramic wind chimes",  _count = 2000)

# Filter and sorting
df = df[(df["description"].str.contains('handmade'))]
new_df = df[["title", "url", "views"]]
new_df.sort_values(by="views", ascending=False).reset_index(drop=True).head(10)
  ```

| id   | title                                               | url                                               | views |
| ---- | --------------------------------------------------- | ------------------------------------------------- | ----- |
| 0    | Hanging ceramic wind chime in gloss white glaz...   | https://www.etsy.com/listing/101462779/hanging... | 24406 |
| 1    | Trending Now! Best Seller Birthday Gift for Mo...   | https://www.etsy.com/listing/555128094/trendin... | 17058 |
| 2    | Beautiful Ceramic outdoor hanging wind chime -...   | https://www.etsy.com/listing/155966922/beautif... | 9758  |
| 3    | Wind Chime, Garden Yard Art for Outdoor Home D...   | https://www.etsy.com/listing/159252106/wind-ch... | 8850  |
| 4    | Ceramic cow bells \| wind chime bell \| wall han... | https://www.etsy.com/listing/538608210/ceramic... | 6540  |
| 5    | Mom Gift Ideas Housewarming Gifts Garden Decor...   | https://www.etsy.com/listing/171539253/mom-gif... | 6123  |
| 6    | Ceramic Wind Chimes single strand Wall Hanging...   | https://www.etsy.com/listing/598234797/ceramic... | 5288  |
| 7    | Handcraft Ceramic Bird Wind Chime/ Bird Windch...   | https://www.etsy.com/listing/697798625/handcra... | 4733  |
| 8    | Glass Wind Chime Green Leaves Windchime Garden...   | https://www.etsy.com/listing/744753959/glass-w... | 4579  |
| 9    | Handmade ceramic and driftwood wind chimes Bea...   | https://www.etsy.com/listing/615210251/handmad... | 2774  |

</details>





### Social

#### [Twitch](./twitch) -- Colect Twitch Streams and Channels Information
<details>
  <summary>How many followers does the Twitch user "Logic" have?</summary>
  
```python
from dataprep.connector import connect

# You can get ”twitch_access_token“ by registering https://www.twitch.tv/signup
conn_twitch = connect("twitch", _auth={"access_token":twitch_access_token}, _concurrency=3)

df = await conn_twitch.query("channels", query="logic", _count = 1000)

df = df.where(df['name'] == 'logic').dropna()
df = df[['name', 'followers']]
df.reset_index()
```





<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>index</th>
      <th>name</th>
      <th>followers</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0</td>
      <td>logic</td>
      <td>540274.0</td>
    </tr>
  </tbody>
</table>
</div>
  </details>  
<details>
  <summary>Which 5 Twitch users that speak English have the most views and what games do they play?</summary>
  
```python
from dataprep.connector import connect

# You can get ”twitch_access_token“ by registering https://www.twitch.tv/signup
conn_twitch = connect("twitch", _auth={"access_token":twitch_access_token}, _concurrency=3)

df = await conn_twitch.query("channels",query="%", _count = 1000)

df = df[df['language'] == 'en']
df = df.sort_values('views', ascending = False)
df = df[['name', 'views', 'game', 'language']]
df = df.head(5)
df.reset_index()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>index</th>
      <th>name</th>
      <th>views</th>
      <th>game</th>
      <th>language</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>495</td>
      <td>Fextralife</td>
      <td>1280705870</td>
      <td>The Elder Scrolls Online</td>
      <td>en</td>
    </tr>
    <tr>
      <th>1</th>
      <td>9</td>
      <td>Riot Games</td>
      <td>1265668908</td>
      <td>League of Legends</td>
      <td>en</td>
    </tr>
    <tr>
      <th>2</th>
      <td>16</td>
      <td>ESL_CSGO</td>
      <td>548559390</td>
      <td>Counter-Strike: Global Offensive</td>
      <td>en</td>
    </tr>
    <tr>
      <th>3</th>
      <td>160</td>
      <td>BeyondTheSummit</td>
      <td>462493560</td>
      <td>Dota 2</td>
      <td>en</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1</td>
      <td>shroud</td>
      <td>433902453</td>
      <td>Rust</td>
      <td>en</td>
    </tr>
  </tbody>
</table>
</div>


  </details>  
<details>
  <summary>Which channel has the most viewers for each of the top 10 games?</summary>
  
```python
from dataprep.connector import connect

# You can get ”twitch_access_token“ by registering https://www.twitch.tv/signup
conn_twitch = connect("twitch", _auth={"access_token":twitch_access_token}, _concurrency=3)

df = await conn_twitch.query("streams", query="%", _count = 1000)

# Group by games, sum viewers and sort by total viewers
df_new = df.groupby(['game'], as_index = False)['viewers'].agg('sum').rename(columns = {'game':'games', 'viewers':'total_viewers'})
df_new = df_new.sort_values('total_viewers',ascending = False)

# Select the channel with most viewers from each game 
df_2 = df.loc[df.groupby(['game'])['viewers'].idxmax()]

# Select the most popular channels for each of the 10 most popular games
df_new = df_new.head(10)['games']
best_games = df_new.tolist()
result_df = df_2[df_2['game'].isin(best_games)]
result_df = result_df.head(10)
result_df = result_df[['game','channel_name', 'viewers']]
result_df.reset_index()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>index</th>
      <th>game</th>
      <th>channel_name</th>
      <th>viewers</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>3</td>
      <td></td>
      <td>seonghwazip</td>
      <td>32126</td>
    </tr>
    <tr>
      <th>1</th>
      <td>21</td>
      <td>Call of Duty: Warzone</td>
      <td>FaZeBlaze</td>
      <td>7521</td>
    </tr>
    <tr>
      <th>2</th>
      <td>9</td>
      <td>Dota 2</td>
      <td>dota2mc_ru</td>
      <td>16118</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2</td>
      <td>Escape From Tarkov</td>
      <td>summit1g</td>
      <td>33768</td>
    </tr>
    <tr>
      <th>4</th>
      <td>15</td>
      <td>Fortnite</td>
      <td>Fresh</td>
      <td>10371</td>
    </tr>
    <tr>
      <th>5</th>
      <td>8</td>
      <td>Hearthstone</td>
      <td>SilverName</td>
      <td>16765</td>
    </tr>
    <tr>
      <th>6</th>
      <td>22</td>
      <td>Just Chatting</td>
      <td>Trainwreckstv</td>
      <td>6927</td>
    </tr>
    <tr>
      <th>7</th>
      <td>0</td>
      <td>League of Legends</td>
      <td>LCK_Korea</td>
      <td>77613</td>
    </tr>
    <tr>
      <th>8</th>
      <td>10</td>
      <td>Minecraft</td>
      <td>Tfue</td>
      <td>15209</td>
    </tr>
    <tr>
      <th>9</th>
      <td>11</td>
      <td>VALORANT</td>
      <td>TenZ</td>
      <td>13617</td>
    </tr>
  </tbody>
</table>
</div>


  </details>  
<details>
  <summary>(1) What is the number of Fortnite and Valorant streams in the past 24 hours?
      (2) Is there any relationship between viewers and channel followers?
</summary>
  
```python
from dataprep.connector import connect
import pandas as pd

# You can get ”twitch_access_token“ by registering https://www.twitch.tv/signup
conn_twitch = connect("twitch", _auth = {"access_token":twitch_access_token}, _concurrency = 3)

df = await conn_twitch.query("streams", query = "%fortnite%VALORANT%", _count = 1000)

df = df[['stream_created_at', 'game', 'viewers', 'channel_followers']]
df['stream_created_at'] = df['stream_created_at'].astype('str') # Convert date to string

for idx, value in enumerate(df['stream_created_at']):
    df.loc[idx,'stream_created_at'] = value[0:9] + ' ' + value[-9:-1] # Extract datetime

df['stream_created_at'] = pd.to_datetime(df['stream_created_at']) 
df['diff'] = pd.Timestamp.now().normalize() - df['stream_created_at'] 
df['diff'] = df['diff'].dt.total_seconds().astype('int') 

df2 = df[['channel_followers', 'viewers']].corr(method='pearson') # Find correlation (part 2)

df = df[df['diff'] > 864000] # Find streams in last 24 hours

options = ['Fortnite', 'VALORANT']
df = df[df['game'].isin(options)]
df = df.groupby(['game'], as_index=False)['diff'].agg('count').rename(columns={'diff':'count'})

# Print correlation part 2
print("Correlation between viewers and channel followers:")
print(df2)

# Print part 1
print('Number of streams in the past 24 hours:')
df
```

    Correlation between viewers and channel followers:
                       channel_followers   viewers
    channel_followers           1.000000  0.851698
    viewers                     0.851698  1.000000
    
Number of streams in the past 24 hours:





<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>game</th>
      <th>count</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Fortnite</td>
      <td>3</td>
    </tr>
    <tr>
      <th>1</th>
      <td>VALORANT</td>
      <td>3</td>
    </tr>
  </tbody>
</table>
</div>
</details>  


#### [Twitter](./twitter) -- Colect Tweets Information

<details>
  <summary>What are the 10 latest english tweets by SFU handle (@SFU) ?</summary>

```python
from dataprep.connector import connect

dc = connect('twitter', _auth={'client_id':client_id, 'client_secret':client_secret})

# Querying 100 tweets from @SFU
df = await dc.query("tweets", _q="from:@SFU -is:retweet", _count=100)

# Filtering english language tweets
df = df[df['iso_language_code'] == 'en'][['created_at', 'text']]

# Displaying latest 10 tweets
df = df.iloc[0:10,]
print('-----------')
for index, row in df.iterrows():   
    print(row['created_at'], row['text'])
    print('-----------')
```

```
-----------
Mon Feb 01 23:59:16 +0000 2021 Thank you to these #SFU student athletes for sharing their insights. #BlackHistoryMonth2021 https://t.co/WGCvGrQOzu
-----------
Mon Feb 01 23:00:56 +0000 2021 How can #SFU address issues of inclusion &amp; access for #Indigenous students &amp; work with them to support their educat… https://t.co/knEM0SSHYu
-----------
Mon Feb 01 21:37:30 +0000 2021 DYK: New #SFU research shows media gender bias; men are quoted 3 times more often than women. #GenderGapTracker loo… https://t.co/c77PsNUIqV
-----------
Mon Feb 01 19:55:03 +0000 2021 With the temperatures dropping, how will you keep warm this winter? Check out our tips on what to wear (and footwea… https://t.co/EOCuYbio4P
-----------
Mon Feb 01 18:06:49 +0000 2021 COVID-19 has affected different groups in unique ways. #SFU researchers looked at the stresses facing “younger” old… https://t.co/gMvcxOlWvb
-----------
Mon Feb 01 16:18:51 +0000 2021 Please follow @TransLink for updates. https://t.co/nQDZQ5JYlt
-----------
Fri Jan 29 23:00:02 +0000 2021 #SFU researchers Caroline Colijn and Paul Tupper performed a modelling exercise to see if screening with rapid test… https://t.co/07aU3SP0j2
-----------
Fri Jan 29 19:01:32 +0000 2021 un/settled, a towering photo-poetic piece at #SFU's Belzberg Library, aims to centre Blackness &amp; celebrate Black th… https://t.co/F6kp0Lwu5A
-----------
Fri Jan 29 17:02:34 +0000 2021 Learning that it’s okay to ask for help is an important part of self-care—and so is recognizing when you don't have… https://t.co/QARn1CRLyp
-----------
Fri Jan 29 00:44:11 +0000 2021 @shashjayy @shashjayy Hi Shashwat, I've spoken to my colleagues in Admissions. They're looking into it and will respond to you directly.
-----------
```

</details>



<details>
  <summary>What are top 10 users based on retweet count ?</summary>

  ```python
from dataprep.connector import connect

dc = connect('twitter', _auth={'client_id':client_id, 'client_secret':client_secret})

# Querying 1000 retweets and filtering only english language tweets
df = await dc.query("tweets", q='RT AND is:retweet', _count=1000)
df = df[df['iso_language_code'] == 'en']

# Iterating over tweets to get users and Retweet Count
retweets = {}
for index, row in df.iterrows():
    if row['text'].startswith('RT'):
        # Eg. tweet 'RT @Crazyhotboye: NMS?\nLeveled up to 80' 
        user_retweeted = row['text'][4:row['text'].find(':')]
        if user_retweeted in retweets:
            retweets[user_retweeted] += 1
        else:
            retweets[user_retweeted] = 1
            
# Sorting and displaying top 10 users
cols = ['User', 'RT_Count']
retweets_df = pd.DataFrame(list(retweets.items()), columns=cols)
retweets_df = retweets_df.sort_values(by=['RT_Count'], ascending=False).reset_index(drop=True).iloc[0:10,:]
retweets_df
  ```

| id   | User            | RT_Count |
| ---- | --------------- | -------- |
| 0    | John_Greed      | 195      |
| 1    | uEatCrayons     | 85       |
| 2    | Demo2020cracy   | 78       |
| 3    | store_pup       | 75       |
| 4    | miknitem_oasis  | 61       |
| 5    | MarkCrypto23    | 54       |
| 6    | realmamivee     | 52       |
| 7    | trailblazers    | 50       |
| 8    | devilsvalentine | 40       |
| 9    | SharingforCari1 | 38       |

</details>



<details>
  <summary>What are the trending topics (Top 10) in twitter now based on hashtags count?</summary>

  ```python
from dataprep.connector import connect
import pandas as pd
import json

dc = connect('twitter', _auth={'client_id':client_id, 'client_secret':client_secret})

pd.options.mode.chained_assignment = None
df = await dc.query("tweets", q=False, _count=2000)

def extract_tags(tags):
    tags_tolist = json.loads(tags.replace("'", '"'))
    only_tag = [str(t['text']) for t in tags_tolist]
    return only_tag
  
# remove tweets which do not have hashtag
has_hashtags = df[df['hashtags'].str.len() > 2]
# only 'en' tweets are our interests
has_hashtags = has_hashtags[has_hashtags['iso_language_code'] == 'en']
has_hashtags['tag_list'] = has_hashtags['hashtags'].apply(lambda t: extract_tags(t))
tags_and_text = has_hashtags[['text','tag_list']]
tag_count = tags_and_text.explode('tag_list').groupby(['tag_list']).agg(tag_count=('tag_list', 'count'))
# remove tag with only one occurence
tag_count = tag_count[tag_count['tag_count'] > 1]
tag_count = tag_count.sort_values(by=['tag_count'], ascending=False).reset_index()
# Top 10 hashtags
tag_count = tag_count.iloc[0:10,:]
tag_count
  ```

| id   | tag_list                 | tag_count |
| ---- | ------------------------ | --------- |
| 0    | jobs                     | 52        |
| 1    | TractorMarch             | 24        |
| 2    | corpsehusbandallegations | 22        |
| 3    | SidNaazians              | 10        |
| 4    | GodMorningTuesday        | 8         |
| 5    | SupremeGodKabir          | 7         |
| 6    | hiring                   | 7         |
| 7    | نماز_راہ_نجات_ہے         | 6         |
| 8    | London                   | 5         |
| 9    | TravelTuesday            | 5         |

</details>



### Video


#### [Youtube](./youtube) -- Colect Youtube's Content MetaData.

<details>
  <summary>What are the top 10 Fitness Channels?</summary>
  
  ```python
from dataprep.connector import connect, info

dc = connect('youtube', _auth={'access_token': auth_token})

df = await dc.query('videos', q='Fitness', part='snippet', type='channel', _count=10)
df[['title', 'description']]
  ```

| id   | title                       | description                                       |
| ---- | --------------------------- | ------------------------------------------------- |
| 0    | Jordan Yeoh Fitness         | Hey! Welcome to my Youtube channel! I got noth... |
| 1    | FitnessBlender              | 600 free full length workout videos & counting... |
| 2    | The Fitness Marshall        | Get early access to dances by clicking here: h... |
| 3    | POPSUGAR Fitness            | POPSUGAR Fitness offers fresh fitness tutorial... |
| 4    | LiveFitness                 | Hi, I am Nicola and I love all things fitness!... |
| 5    | TpindellFitness             | Strive for progress, not perfection.              |
| 6    | Love Sweat Fitness          | My personal weight loss journey of 45 pounds c... |
| 7    | Martial Arts Fitness        | Welcome To My Channel. I love Martial Arts 🥇 ...  |
| 8    | Zuzka Light                 | My name is Zuzka Light, and my channel is all ... |
| 9    | Fitness Factory Lüdenscheid | Schaut unter ff-luedenscheid.com Kostenlos übe... |

</details>

<details>
  <summary>Whats the top Playlists of a list of Singers?</summary>
  
  ```python
from dataprep.connector import connect, info
import pandas as pd

dc = connect('youtube', _auth={'access_token': auth_token})

df = pd.DataFrame()
singers = [
    'taylor swift',
    'ed sheeran',
    'shawn mendes',
    'ariana grande',
    'michael jackson',
    'selena gomez',
    'lady gaga',
    'shreya ghoshal',
    'bruno mars',
    ]

for singer in singers:
    df1 = await dc.query('videos', q=singer, part='snippet', type='playlist',
                   _count=1)
    df = df.append(df1, ignore_index=True)

df[['title', 'description', 'channelTitle']]
  ```

| id   | title                                               | description                                         | channelTitle           |
| ---- | --------------------------------------------------- | --------------------------------------------------- | ---------------------- |
| 0    | Taylor Swift Discography                            |                                                     | Sarah Bella            |
| 1    | Ed Sheeran - New And Best Songs (2021)              | Best Of Ed Sheeran 2021 \|\| Ed Sheeran Greatest... | Full Albums!           |
| 2    | Shawn Mendes: The Album 2018 (Full Album)           |                                                     | WorldMusicStream       |
| 3    | Ariana Grande - Positions (Full Album)              | October 30, 2020.                                   | lo115                  |
| 4    | Michael Jackson Mix                                 | Michael Jackson's Songs.                            | Leo Meneses            |
| 5    | Selena Gomez - Rare [FULL ALBUM 2020]               | selena gomez,selena gomez rare album,selena go...   | THUNDERS               |
| 6    | Lady Gaga - Greatest Hits                           | Lady Gaga - Greatest Hits 01 The Edge Of Glory...   | Gunther Ruymen         |
| 7    | Shreya Ghoshal Tamil Hit Songs \| #TamilSongs \|... |                                                     | Sony Music South       |
| 8    | The Best of Bruno Mars                              |                                                     | Warner Music Australia |

</details>






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
    <td align="center"><a href="http://wooya.me"><img src="https://avatars1.githubusercontent.com/u/998606?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Weiyuan Wu</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=dovahcrow" title="Code">💻</a> <a href="#maintenance-dovahcrow" title="Maintenance">🚧</a></td>
    <td align="center"><a href="http://www.sfu.ca/~peiw/"><img src="https://avatars0.githubusercontent.com/u/15167104?v=4?s=100" width="100px;" alt=""/><br /><sub><b>peiwangdb</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=peiwangdb" title="Code">💻</a> <a href="#maintenance-peiwangdb" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://github.com/nick-zrymiak"><img src="https://avatars0.githubusercontent.com/u/35017006?v=4?s=100" width="100px;" alt=""/><br /><sub><b>nick-zrymiak</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=nick-zrymiak" title="Code">💻</a> <a href="#maintenance-nick-zrymiak" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://www.pallavibharadwaj.com"><img src="https://avatars1.githubusercontent.com/u/17384838?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Pallavi Bharadwaj</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=pallavibharadwaj" title="Code">💻</a></td>
    <td align="center"><a href="https://www.linkedin.com/in/hilal-asmat/"><img src="https://avatars1.githubusercontent.com/u/28606148?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Hilal Asmat</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=h-asmat" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/Wukkkinz-0725"><img src="https://avatars.githubusercontent.com/u/60677420?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Wukkkinz-0725</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=Wukkkinz-0725" title="Code">💻</a> <a href="#maintenance-Wukkkinz-0725" title="Maintenance">🚧</a></td>
    <td align="center"><a href="https://github.com/Yizhou150"><img src="https://avatars.githubusercontent.com/u/62522644?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Yizhou</b></sub></a><br /><a href="https://github.com/sfu-db/DataConnectorConfigs/commits?author=Yizhou150" title="Code">💻</a> <a href="#maintenance-Yizhou150" title="Maintenance">🚧</a></td>

  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
