# What Drives Household Income in the EU? A Data-Driven Econometric Comparison (Spain vs. Sweden)

### 📊 Executive Summary
This project explores the socioeconomic determinants of household income in two distinct European economies: Spain and Sweden. Using survey data from the European Social Survey (ESS), I built and evaluated Multiple Linear Regression (OLS) models to quantify the impact of education, gender, age, and marital status on income levels. To ensure the reliability of the insights, rigorous econometric diagnostics were performed, and heteroskedasticity was corrected using Robust Standard Errors (HC1). 

**Key Insight:** While education positively impacts income in both countries, the gender wage gap and the life-cycle income effect (age) present notable differences in magnitude between the Southern and Nordic economic models.

---

### 🎯 Objectives
* To identify and quantify the primary factors influencing household income in Spain and Sweden.
* To perform a robust comparative econometric analysis between a Mediterranean and a Nordic welfare state.
* To translate complex statistical outputs into actionable, visual insights.

---

### 💾 Data & Preprocessing
* **Data Source:** European Social Survey (ESS 11).
* **Target Variable:** Household Income Index (`hinctnta`).
* **Data Cleaning (Tidyverse):** * Filtered data strictly for Spain (ES) and Sweden (SE).
  * Handled missing values (NAs) encoded as specific numbers in the raw dataset.
  * Transformed categorical variables into factors for proper regression modeling.
  * Engineered a new feature, `Age_Squared`, to capture the non-linear, life-cycle effect of age on income.

---

### 🔬 Methodology & Econometric Diagnostics
The core analysis relies on **Multiple Linear Regression (OLS)**. To ensure the statistical validity of the models, several diagnostic tests were conducted using `lmtest`, `car`, and `tseries`:

1. **Multicollinearity:** Evaluated using Variance Inflation Factor (VIF). Variables like occupation (`isco08`) and economic sector (`nacer2`) were removed from the initial full model to eliminate multicollinearity.
2. **Heteroskedasticity:** Detected using the Breusch-Pagan test. Consequently, **Robust Standard Errors (HC1)** via the `sandwich` package were applied to correct the standard errors and calculate reliable p-values.
3. **Normality of Residuals:** Assessed via the Jarque-Bera test.
4. **Autocorrelation:** Checked using the Durbin-Watson test.
5. **Model Specification:** Validated using the Ramsey RESET test.

---

### 📈 Key Findings & Visualizations

#### 1. The Education Premium
Education is a strong predictor of higher income in both nations, but the baseline impact scales differently.


#### 2. The Gender Gap and Marital Status
Holding all other variables constant (age, education, etc.), being female has a statistically significant negative impact on the household income index compared to the male reference group in both countries (-0.525 in Spain, -0.473 in Sweden). 


#### 3. The Life-Cycle Effect (Age)
By introducing the `Age_Squared` variable, the model successfully captures the quadratic relationship between age and income. Income tends to rise as individuals gain experience, peaks during late middle age, and declines post-retirement.


---

### 🛠️ Tech Stack
* **Language:** R
* **Data Manipulation:** `dplyr`, `tidyverse`, `readxl`
* **Econometric Modeling:** `stats` (lm), `lmtest`, `sandwich` (Robust SEs), `car` (VIF), `tseries`
* **Data Visualization:** `ggplot2`, `stargazer`
