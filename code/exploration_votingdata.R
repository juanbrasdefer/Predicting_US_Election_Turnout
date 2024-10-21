# libraries -------------------------------------------------------------------

# loading
library(tidyverse)
library(here)

# set directory
here::i_am("code/exploration_votingdata.R")

county_pres <- read_csv(here("data/countypres_2000-2020.csv"))

# USING FIPS ----------------------------------------------------------------


# number of counties in each year 
counties_in_year <- county_pres %>%
  group_by(year) %>%
  summarise(num_counties = n_distinct(county_fips))
# this seems too good to be true; need to investigate


# looking at unique years in each county
year_fips_combinations <- county_pres %>%
  distinct(year, county_fips) %>%
  group_by(county_fips) %>%
  mutate(years_present = n_distinct(year))
# not so helpful; still a super manual task



#go one layer down and count how many distinct years each county has
counts_years <- county_pres %>% 
  group_by(county_fips) %>%
  summarise(year_counts = n_distinct(year))
# this looks pretty good

appearances_distribution <- counts_years %>%
  group_by(year_counts) %>%
  summarise(n_counties = n_distinct(county_fips))

counties_troublesome <- year_fips_combinations %>%
  filter(years_present < 6)



# USING COUNTY NAME ---------------------------------------------------------

county_pres %>%
  summarise(unique_count = n_distinct(county_name))

county_pres %>%
  summarise(unique_count = n_distinct(county_fips))


# number of counties in each year 
counties_in_year <- county_pres %>%
  group_by(year) %>%
  summarise(num_counties = n_distinct(county_name))
# this seems too good to be true; need to investigate


# looking at unique years in each county
year_county_combinations <- county_pres %>%
  distinct(year, county_name) %>%
  group_by(county_name) %>%
  mutate(years_present = n_distinct(year))
# not so helpful; still a super manual task

#go one layer down and count how many distinct years each county has
counts_years <- county_pres %>% 
  group_by(county_name) %>%
  summarise(year_counts = n_distinct(year))
# this looks pretty good

appearances_distribution <- counts_years %>%
  group_by(year_counts) %>%
  summarise(n_counties = n_distinct(county_name))

