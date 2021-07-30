# Webscraping Lionel Messi career data from Wikepedia

# load libaries ----
# clean data
library(tidyverse)
library(lubridate)
library(stringr)
library(janitor)

# scrap data
library(rvest)
library(httr)
library(polite)

# url for scraping ----
messi_url <- "https://en.wikipedia.org/wiki/Lionel_Messi"


# using polite ----
url_bow_messi <- polite::bow(messi_url)
url_bow_messi 

# the scraping ----
# go to website, command+shift+C, find table. 
# find what html is called: in both cases here table.wikitable

messi_html <-
  polite::scrape(url_bow_messi) %>%
  rvest::html_nodes("table.wikitable") %>%
  rvest::html_table(fill = TRUE)

# flatten table to data frame ----
# we have two tables, international and club

messi_club_tab <-
  messi_html[[1]] %>%
  clean_names()

messi_int_tab <-
  messi_html[[2]] %>%
  clean_names()

# review scraped data! ----
messi_club_tab %>% glimpse()
messi_int_tab %>% glimpse()

# clean club data ----
messi_club <- messi_club_tab %>%
  rename(league_apps = league_2, # rename columns using secondary headers
         league_goals = league_3,
         copa_del_rey_apps = copa_del_rey,
         copa_del_rey_goals = copa_del_rey_2,
         champions_league_apps = champions_league,
         champions_league_goals = champions_league_2,
         other_apps = other,
         other_goals = other_2,
         total_apps = total,
         total_goals = total_2) %>%
  filter(!str_detect(season, "Total|total")) %>% # remove total rows 
  slice(-1) %>%  # remove the second headers
  na_if("—") %>% # change — to NA
  mutate(
    season = str_replace(season, "\\[.*", ""),
    other_apps = str_replace(other_apps, "\\[.*", "")
  )

# other (easier option) than str_replace
# word(messi_club$season, sep = "\\[")
# regex means: find [ and all data after [

# clean international data ----