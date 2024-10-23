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




# BASIC API FETCH -------------------------------------------------------------------
# Basic GET request to the API
#["DP02_0060PE",
#"Percent!!EDUCATIONAL ATTAINMENT!!Population 25 years and over!!9th to 12th grade, no diploma",
#"SELECTED SOCIAL CHARACTERISTICS IN THE UNITED STATES"]

# 2008 does not have 5 year data, as the survey began in 2005
# 2009 does have 5 year data
#url <- "https://api.census.gov/data/2008/acs/acs1/profile?get=DP02_0060PE&for=county:*&key=6b04ff55736c418eed28d02b041d8a382d5b0319"  
url <- "https://api.census.gov/data/2009/acs/acs5/profile?get=DP02_0060PE&for=county:*&key=6b04ff55736c418eed28d02b041d8a382d5b0319"  


# FUNCTION: FETCH XML VARIABLE TAGS FROM API -------------------------------------
# Define the function
api_fetch_xmlvardata <- function(year, acs_type = "acs5") {
  print(paste0("querying api for xml variable keys: ", year, "-", acs_type))
  
  # construct the URL dynamically
  url <- paste0("https://api.census.gov/data/", 
                year, 
                "/acs/",
                acs_type,
                "/profile/variables.xml")
  
  # fetch the XML data from URL
  response <- GET(url)
  as_xml <- read_xml(response)
  
  print("xml landed")
  
  file_path <- paste0(here("data/api_censuslabels/xml_labels/response_"),
                      year,
                      "_",
                      acs_type)
  write_xml(as_xml,
            file_path)  
  
  print("xml saved at: data/api_censuslabels/xml_labels")
  return(as_xml)
}


# FUNCTION: CONVERT XML VARIABLE TAGS INTO DATAFRAME FORMAT --------------------------------

convert_xmlvardata_to_df <- function (xml_data){
  print("extracting variable tags")
  # Extract <var> nodes
  var_nodes <- xml_find_all(xml_data, ".//d1:var", 
                            xml_ns(xml_data))

  # Convert to a dataframe
  xml_as_dataframe <- data.frame(
    var_id = xml_attr(var_nodes, "id"),
    var_label = xml_attr(var_nodes, "label"),
    concept = xml_attr(var_nodes, "concept"),
    predicate_type = xml_attr(var_nodes, "predicate-type"),
    group = xml_attr(var_nodes, "group"),
    limit = xml_attr(var_nodes, "limit"),
    attributes = xml_attr(var_nodes, "attributes"),
    stringsAsFactors = FALSE)
  
  xml_as_dataframe <- xml_as_dataframe %>%
    arrange(var_id)
  
  print("dataframe ready")

  return(xml_as_dataframe)
}


# FUNCTION: SAVE VARIABLE TAGS DATAFRAME to CSV --------------------------------

write_labeldf_tocsv <- function (var_labels_df){
  
  object_name_as_string <- deparse(substitute(var_labels_df))
  
  file_path = paste0(here("data/api_censuslabels/csv_labels/"),
                     object_name_as_string,
                     ".csv")
  write_csv(var_labels_df,
            file_path)
  
  print(paste0("dataframe flushed to csv at: data/api_censuslabels/csv_labels"))
}






# USAGE
xml_2009 <- api_fetch_xmlvardata("2009")
var_labels_2009 <- convert_xmlvardata_to_df(xml_2009)
write_labeldf_tocsv(var_labels_2009)


# USAGE
xml_2012 <- api_fetch_xmlvardata("2012")
var_labels_2012 <- convert_xmlvardata_to_df(xml_2012)
write_labeldf_tocsv(var_labels_2012)


# USAGE
xml_2016 <- api_fetch_xmlvardata("2016")
var_labels_2016 <- convert_xmlvardata_to_df(xml_2016)
write_labeldf_tocsv(var_labels_2016)


# USAGE
xml_2020 <- api_fetch_xmlvardata("2020")
var_labels_2020 <- convert_xmlvardata_to_df(xml_2020)
write_labeldf_tocsv(var_labels_2020)





  
# USEFUL FOR changing column names in OG data dataframe  
  # Rename columns in the provided dataframe
  original_columns <- colnames(df)
  new_column_names <- sapply(original_columns, function(col) {
    label_row <- label_df[label_df$VariableID == col, ]
    
    # If the column has a matching label, use it; otherwise, keep the original name
    if (nrow(label_row) > 0) {
      return(label_row$Label)
    } else {
      return(col)
    }
  })
  
  # Set the new column names
  colnames(df) <- new_column_names
  
  # Return the renamed dataframe
  return(df)
  
  
  
  













# API FETCH -------------------------------------------------------------------
# Basic GET request to the API
#["DP02_0060PE",
#"Percent!!EDUCATIONAL ATTAINMENT!!Population 25 years and over!!9th to 12th grade, no diploma",
#"SELECTED SOCIAL CHARACTERISTICS IN THE UNITED STATES"]

# 2008 does not have 5 year data, as the survey began in 2005
# 2009 does have 5 year data
#url <- "https://api.census.gov/data/2008/acs/acs1/profile?get=DP02_0060PE&for=county:*&key=6b04ff55736c418eed28d02b041d8a382d5b0319"  
url <- "https://api.census.gov/data/2009/acs/acs5/profile?get=DP02_0060PE&for=county:*&key=6b04ff55736c418eed28d02b041d8a382d5b0319"  




#<https://api.census.gov/data/2016/acs/acs1?get =group(B01001)&for=us:*>.
group_url <- "https://api.census.gov/data/2009/acs/acs5/profile?get=group(DP02)&for=county:*&key=6b04ff55736c418eed28d02b041d8a382d5b0319"  

response <- GET(group_url)
data <- content(response, as = "text", encoding = "UTF-8")

json_data <- fromJSON(data)

df <- as.data.frame(json_data[-1, ])  # Skip the first row (header)
colnames(df) <- json_data[1, ]  # Assign the first row as column names


file_name <- paste0(here("data/api_censusdata/2009_group(DP02).csv"))
write.csv(df, file_name, row.names = FALSE)














# FUNCTION: API FETCH and SAVE --------------------------------------------------------

fetch_and_save_data <- function(variable, year, key) {
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
  file_name <- paste0(here("data/api_censusdata/"), year, "_", variable, ".csv")
  # save the dataframe as a CSV file
  write.csv(df, file_name, row.names = FALSE)
  
  cat("Saved:", file_name, "\n")  # Print a message for confirmation
  Sys.sleep(3)
  
}











# USAGE --------------------------------------------------------------------------

year <- "2009"  
variables <- c("DP02_0060PE", "DP03_0119PE")  # Add more variables as needed


# Loop through the variables and fetch data for each
for (var in variables) {
  fetch_and_save_data(var, year, USCB_APIkey)
}




