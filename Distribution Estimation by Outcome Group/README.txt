# Practical Class 2: Distribution Estimation by Outcome Group

## 1. Assignment Overview

**Task:** For each continuous variable in the dataset `data_for_analysis.csv`, estimate the optimal probability distribution (Normal, Log‑normal, or Exponential) separately for the two outcome groups (`outcome = 0` and `outcome = 1`). The selection of the best model is based on the **Bayesian Information Criterion (BIC)**. Additionally, descriptive statistics and the estimated parameters of the chosen distribution must be reported.

**Extra points task:** Identify and correct errors in the variable `lipids5` (missing data handling) and repeat the analysis including this variable.

## 2. Student Information

| | |
|---|---|
| **Name** | [Oleg Kudryashov] |
| **Date** | 19.04.2026 |
| **Course** | Data Analysis 2026 |
| **Group** | Subgroup 2 (ЦТм-25-1) |

## 3. Data Description

- **Source file:** `data_for_analysis.csv`
- **Observations:** 1148
- **Variables:** 31 (mixed types)
- **Outcome groups:**  
  - `outcome = 0`: 987 observations  
  - `outcome = 1`: 160 observations  
  - (1 observation with missing `outcome` was excluded automatically)

### Variables analysed

All numeric columns except identifiers and categorical factors were treated as continuous. The following 25 variables were analysed in the main task:

`hormone1` – `hormone8`, `hormone10_generated`, `lipids1` – `lipids4`, `сarb_metabolism`, `lipid_pero1` – `lipid_pero5`, `antioxidant1` – `antioxidant5`.

For the extra‑points task, `lipids5` was added after imputation.

### Missing data in `lipids5`

- **Initial state:** 276 missing values (`NA`).
- **Correction strategy:** Missing values were replaced by the **group‑specific median** (computed separately for `outcome = 0` and `outcome = 1`).
- **After correction:** 0 missing values.

## 4. Methods

All computations were performed in **R 4.5.3** using the packages `MASS` (for maximum likelihood estimation) and `dplyr` / `tidyr` (for data manipulation).

### 4.1 Distribution fitting

For each continuous variable and each outcome group, the following three distributions were fitted using the function `fitdistr()`:

- **Normal** – `fitdistr(x, "normal")`
- **Log‑normal** – `fitdistr(x, "lognormal")`
- **Exponential** – `fitdistr(x, "exponential")`

### 4.2 Model selection

For every valid fit, the Bayesian Information Criterion was calculated as:

`BIC = -2 · log(L) + k · log(n)`

where `L` is the likelihood, `k` is the number of parameters, and `n` is the sample size.

The model with the **lowest BIC value** was selected as the best‑fitting distribution.

### 4.3 Output tables

Two summary tables were generated:

| File name | Contents |
|---|---|
| `descriptive_stats_main.csv` | Results for all continuous variables **except** `lipids5` (main assignment) |
| `descriptive_stats_extra.csv` | Results for all continuous variables **including** the imputed `lipids5` (extra points) |

Each table contains the following columns:

- `variable` – name of the continuous variable
- `outcome` – group (0 or 1)
- `n`, `mean`, `sd`, `median`, `min`, `max` – descriptive statistics
- `best_dist` – chosen distribution (`"normal"`, `"lognormal"`, or `"exponential"`)
- `param1`, `param2` – estimated parameters (e.g., `meanlog` and `sdlog` for log‑normal)
- `BIC` – BIC value of the selected model

## 5. Key Findings

### 5.1 Dominance of the log‑normal distribution

Across both outcome groups, the **log‑normal distribution was selected for the overwhelming majority of variables**. This indicates that most hormone, lipid, and antioxidant measurements are positively skewed and strictly positive – a pattern that is common in biological and medical data.

### 5.2 Occasional use of the normal distribution

The **normal distribution** was chosen only for a few variables, notably:

- `hormone3`, `hormone5`, `hormone7` in group 0
- `antioxidant1` in both groups
- `lipid_pero5` in group 1
- `сarb_metabolism` in group 1

These variables either contain zero values (which prevent fitting a log‑normal model) or exhibit a roughly symmetric distribution.

### 5.3 Exponential distribution – rare

The **exponential distribution** did **not** appear as the best model for any variable in this dataset. This suggests that the decay patterns characteristic of exponential waiting times are not present among the analysed biomarkers.

### 5.4 Group comparisons

- Mean and median values are **slightly higher in the `outcome = 1` group** for several variables (e.g., `hormone3`, `hormone4`, `lipids2`, `lipids4`), though the differences are generally moderate.
- The log‑normal parameters (`meanlog` and `sdlog`) are very similar between groups, indicating that the underlying distribution shape is consistent regardless of the outcome.

## 6. Repository Contents

| File | Description |
|---|---|
| `data_for_analysis.csv` | Original dataset |
| `analysis_script.R` | R script performing all data processing, distribution fitting, and export |
| `descriptive_stats_main.csv` | Summary table for the main assignment (without `lipids5`) |
| `descriptive_stats_extra.csv` | Summary table for the extra‑points assignment (with imputed `lipids5`) |
| `README.md` | This document |


## 7. Conclusion

The assignment was successfully completed:

- Optimal probability distributions were identified for all continuous variables stratified by `outcome`.
- Descriptive statistics and estimated parameters were compiled into structured CSV tables.
- Missing values in `lipids5` were corrected using group‑wise median imputation, enabling a complete analysis for the extra‑points task.
- The log‑normal model proved to be the most appropriate description for the vast majority of the biomarkers, reflecting their inherent positive skewness.

