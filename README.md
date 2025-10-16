# Project Overview 

This repository demonstrates longitudinal data analysis using R. 

## Workflow 

1. **Data Cleaning & Preparation (`0_data_cleaning.R`)** 
   - Data import, variable renaming, missing data inspection 

2. **Latent Growth Modeling (`1_LGM.R`)** 

3. **Hierarchical Linear Modeling (`2_HLM.R`)** 

4. **Cross-Lagged Panel Modeling (`3_CLPM.R`)** 

5. **Survival / Time-to-Event Analysis (`4_Survival.R`)** 

6. **Data Linkage & Propensity Matching (`5_Data_Linkage.R`)** 

## 0_data_cleaning - Data Preparation 

This script cleans and reshapes the HRS Prospective Social Security Wealth data (1992–2020) into a long-format dataset for longitudinal analysis. 

**Key operations:** 
- Selects respondent-level SSW and claimed status variables 
- Reshapes from wide to long format 
- Creates a `year` variable 
- Checks and visualizes missing data across waves 

## 1_ Latent Growth Modeling (`1_LGM.R`) 

This script demonstrates **LGM** using longitudinal Social Security Wealth data from 1992–2020.   

It compares **linear**, **quadratic**, and **latent basis** growth models to identify the best representation of long-term wealth trajectories. 

--- 

###  Objectives 

- Examine how individuals’ Social Security Wealth changes across 15 waves (1992–2020)  
- Compare linear, quadratic, and flexible nonlinear models   
- Estimate individual differences in initial levels and growth rates   

--- 

###  Workflow 

1. **Data Preparation** 
   - Select relevant SSW variables and rescale values  
   - Check missing data rates   
   - Prepare data for full-information maximum likelihood (FIML) estimation   

2. **Model Specification** 
   - **Linear Model:** assumes a constant rate of change   
   - **Quadratic Model:** introduces a curvature term to capture acceleration/deceleration   
   - **Latent Basis Model:** freely estimates time loadings, allowing a data-driven nonlinear trajectory   

3. **Model Estimation** 
   - Models are estimated using the `lavaan` package  
   - Fit indices (CFI, TLI, RMSEA, SRMR) are compared across models    

4. **Visualization** 
   - The predicted mean trajectory of SSW (1992–2020) is plotted with `ggplot2`   
   - The curve shows slow early growth, acceleration after 2000, and stabilization after 2016   

--- 

### Model Comparison 

| Model | Description | Fit Summary | Interpretation | 

|--------|--------------|-------------|----------------| 

| Linear | Constant growth rate | Poor fit (CFI < .80, RMSEA > .10) | Too restrictive | 

| Quadratic | Adds curvature term | Moderate fit (CFI ≈ .88, RMSEA ≈ .13) | Partial improvement | 

| **Latent Basis (Free Time Loadings)** | Flexible, data-driven shape | **Best fit (CFI = .95, TLI = .95, RMSEA = .09, SRMR = .03)** | Captures nonlinear acceleration | 

--- 

###  Interpretation 

The latent basis model revealed a **nonlinear acceleration pattern** of Social Security Wealth: 
- Slow accumulation in early years (1992–2000)   
- Rapid increase between 2000 and 2016   
- Stabilization after 2016   

Both intercept and slope variances were significant, indicating substantial individual differences.   

The strong positive correlation between intercept and slope (r = .86) suggests that individuals with higher initial wealth tended to accumulate faster — a *cumulative advantage* pattern. 

--- 

## 3. Hierarchical Linear Modelling (`2_HLM `) 

This script demonstrates how to model longitudinal change in Social Security Wealth using **Hierarchical Linear Modelling (HLM)** in R. 

### Overview 

HLM captures both **within-person change over time** and **between-person differences** in growth patterns.   

Two models were compared: 

1. **Random intercept model:** allows individual differences in baseline SSW.   

2. **Random intercept + slope model:** also allows individuals to differ in their rates of change. 

### Key Steps 

- Prepare variables  
- Fit two multilevel models   
- Compare models  
- Extract and interpret random effects  
- Visualize population-level growth trajectories 

### Main Results 

- Adding random slopes **significantly improved model fit** (Δχ² = 9753.4, p < .001).   
- **Average SSW in 2006 ≈ 40.5 thousand**, increasing by **~0.6 thousand per year**.   
- Individuals varied substantially in both baseline levels and growth rates.   
- The high intercept–slope correlation (r ≈ 1.00) suggests largely parallel upward trends. 

### Visualization 

The dashed gray line represents the observed yearly means,  and the solid orange line shows the model-predicted average trajectory (1992–2020). 

--- 