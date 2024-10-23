# libraries -------------------------------------------------------------------

# loading
library(tidyverse)
library(here)
library(httr)
library(jsonlite)
library(xml2)


# set directory
here::i_am("code/apifetch_censusdata.R")

# US Census Board API Key
# 6b04ff55736c418eed28d02b041d8a382d5b0319
USCB_APIkey <- "6b04ff55736c418eed28d02b041d8a382d5b0319"





# FUNCTION: API FETCH and SAVE --------------------------------------------------------

apifetch_censusdata <- function(variable, year, key) {
  print(paste0("fetching: ", year, "-", variable))
  
  # construct the URL with the variable, year, and key dynamically
  url <- paste0("https://api.census.gov/data/", 
                year, 
                "/acs/acs5/profile?get=", 
                variable, 
                "&for=county:*&key=", 
                key)
  
  

  # make the API request
  response <- GET(url)
  # parse the JSON response
  data <- content(response, 
                  as = "text", 
                  encoding = "UTF-8")
  json_data <- fromJSON(data)
  
  # convert the JSON data to a dataframe
  df <- as.data.frame(json_data[-1, ])  # Skip the first row (header)
  colnames(df) <- json_data[1, ]  # Assign the first row as column names
  # create a dynamic filename based on the variable and year
  file_name <- paste0(here("data/api_censusdata/"), variable, "_", year, ".csv")
  # save the dataframe as a CSV file
  write.csv(df, file_name, row.names = FALSE)
  
  print(paste0("Saved:", 
      variable,
      "_",
      year,
      ".csv")) 
  Sys.sleep(3)
  
}







# USAGE --------------------------------------------------------------------------
  
apifetch_censusdata("group(DP02)",
                      "2012",
                      USCB_APIkey)

# Loop through the variables and fetch data for each
years <- c("2009", 
          "2012",
          "2016",
          "2020")

groups <- c("group(DP02)",
            "group(DP03)",
            "group(DP04)",
            "group(DP05)")

for (year in years){
  for (group in groups){
    apifetch_censusdata(group,
                        year,
                        USCB_APIkey)
  }
}






# API GROUP FETCH no function-------------------------------------------------------------------


#<https://api.census.gov/data/2016/acs/acs1?get =group(B01001)&for=us:*>.
group_url <- "https://api.census.gov/data/2009/acs/acs5/profile?get=group(DP02)&for=county:*&key=6b04ff55736c418eed28d02b041d8a382d5b0319"  

response <- GET(group_url)
data <- content(response, as = "text", encoding = "UTF-8")

json_data <- fromJSON(data)

df <- as.data.frame(json_data[-1, ])  # Skip the first row (header)
colnames(df) <- json_data[1, ]  # Assign the first row as column names


file_name <- paste0(here("data/api_censusdata/2009_group(DP02).csv"))
write.csv(df, file_name, row.names = FALSE)







# OLD: BASIC API FETCH -------------------------------------------------------------------
# Basic GET request to the API
#["DP02_0060PE",
#"Percent!!EDUCATIONAL ATTAINMENT!!Population 25 years and over!!9th to 12th grade, no diploma",
#"SELECTED SOCIAL CHARACTERISTICS IN THE UNITED STATES"]

# 2008 does not have 5 year data, as the survey began in 2005
# 2009 does have 5 year data
#url <- "https://api.census.gov/data/2008/acs/acs1/profile?get=DP02_0060PE&for=county:*&key=6b04ff55736c418eed28d02b041d8a382d5b0319"  
url <- "https://api.census.gov/data/2009/acs/acs5/profile?get=DP02_0060PE&for=county:*&key=6b04ff55736c418eed28d02b041d8a382d5b0319"  

