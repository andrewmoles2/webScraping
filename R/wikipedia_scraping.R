# Wikipedia web scraping ####
# code and idea from https://ivelasq.rbind.io/blog/politely-scraping/

# load libaries ----
# clean data
library(tidyverse)
library(lubridate)
library(janitor)

# scrap data
library(rvest)
library(httr)
library(polite)

# urls for scraping ----
messi_url <- "https://en.wikipedia.org/wiki/Lionel_Messi"

indep_url <- "https://en.wikipedia.org/wiki/List_of_national_independence_days"

# using polite ----
# 
url_bow_indep <- polite::bow(indep_url)
url_bow_indep

url_bow_messi <- polite::bow(messi_url)
url_bow_messi 

# the scraping ----
# go to website, command+shift+C, find table. 
# find what html is called: in both cases here table.wikitable

ind_html <- 
  polite::scrape(url_bow_indep) %>%
  rvest::html_nodes("table.wikitable") %>%
  rvest::html_table(fill = TRUE)

messi_html <-
  polite::scrape(url_bow_messi) %>%
  rvest::html_nodes("table.wikitable") %>%
  rvest::html_table(fill = TRUE)

# flatten table to data frame ----
ind_tab <- 
  ind_html[[1]] %>%
  clean_names()

messi_club <-
  messi_html[[1]] %>%
  clean_names()

messi_int <-
  messi_html[[2]] %>%
  clean_names()

# review scraped data! ----
ind_tab %>% glimpse()
messi_club %>% glimpse()
messi_int %>% glimpse()


# Additional information not on blog post ----
# Why use polite when web scraping
# https://ryo-n7.github.io/2020-05-14-webscrape-soccer-data-with-R/
# Rest of code from blog post with cleaning scripts
# https://github.com/ivelasq/data-visualization-portfolio/blob/main/independence-days/independence_days.R

