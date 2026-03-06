#import data
install.packages('readxl')
library(readxl)
data <- read_excel('C:/R_project/ALL DATA ESS11.xlsx')
data

#φιλτράρω τα δεδομένα για τις χώρες μου(Ισπανία, Σουηδία) 
#και για τους παράγοντες που θεωρώ οτι επηρεάζουν το εισοδημά μου
install.packages('tidyverse')
library(tidyverse)
my_data <- data %>%
  filter(cntry %in% c("ES", "SE")) %>%
  select(
    cntry,
    hinctnta,
    hincsrca,
    gndr,
    agea,
    marsts,
    edulvlb,
    isco08,
    emplrel,
    nacer2,
    tporgwk,
    domicil,
    chldhhe
  )

#καθαρίζω τα δεδομένα από τιμές NA κτλ
#clean data (NA values etc)
my_clean_data <- my_data %>%
  mutate(Age_Squared = agea ^ 2) %>% 
  mutate (
    hinctnta = ifelse(hinctnta %in% c(77, 88, 99), NA, hinctnta),
    hincsrca = ifelse(hincsrca %in% c(77, 88, 99), NA, hincsrca),
    gndr = ifelse(gndr %in% c(9), NA, gndr),
    agea = ifelse(agea %in% c(999), NA, agea),
    marsts = ifelse(marsts %in% c(66, 77, 88, 99), NA, marsts),
    domicil = ifelse(domicil %in% c(7, 8, 9), NA, domicil),
    chldhhe = ifelse(chldhhe %in% c(6, 7, 8, 9), NA, chldhhe),
    edulvlb = ifelse(edulvlb %in% c(5555, 7777, 8888, 9999), NA, edulvlb),
    isco08 = ifelse(isco08 %in% c(66666, 77777, 88888, 99999), NA, isco08),
    emplrel = ifelse(emplrel %in% c(6, 7, 8, 9), NA, emplrel),
    nacer2 = ifelse(nacer2 %in% c(66, 77, 88, 99), NA, nacer2),
    tporgwk = ifelse(tporgwk %in% c(66, 77, 88, 99), NA, tporgwk)
  ) %>%
  drop_na() %>%
  

#μετατρέπω σε factor τις κατηγορικές μεταβλητές
  mutate(
    cntry = as_factor(cntry),
    hincsrca = as_factor(hincsrca),
    gndr = as_factor(gndr),
    marsts = as_factor(marsts),
    edulvlb = as_factor(edulvlb), 
    isco08 = as_factor(isco08),
    emplrel = as_factor(emplrel),
    nacer2 = as_factor(nacer2),
    domicil = as_factor(domicil),
    chldhhe = as_factor(chldhhe)
  )
  


#διαχωρισμός των δεδομένων σε χώρες
data_ES <- my_clean_data %>% filter(cntry == "ES")
data_SE <- my_clean_data %>% filter(cntry == "SE")


#περιγραφικές Στατιστικές Εισοδήματος (data_ES)
print("Ισπανία (hinctnta):")
summary(data_ES$hinctnta)

# Περιγραφικές Στατιστικές Εισοδήματος (data_SE)
print("Σουηδία (hinctnta):")
summary(data_SE$hinctnta)

#ελέγχω ποιες είναι οι μοναδικές τιμές της μεταβλητής hinctnta
unique(my_clean_data$hinctnta)

#δημιουργία γραφημάτων
install.packages('ggplot2')
library(ggplot2)
library(tidyverse)

#μετατρoπή της hinctnta σε factor μόνο για το γράφημα
#για να εμφανίζονται σωστά οι μπάρες (αν και είναι αριθμητική στην OLS)
my_clean_data_plot <- my_clean_data %>%
  mutate(hinctnta_factor = as_factor(hinctnta))
  
#δημιουργία Ιστογράμματος (Bar Plot)
ggplot(my_clean_data_plot, aes(x = hinctnta_factor, fill = cntry)) +
  geom_bar(position = "dodge") +
  facet_wrap(~ cntry, scales = "free_y") +
  labs(
    title = "Κατανομή Εισοδηματικού Δείκτη (hinctnta: 1-10) ανά Χώρα",
    x = "Εισοδηματικός Δείκτης (1-10)",
    y = "Πλήθος Παρατηρήσεων"
  ) +
  theme_minimal()

#πλήρης φόρμουλα με hinctnta (ως αριθμητική)
model_formula_full <- hinctnta ~ edulvlb + gndr + agea + Age_Squared + marsts + hincsrca +
  domicil + chldhhe + isco08 + emplrel + nacer2 + tporgwk

#εκτίμηση πλήρων μοντέλων
ols_ES_full <- lm(model_formula_full, data = data_ES)
ols_SE_full <- lm(model_formula_full, data = data_SE)
summary(ols_ES_full)
summary(ols_SE_full)

#έλεγχος πολυσυγραμμικότητας
install.packages("lmtest")
install.packages("car")
library(lmtest)
library(car)
vif(ols_ES_full)
vif(ols_SE_full)

#ελέγχω αν υπάρχουν NA συντελεστές στο μοντέλο ols_ES_full
if (any(is.na(coef(ols_ES_full)))){
  cat("ΠΡΟΒΛΗΜΑ: Το μοντέλο ols_ES_full περιέχει NA συντελεστές. Αυτό υποδηλώνει τέλεια πολυσιγγραμμικότητα (Singularities) και καθιστά αναξιόπιστα τα αποτελέσματα.\n")
} else {
  cat("Το μοντέλο είναι στατιστικά σταθερό (δεν έχει NA συντελεστές).\n")
}

#αφαίρεση isco08, nacer2, emplrel, tporgwk λόγω VIF
model_formula_reduced <- hinctnta ~ edulvlb + gndr + agea + Age_Squared + marsts + hincsrca +
  domicil + chldhhe

#εκτίμηση του μειωμένου μοντέλου
ols_ES_reduced <- lm(model_formula_reduced, data = data_ES)
ols_SE_reduced <- lm(model_formula_reduced, data = data_SE)
summary(ols_ES_reduced)
summary(ols_SE_reduced)

#έλεγχος VIF στο μειωμένο μοντέλο 
print("VIF Ισπανίας (Μειωμένο Μοντέλο):")
vif(ols_ES_reduced)

print("VIF Σουηδίας (Μειωμένο Μοντέλο):")
vif(ols_SE_reduced)


#έλεγχος ετεροσκεδαστικότητας 
bptest(ols_ES_reduced)
bptest(ols_SE_reduced)

#τα standard errors του μοντέλου της Ισπανίας δεν είναι αξιόπιστα και πρέπει να διορθωθούν
install.packages('sandwich')
library(sandwich)
library(lmtest)

robust_vce_ES <- vcovHC(ols_ES_reduced, type = "HC1")
print("Robust Standard Errors για την Ισπανία:")
coeftest(ols_ES_reduced, vcov = robust_vce_ES)

#διορθώνω και της Σουηδίας για σιγουριά
robust_vce_SE <- vcovHC(ols_SE_reduced, type = "HC1")
print("Robust Standard Errors για τη Σουηδία:")
coeftest(ols_SE_reduced, vcov = robust_vce_SE)

#έλεγχος κανονικότητας καταλείπων
install.packages('tseries')
library(tseries)
jarque.bera.test(ols_ES_reduced$residuals)
jarque.bera.test(ols_SE_reduced$residuals)
 
#έλεγχος αυτοσυσχέτισης
dwtest(ols_ES_reduced)
dwtest(ols_SE_reduced)

#Ramsey Reset
resettest(ols_ES_reduced)
resettest(ols_SE_reduced)


#σύγριση
install.packages('stargazer')
library(stargazer)
stargazer(ols_ES_reduced, ols_SE_reduced, 
          type = "text",
          title = "Σύγκριση Μοντέλων OLS (Ισπανία vs Σουηδία) - Robust SEs",
          dep.var.labels = c("Εισοδηματικός Δείκτης (hinctnta)"),
          se = list(sqrt(diag(robust_vce_ES)), sqrt(diag(robust_vce_SE))), # Χρησιμοποιεί τα Robust SEs
          notes = "Το μοντέλο είναι μειωμένο για την αντιμετώπιση της πολυσιγγραμμικότητας. Χρησιμοποιούνται Robust Standard Errors (HC1) λόγω ετεροσκεδαστικότητας.",
          omit.stat = c("f", "ser"),
          star.cutoffs = c(0.05, 0.01, 0.001), 
          header = FALSE
)

#διαγραμματική απεικόνιση των αποτελεσμάτων
library(ggplot2)
install.packages('dplyr')
library(dplyr)

#ΕΚΠΑΙΔΕΥΣΗ

#dεδομένα Ισπανίας (xρησιμοποιούνται μόνο οι σημαντικές κατηγορίες εκπαίδευσης για απλότητα)
#(Ref: edulvlb100 = ISCED 0, Estimate = 0, SE = 0)
data_ES_edu <- data.frame(
  Category = c("ISCED 0 (Ref)", "113", "129", "213", "222", "311", "313", "322", "421", "520", "620", "720", "800"),
  Estimate = c(0, 0.385, 0.569, 1.102, 1.045, 1.321, 1.365, 1.667, 1.074, 1.733, 3.393, 3.123, 3.771),
  SE = c(0, 0.526, 1.100, 0.537, 0.713, 0.695, 0.625, 0.653, 0.654, 0.683, 0.577, 0.584, 1.287)
)

#υπολογισμός 95% Διαστημάτων Εμπιστοσύνης (Confidence Intervals)
#CI = Estimate ± 1.96 * SE
data_ES_edu <- data_ES_edu %>%
  mutate(
    Lower_CI = Estimate - 1.96 * SE,
    Upper_CI = Estimate + 1.96 * SE,
    Significant = ifelse(Lower_CI > 0 | Upper_CI < 0, "Significant", "Not Significant")
  )

#δημιουργία διαγράμματος
ggplot(data_ES_edu, aes(x = Estimate, y = reorder(Category, Estimate), color = Significant)) +
  geom_point(size = 3) +
  geom_errorbarh(aes(xmin = Lower_CI, xmax = Upper_CI), height = 0.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "🇪🇸 Ισπανία: Επίδραση Εκπαίδευσης στον Εισοδηματικό Δείκτη",
    x = "Επίδραση Συντελεστή (Ref: ISCED 0)",
    y = "Επίπεδο Εκπαίδευσης (edulvlb)",
    color = "Στατιστική Σημαντικότητα"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#δεδομένα Σουηδίας
data_SE_edu <- data.frame(
  Category = c("ISCED 0 (Ref)", "113", "213", "313", "321", "323", "413", "423", "520", "610", "620", "710", "720", "800"),
  Estimate = c(0, 0.749, 1.563, 1.248, 1.053, 0.771, 1.299, 1.028, 1.575, 2.091, 2.300, 2.509, 3.073, 3.634),
  SE = c(0, 0.608, 0.572, 0.632, 0.626, 0.650, 0.644, 0.595, 0.613, 0.673, 0.660, 0.746, 0.744, 1.115)
)

#υπολογισμός 95% Διαστημάτων Εμπιστοσύνης (Confidence Intervals)
data_SE_edu <- data_SE_edu %>%
  mutate(
    Lower_CI = Estimate - 1.96 * SE,
    Upper_CI = Estimate + 1.96 * SE,
    Significant = ifelse(Lower_CI > 0 | Upper_CI < 0, "Significant", "Not Significant")
  )

#δημιουργία διαγράμματος Σουηδίας
ggplot(data_SE_edu, aes(x = Estimate, y = reorder(Category, Estimate), color = Significant)) +
  geom_point(size = 3) +
  geom_errorbarh(aes(xmin = Lower_CI, xmax = Upper_CI), height = 0.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "🇸🇪 Σουηδία: Επίδραση Εκπαίδευσης στον Εισοδηματικό Δείκτη",
    x = "Επίδραση Συντελεστή (Ref: ISCED 0)",
    y = "Επίπεδο Εκπαίδευσης (edulvlb)",
    color = "Στατιστική Σημαντικότητα"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#Φύλο & Οικ. Κατάσταση

#συλλογή δεδομένων (από πίνακα stargazer)
#(Ref: gndr1 = Άνδρας, marsts1 = Παντρεμένος)
data_gndr_marsts <- data.frame(
  Country = rep(c("Ισπανία (1)", "Σουηδία (2)"), each = 6),
  Variable = rep(c("Γυναίκα (gndr2)", 
                   "marsts2 (Δεσμευμένος/η)", 
                   "marsts4 (Διαζευγμένος/η)", 
                   "marsts5 (Χωρισμένος/η)", 
                   "marsts6 (Χήρος/α)",
                   "marsts3 (Ελεύθερος/η)" # Χρησιμοποιούμε την marsts3 για την Ισπανία
  ), 2),
  Estimate = c(
    #Ισπανία (1)
    -0.525, NA, -0.653, -0.868, -0.877, -0.695, 
    #Σουηδία (2)
    -0.473, 1.007, -0.905, -1.808, -0.383, NA 
  ),
  SE = c(
    #Ισπανία (1)
    0.235, NA, 0.634, 0.635, 0.648, 0.796, 
    #Σουηδία (2)
    0.230, 0.758, 0.732, 0.743, 0.723, NA
  )
)

#διόρθωση: Σουηδία marsts3/Ισπανία marsts2 απουσιάζουν
#(σημείωση: στον πίνακα stargazer: Ισπανία έχει marsts3, Σουηδία έχει marsts2. 
#θα χρησιμοποιήσουμε τις κοινές, σημαντικές κατηγορίες για απλότητα)

data_gndr_marsts_clean <- data.frame(
  Country = rep(c("Ισπανία", "Σουηδία"), each = 5),
  Variable = rep(c("Γυναίκα (gndr2)", 
                   "Διαζευγμένος/η (marsts4)", 
                   "Χωρισμένος/η (marsts5)", 
                   "Χήρος/α (marsts6)",
                   "Ελεύθερος/η (marsts3)"
  ), 2),
  Estimate = c(
    #Ισπανία (1)
    -0.525, -0.653, -0.868, -0.877, -0.695, 
    #Σουηδία (2)
    -0.473, -0.905, -1.808, -0.383, 1.007 # marsts2 στη Σουηδία, το χρησιμοποιούμε ως marsts3 (Ελεύθερος/η) για σύγκριση
  ),
  SE = c(
    #Ισπανία (1)
    0.235, 0.634, 0.635, 0.648, 0.796, 
    #Σουηδία (2)
    0.230, 0.732, 0.743, 0.723, 0.758
  ),
  Significant = c(
    #Ισπανία (1)
    TRUE, FALSE, FALSE, FALSE, FALSE,
    #Σουηδία (2)
    TRUE, FALSE, TRUE, FALSE, FALSE
  )
)

#υπολογισμός 95% Διαστημάτων Εμπιστοσύνης (Confidence Intervals)
data_gndr_marsts_clean <- data_gndr_marsts_clean %>%
  mutate(
    Lower_CI = Estimate - 1.96 * SE,
    Upper_CI = Estimate + 1.96 * SE,
    CI_Crosses_Zero = Lower_CI < 0 & Upper_CI > 0 # Ελέγχει αν το CI διασχίζει το μηδέν (Μη Σημαντικό)
  ) %>%
  #προσθήκη σήμανσης για μη σημαντικές τιμές
  mutate(
    Label = ifelse(Significant, paste0(round(Estimate, 3), "*"), round(Estimate, 3))
  )

#σχεδίαση
ggplot(data_gndr_marsts_clean, aes(x = Variable, y = Estimate, fill = Country)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9), color = "black") +
  
  #προσθήκη Διαστημάτων Εμπιστοσύνης (Error bars)
  geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), 
                position = position_dodge(width = 0.9), 
                width = 0.25) +
  
  #προσθήκη γραμμής μηδέν για αναφορά
  geom_hline(yintercept = 0, linetype = "dashed", color = "red", size = 1) +
  
  #Labels
  labs(
    title = "Συγκριτική Επίδραση Φύλου & Οικογενειακής Κατάστασης στον Εισοδηματικό Δείκτη",
    subtitle = "Βάση: Άνδρας & Παντρεμένος. Οι στήλες δείχνουν τον συντελεστή β. Οι γραμμές είναι 95% CI (Robust SEs).",
    x = "Μεταβλητή (Ομάδα Αναφοράς: Άνδρας / Παντρεμένος)",
    y = "Επίδραση στον Εισοδηματικό Δείκτη (log)",
    fill = "Χώρα"
  ) +
  
  #εμφάνιση των τιμών (Labels)
  geom_text(aes(label = Label, y = ifelse(Estimate > 0, Upper_CI + 0.1, Lower_CI - 0.1)),
            position = position_dodge(width = 0.9),
            vjust = ifelse(data_gndr_marsts_clean$Estimate > 0, -0.5, 1.5),
            size = 3) +
  
  scale_fill_manual(values = c("Ισπανία" = "#FF7F50", "Σουηδία" = "#4682B4")) + # Ωραία χρώματα
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 15, hjust = 1)
  )

#συγκριτικό διάγραμμα επίδρασης ηλικίας (Age Plot)

#δημιουργία δεδομένων για πρόβλεψη
age_range <- 18:85
predict_data <- data.frame(
  agea = age_range,
  Age_Squared = age_range^2,
  
  #κρατάμε τις άλλες μεταβλητές στην ομάδα αναφοράς για πρόβλεψη:
  # Reference: gndr1 (Άνδρας), marsts1 (Παντρεμένος), edulvlb100 (ISCED 0), κ.λπ.
  gndr = factor(1, levels = levels(data_ES$gndr)),
  marsts = factor(1, levels = levels(data_ES$marsts)),
  edulvlb = factor(1, levels = levels(data_ES$edulvlb)),
  hincsrca = factor(1, levels = levels(data_ES$hincsrca)),
  domicil = factor(1, levels = levels(data_ES$domicil)),
  chldhhe = factor(1, levels = levels(data_ES$chldhhe))
)

#πρόβλεψη για Ισπανία
predict_data$hinctnta_ES <- predict(ols_ES_reduced, newdata = predict_data)

#πρόβλεψη για Σουηδία
predict_data$hinctnta_SE <- predict(ols_SE_reduced, newdata = predict_data)

#μετασχηματισμός για ggplot
plot_data_age <- predict_data %>%
  tidyr::pivot_longer(
    cols = starts_with("hinctnta"),
    names_to = "Country",
    values_to = "Predicted_hinctnta"
  ) %>%
  mutate(
    Country = ifelse(Country == "hinctnta_ES", "Ισπανία", "Σουηδία")
  )

#σχεδίαση
ggplot(plot_data_age, aes(x = agea, y = Predicted_hinctnta, color = Country)) +
  geom_line(size = 1.2) +
  labs(
    title = "Συγκριτική Επίδραση της Ηλικίας στον Εισοδηματικό Δείκτη",
    subtitle = "Όλες οι άλλες μεταβλητές σταθερές στην ομάδα αναφοράς (Άνδρας, Παντρεμένος, ISCED 0).",
    x = "Ηλικία (agea)",
    y = "Προβλεπόμενος Εισοδηματικός Δείκτης (hinctnta)",
    color = "Χώρα"
  ) +
  scale_color_manual(values = c("Ισπανία" = "#FF7F50", "Σουηδία" = "#4682B4")) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#διαγράμματα κατανομής καταλοίπων 
#Ισπανία: Histogram Καταλοίπων
hist(ols_ES_reduced$residuals, 
     main = "🇪🇸 Ισπανία: Κατανομή Καταλοίπων (OLS)",
     xlab = "Κατάλοιπα",
     col = "lightblue", 
     border = "black")

#Σουηδία: Histogram Καταλοίπων
hist(ols_SE_reduced$residuals, 
     main = "🇸🇪 Σουηδία: Κατανομή Καταλοίπων (OLS)",
     xlab = "Κατάλοιπα",
     col = "lightgreen", 
     border = "black")

#διαγράμματα ετεροσκεδαστικότητας
#Ισπανία: Residuals vs Fitted
plot(ols_ES_reduced$fitted.values, ols_ES_reduced$residuals,
     main = "🇪🇸 Ισπανία: Κατάλοιπα vs Προβλεπόμενες Τιμές",
     xlab = "Προβλεπόμενες Τιμές (Fitted)",
     ylab = "Κατάλοιπα (Residuals)")
abline(h = 0, col = "red")

#Σουηδία: Residuals vs Fitted
plot(ols_SE_reduced$fitted.values, ols_SE_reduced$residuals,
     main = "🇸🇪 Σουηδία: Κατάλοιπα vs Προβλεπόμενες Τιμές",
     xlab = "Προβλεπόμενες Τιμές (Fitted)",
     ylab = "Κατάλοιπα (Residuals)")
abline(h = 0, col = "red")



