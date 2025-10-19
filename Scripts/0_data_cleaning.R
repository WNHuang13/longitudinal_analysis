library(data.table)
library(rio) 
library(tidyverse) 
library(janitor)

library(dplyr)
library(tidyr)
library(stringr)

library(lavaan)
library(mice)
library(naniar)

file_path <- "Library/CloudStorage/OneDrive-TheUniversityofAuckland/Codes/Longitudinal_Modeling_R/Data/randhrs1992_2022.sav" 
file_path <- "C:/Users/whua616/OneDrive - The University of Auckland/Codes/Longitudinal_Modeling_R/Data/randhrs1992_2022.sav"

hrs_data_raw <- rio::import(
  file_path, 
  setclass = "data.table"
) 

# select variables
vars_id <- c("HHIDPN", "RDEATH")

vars_demo <- c("S1RACEM", "S1HISPAN", "RAGENDER","S1GENDER", "S1EDUC", "S1MEDUC", "S1FEDUC")

vars_wave <- c(
  # Health
  outer(paste0(c("S", "R"), 1:16), c("CESD", "COG27", "SRH", "CHRON"), paste0),
  # Function
  outer(paste0(c("S", "R"), 1:16), c("ADL", "IADL"), paste0),
  # Economic
  outer(paste0(c("S", "R"), 1:16), c("FINR", "FAMR", "ATOT"), paste0),
  # Behaviour
  outer(paste0(c("S", "R"), 1:16), c("MSTAT", "SMOKEV", "DAGE_Y"), paste0)
) %>% as.vector()

vars_keep <- unique(c(vars_id, vars_demo, vars_wave))


# wide format data
vars_exist <- intersect(vars_keep, names(hrs_data_raw))

data_wide <- hrs_data_raw[, ..vars_exist]

setnames(data_wide, tolower(names(data_wide)))

data_wide <- data_wide %>%
  rename(gender = ragender)

#long format data
data_long <- data_wide %>%
  pivot_longer(
    cols = matches("^(s|r)[0-9]+(cesd|cog27|srh|adl|iadl|finr|famr|atot|mstat|smokev|dage_y|chron)$"),
    names_to = c("wave", "variable"),
    names_pattern = "([sr][0-9]+)([a-z0-9_]+)",
    values_to = "value"
  ) %>%
  pivot_wider(
    names_from = variable,
    values_from = value,
    values_fn = ~ dplyr::first(na.omit(.))
  ) %>%
  mutate(
    wave = as.numeric(str_extract(wave, "\\d+")),
    year = 1990 + wave * 2,
    gender = as.factor(gender)
  )

# delete invalid participants
data_wide <- data_wide[, which(colSums(!is.na(data_wide)) > 0), with = FALSE]
data_long <- data_long[, which(colSums(!is.na(data_long)) > 0), with = FALSE]


output_dir <- "Library/CloudStorage/OneDrive-TheUniversityofAuckland/Codes/Longitudinal_Modeling_R/Data/"

fwrite(data_wide, paste0(output_dir, "data_wide.csv"))
fwrite(data_long, paste0(output_dir, "data_long.csv"))


# missing data

miss_summary <- miss_var_summary(data_long)
print(miss_summary)

gg_miss_upset(data_long, nsets = 10)



