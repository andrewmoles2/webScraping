# code adapted from https://srome.github.io/Parsing-HTML-Tables-in-Python-with-BeautifulSoup-and-pandas/

import pandas as pd
from bs4 import BeautifulSoup
import requests
from html_table_parse import *

# testing out parsing text from html using requests
url = "https://pokemondb.net/pokedex/all"
#response = requests.get(url)
#print(response.text[:100])

# get html table class to hp
hp = htmlTable()
table = hp.parse_url(url)[0][1]
print(table.head())
