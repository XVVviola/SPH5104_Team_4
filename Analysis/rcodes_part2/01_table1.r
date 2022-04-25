## load library and functions required
if(!require('table1')) install.packages('table1'); library(table1)
source('rcodes/02_functions_tables.r')

data = read.csv('input/Final data_9April.csv', header = TRUE)
data = read.csv('input/Final cohort with SOFA.csv', header = TRUE)

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
data$first_careunit_1_cat = ifelse(data$first_careunit_1 %in% c("Coronary Care Unit (CCU)", "Cardiac Vascular Intensive Care Unit (CVICU)"),
                                   "Yes", "No")
## exclusion criteria for analysis
data = data[data$no_rep == 0, ] # do this first
data = data[data$T1_Tmax == 0, ] # then do this next
data = data[data$statin %in% c(0,1), ]
data = data[data$value_max > 0.4, ]
# data$analyse = ifelse(data$value_max > 0.04 & data$value_max <= 0.4 & data$no_rep == 0
#                       & data$statin %in% c(0,1) & data$priority_1 %in% "STAT" & data$T1_Tmax == 0 &
#                         !data$first_careunit_1 %in%  c("Coronary Care Unit (CCU)", "Cardiac Vascular Intensive Care Unit (CVICU)"), 1, 0)
# data$analyse = ifelse(data$value_max <= 0.4 # data$value_max > 0.04 & 
#                       & data$statin %in% c(0,1) , 1, 0)
# # data$analyse = ifelse(data$statin %in% c(0,1) , 1, 0)
# data = data[data$analyse == 1, ]

## make groups for comparison
data$Intervention = ifelse(data$statin == 0, "Non-statin", "Statin before")
data$Group = factor(data$Intervention, levels=c("Non-statin", "Statin before", "P-value"),
                    labels=c("Non-statin", "Statin before", "P-value"))

# data$Intervention = ifelse(data$value_max <= 0.4, "<= 0.4", "> 0.4")
# data$Group = factor(data$Intervention, levels=c("<= 0.4", "> 0.4", "P-value"),
#                     labels=c("<= 0.4", "> 0.4", "P-value"))

# data$Intervention = ifelse(data$analyse == 1, "Include", "Exclude")
# data$Group = factor(data$Intervention, levels=c("Include", "Exclude", "P-value"),
#                     labels=c("Include", "Exclude", "P-value"))

strata = c(list(Overall=data), split(data, data$Group))

#--------------------------------------------------------

## Define the variables and also add the labels and units 
labels = list(variables = list(
  
  # abnormal = "Trop max greater than 0.4",
  
  value_1 = "First troponin reading",
  value_max = "Max. troponin reading",
  value_mean = "Mean troponin reading",
  value_median = "Median troponin reading",
  
  change_1max = "Max. relative change (Tmax-T1)/T1",
  
  priority_1 = "Priority of first troponin reading",
  
  los_1 = "Length of ICU stay",
  first_careunit_1_cat = "First care unit in CCU or CVICU",
  
  
  creatinine_value_1 = "Creatinine",
  
  gender = "Sex",
  anchor_age = "Anchor age",
  Admission.Weight..Kg. = "Weight at admission",
  
  sofa_24hours = "First SOFA value",
  Chronic_kidney_disease_cat = "CKD",
  COPD_cat = "COPD",
  Atrial_fibrillation_cat = "Atrial fibrillation",
  hypertension_cat = "Hypertension",
  Ischemic_heart_disease_cat = "IHD",
  diabetes_cat = "Diabetes",
  Cerebrovascular_cat = "Cerebrovascular"
  
  # first_careunit_1 = "First care unit",
  # last_careunit_1 = "Last care unit"
  
),
groups=list("", "Intervention"))

## Generate table 1
# assume normality for continuous variable
table1(strata, labels, groupspan=c(1, 3),
       render.continuous = my.render.cont.JEM,
       render.categorical = my.render.cat,
       render = rndr, # chi sq test for categorical variables, t test for continuous
       render.strat = rndr.strat)

# table1(strata, labels, groupspan=c(1, 3),
#        render.continuous = my.render.cont.JEM, 
#        render.categorical = my.render.cat)

# names(data)



