library(readxl)
file <- "amat/inst/extdata/tag-active-mode-appraisal-toolkit.xlsx"

# 1. TAG Growth
tg <- as.data.frame(read_excel(file, sheet = "TAG Growth", col_names = FALSE))
years_idx <- which(!is.na(as.numeric(tg[, 2])))
years <- as.numeric(tg[years_idx, 2])
gdp_deflator <- as.numeric(tg[years_idx, 4])
real_gdp_idx <- as.numeric(tg[years_idx, 26])

tag_growth <- data.frame(
  year = years,
  gdp_deflator = gdp_deflator,
  real_gdp_idx = real_gdp_idx
)

tag_decongestion <- readRDS("amat/inst/extdata/mecc2.rds")

# 3. TAG Journey Quality
cycle_ambience_rates <- c(
  "No provision" = 0.0,
  "Off-road segregated cycle track" = 16.277973176395562,
  "On-road segregated cycle lane" = 5.7100743603062964,
  "On-road non-segregated cycle lane" = 5.2161504611786578,
  "Wider lane" = 3.4658162783948669,
  "Shared bus lane" = 1.278374856784992
)

cycle_facility_rates <- c(
  "secure_parking" = 168.49438221426865,
  "showers" = 36.691165683022561
)

walk_ambience_rates <- c(
  "street_lighting" = 5.8458307715305278,
  "kerb_level" = 4.1264687799039015,
  "crowding" = 2.9229153857652639,
  "pavement_evenness" = 1.3754895933013007,
  "information_panels" = 1.3754895933013007,
  "benches" = 0.8596809958133127,
  "directional_signage" = 0.8596809958133127
)

# 4. Health Parameters
health_params <- list(
  vol = 92239.543518324514,
  value_working_hour = 30.029348451816388,
  hours_per_day = 7.5,
  sickness_days_per_year = 5.7,
  absenteeism_reduction = 0.25,
  std_dose_met_hr = 11.25,
  rr_standard_cycle = 0.90,
  rr_standard_walk = 0.89,
  max_risk_reduction = 0.70,
  market_price_conversion = 1.19,
  
  # Demographics and mortality
  cycle_age_groups = c("0-19", "20-49", "50-64", "65-80", "80+"),
  cycle_split_m = c(0.16, 0.39, 0.13, 0.05, 0.01),
  cycle_split_f = c(0.04, 0.16, 0.05, 0.01, 0.00),
  cycle_dist_m = c(1.81, 3.73, 3.92, 2.79, 2.04),
  cycle_dist_f = c(1.55, 2.49, 2.33, 1.71, 1.05),
  cycle_speed_m = c(6.12, 9.12, 8.91, 7.48, 7.99),
  cycle_speed_f = c(4.45, 7.22, 7.07, 5.99, 4.20),
  
  walk_split_m = c(0.15, 0.17, 0.07, 0.05, 0.01),
  walk_split_f = c(0.15, 0.24, 0.09, 0.05, 0.01),
  walk_dist_m = c(0.68, 0.74, 0.76, 0.73, 0.60),
  walk_dist_f = c(0.64, 0.67, 0.73, 0.68, 0.53),
  walk_speed_m = c(2.55, 2.74, 2.62, 2.49, 2.11),
  walk_speed_f = c(2.53, 2.60, 2.49, 2.35, 2.04),
  
  mortality_m = c(3.26719793573801e-04, 1.18802544579716e-03, 5.4048770870311e-03, 2.16505693753428e-02, 9.76699901821435e-02),
  mortality_f = c(2.77983089032082e-04, 6.86176550262084e-04, 3.55289367666657e-03, 1.49402549806851e-02, 9.60256139749733e-02),
  
  yll_discounted_m = c(52.3723376463229, 36.4225498067379, 25.6879417195815, 16.6725608923611, 9.36051732013226),
  yll_discounted_f = c(52.6960369314373, 35.8889225377148, 25.6879417195815, 16.6725608923611, 9.36051732013226)
)

dir.create("amat/R", showWarnings = FALSE)
save(tag_growth, tag_decongestion, cycle_ambience_rates, cycle_facility_rates, 
     walk_ambience_rates, health_params, file = "amat/R/sysdata.rda")
cat("Successfully built and saved amat/R/sysdata.rda\n")
