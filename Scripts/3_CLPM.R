
library(lavaan)
library(tidyverse)
library(semPlot)
library(psych)


ri_data <- data_long %>%
  filter(wave %in% 4:8) %>% 
  select(hhidpn, wave, cog27, cesd) %>%
  group_by(hhidpn) %>%
  mutate(n_nonmiss = sum(!is.na(cog27) & !is.na(cesd))) %>%
  ungroup() %>%
  filter(n_nonmiss >= 3) %>%
  select(-n_nonmiss) %>%
  pivot_wider(
    id_cols = hhidpn,
    names_from = wave,
    values_from = c(cog27, cesd),
    names_sep = "_"
  )


summary(ri_data)
colMeans(is.na(ri_data))

riclpm_model <- '
  RI_cog =~ 1*cog27_4 + 1*cog27_5 + 1*cog27_6 + 1*cog27_7 + 1*cog27_8
  RI_dep =~ 1*cesd_4  + 1*cesd_5  + 1*cesd_6  + 1*cesd_7  + 1*cesd_8
  RI_cog ~~ RI_cog
  RI_dep ~~ RI_dep
  RI_cog ~~ 0*RI_dep
  
  cog27_4 ~~ 0*RI_cog
  cog27_5 ~~ 0*RI_cog
  cog27_6 ~~ 0*RI_cog
  cog27_7 ~~ 0*RI_cog
  cog27_8 ~~ 0*RI_cog
  cesd_4  ~~ 0*RI_dep
  cesd_5  ~~ 0*RI_dep
  cesd_6  ~~ 0*RI_dep
  cesd_7  ~~ 0*RI_dep
  cesd_8  ~~ 0*RI_dep

  cog27_5 ~ a*cog27_4 + c*cesd_4
  cog27_6 ~ a*cog27_5 + c*cesd_5
  cog27_7 ~ a*cog27_6 + c*cesd_6
  cog27_8 ~ a*cog27_7 + c*cesd_7

  cesd_5  ~ b*cesd_4  + d*cog27_4
  cesd_6  ~ b*cesd_5  + d*cog27_5
  cesd_7  ~ b*cesd_6  + d*cog27_6
  cesd_8  ~ b*cesd_7  + d*cog27_7

  cog27_4 ~~ cesd_4
  cog27_5 ~~ cesd_5
  cog27_6 ~~ cesd_6
  cog27_7 ~~ cesd_7
  cog27_8 ~~ cesd_8
'

fit_riclpm <- lavaan(
  riclpm_model,
  data = ri_data,
  missing = "fiml",
  estimator = "MLR",
  auto.fix.first = TRUE,
  auto.var = TRUE,
  auto.cov.lv.x = TRUE,
  auto.th = TRUE
)

summary(fit_riclpm, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE)
fitMeasures(fit_riclpm, c("cfi","tli","rmsea","srmr"))


clpm_latent <- '
  cog4 =~ 1*cog27_4
  cog5 =~ 1*cog27_5
  cesd4 =~ 1*cesd_4
  cesd5 =~ 1*cesd_5

  cog5 ~ a*cog4 + c*cesd4
  cesd5 ~ b*cesd4 + d*cog4

  cog4 ~~ cesd4
  cog5 ~~ cesd5
'

fit_clpm <- lavaan(
  clpm_latent,
  data= ri_data,
  missing = "fiml",
  estimator = "MLR",
  auto.fix.first= TRUE,
  auto.var= TRUE,
  auto.cov.lv.x= TRUE,
  auto.th= TRUE
)

summary(fit_clpm,
        fit.measures = TRUE,
        standardized = TRUE,
        rsquare= TRUE) 


