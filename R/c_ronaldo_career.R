# Webscraping Christiano Ronaldo's career stats

# load libaries ----
library(here)

# clean data
library(tidyverse)
library(lubridate)
library(stringr)
library(janitor)

# scrap data
library(rvest)
library(httr)
library(polite)

# url ----

url <- "https://en.wikipedia.org/wiki/Cristiano_Ronaldo"


# Intro to website with polite ----

url_bow <- polite::bow(url)

# Scrape ----

ronaldo_html <-
  polite::scrape(url_bow) %>%
  rvest::html_nodes("table.wikitable") %>%
  rvest::html_table(fill = TRUE)

# flatten table to data frame ----
# we have two tables, international and club

ronaldo_club_tab <-
  ronaldo_html[[1]] %>%
  clean_names()

ronaldo_int_tab <-
  ronaldo_html[[2]] %>%
  clean_names()

# review scraped data ----
ronaldo_club_tab %>% glimpse()
ronaldo_int_tab %>% glimpse()

# clean club data ----
ronaldo_club <- ronaldo_club_tab %>%
  rename(league_apps = league_2, # rename columns using secondary headers
         league_goals = league_3,
         national_cup_apps = national_cup_a,
         national_cup_goals = national_cup_a_2,
         league_cup_apps = league_cup_b,
         league_cup_goals = league_cup_b_2,
         europe_cup_apps = europe_c,
         europe_cup_goals = europe_c_2,
         other_apps = other,
         other_goals = other_2,
         total_apps = total,
         total_goals = total_2) %>%
  filter(!str_detect(season, "Total|total")) %>% # remove total rows 
  slice(-1) %>%  # remove the second headers
  na_if("—") %>% # change — to NA
  mutate(
    season = str_replace(season, "\\[.*", ""),
    other_apps = str_replace(other_apps, "\\[.*", ""),
    club = str_replace(club, "\\[.*", ""),
    europe_cup_apps = str_replace(europe_cup_apps, "\\[.*", ""),
    league_goals = str_replace(league_goals, "\\[.*", "")
  )


# clean international data ----
ronaldo_int <- ronaldo_int_tab %>%
  rename(competitive_apps = competitive,
         competitive_goals = competitive_2,
         friendly_apps = friendly,
         friendly_goals = friendly_2,
         total_apps = total,
         total_goals = total_2) %>%
  filter(!str_detect(year, "Total|total")) %>% # remove total rows
  slice(-1) %>%
  mutate(friendly_apps = word(friendly_apps, sep = "\\["),
         competitive_apps = word(competitive_apps, sep = "\\[")) %>%
  na_if("—")

# export data ----

write_csv(ronaldo_club, here("R", "data", "ronaldo_club.csv"))
write_csv(ronaldo_int, here("R", "data", "ronaldo_int.csv"))
