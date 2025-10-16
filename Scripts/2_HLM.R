library(tidyverse)
library(lme4)
library(lmerTest)
library(ggplot2)

df_long <- df_long %>%
  rename(ssw = ssw_r) %>% 
  mutate(
    year = as.numeric(year),
    ssw = ssw / 1000, 
    year_c = year - 2006)

# HLM
# Random intercept
hlm_int <- lmer(ssw ~ year_c + (1 | id), data = df_long, REML = FALSE)

#Random intercept +slope
hlm_slope <- lmer(ssw ~ year_c + (year_c | id), data = df_long, REML = FALSE)

# Compare model
anova(hlm_int, hlm_slope)

summary(hlm_slope)
VarCorr(hlm_slope)

# Visualization
pred_df <- df_long %>%
  group_by(year) %>%
  summarize(predicted = predict(
    hlm_slope,
    newdata = data.frame(year_c = year - 2006, id = NA),
    re.form = NA
  ))

obs_df <- df_long %>%
  group_by(year) %>%
  summarize(mean_ssw = mean(ssw, na.rm = TRUE))

ggplot() +
  geom_line(data = obs_df, aes(x = year, y = mean_ssw),
            color = "gray50", size = 1, linetype = "dashed") +
  geom_line(data = pred_df, aes(x = year, y = predicted),
            color = "darkorange", size = 1.2) +
  theme_minimal(base_size = 13) +
  labs(
    title = "HLM: Average Growth Trajectory (1992–2020)",
    subtitle = "Orange line = Model prediction; Gray dashed line = Observed mean",
    x = "Year",
    y = "Social Security Wealth (thousand units)"
  )

