# Project Overview 
This repository demonstrates longitudinal data analysis using R. 

## data_cleaning - Data Preparation 

This script prepares the RAND HRS 1992–2022 dataset for longitudinal analysis.  
It selects relevant variables, reshapes the data from wide to long format, handles missing values, and exports clean files for modeling.

### Variable Overview

| Variable Group | Example Variables | Description |
|----------------|------------------|--------------|
| **Identifiers** | `hhidpn`, `rdeath` | Respondent ID and death status |
| **Demographics** | `s1educ`, `s1meduc`, `s1feduc`, `gender` | Background characteristics |
| **Cognition** | `cog27`, `srh`, `cesd` | Cognitive and psychological indicators |
| **Health & Function** | `adl`, `iadl`, `chron` | Physical function and chronic conditions |
| **Economics** | `finr`, `famr`, `atot` | Financial and asset measures |
| **Behavioural** | `mstat`, `smokev`, `dage_y` | Marital status, smoking, and age variables |

--- 

## Longitudinal Modeling of Cognitive Aging

This project investigates how cognitive function changes over time among older adults using data from the HRS.  
The analysis focuses on the COG27 cognitive score (range 0–27) across four waves between 1996 and 2002.


### Overview

I applied **LGM** within a **MIMIC framework** to explore whether individual differences in **education** and **gender** predict:
- the **baseline level** of cognition, and  
- the **rate of cognitive decline** over time.

Three models were tested:
1. **Linear Growth Model** – assumes a constant rate of change.  
2. **Quadratic Growth Model** – allows acceleration or deceleration.  
3. **Free-Loading Growth Model (Final)** – estimates time loadings freely to capture nonlinear patterns.

Missing data were handled using **Full Information Maximum Likelihood (FIML)** in R.

### Model Fit Comparison

| Model | CFI | TLI | RMSEA | SRMR | 
|:------|:----:|:----:|:------:|:------|
| Linear | 0.681 | 0.503 | 0.182 | 0.110 | 
| Quadratic | 0.928 | 0.663 | 0.150 | 0.064 | 
| **Free-Loading (Final)** | **0.956** | **0.898** | **0.083** | **0.031** | 

> The free-loading model provided the best fit, showing that cognitive change follows a **nonlinear trajectory** rather than a uniform decline.

### Key Findings 

| Path | β | p value | Interpretation |
|------|----:|:--:|----------------|
| **Education → Intercept** | 0.53 | < .001 | Higher education → higher baseline cognition |
| **Education → Slope** | −0.13 | < .001 | Higher education → slower decline |
| **Gender → Intercept** | −0.22 | < .001 | Females start slightly lower |
| **Gender → Slope** | 0.35 | < .001 | Females show faster decline or greater variability |
| **Intercept ↔ Slope** | −0.57 | — | Higher baseline → slower decline  |

### Interpretation

- Cognitive aging is **nonlinear**: stability in mid-waves followed by accelerated decline later.  
- **Education** acts as a strong **protective factor** for both baseline ability and rate of change.  
- A negative correlation between intercept and slope supports the **cognitive reserve hypothesis**—individuals starting with higher cognition decline more slowly.  


### Summary

The **Free-Loading MIMIC LGM** achieved strong fit  
(CFI = 0.956, TLI = 0.898, RMSEA = 0.083, SRMR = 0.031),  
revealing that **education** buffers cognitive decline and that **aging-related change** in cognition is distinctly **nonlinear**.

