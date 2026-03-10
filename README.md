# What Drives Household Income in the EU? A Data-Driven Econometric Comparison (Spain vs. Sweden)

### 📌 Project Overview
This project explores the socioeconomic determinants of household income in two distinct European economies: **Spain** (Mediterranean welfare model) and **Sweden** (Nordic welfare model). 

Using micro-data from the **European Social Survey (ESS)**, the analysis employs Multiple Linear Regression (OLS) to identify how education, gender, age, marital status, and income sources affect a household's placement on the 1-10 income decile scale (`hinctnta`).

### 🛠️ Data & Preprocessing
* **Source:** European Social Survey (ESS).
* **Data Cleaning:** Filtered for ES and SE. Handled missing values (NAs) across all variables (e.g., removing refusal to answer or "don't know" codes).
* **Transformations:** Converted categorical variables into factors and created a non-linear age variable (`Age_Squared`) to test for life-cycle income effects.

### 📊 Econometric Methodology & Diagnostics
To ensure the statistical validity of the findings, a rigorous econometric pipeline was followed:

1. **Model Specification & Multicollinearity:** The initial full model (including hundreds of `isco08` occupation codes) exhibited perfect multicollinearity (singularities). A **Reduced Model** was successfully specified. Variance Inflation Factor (VIF) tests confirmed that all remaining variables had a VIF < 2, perfectly resolving the issue (structural multicollinearity for Age/Age_Squared was naturally retained).
2. **Heteroskedasticity Correction:** The Breusch-Pagan test detected heteroskedasticity in the Spanish model (p-value = 0.002). To correct this, **Robust Standard Errors (HC1)** were calculated using the `sandwich` package for both countries, ensuring reliable p-values.
3. **Normality of Residuals:** The Jarque-Bera test confirmed that the residuals are normally distributed (Spain: p = 0.097, Sweden: p = 0.631).
4. **Autocorrelation:** The Durbin-Watson test confirmed the absence of autocorrelation, with values perfectly centered around 2.0 (Spain: 2.04, Sweden: 2.07).
5. **Model Specification:** The Ramsey RESET test confirmed that the models are correctly specified with no omitted non-linear variables (Spain: p = 0.768, Sweden: p = 0.132).

### 💡 Key Findings

Through the robust OLS models, several critical insights emerged regarding how income is distributed in these two countries:

* **1. The Universal Education Premium:** Higher education is the strongest driver of income in both nations. Holding all else constant, completing a Bachelor's, Master's, or PhD (`edulvlb` 620, 720, 800) boosts a household's income decile by +2.3 to +3.7 points compared to the baseline.
* **2. The Gender Wage Gap Persists:** Even after controlling for education, age, and location, identifying as female (`gndr2`) has a statistically significant negative impact on the household income decile in **both** Spain (-0.525) and Sweden (-0.473).
* **3. The Life-Cycle Effect (Age):** A fascinating divergence appears here. In **Spain**, age exhibits a classic, statistically significant non-linear effect (an inverted-U shape where income rises and then falls towards retirement). In **Sweden**, age and age-squared are strictly insignificant (p > 0.44). This suggests the Nordic welfare system (e.g., strong student subsidies and robust pensions) effectively neutralizes age-based income disparities.
* **4. Main Source of Income:** In Sweden, the main source of income (`hincsrca`) acts as a massive determinant. Relying on unemployment benefits or pensions (compared to wages) drastically lowers the predicted income decile (e.g., coefficients reaching -3.7 to -4.6). 

### 📈 Model Fit
The final models provide a realistic and solid explanatory power for cross-sectional micro-data:
* **Sweden:** Explains **38.5%** of the variance in household income (Adjusted R-squared: 0.3847).
* **Spain:** Explains **22.6%** of the variance in household income (Adjusted R-squared: 0.2264). 

*(The full R script, including all diagnostic tests and robust standard error calculations, is available in the repository files).*
