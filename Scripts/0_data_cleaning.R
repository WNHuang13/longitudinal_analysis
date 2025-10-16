library(tidyverse)
library(naniar)

SSWEALTH <- read_csv("data/SSWEALTH.csv")


id_vars <- c("HHID", "PN")
ssw_vars <- grep("^R[0-9]+SSWRXA$", names(SSWEALTH), value = TRUE)
claim_vars <- grep("^R[0-9]+CLAIMED$", names(SSWEALTH), value = TRUE)

ssw_spouse_vars <- grep("^S[0-9]+SSWRXA$", names(SSWEALTH), value = TRUE)
ssw_house_vars  <- grep("^H[0-9]+SSWRXA$", names(SSWEALTH), value = TRUE)

df <- SSWEALTH %>%
  select(all_of(id_vars), all_of(ssw_vars), all_of(claim_vars))


# Reshape from wide to long format
df_long <- df %>%
  pivot_longer(cols = starts_with("R"),names_to = "wave", values_to = "ssw_r") %>%
  mutate(
    wave = as.numeric(str_extract(wave, "[0-9]+")),
    id = paste(HHID, PN, sep = "_")
  ) %>%
  arrange(id, wave)

# Add year variable 
df_long <- df_long %>%
  mutate(year = 1990 + 2 * wave)

# Missing data

# Quick overall missing rate
df_long %>%
  summarise(
    total_rows = n(),
    missing_ssw = sum(is.na(ssw_r)),
    pct_missing = round(mean(is.na(ssw_r)) * 100, 2)
  )

# Missing rate per wave
df_long %>%
  group_by(wave) %>%
  summarise(
    n = n(),
    missing_n = sum(is.na(ssw_r)),
    pct_missing = round(mean(is.na(ssw_r)) * 100, 2)
  )

# Missing data visualization
df_long %>%
  group_by(wave) %>%
  summarise(pct_available = (1 - mean(is.na(ssw_r))) * 100) %>%
  ggplot(aes(x = wave, y = pct_available)) +
  geom_col(fill = "steelblue") +
  theme_minimal() +
  labs(title="Percentage of Available SSW Data by Wave",y="Available", x="Wave")

write_csv(df_long, "Longitudinal_Modeling_R/Data/SSW_long.csv")


# Ensure unique 
df_long_unique <- df_long %>%
  group_by(id, wave) %>%
  slice(1) %>% 
  ungroup()

# Convert to wide format
df_wide <- df_long_unique %>%
  mutate(year_label = paste0("ssw_", year)) %>%
  pivot_wider(
    id_cols = c(id, HHID, PN),
    names_from = year_label,
    values_from = ssw_r
  )


write_csv(df_wide, "Longitudinal_Modeling_R/Data/SSW_wide.csv")



