## load library and functions required
if(!require('table1')) install.packages('table1'); library(table1)
source('rcodes/02_functions_tables.r')

data = read.csv('input/Final data_9April.csv', header = TRUE)

## convert the diseases
data$Chronic_kidney_disease_cat = ifelse(data$Chronic_kidney_disease %in% 1, "Yes", "No")
data$COPD_cat = ifelse(data$COPD %in% 1, "Yes", "No")
data$Atrial_fibrillation_cat = ifelse(data$Atrial_fibrillation %in% 1, "Yes", "No")
data$hypertension_cat = ifelse(data$hypertension %in% 1, "Yes", "No")
data$Ischemic_heart_disease_cat = ifelse(data$Ischemic_heart_disease %in% 1, "Yes", "No")
data$diabetes_cat = ifelse(data$diabetes %in% 1, "Yes", "No")
data$Cerebrovascular_cat = ifelse(data$Cerebrovascular %in% 1, "Yes", "No")

## add some variables
data$T1_Tmax = ifelse(data$value_1 == data$value_max, 1, 0)
table(data$T1_Tmax, data$statin)
# change those 0 to NA
data[, paste0("value_",1:28)] = apply(data[, paste0("value_",1:28)], 2, function(x) ifelse(x == 0, NA, x))
data$value_max2 = apply(data[, paste0("value_",2:28)], 1, function(x) {
  if(is.na(x[1])) NA else{
    max(x, na.rm = 1)
  }
})
data$value_mean = apply(data[, paste0("value_",1:28)], 1, function(x) mean(x, na.rm = 1))
data$value_median = apply(data[, paste0("value_",1:28)], 1, function(x) median(x, na.rm = 1))
data$change_1max = (data$value_max - data$value_1)/data$value_1
data$change_1max2 = (data$value_max2 - data$value_1)/data$value_1

data$abnormal = ifelse(data$value_max >= 0.4, "Yes", "No")
data$no_rep = ifelse(is.na(data$value_2), 1, 0)

## exclusion criteria for analysis
sum(data$no_rep)
data = data[data$no_rep == 0, ] # do this first
sum(data$T1_Tmax)
data = data[data$T1_Tmax == 0, ] # then do this next
sum(data$statin == 2)
data = data[data$statin %in% c(0, 1), ]
table(data$statin)

sum(data$value_max <= 0.4)
data = data[data$value_max <= 0.4, ]
table(data$statin)
sum(data$value_max > 0.04)
data = data[data$value_max > 0.04, ]
table(data$statin)
sum(!data$first_careunit_1 %in% c("Coronary Care Unit (CCU)", "Cardiac Vascular Intensive Care Unit (CVICU)"))
data = data[!data$first_careunit_1 %in% c("Coronary Care Unit (CCU)", "Cardiac Vascular Intensive Care Unit (CVICU)"), ]
table(data$statin)

