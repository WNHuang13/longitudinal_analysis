
library(tidyverse)
library(lavaan)
library(ggplot2)

glimpse(df_wide)

ssw_vars <- paste0("ssw_", seq(1992, 2020, 2))


# Select relevant variables
df_model <- df_wide %>%
  select(id, starts_with("ssw_"))

# check missing data
missing_rate <- df_model %>%
  summarise(pct_missing = mean(is.na(across(all_of(ssw_vars)))) * 100)

print(missing_rate)

# Latent Growth Model
df_model <- df_model %>%
  mutate(across(starts_with("ssw_"), ~ . / 1000))

years <- c(1992, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 
           2008, 2010, 2012, 2014, 2016, 2018, 2020)
years_scaled <- scale(years, center = 2006, scale = FALSE)

model_lgm <- paste0("
  i =~ ", paste0("1*", ssw_vars, collapse = " + "), "
  s =~ ", paste0(round(as.numeric(years_scaled), 1), "*", ssw_vars, collapse = " + "), "
  i ~ 1
  s ~ 1
  i ~~ s
")

fit_lgm <- growth(model_lgm, data = df_model, missing = 'fiml')
summary(fit_lgm, fit.measures = TRUE, standardized = TRUE)


# The model did not fit the data well, so a quadratic term was added
years_scaled2 <- (years_scaled)^2

model_lgm2 <- paste0("
  i =~ ", paste0("1*", ssw_vars, collapse = " + "), "
  s =~ ", paste0(round(as.numeric(years_scaled), 1), "*", ssw_vars, collapse = " + "), "
  q =~ ", paste0(round(as.numeric(years_scaled2), 1), "*", ssw_vars, collapse = " + "), "
  i ~ 1
  s ~ 1
  q ~ 1
  i ~~ s + q
  s ~~ q
")

fit_lgm2 <- growth(model_lgm2, data = df_model, missing = 'fiml')
summary(fit_lgm2, fit.measures = TRUE, standardized = TRUE)


# Latent Basis Model
ssw_vars <- paste0("ssw_", seq(1992, 2020, 2))

model_basis <- paste0("
  i =~ 1*", paste(ssw_vars, collapse = " + 1*"), "
  s =~ 0*", ssw_vars[1], " + NA*", ssw_vars[2], " + ",
                      paste0(ssw_vars[3:(length(ssw_vars)-1)], collapse = " + "), " + 1*", ssw_vars[length(ssw_vars)], "
  i ~ 1
  s ~ 1
  i ~~ s")

fit_basis <- growth(model_basis, data = df_model, missing = "fiml")
summary(fit_basis, fit.measures = TRUE, standardized = TRUE)


# Visualization

param_est <- parameterEstimates(fit_basis)

lambda_est <- param_est %>%
  filter(lhs == "s", op == "=~") %>%
  select(year = rhs, loading = est) %>%
  mutate(year = as.numeric(str_extract(year, "\\d+")))

mean_i <- param_est %>% filter(lhs == "i", op == "~1") %>% pull(est)
mean_s <- param_est %>% filter(lhs == "s", op == "~1") %>% pull(est)

avg_traj <- lambda_est %>%
  mutate(predicted_ssw = mean_i + mean_s * loading)

ggplot(avg_traj, aes(x = year, y = predicted_ssw)) +
  geom_line(color = "steelblue", size = 1.2) +
  geom_point(color = "darkblue") +
  theme_minimal(base_size = 13) +
  labs(
    title = "Estimated Growth Trajectory of Social Security Wealth (1992–2020)",
    x = "Year",
    y = "Predicted SSW (thousand units)"
  )


