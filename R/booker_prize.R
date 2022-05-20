# Webscraping booker data from Wikepedia

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

# table url
url_all <- "https://en.wikipedia.org/wiki/List_of_winners_and_shortlisted_authors_of_the_Booker_Prize"

url_all_bow <- bow(url_all)

url_win <- "https://en.wikipedia.org/wiki/Booker_Prize"

url_win_bow <- bow(url_win)

# the scraping ----
# go to website, command+shift+C, find table. 
# find what html is called: class = sortable wikitable jquery-tablesorter
booker_html <-
  polite::scrape(url_all_bow) %>%
  rvest::html_nodes("table.wikitable.sortable") %>%
  rvest::html_table(fill = TRUE)

booker_win_html <-
  polite::scrape(url_win_bow) %>%
  rvest::html_nodes("table.wikitable.sortable") %>%
  rvest::html_table(fill = TRUE)

# flatten table to data frame ----
booker_tab <-
  booker_html[[1]] %>%
  clean_names()

booker_tab |> glimpse()

booker_win_tab <-
  booker_win_html[[1]] %>%
  clean_names()

booker_win_tab |> glimpse()

# tidy things up ----
# clean up all nominations
booker_tab_tidy <- booker_tab |> 
  mutate(year = str_replace(year, "\\[.*", ""),
         title = str_replace(title, "\\[.*", "")) |># removes everything after [
  tidyr::separate(col = judges, # move judges to seperate cols
                  into = c("judge_1", "judge_2", "judge_3", "judge_4", "judge_5"),
                  sep = "\n") |> 
  mutate(judge_4 = str_replace(judge_4, "\\[.*", "")) # fix any more references

# extract 'lost booker prize', then remove from main data
lost_booker <- booker_tab_tidy[grep("1970  Awarded", x = booker_tab_tidy$year), ]
booker_tab_tidy <- booker_tab_tidy[-grep("1970  Awarded", x = booker_tab_tidy$year), ]

# clean up winners
booker_win_tab_tidy <- booker_win_tab |> 
  mutate(author = str_replace(author, "\\[.*", "")) |> 
  rename(genre = genre_s)

# data cleaning ----
str(booker_tab_tidy)
str(booker_win_tab_tidy)

booker <- booker_tab_tidy |> 
  mutate(year = as.integer(year)) |> 
  left_join(booker_win_tab_tidy) |> 
  mutate(winner = if_else(is.na(genre), "no", "yes"))

# save the data ----
write_csv(booker, here("R","data","booker_prize.csv"))

# what can you do with this data? ----
# likely tables are your best bet! 
# example using gt and gt extras
booker |> 
  count(author, sort = T)

library(gt)
library(gtExtras)

booker |> 
  filter(author == "Margaret Atwood" | author == "Iris Murdoch") |> 
  select(year:title, winner) |> 
  gt(rowname_col = "year") |> 
  gt_highlight_rows(rows = winner == "yes",
                    bold_target_only = TRUE,
                    target_col = author) |>
  tab_header(title = md("Booker prize nominations for **Iris Murdoch** and **Margaret Atwood**"),
             subtitle = "They are the authors with the most nominations of 6 each") |> 
  cols_label(author = "Author",
             title = "Title",
             winner = "Winner") |> 
  gtsave_extra(here("R","figs","booker_prize.png"))

