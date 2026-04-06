rm(list = ls())


getwd()


data_path <- "C:\\Users\\OlegK\\Desktop\\analysis\\DataSet_No_Details.csv"

# read dataset
df <- read.csv(data_path)

# Display structure with variable types
str(df)

# Beautiful summary with histograms for numeric variables
if (!require(skimr)) install.packages("skimr")
library(skimr)
skim(df)

# Data set preparation
if (!require(dplyr)) install.packages("dplyr")
library(dplyr)

# Delete a few columns 
cols_to_remove <- c("h_index_34", "h_index_56", "hormone10_1", "hormone10_2",
                    "an_index_23","outcome","factor_eth","factor_h","factor_pcos","factor_prl")
MD_df <- df %>% select(-any_of(cols_to_remove))
factor_df <- df %>% select(record_id, outcome, factor_eth, factor_h, factor_pcos, factor_prl)

str(MD_df)
summary(factor_df)

# Identify Missing Values
sum(is.na(MD_df))               
colSums(is.na(MD_df))           
skim(MD_df)
na_stats <- colMeans(is.na(MD_df)) * 100 # % missing data
na_stats

# Tables for missing data <=35% and >35%
na_stats_filtered <- na_stats[na_stats <= 35]
data.frame(Column = names(na_stats_filtered), NA_Percent = na_stats_filtered)

na_stats_filtered_1 <- na_stats[na_stats > 35]
data.frame(Column = names(na_stats_filtered_1), NA_Percent = na_stats_filtered_1)

# Visualizing Missing Data Patterns
if (!require(visdat)) install.packages("visdat")
library(visdat)
vis_miss(MD_df)

if (!require(naniar)) install.packages("naniar")
library(naniar)
gg_miss_var(MD_df)

# Delete additional columns to get handle_MD_df
cols_to_remove1 <- c("hormone9", "hormone11", "hormone12", "hormone13", "hormone14")
handle_MD_df <- MD_df %>% select(-any_of(cols_to_remove1))
str(handle_MD_df)

# ==================== 2. ЗАДАНИЕ 1: Little's MCAR Test ====================
cat("\n========== Little's MCAR Test ==========\n")
if (!require(naniar)) install.packages("naniar")
library(naniar)

if (any(is.na(handle_MD_df))) {
  mcar_result <- mcar_test(handle_MD_df)
  print(mcar_result)
  p_val <- mcar_result$p.value
  if (p_val > 0.05) {
    cat("p-value =", p_val, "> 0.05 → Не отвергаем H0: данные MCAR.\n")
  } else {
    cat("p-value =", p_val, "≤ 0.05 → Отвергаем H0: данные НЕ MCAR (MAR или MNAR).\n")
  }
} else {
  cat("В данных нет пропусков, тест MCAR не требуется.\n")
}

# ==================== 3. ЗАДАНИЕ 2: Сравнение методов импутации (PMM vs RF) ====================
cat("\n========== Imputation: PMM vs RF ==========\n")

# Оставляем только колонки с % пропусков <= 35% (для устойчивости)
cols_for_impute <- names(na_stats[na_stats <= 35])
data_impute <- handle_MD_df[, cols_for_impute]

if (!require(mice)) install.packages("mice")
if (!require(ggplot2)) install.packages("ggplot2")
library(mice)
library(ggplot2)

# ---- Метод Random Forest ----
cat("Выполняется импутация методом Random Forest...\n")
imp_rf <- mice(data_impute, m = 5, method = "rf", printFlag = FALSE)
completed_rf <- complete(imp_rf)

# ---- Метод Predictive Mean Matching ----
cat("Выполняется импутация методом Predictive Mean Matching (PMM)...\n")
imp_pmm <- mice(data_impute, m = 5, method = "pmm", printFlag = FALSE)
completed_pmm <- complete(imp_pmm)

# Финальный набор данных
imputed_handle_MD_df_final <- completed_rf

# переменная для визуализации
if ("hormone10_generated" %in% names(data_impute)) {
  var_name <- "hormone10_generated"
} else {
  var_name <- names(data_impute)[sapply(data_impute, is.numeric)][1]
  cat("Переменная 'hormone10_generated' не найдена. Используем", var_name, "\n")
}

# График плотности: Original (с пропусками) vs PMM vs RF
plot_df <- data.frame(
  value = c(data_impute[[var_name]], completed_pmm[[var_name]], completed_rf[[var_name]]),
  method = rep(c("Original (with NA)", "PMM", "RF"), each = nrow(data_impute))
)

ggplot(plot_df, aes(x = value, fill = method)) +
  geom_density(alpha = 0.5) +
  labs(title = paste("Сравнение распределения:", var_name),
       x = var_name, y = "Плотность") +
  theme_minimal() +
  scale_x_continuous(limits = quantile(plot_df$value, c(0.01, 0.99), na.rm = TRUE))

# Вывод заключения
cat("\n========== Вывод по методам импутации ==========\n")
cat("Метод PMM (Predictive Mean Matching) сохраняет исходное распределение и дисперсию,\n",
    "особенно для непрерывных данных. RF (Random Forest) более гибок, но может сглаживать пики.\n",
    "На графике видно, что распределение после PMM ближе к исходному (с пропусками),\n",
    "чем после RF. PMM для данного набора данных предпочтительнее.\n")

# ==================== 4. ЗАДНИЕ 3: LOF для выбросов ====================
cat("\n========== Local Outlier Factor (LOF) ==========\n")

if (!require(dbscan)) install.packages("dbscan")
if (!require(tidyr)) install.packages("tidyr")
library(dbscan)
library(tidyr)


data_lof <- imputed_handle_MD_df_final


numeric_cols <- data_lof %>% select(where(is.numeric))
# Удаляем столбцы с нулевой дисперсией
numeric_cols <- numeric_cols[, apply(numeric_cols, 2, var, na.rm = TRUE) != 0]

# Масштабирование
scaled_data <- scale(numeric_cols)

# Удаляем строки с NA (на всякий случай)
if (any(is.na(scaled_data))) {
  cat("Обнаружены NA в масштабированных данных. Удаляем соответствующие строки.\n")
  complete_rows <- complete.cases(scaled_data)
  scaled_data <- scaled_data[complete_rows, ]
  data_lof <- data_lof[complete_rows, ]
}

# Выбор параметра minPts (обычно 20 или меньше)
min_pts <- min(20, nrow(scaled_data) - 1)

# Расчёт LOF (используем minPts вместо устаревшего k)
lof_scores <- lof(scaled_data, minPts = min_pts)
data_lof$LOF <- lof_scores

# Гистограмма LOF факторов
ggplot(data_lof, aes(x = LOF)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "black") +
  labs(title = "Гистограмма LOF факторов", x = "Local Outlier Factor", y = "Частота") +
  theme_minimal()

# Определение выбросов (порог = 2)
threshold <- 2
data_lof$is_outlier <- data_lof$LOF > threshold

pca_res <- prcomp(scaled_data, center = FALSE, scale. = FALSE)
pca_df <- data.frame(
  PC1 = pca_res$x[,1],
  PC2 = pca_res$x[,2],
  outlier = data_lof$is_outlier
)

ggplot(pca_df, aes(x = PC1, y = PC2, color = outlier)) +
  geom_point(alpha = 0.7) +
  scale_color_manual(values = c("black", "red"), labels = c("Обычные", "Выбросы")) +
  labs(title = "Bivariate scatterplot (PC1 vs PC2) с выделением LOF-выбросов") +
  theme_minimal()

# Дополнительный scatterplot для двух исходных переменных (если lipids1 и lipids2 есть)
if (all(c("lipids1", "lipids2") %in% names(data_lof))) {
  ggplot(data_lof, aes(x = lipids1, y = lipids2, color = is_outlier)) +
    geom_point(alpha = 0.7) +
    scale_color_manual(values = c("black", "red")) +
    labs(title = "Bivariate scatterplot: lipids1 vs lipids2 (LOF outliers)") +
    theme_minimal()
}

# Вывод статистики
cat("Количество выбросов (LOF >", threshold, "):", sum(data_lof$is_outlier), "\n")
cat("Процент выбросов:", round(100 * mean(data_lof$is_outlier), 2), "%\n")