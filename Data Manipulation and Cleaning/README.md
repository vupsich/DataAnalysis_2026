# Module: Data Manipulation and Cleaning

## Assignment
Task 1 (Deadline 30.03.2026 23:59)  
- Perform Little's MCAR test on `handle_MD_df`.
- Compare imputation methods: `pmm` (Predictive Mean Matching) vs `rf` (Random Forest).
- Detect outliers using Local Outlier Factor (LOF) on the imputed dataset.

## Data Description
- **File**: `DataSet_No_Details.csv`
- **Observations**: 1148
- **Variables**: 41 original, reduced to 26 after removing columns with >35% missing values.
- **Missing data**: Present in several variables (e.g., `hormone10_generated` 34.2% missing).

## R Version and Environment
- **R version**: 4.0+ (tested on 4.3.2)
- **Packages used**: `skimr`, `dplyr`, `visdat`, `naniar`, `mice`, `ggplot2`, `dbscan`, `tidyr`, `BaylorEdPsych`

## Procedures Performed

### 1. Data Preparation
- Removed columns: `h_index_34`, `h_index_56`, `hormone10_1`, `hormone10_2`, `an_index_23`, `outcome`, `factor_eth`, `factor_h`, `factor_pcos`, `factor_prl`.
- Created `handle_MD_df` by further removing `hormone9`, `hormone11`–`hormone14`.
- Analyzed missing data patterns (see `vis_miss` and `gg_miss_var`).

### 2. Little's MCAR Test
- Used `naniar::mcar_test()`.
- **Result**: p-value = 0 → reject H₀. Data are **not MCAR** (MAR or MNAR).

### 3. Imputation Comparison (PMM vs RF)
- Performed multiple imputation with `mice` (m=5) using `method="pmm"` and `method="rf"`.
- Compared density plots of `hormone10_generated`.
- **Conclusion**: PMM preserves original distribution better; recommended for this dataset.

### 4. Outlier Detection (LOF)
- Applied LOF on the RF-imputed dataset (`imputed_handle_MD_df_final`).
- Parameters: `minPts = 20`, threshold = 2.
- **Results**: 5 outliers detected (0.57% of data).
- Visualized with histogram and bivariate scatterplots (PCA and original variables).

## Output Files
- `results.txt` – full console log of the analysis.
- `mcar_test.png` – Little's MCAR test output (screenshot).
- `density_comparison.png` – density plot of `hormone10_generated` for Original, PMM, RF.
- `lof_histogram.png` – histogram of LOF scores.
- `pca_outliers.png` – PCA scatterplot with outliers highlighted in red.
- `lipids_scatter.png` – bivariate scatterplot of `lipids1` vs `lipids2` with outliers.

## How to Reproduce
1. Clone this repository.
2. Open `Homework_Task1.R` in RStudio.
3. Set the correct path to `DataSet_No_Details.csv`.
4. Run the entire script (it will install missing packages automatically).
5. All outputs will be printed in the console and plots will appear.

## Author
Oleg K. – (https://github.com/vupsich/)

## Date
2026-04-06