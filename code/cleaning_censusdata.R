
# description -----------------------------------------------------------------------
# step 1 
  # batch-load datasets into environment

# step 2
  # for each year:
    # for each DP file:
      # drop columns BEGINNING WITH 'DP' that DONT END IN 'PE'


# step 3
  # for each year:
    # join DP files by "GEO_ID", innerjoin
    # add new column to the joint datasets, "year"

# step 4
  # drop columns (DP columns) not present in EVERY year
    # do this by pulling 'names' of each df and creating a lowest common denom list
  # rowbind()

# step 5
  # prep for join with voting data




# libraries -------------------------------------------------------------------

# loading
library(tidyverse)
library(here)


# set directory
here::i_am("code/cleaning_censusdata.R")


# Step 1 - load data ----------------------------------------------------------------------------------

# CENSUS DATASETS
# Specify the folder path where the CSV files are located
folder_path <- paste0(here("data/raw/api_censusdata"))
# Get all file names in the folder that match the CSV format
file_list <- list.files(path = folder_path, full.names = TRUE)
# Load each file and dynamically name each dataframe
for (file in file_list) {
  # Extract the file name without the path and extension
  file_name <- basename(file)
  # Create a variable name by removing "group(" and ").csv"
  var_name <- str_remove_all(file_name, "\\.csv")
  # Assign the data to a variable with the dynamically created name
  assign(var_name, read_csv(file))}





# Step 2 - Drop Irrelevant Columns ----------------------------------------------------------------------
# Get a list of all dataframe names in the environment that match your naming convention
dataframe_names <- ls(pattern = "^DP\\d{2}_\\d{4}")

# Define a function to drop columns that start with "DP" but do not end with "PE"
drop_nonPE_cols <- function(df) {
  df %>%
    select(contains("PE") | matches("^GEO_ID$")) %>% # this also drops state (num), county (num), name (string)
    select(-contains("PEA")) %>%
    select(where(~ !any(. == "(X)", na.rm = TRUE))) %>%
    select(where(~ !any(. == "-888888888", na.rm = TRUE)))
}


# Apply the function to each dataframe in the environment and update them
for (name in dataframe_names) {
  assign(name, drop_nonPE_cols(get(name)))
}




# Step 3 -  Join DPs by year together ----------------------------------------------------

census_2009 <- DP02_2009 %>%
  inner_join(DP03_2009, by = "GEO_ID") %>%
  inner_join(DP04_2009, by = "GEO_ID") %>%
  inner_join(DP05_2009, by = "GEO_ID") %>%
  mutate(census_year = "2008") 

census_2012 <- DP02_2012 %>%
  inner_join(DP03_2012, by = "GEO_ID") %>%
  inner_join(DP04_2012, by = "GEO_ID") %>%
  inner_join(DP05_2012, by = "GEO_ID") %>%
  mutate(census_year = "2012")


census_2016 <- DP02_2016 %>%
  inner_join(DP03_2016, by = "GEO_ID") %>%
  inner_join(DP04_2016, by = "GEO_ID") %>%
  inner_join(DP05_2016, by = "GEO_ID") %>%
  mutate(census_year = "2016") 


census_2020 <- DP02_2020 %>%
  inner_join(DP03_2020, by = "GEO_ID") %>%
  inner_join(DP04_2020, by = "GEO_ID") %>%
  inner_join(DP05_2020, by = "GEO_ID") %>%
  mutate(census_year = "2020") 
  


# Step 4 - drop all year dfs to lowest common denominator of columns ----------------------

# Step 1: Identify common columns
common_columns <- Reduce(intersect, list(names(census_2009), 
                                         names(census_2012), 
                                         names(census_2016), 
                                         names(census_2020)))

# Step 2: Subset each dataset by the common columns
# subsetting by our list means they will all be in same order
# which means we can rbind afterwards without issue
LCD_census_2009 <- census_2009[ , common_columns]
LCD_census_2012 <- census_2012[ , common_columns]
LCD_census_2016 <- census_2016[ , common_columns]
LCD_census_2020 <- census_2020[ , common_columns]

# Step 3: Row-bind the datasets
full_censusdata <- do.call(rbind, list(LCD_census_2009, 
                                     LCD_census_2012, 
                                     LCD_census_2016, 
                                     LCD_census_2020))


# step 5 - prep for join with voting data ------------------------------------------------
full_censusdata <- full_censusdata %>%
  mutate(county_fips = str_extract(GEO_ID, "(?<=US)\\d+")) %>%
  mutate(unique_id = paste0(census_year, "_", county_fips)) # "YEAR_FIPS"


full_censusdata %>%
  write_csv(here("data/clean/ACS_2009-2020_SelectedIndicators.csv"))


# step 5.alt - prepare alternate data, dropping columns of total pop----------------------------


full_censusdata$census_year<-as.character(full_censusdata$census_year) 
full_censusdata$county_fips<-as.character(full_censusdata$county_fips) 

full_censusdata_slim <- full_censusdata %>%
  #select(-where(~ all(. >= 101, na.rm = TRUE)))
  group_by(unique_id,
           census_year,
           county_fips,
           DP05_0001PE) %>%
  select(where(~ !any(. > 101, na.rm = TRUE))) # drop all except one column of total pop

full_censusdata_slim %>%
  write_csv(here("data/clean/ACS_2009-2020_SelectedIndicators_Slim.csv"))

