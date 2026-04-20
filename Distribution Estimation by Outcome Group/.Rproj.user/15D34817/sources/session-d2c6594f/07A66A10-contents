
library(MASS)      # для подбора распределений
library(dplyr)     # для удобной работы с данными
library(tidyr)     # для tidy-формата

# Читаем данные
df <- read.csv("C:\\Users\\OlegK\\Desktop\\Atalyan\\2\\data_for_analysis.csv", 
               stringsAsFactors = FALSE, na.strings = c("NA", ""))

# Смотрим, сколько пропусков в столбце lipids5
table(is.na(df$lipids5))

#заменяем NA на медиану по группам outcome (для доп. задания)
df_fixed <- df %>%
  group_by(outcome) %>%
  mutate(lipids5 = ifelse(is.na(lipids5), median(lipids5, na.rm = TRUE), lipids5)) %>%
  ungroup()

# Определяем список непрерывных переменных (исключая id, факторы и lipids5)
factor_vars <- c("record_id", "outcome", "factor_eth", "factor_h", "factor_pcos", "factor_prl")
continuous_vars_main <- setdiff(names(df), c(factor_vars, "lipids5"))
continuous_vars_extra <- c(continuous_vars_main, "lipids5")   # для доп. задания

# Функция, которая подгоняет одно распределение и возвращает BIC
fit_distribution <- function(x, dist_name) {
  if (dist_name == "lognormal" && any(x <= 0, na.rm = TRUE)) return(NULL)
  if (dist_name == "exponential" && any(x <= 0, na.rm = TRUE)) return(NULL)
  tryCatch({
    fit <- fitdistr(x, densfun = dist_name)
    bic <- BIC(fit)
    list(fit = fit, bic = bic)
  }, error = function(e) NULL)
}

# Выбор модели среди normal, lognormal, exponential по BIC
select_best_model <- function(x) {
  models <- list(
    normal = fit_distribution(x, "normal"),
    lognormal = fit_distribution(x, "lognormal"),
    exponential = fit_distribution(x, "exponential")
  )
  models <- models[!sapply(models, is.null)]
  if (length(models) == 0) return(NULL)
  
  bics <- sapply(models, function(m) m$bic)
  best_name <- names(which.min(bics))
  best_fit <- models[[best_name]]$fit
  
  list(
    distribution = best_name,
    params = as.list(best_fit$estimate),
    bic = min(bics)
  )
}

# для расчёта описательных статистик и параметров распределения
summarise_var <- function(data, var_name) {
  x <- data[[var_name]]
  x <- x[is.finite(x)]
  
  desc <- data.frame(
    n = length(x),
    mean = mean(x),
    sd = sd(x),
    median = median(x),
    min = min(x),
    max = max(x)
  )
  
  best <- select_best_model(x)
  if (!is.null(best)) {
    desc$best_dist <- best$distribution
    desc$param1 <- ifelse(length(best$params) > 0, best$params[[1]], NA)
    desc$param2 <- ifelse(length(best$params) > 1, best$params[[2]], NA)
    desc$BIC <- best$bic
  } else {
    desc$best_dist <- NA
    desc$param1 <- NA
    desc$param2 <- NA
    desc$BIC <- NA
  }
  desc
}

# Основной анализ (без lipids5)
results_main <- data.frame()
for (grp in c(0, 1)) {
  df_grp <- df %>% filter(outcome == grp)
  for (var in continuous_vars_main) {
    if (is.numeric(df_grp[[var]])) {
      sum_row <- summarise_var(df_grp, var)
      sum_row$variable <- var
      sum_row$outcome <- grp
      results_main <- bind_rows(results_main, sum_row)
    }
  }
}

# для дополнительного задания ( lipids5 испавлен)
results_extra <- data.frame()
for (grp in c(0, 1)) {
  df_grp <- df_fixed %>% filter(outcome == grp)
  for (var in continuous_vars_extra) {
    if (is.numeric(df_grp[[var]])) {
      sum_row <- summarise_var(df_grp, var)
      sum_row$variable <- var
      sum_row$outcome <- grp
      results_extra <- bind_rows(results_extra, sum_row)
    }
  }
}

write.csv(results_main, "descriptive_stats_main.csv", row.names = FALSE)
write.csv(results_extra, "descriptive_stats_extra.csv", row.names = FALSE)