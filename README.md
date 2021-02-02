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
