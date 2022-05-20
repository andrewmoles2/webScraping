# load in libaries
library(rvest) # for web scraping
library(tidyverse) # for data wrangling
library(janitor) # for tidying col names
library(here) # for dealing with pathways

# the web scraping ----
# read in url from pokemon database 
pokemon_html <- read_html("https://pokemondb.net/pokedex/all")
# convert table element to a html table > making into R data frame
pokemon_tab <- pokemon_html %>%
  html_node('table') %>%
  html_table()

# cleaning ---- 
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

# Vectors for the generations
gen1 <- 1:151
gen2 <- 152:251
gen3 <- 252:386
gen4 <- 387:493
gen5 <- 494:649
gen6 <- 650:721
gen7 <- 722:809
gen8 <- 810:905

# tidying up the data
pokemon_full <- pokemon_tab |> 
  dplyr::rename(number = "#") |> 
  # tidy up column names
  janitor::clean_names() |> 
  # find the legendary pokemon - can also use `str_detect(pokemon_tab$Name, paste(legendary, collapse = "|"))`
  dplyr::mutate(legendary = name %in% legendary) |> 
  # add information to which generation of game the pokemon was first seen
  dplyr::mutate(generation = dplyr::case_when(
    number %in% gen1 ~ 1,
    number %in% gen2 ~ 2,
    number %in% gen3 ~ 3,
    number %in% gen4 ~ 4,
    number %in% gen5 ~ 5,
    number %in% gen6 ~ 6,
    number %in% gen7 ~ 7,
    number %in% gen8 ~ 8,
    TRUE ~ 9
  )) |> 
  # seperate the type of the pokemon into two columns
  #warning because some pokemon have one type and some have two - they get filled with NA
  tidyr::separate(col = type, 
           into = c("type1", "type2"),
           sep = "(?<=[a-z])(?=[A-Z])") |> 
  # tidy up the names by adding space before capital letters
  dplyr::mutate(name = stringr::str_replace(name, "(?<=[a-z])(?=[A-Z])", " "))

# remove duplicate names within the names - make function to fix issue, then add to data
# function detects duplicate strings and removes them
remove_dup_name <- function(x){
  paste(unique(tolower(trimws(unlist(strsplit(x,split="(?!')[ [:punct:]]",fixed=F,perl=T))))),collapse = " ")
}
# vectorised version - likely more useful overall
remove_dup_name_vect <- Vectorize(rem_dup.one, USE.NAMES = FALSE)
# fix names
pokemon_full <- pokemon_full |> 
  dplyr::mutate(
    name = remove_dup_name_vect(name) |> stringr::str_to_title()
  )

# add image urls from pokemon database
# take the names, convert to lower case, add name to url path, remove spaces with - for non-standard pokemon
url_names <- pokemon_full$name %>% tolower() %>%
  paste0("https://img.pokemondb.net/sprites/home/normal/", .,".png") %>%
  str_replace_all(fixed(" "), "-")

url_names[1:5]
# add to main dataset
pokemon_full$image_url <- url_names

# making a subset that excludes all the 'extra' pokemon like mega evolutions, Galarian versions and such
pokemon <- pokemon_full |> 
  filter(str_detect(name, "Mega|Alolan|Galarian|Primal|Partner|Altered|Eternamax|Hisuian", negate = TRUE))

# write out full and filtered to csv format ----
write_csv(pokemon, here('R', 'data', 'pokemon.csv'))
write_csv(pokemon_full, here('R', 'data', 'pokemon_full.csv'))

