library(rvest)
library(tidyverse)
library(here)

pokemon <- read_html("https://pokemondb.net/pokedex/all")

pokemon <- pokemon %>%
  html_node('table') %>%
  html_table()

# cleaning
# Need to separate type to type 1 and type 2
# https://www.regular-expressions.info/lookaround.html

pokemon <- tidyr::separate(pokemon, Type,
                into = c('Type1','Type2'),
                sep = "(?<=[a-z])(?=[A-Z])")

# write out to csv format
write_csv(pokemon, here('WebScraping', 'R', 'data', 'pokemon.csv'))

