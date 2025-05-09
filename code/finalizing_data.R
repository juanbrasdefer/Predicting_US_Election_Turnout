
# libraries -------------------------------------------------------------------

# loading
library(tidyverse)
library(here)


# set directory
here::i_am("code/finalizing_data.R")


# Step 1 - load data -------------------------------------------------------------------

clean_voting <- read_csv(here("data/clean/CountyPresReturns_2000-2020_Flattened.csv")) %>%
  select(-state,
         -state_county)
clean_census <- read_csv(here("data/clean/ACS_2009-2020_SelectedIndicators_Slim.csv")) %>%
  select(-county_fips,
         -census_year,
         -GEO_ID)


# Step 2 - join data and create target variable, 'Turnout Percentage' ------------------------------------------------------

pipeline_ready <- clean_voting %>%
  inner_join(clean_census, by = "unique_id") %>%
  mutate(voter_turnout = totalvotes/ DP05_0001PE)  #create target column: turnout percentage
                      #based off of col "DP05_0001PE" and "totalvotes"
                      # note: this results in some 





# Step 3 - Assess missing values ---------------------------------------------------------

na_counts <- pipeline_ready %>%
  summarise(across(everything(), ~ sum(is.na(.)), .names = "NA_count_{.col}")) %>%
  pivot_longer(everything(), names_to = "Column", values_to = "NA_Count") %>%
  arrange(desc(NA_Count))

# no missing values!
# this means all of our innerjoin & cleaning efforts until now have been successful :)

pipeline_ready %>%
  write_csv(here("data/clean/Combined_Voting&Census_2008-2020.csv"))


