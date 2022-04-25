#############################################
########## Packages to install ##############
#############################################
if(!require('textcat')) install.packages('textcat'); library(textcat)
if(!require('table1')) install.packages('table1'); library(table1)
if(!require('miceadds')) install.packages('miceadds'); library(miceadds)
if(!require('rstatix')) install.packages('rstatix'); library(rstatix)
if(!require('sjPlot')) install.packages('sjPlot'); library(sjPlot)
########################################################################

data = read.csv('input/Final data_9April.csv', header = TRUE)
data = read.csv('input/Final cohort with SOFA.csv', header = TRUE)

table(data$first_careunit_1)

## convert the diseases
data$Chronic_kidney_disease = ifelse(data$Chronic_kidney_disease %in% 1, "Yes", "No")
data$COPD = ifelse(data$COPD %in% 1, "Yes", "No")
data$Atrial_fibrillation = ifelse(data$Atrial_fibrillation %in% 1, "Yes", "No")
data$hypertension = ifelse(data$hypertension %in% 1, "Yes", "No")
data$Ischemic_heart_disease = ifelse(data$Ischemic_heart_disease %in% 1, "Yes", "No")
data$diabetes = ifelse(data$diabetes %in% 1, "Yes", "No")
data$Cerebrovascular = ifelse(data$Cerebrovascular %in% 1, "Yes", "No")

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
data$last_careunit_1_cat = ifelse(data$last_careunit_1 %in% c("Coronary Care Unit (CCU)", "Cardiac Vascular Intensive Care Unit (CVICU)"),
                                   "Yes", "No")
data$Admission.Weight..Kg. = ifelse(is.na(data$Admission.Weight..Kg.), 78.13, (data$Admission.Weight..Kg.))

## exclusion criteria for analysis
data = data[data$no_rep == 0, ] # do this first
data = data[data$T1_Tmax == 0, ] # then do this next
data = data[data$statin %in% c(0,1), ]
data$Intervention = ifelse(data$statin == 0, "Non-statin", "Statin before")

reg1 = data
reg2a = data[data$value_max <= 0.4, ]
reg2b = data[data$value_max > 0.4, ]
reg3 = reg2a[reg2a$value_max > 0.04, ]
reg4 = reg3[reg3$first_careunit_1_cat %in% "No", ]
# reg5 = reg4[reg4$priority_1 %in% "STAT", ]

outcome = "change_1max"
#-----------------------------------------------------------------------------

# model1 = lm(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1
#             + Atrial_fibrillation + Chronic_kidney_disease + diabetes + Cerebrovascular + hypertension 
#             + gender, data = reg1)
# 
# model2a = lm(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1
#             + Atrial_fibrillation + Chronic_kidney_disease + diabetes + Cerebrovascular + hypertension 
#             + gender, data = reg2a)
# 
# model2b = lm(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1
#              + Atrial_fibrillation + Chronic_kidney_disease + diabetes + Cerebrovascular + hypertension 
#              + gender, data = reg2b)
# 
# model3 = lm(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1
#              + Atrial_fibrillation + Chronic_kidney_disease + diabetes + Cerebrovascular + hypertension 
#              + gender, data = reg3)
# 
# model4 = lm(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1
#             + Atrial_fibrillation + Chronic_kidney_disease + diabetes + Cerebrovascular + hypertension 
#             + gender, data = reg4)
# 
# model5 = m(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1
#            + Atrial_fibrillation + Chronic_kidney_disease + diabetes + Cerebrovascular + hypertension 
#            + gender, data = reg5)
# 
# tab_model(model1, model2a, model2b, model3, model4, model5, 
#           dv.labels = c("Model 1", "Model2 <= 0.4", "Model 2 > 0.4", "Model 3", "Model 4", "Model 5"), 
#           p.style = "both", collapse.ci = TRUE, 
#           digits = 2, digits.p = 2)

#-----------------------------------------------------------------------------

# model1 = lm(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1, data = reg1)
# 
# model2a = lm(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1, data = reg2a)
# 
# model2b = lm(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1, data = reg2b)
# 
# model3 = lm(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1, data = reg3)
# 
# model4 = lm(change_1max ~ Intervention + los_1 + Admission.Weight..Kg. + anchor_age + creatinine_value_1, data = reg4)
# 
# tab_model(model2a, model3, model4, 
#           dv.labels = c("Model2 <= 0.4", "Model 3", "Model 4"), 
#           p.style = "both", collapse.ci = TRUE, 
#           digits = 2, digits.p = 2)
# tab_model(model1, model2a, model2b, model3, model4, 
#           dv.labels = c("Model 1", "Model2 <= 0.4", "Model 2 > 0.4", "Model 3", "Model 4"), 
#           p.style = "both", collapse.ci = TRUE, 
#           digits = 2, digits.p = 2)

#-----------------------------------------------------------------------------
model1_4 = lm(change_1max ~ Intervention + anchor_age + los_1 + Admission.Weight..Kg. + creatinine_value_1 + sofa_24hours, data = reg1)
model1_10 = lm(change_1max ~ Intervention + anchor_age + los_1 + Admission.Weight..Kg. + creatinine_value_1 + sofa_24hours
            + Atrial_fibrillation + hypertension + gender + last_careunit_1 + diabetes + Cerebrovascular 
            , data = reg1)
tab_model(model1_4, model1_10,
          dv.labels = c("Model 1, 4 adjustments", "Model 1, 10 adjustments"), 
          p.style = "both", collapse.ci = TRUE, 
          digits = 2, digits.p = 2)




model1_4 = lm(change_1max ~ Intervention + anchor_age + los_1 + Admission.Weight..Kg. + creatinine_value_1 + sofa_24hours, data = reg1)
model1_10 = lm(change_1max ~ Intervention + anchor_age + los_1 + Admission.Weight..Kg. + creatinine_value_1 + sofa_24hours
               + Atrial_fibrillation + hypertension + gender + last_careunit_1_cat + diabetes + Cerebrovascular 
               , data = reg1)
model2a = lm(change_1max ~ Intervention + anchor_age + los_1 + Admission.Weight..Kg. + creatinine_value_1 + sofa_24hours
             + Atrial_fibrillation + hypertension + gender + last_careunit_1_cat + diabetes + Cerebrovascular 
             , data = reg2a)
model2b = lm(change_1max ~ Intervention + anchor_age + los_1 + Admission.Weight..Kg. + creatinine_value_1 + sofa_24hours
             + Atrial_fibrillation + hypertension + gender + last_careunit_1_cat + diabetes + Cerebrovascular 
             , data = reg2b)
model3 = lm(change_1max ~ Intervention + anchor_age + los_1 + Admission.Weight..Kg. + creatinine_value_1 + sofa_24hours
            + Atrial_fibrillation + hypertension + gender + last_careunit_1_cat + diabetes + Cerebrovascular 
            , data = reg3)

model4 = lm(change_1max ~ Intervention + anchor_age + los_1 + Admission.Weight..Kg. + creatinine_value_1 + sofa_24hours
            + Atrial_fibrillation + hypertension + gender + last_careunit_1_cat + diabetes + Cerebrovascular 
            , data = reg4)

tab_model(model1_4, model1_10, model2a, model2b, model3, model4,
          dv.labels = c("Model 1, 4 adjustments", "Model 1, 10 adjustments",
                        "2a", "2b", "3", "4"), 
          p.style = "both", collapse.ci = TRUE, 
          digits = 2, digits.p = 2)

