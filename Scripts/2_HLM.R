library(lme4)
library(lmerTest)
library(tidyverse)
library(performance)


hlm_data <- data_long %>%
  filter(wave %in% 3:6) %>%  
  select(hhidpn, wave, gender, s1educ, cog27) %>%
  drop_na(cog27) %>%
  mutate(
    wave = as.numeric(wave),
    gender = ifelse(gender == 2, 1, 0), 
    s1educ = as.numeric(s1educ),
    time = wave - min(wave, na.rm = TRUE) 
  )

summary(hlm_data)



# Model 1: Random intercept
model1 <- lmer(cog27 ~ time + (1 | hhidpn), data = hlm_data, REML = FALSE)
summary(model1)
icc(model1)

# Model 2: Random intercept + slope
model2 <- lmer(cog27 ~ time + (time | hhidpn), data = hlm_data, REML = FALSE)
summary(model2)
icc(model2)

# Model 3:Add gender+ education as predictors
model3 <- lmer(
  cog27 ~ time + s1educ + gender + time:s1educ + time:gender + (time | hhidpn),
  data = hlm_data, REML = FALSE
)

summary(model3)
icc(model3)

# Model comparison
anova(model1, model2, model3)







