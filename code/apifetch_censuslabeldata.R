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







# USAGE -------------------------------------------------------------

# USAGE 2009
xml_2009 <- api_fetch_xmlvardata("2009")
var_labels_2009 <- convert_xmlvardata_to_df(xml_2009)
write_labeldf_tocsv(var_labels_2009)


# USAGE 2012
xml_2012 <- api_fetch_xmlvardata("2012")
var_labels_2012 <- convert_xmlvardata_to_df(xml_2012)
write_labeldf_tocsv(var_labels_2012)


# USAGE 2016
xml_2016 <- api_fetch_xmlvardata("2016")
var_labels_2016 <- convert_xmlvardata_to_df(xml_2016)
write_labeldf_tocsv(var_labels_2016)


# USAGE 2020
xml_2020 <- api_fetch_xmlvardata("2020")
var_labels_2020 <- convert_xmlvardata_to_df(xml_2020)
write_labeldf_tocsv(var_labels_2020)



