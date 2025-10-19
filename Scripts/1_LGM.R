library(dplyr)
library(tidyr)
library(lavaan)

# select variables 
lgm_data <- data_long %>%
  filter(wave %in% 3:6) %>%
  select(hhidpn, wave, cog27, gender, s1educ) %>%
  pivot_wider(names_from = wave, values_from = cog27,
              names_prefix = "cog27_")

sum(is.na(lgm_data$gender))
mean(is.na(lgm_data$gender))

# missing data
summary(lgm_data)

#LGM
model_mimic <- '
  i =~ 1*cog27_3 + 1*cog27_4 + 1*cog27_5 + 1*cog27_6
  s =~ 0*cog27_3 + 1*cog27_4 + 2*cog27_5 + 3*cog27_6

  i ~ 1
  s ~ 1

  i ~~ s
  i ~~ i
  s ~~ s

  cog27_3 ~~ e*cog27_3
  cog27_4 ~~ e*cog27_4
  cog27_5 ~~ e*cog27_5
  cog27_6 ~~ e*cog27_6

  i ~ s1educ + gender
  s ~ s1educ + gender
'

fit_mimic <- growth(model_mimic, data = lgm_data, missing = "FIML")
summary(fit_mimic, fit.measures = TRUE, standardized = TRUE)
fitMeasures(fit_mimic, c("cfi", "tli", "rmsea", "srmr"))


# Residual free estimate

model_free <- '
  i =~ 1*cog27_3 + 1*cog27_4 + 1*cog27_5 + 1*cog27_6
  s =~ 0*cog27_3 + 1*cog27_4 + 2*cog27_5 + 3*cog27_6

  i ~ 1
  s ~ 1

  i ~~ s
  i ~~ i
  s ~~ s

  cog27_3 ~~ cog27_3
  cog27_4 ~~ cog27_4
  cog27_5 ~~ cog27_5
  cog27_6 ~~ cog27_6

  i ~ s1educ + gender
  s ~ s1educ + gender
'

fit_free <- growth(model_free, data = lgm_data, missing = "FIML")
summary(fit_free, fit.measures = TRUE, standardized = TRUE)
fitMeasures(fit_free, c("cfi", "tli", "rmsea", "srmr"))

# Quadratic growth model

model_quad <- '
  i =~ 1*cog27_3 + 1*cog27_4 + 1*cog27_5 + 1*cog27_6
  s =~ 0*cog27_3 + 1*cog27_4 + 2*cog27_5 + 3*cog27_6
  q =~ 0*cog27_3 + 1*cog27_4 + 4*cog27_5 + 9*cog27_6

  i ~ 1
  s ~ 1
  q ~ 1

  i ~~ s + q
  s ~~ q
  i ~~ i
  s ~~ s
  q ~~ q

  i ~ s1educ + gender
  s ~ s1educ + gender
  q ~ s1educ + gender
'

fit_quad <- growth(model_quad, data = lgm_data, missing = "FIML")
summary(fit_quad, fit.measures = TRUE, standardized = TRUE)
fitMeasures(fit_quad, c("cfi", "tli", "rmsea", "srmr"))

# Free loadings
model_free_load <- '
  i =~ 1*cog27_3 + 1*cog27_4 + 1*cog27_5 + 1*cog27_6
  s =~ 0*cog27_3 + l1*cog27_4 + l2*cog27_5 + l3*cog27_6

  i ~ 1
  s ~ 1

  i ~~ s
  i ~~ i
  s ~~ s

  cog27_3 ~~ cog27_3
  cog27_4 ~~ cog27_4
  cog27_5 ~~ cog27_5
  cog27_6 ~~ cog27_6

  i ~ s1educ + gender
  s ~ s1educ + gender
'

fit_free_load <- growth(model_free_load, data = lgm_data, missing = "FIML")
summary(fit_free_load, fit.measures = TRUE, standardized = TRUE)
fitMeasures(fit_free_load, c("cfi", "tli", "rmsea", "srmr"))




