library(rvest)
library(tidyverse)
library(here)

pokemon_html <- read_html("https://pokemondb.net/pokedex/all")

pokemon_tab <- pokemon_html %>%
  html_node('table') %>%
  html_table()

# cleaning
# Need to separate type to type 1 and type 2
# https://www.regular-expressions.info/lookaround.html
# add legendary (includes mythical) T/F and which gen
legendary <- c('Articuno', 'Zapdos', 'Moltres', 'Raikou', 'Entei', 'Suicune', 'Regirock',
               'Regice', 'Registeel', 'Latias', 'Latios', 'Uxie', 'Mesprit', 'Azelf', 'Heatran', 
               'Regigigas', 'Cresselia', 'Cobalion', 'Terrakion', 'Virizion', 'Tornadus', 'Thundurus',
               'Landorus', 'Type: Null', 'Silvally', 'Tapu Koko', 'Tapu Lele', 'Tapu Bulu', 'Tapu Fini',
               'Nihilego', 'Buzzwole', 'Pheromosa', 'Xurkitree', 'Celesteela', 'Kartana',
               'Guzzlord', 'Poipole', 'Naganadel', 'Stakataka', 'Blacephalon', 'Kubfu',
               'Urshifu', 'Regieleki', 'Regidrago', 'Glastrier', 'Spectrier', 'Mewtwo',
               'Lugia', 'Ho-Oh', 'Kyogre', 'Groudon', 'Rayquaza', 'Dialga', 'Palkia', 'Giratina',
               'Reshiram', 'Zekrom', 'Kyurem', 'Xerneas', 'Yveltal', 'Zygarde', 'Cosmog',
               'Cosmoem', 'Solgaleo', 'Lunala', 'Necrozma', 'Zacian', 'Zamazenta', 'Eternatus',
               'Calyrex', 'Mew', 'Celebi', 'Jirachi', 'Deoxys', 'Phione', 'Manaphy', 'Darkrai',
               'Shaymin', 'Arceus', 'Victini', 'Keldeo', 'Meloetta', 'Genesect', 'Diancie', 
               'Hoopa', 'Volcanion', 'Magearna', 'Marshadow', 'Zeraora', 'Meltan', 'Melmetal', 'Zarude')

gen1 <- 1:151
gen2 <- 152:251
gen3 <- 252:386
gen4 <- 387:493
gen5 <- 494:649
gen6 <- 650:721
gen7 <- 722:809
gen8 <- 810:898

pokemon <- pokemon_tab %>%
  mutate(legendary = Name %in% legendary) %>%
  rename(Number = `#`) %>%
  tidyr::separate(Type,
                  into = c('Type1','Type2'),
                  sep = "(?<=[a-z])(?=[A-Z])") %>%
  filter(str_detect(Name, "Mega|Alolan|Galarian", negate = TRUE)) %>%
  mutate(gen = if_else(Number %in% gen1, 1, 
                       if_else(Number %in% gen2, 2,
                               if_else(Number %in% gen3, 3,
                                       if_else(Number %in% gen4, 4,
                                               if_else(Number %in% gen5, 5,
                                                       if_else(Number %in% gen6, 6,
                                                               if_else(Number %in% gen7, 7, 8))))))))


# write out to csv format
write_csv(pokemon, here('R', 'data', 'pokemon.csv'))

