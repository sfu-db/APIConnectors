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


#### [CoinGecko](./coingecko) -- Collect Cryptocurrency Data

<details>
  <summary>What is top 10 cryptocurrency with highest market cap and their current information?</summary>
  
```python
from dataprep.connector import connect

conn_coingecko = connect("coingecko")
df = await conn_coingecko.query('markets', vs_currency='usd', order='market_cap_desc', per_page=10, page=1)
df
```
|    | name         | symbol   |   current_price |   market_cap |   market_cap_rank |     high_24h |      low_24h |   price_change_24h |   price_change_percentage_24h |   market_cap_change_24h |   market_cap_change_percentage_24h | last_updated             |
|---:|:-------------|:---------|----------------:|-------------:|------------------:|-------------:|-------------:|-------------------:|------------------------------:|------------------------:|-----------------------------------:|:-------------------------|
|  0 | Bitcoin      | btc      |    36811        |  6.86613e+11 |                 1 | 37153        | 35344        |      1440.68       |                       4.0731  |             3.10933e+10 |                            4.7433  | 2021-02-03T19:24:09.271Z |
|  1 | Ethereum     | eth      |     1628.99     |  1.87035e+11 |                 2 |  1645.73     |  1486.42     |       132.91       |                       8.88404 |             1.64296e+10 |                            9.63018 | 2021-02-03T19:22:32.413Z |
| .. | ...          | ...      |  ...            |  ...         |               ... |   ...        |     ...      |        ...         |                           ... |                     ... |                                ... |                      ... |
|  9 | Binance Coin | bnb      |       51.47     |  7.60256e+09 |                10 |    51.63     |    49.76     |         1.24       |                       2.47631 |             1.64863e+08 |                            2.21659 | 2021-02-03T19:25:45.456Z |
</details>

<details>
  <summary>What are the cryptocurrency with highest increase percentage and decrease percentage?</summary>
  
```python
from dataprep.connector import connect

conn_coingecko = connect("coingecko")
df = await conn_coingecko.query('markets', vs_currency='usd', per_page=1000, page=1)
df = df.sort_values(by=['price_change_percentage_24h']).reset_index(drop=True).dropna()
print("Coin with highest decrease percetage: {}, which decreases {}%".format(df['name'].iloc[0], df['price_change_percentage_24h'].iloc[0]))
print("Coin with highest increase percetage: {}, which decreases {}%".format(df['name'].iloc[-1], df['price_change_percentage_24h'].iloc[-1]))
```
Coin with the highest decrease percentage: `PancakeSwap`, which decreases `-13.79622%`

Coin with the highest increase percentage: `StormX`, which decreases `101.24182%`
</details>

<details>
  <summary>What is the trending in CoinGecko?</summary>
  
```python
from dataprep.connector import connect

conn_coingecko = connect("coingecko")
df = await conn_coingecko.query('trend')
df
```
|    | id                | name        | symbol   |   market_cap_rank |   score |
|---:|:------------------|:------------|:---------|------------------:|--------:|
|  0 | bao-finance       | Bao Finance | BAO      |               175 |       0 |
|  1 | milk2             | MILK2       | MILK2    |               634 |       1 |
|  2 | unitrade          | Unitrade    | TRADE    |               529 |       2 |
|  3 | pancakeswap-token | PancakeSwap | CAKE     |               110 |       3 |
|  4 | fsw-token         | Falconswap  | FSW      |               564 |       4 |
|  5 | zeroswap          | ZeroSwap    | ZEE      |               550 |       5 |
|  6 | storm             | StormX      | STMX     |               211 |       6 |

</details>

<details>
  <summary>What are the top10 US exchanges with highest trade volume in 24h?</summary>

```python
from dataprep.connector import connect

conn_coingecko = connect("coingecko")
df = await conn_coingecko.query('exchanges')
result = df[df['country']=='United States'].reset_index(drop=True).head(10)
result
```
|    | id         | name         |   year_established | ... |   trade_volume_24h_btc_normalized |
|---:|:-----------|:-------------|-------------------:|:----|----------------------------------:|
|  0 | gdax       | Coinbase Pro |               2012 | ... |                         90085.6   |
|  1 | kraken     | Kraken       |               2011 | ... |                         48633.1   |
|  2 | binance_us | Binance US   |               2019 | ... |                         7380.83   |
| .. | ...        | ...          |                ... | ... | ...                               |

</details>

<details>
  <summary>What are the top3 latest traded derivatives with perpetual contract?</summary>

```python
from dataprep.connector import connect
import pandas as pd

conn_coingecko = connect("coingecko")
df = await conn_coingecko.query('derivatives')
perpetual_df = df[df['contract_type'] == 'perpetual'].reset_index(drop=True)
perpetual_df['last_traded_at'] = pd.to_datetime(perpetual_df['last_traded_at'], unit='s')
perpetual_df.sort_values(by=['last_traded_at'], ascending=False).head(3).reset_index(drop=True)
```
|    | market         | symbol     | index_id   | contract_type   |         index |     basis |   funding_rate |   open_interest |       volume_24h | last_traded_at      |
|---:|:---------------|:-----------|:-----------|:----------------|--------------:|----------:|---------------:|----------------:|-----------------:|:--------------------|
|  0 | Huobi Futures  | MATIC-USDT | MATIC      | perpetual       |     0.0433357 | -0.606296 |       0.247604 |             nan |      1.43338e+06 | 2021-02-03 20:14:24 |
|  1 | Biki (Futures) | 1          | BTC        | perpetual       | 36769.8       | -0.153111 |      -0.0519   |             nan |      1.00131e+08 | 2021-02-03 20:14:23 |
|  2 | Huobi Futures  | CVC-USDT   | CVC        | perpetual       |     0.178268  | -0.336302 |       0.106314 |             nan | 876960           | 2021-02-03 20:14:23 |
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



#### [Currents](./currents) -- Collect Currents News Data
<details>
  <summary>How to get latest Chinese news?</summary>
  
```python
from dataprep.connector import connect

# You can get ”currents_access_token“ by following https://currentsapi.services/zh_CN
conn_currents = connect('currents', _auth={'access_token': currents_access_token})
df = await conn_currents.query('latest_news', language='zh')
df.head()
```
| id | title            | category     | ... | author  | published                 |
|---:|:-----------------|:-------------|:----|:--------|:--------------------------|
|  0 | 為何上市公司該汰換了 |[entrepreneur]| ... | 經濟日報 | 2021-02-03 08:48:39 +0000 |
</details>

<details>
  <summary>How to get the politics news about 'Trump'?</summary>
  
```python
from dataprep.connector import connect

# You can get ”currents_access_token“ by following https://currentsapi.services/zh_CN
conn_currents = connect('currents', _auth={'access_token': currents_access_token})
df = await conn_currents.query('search', keywords='Trump', category='politics')
df.head(3)
```
|    | title                                                                                                        | category              | description                                                                                                                    | url                                                                                                               | author        | published                 |
|---:|:-------------------------------------------------------------------------------------------------------------|:----------------------|:-------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------|:--------------|:--------------------------|
|  0 | Biden Started The Process Of Unwinding Trump's Assault On Immigration, But Activists Want Him To Move Faster | ['politics', 'world'] | "These people cannot continue to wait."                                                                                        | https://www.buzzfeednews.com/article/adolfoflores/biden-immigration-executive-orders-review                       | Adolfo Flores | 2021-02-03 08:39:51 +0000 |
|  1 | Pro-Trump lawyer Lin Wood reportedly under investigation for voter fraud                                     | ['politics', 'world'] | A source told CBS Atlanta affiliate WGCL that Lin Wood is being investigated for allegedly voting "out of state."              | https://www.cbsnews.com/news/pro-trump-lawyer-lin-wood-under-investigation-for-alleged-illegal-voting-2020-02-03/ | April Siese   | 2021-02-03 08:21:25 +0000 |
|  2 | Trump Supporters Say They Attacked The Capitol Because He Told Them To, Undercutting His Impeachment Defense | ['politics', 'world'] | “President Trump told Us to ‘fight like hell,’” one Trump supporter reportedly posted online after the assault on the Capitol. | https://www.buzzfeednews.com/article/zoetillman/trump-impeachment-capitol-rioters-fight-like-hell                 | Zoe Tillman   | 2021-02-03 07:25:34 +0000 |
</details>

<details>
  <summary>How to get the news about 'covid-19' in 2020-12-25?</summary>

```python
from dataprep.connector import connect

# You can get ”currents_access_token“ by following https://currentsapi.services/zh_CN
conn_currents = connect('currents', _auth={'access_token': currents_access_token})
df = await conn_currents.query('search', keywords='covid', start_date='2020-12-25',end_date='2020-12-25')
df.head(1)
```

|    | title                                                               | category    | ... | published                 |
|---:|:--------------------------------------------------------------------|:------------|:----|:--------------------------|
|  0 | Commentary: Let our charitable giving equal our political donations | ['opinion'] | ... | 2020-12-25 00:00:00 +0000 |
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
