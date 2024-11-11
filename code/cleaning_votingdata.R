

# libraries -------------------------------------------------------------------

# loading
library(tidyverse)
library(here)


# set directory
here::i_am("code/cleaning_votingdata.R")


# Step 1 - load data ----------------------------------------------------------------------------------
countypres_raw <- read_csv(here("data/raw/countypres_2000-2020.csv"))

# Step 2 - Make Dataset Wide --------------------------------------------------------------------

# making the dataset wide
voting_as_wide <- countypres_raw %>%
  pivot_wider(names_from = party, 
              values_from = candidatevotes) %>%
  mutate(state_county = paste0(state_po,
                               "-",
                               county_name)) %>% # retain only our identifier columns
  filter(!(is.na(county_fips))) %>%
  filter(county_fips != "2938000") %>% # remove Kansas City because jackson county already in dataset
                                        # and this long fips is nonexistent in census dataset
                                        # so it'll get dropped anyway
  filter(county_fips != 02099) # drop District 99 Arkansas which is empty in the data 
# Connecticut - WRITE-IN
# Maine - Uniformed Service & Overseas
# Rhode Island - Federal Precinct 

# Step 3 - Flatten dataset and calculate aggregates, proportions, margins--------------------------------------------------

flattened_voting_wide <- voting_as_wide %>%
  group_by(year,
           state,
           state_po,
           state_county,
           county_name,
           county_fips,
           totalvotes) %>%
  summarise(aggvotes_D = sum(DEMOCRAT, na.rm = TRUE),
            aggvotes_R = sum(REPUBLICAN, na.rm = TRUE),
            aggvotes_G = sum(GREEN, na.rm = TRUE),
            aggvotes_L = sum(LIBERTARIAN, na.rm = TRUE),
            aggvotes_O = sum(OTHER, na.rm = TRUE)) %>%
  mutate(county_fips = str_pad(county_fips, width = 5, side = "left", pad = "0"))


minvotes <- min(flattened_voting_wide$totalvotes)
maxvotes <- max(flattened_voting_wide$totalvotes)

flattened_voting_wide <- flattened_voting_wide %>%
  mutate(unique_id = paste0(year, "_", county_fips)) %>%
  mutate(
    proportion_D = aggvotes_D / totalvotes,  # Democratic proportion
    proportion_R = aggvotes_R / totalvotes,  # Republican proportion
    proportion_G = aggvotes_G / totalvotes,  # Green proportion
    proportion_L = aggvotes_L / totalvotes,  # Libertarian proportion
    proportion_O = aggvotes_O / totalvotes   # 'Other' proportion
    ) 


flattened_voting_wide %>%
  write_csv(here("data/clean/CountyPresReturns_2000-2020_Flattened.csv"))


