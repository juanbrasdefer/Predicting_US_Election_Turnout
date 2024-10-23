# libraries -------------------------------------------------------------------

# loading
library(tidyverse)
library(here)
library(httr)
library(jsonlite)


# set directory
here::i_am("code/exploration_censusdata.R")






# EPLORATIONS -------------------------------------------------------------
# Decennial ----------------------------------------------------------------
# load data
Decennial_2000 <- read_csv(here("data/DECENNIALDPSF42000.DP1_2024-10-19T161201/DECENNIALDPSF42000.DP1-Data.csv"))

Decennial_2000_edited <- Decennial_2000 %>%
  select(-contains("Percent"),
         -contains("Margin"))

names(Decennial_2000_edited)
# Total population!!SEX AND AGE
# RELATIONSHIP
# HOUSEHOLDS BY TYPE
# HOUSING TENURE





# 2009 API DP02 - Social ----------------------------------------------------------------
# load data
DP2_2009_5Y <- read_csv(here("data/api_censusdata/2009_group(DP02).csv"))

DP2_2009_5Y_edited <- DP2_2009_5Y %>%
  select(-contains("Percent"),
         -contains("Margin"),
         -contains("GRANDPARENTS"))

names(DP2_2009_5Y_edited)


# DP2 - Social ----------------------------------------------------------------
# load data
DP2_2012_5Y <- read_csv(here("data/productDownload_2024-10-19T191219/ACSDP5Y2012.DP02-Data.csv"))

DP2_2012_5Y_edited <- DP2_2012_5Y %>%
  select(-contains("Percent"),
         -contains("Margin"),
         -contains("GRANDPARENTS"))

names(DP2_2012_5Y_edited)
# HOUSEHOLDS BY TYPE
# RELATIONSHIP
# MARITAL STATUS
# FERTILITY
# SCHOOL ENROLLMENT
# EDUCATIONAL ATTAINMENT
# VETERAN STATUS
# DISABILITY STATUS OF THE CIVILIAN NONINSTITUTIONALIZED POPULATION
# RESIDENCE 1 YEAR AGO
# PLACE OF BIRTH
# U.S. CITIZENSHIP STATUS
# YEAR OF ENTRY
# WORLD REGION OF BIRTH OF FOREIGN BORN
# LANGUAGE SPOKEN AT HOME
# ANCESTRY

# Function to count "null" values in each column
count_nulls <- function(col) {
  sum(tolower(trimws(col)) == "null", na.rm = TRUE)
}

# Apply the function to each column in the dataframe
null_counts <- sapply(DP2_2012_5Y_edited, count_nulls)
# you can check this out to see it's 78 across all






# DP3 - Economic ----------------------------------------------------------------
# load data
DP3_2012_5Y <- read_csv(here("data/productDownload_2024-10-19T191310/ACSDP5Y2012.DP03-Data.csv"))

DP3_2012_5Y_edited <- DP2_2012_5Y %>%
  select(-contains("Percent"),
         -contains("Margin"))

names(DP3_2012_5Y_edited)
# EMPLOYMENT STATUS
# COMMUTING TO WORK
# OCCUPATION
# INDUSTRY
# CLASS OF WORKER
# INCOME AND BENEFITS (IN 2012 INFLATION-ADJUSTED DOLLARS)
# HEALTH INSURANCE COVERAGE




# DP4 - Selected Housing ----------------------------------------------------------------
# load data
DP4_2012_5Y <- read_csv(here("data/productDownload_2024-10-19T191541/ACSDP5Y2012.DP04-Data.csv"))

DP4_2012_5Y_edited <- DP4_2012_5Y %>%
  select(-contains("Percent"),
         -contains("Margin"))

names(DP4_2012_5Y_edited)
# HOUSING OCCUPANCY
# UNITS IN STRUCTURE
# YEAR STRUCTURE BUILT
# ROOMS
# BEDROOMS
# HOUSING TENURE
# YEAR HOUSEHOLDER MOVED INTO UNIT
# VEHICLES AVAILABLE
# HOUSE HEATING FUEL
# SELECTED CHARACTERISTICS
# OCCUPANTS PER ROOM
# VALUE
# MORTGAGE STATUS
# SELECTED MONTHLY OWNER COSTS (SMOC)
# GROSS RENT





# DP4 - Selected Housing ----------------------------------------------------------------
# load data
DP5_2012_5Y <- read_csv(here("data/productDownload_2024-10-19T191549/ACSDP5Y2012.DP05-Data.csv"))

DP5_2012_5Y_edited <- DP5_2012_5Y %>%
  select(-contains("Percent"),
         -contains("Margin"))

names(DP5_2012_5Y_edited)
# SEX AND AGE
# RACE
# HISPANIC OR LATINO AND RACE
# Total housing units