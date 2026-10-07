amat_run <- function(
  cycle_trips_without = 200,
  cycle_trips_with = 260,
  cycle_trip_km = 5.71,
  cycle_prop_on_scheme = 0.2066,
  cycle_current_infra = "No provision",
  cycle_proposed_infra = "Off-road segregated cycle track",
  walk_trips_without = 0,
  walk_trips_with = 0,
  walk_trip_km = 1.18,
  walk_prop_on_scheme = 1.0,
  walk_current_infra = character(0),
  walk_proposed_infra = character(0),
  appraisal_year = 2025,
  opening_year = 2026,
  appraisal_period = 20,
  annual_days = 253,
  user_growth = 0.0075,
  growth_yrs = 20,
  invest_costs = list("2023" = 100, "2024" = 150, "2025" = 150),
  oper_costs = list("2026" = 10, "2031" = 10, "2036" = 10, "2041" = 10),
  optimism_bias = 0.23,
  car_divert = 0.24,
  car_occ = 1.60,
  taxi_divert = 0.06,
  taxi_occ = 2.40,
  prop_employed = 0.564,
  return_prop = 0.9,
  cycle_speed_kmh = 15,
  walk_speed_kmh = 5
) {
  appraisal_years <- opening_year:(opening_year + appraisal_period - 1)
  cost_years <- as.integer(c(names(invest_costs), names(oper_costs)))
  all_years <- sort(unique(c(cost_years, appraisal_years)))
  in_appraisal <- all_years %in% appraisal_years

  disc_nonhealth <- sapply(all_years, function(y) {
    1 / ((1.035^max(0, min(y, appraisal_year) - 2023)) * (1.035^max(0, y - appraisal_year)))
  })
  disc_health <- sapply(all_years, function(y) {
    1 / ((1.035^max(0, min(y, appraisal_year) - 2023)) * (1.015^max(0, y - appraisal_year)))
  })

  growth_mult <- sapply(all_years, function(y) {
    if (y <= opening_year) 1
    else (1 + user_growth)^min(y - opening_year, growth_yrs)
  })

  gdp_idx_2023 <- tag_growth$real_gdp_idx[tag_growth$year == 2023]
  real_gdp_mult <- sapply(all_years, function(y) {
    val <- tag_growth$real_gdp_idx[tag_growth$year == y]
    if (length(val) == 1 && !is.na(val)) val / gdp_idx_2023 else 1
  })

  veh_shift <- (car_divert / car_occ) + (taxi_divert / taxi_occ)
  c_new_trips <- max(0, cycle_trips_with - cycle_trips_without)
  w_new_trips <- max(0, walk_trips_with - walk_trips_without)
  c_veh_km_k <- (c_new_trips * cycle_trip_km * annual_days * veh_shift) / 1000
  w_veh_km_k <- (w_new_trips * walk_trip_km * annual_days * veh_shift) / 1000
  tot_veh_km_k <- c_veh_km_k + w_veh_km_k

  m_ext <- tag_decongestion[match(all_years, tag_decongestion$year), ]
  m_ext[is.na(m_ext)] <- 0

  congest_pv <- sum(tot_veh_km_k * m_ext$congestion / 100 * disc_nonhealth * in_appraisal * growth_mult)
  infra_pv <- sum(tot_veh_km_k * m_ext$infrastructure / 100 * disc_nonhealth * in_appraisal * growth_mult)
  accident_pv <- sum(tot_veh_km_k * m_ext$accident / 100 * disc_nonhealth * in_appraisal * growth_mult)
  air_pv <- sum(tot_veh_km_k * m_ext$air_quality / 100 * disc_nonhealth * in_appraisal * growth_mult)
  noise_pv <- sum(tot_veh_km_k * m_ext$noise / 100 * disc_nonhealth * in_appraisal * growth_mult)
  ghg_pv <- sum(tot_veh_km_k * m_ext$greenhouse_gases / 100 * disc_nonhealth * in_appraisal * growth_mult)
  ind_tax_pv <- sum(tot_veh_km_k * m_ext$indirect_tax / 100 * disc_nonhealth * in_appraisal * growth_mult)

  c_new_users <- c_new_trips / (1 + return_prop)
  c_trip_dur <- 60 * (1 + return_prop) * cycle_trip_km / cycle_speed_kmh
  c_pa_days <- c_trip_dur * annual_days / (30 * (5/7) * 365)
  c_absent_days <- health_params$absenteeism_reduction * c_pa_days * health_params$sickness_days_per_year * prop_employed
  c_annual_absent <- (c_absent_days * c_new_users) * (health_params$value_working_hour * health_params$hours_per_day)

  w_new_users <- w_new_trips / (1 + return_prop)
  w_trip_dur <- 60 * (1 + return_prop) * walk_trip_km / walk_speed_kmh
  w_pa_days <- w_trip_dur * annual_days / (30 * (5/7) * 365)
  w_absent_days <- health_params$absenteeism_reduction * w_pa_days * health_params$sickness_days_per_year * prop_employed
  w_annual_absent <- (w_absent_days * w_new_users) * (health_params$value_working_hour * health_params$hours_per_day)

  tot_annual_absent <- c_annual_absent + w_annual_absent
  absent_pv <- sum((tot_annual_absent / 1000) * disc_nonhealth * in_appraisal * growth_mult * real_gdp_mult)

  c_rate_diff <- if (cycle_proposed_infra %in% names(cycle_ambience_rates) && cycle_current_infra %in% names(cycle_ambience_rates)) {
    cycle_ambience_rates[[cycle_proposed_infra]] - cycle_ambience_rates[[cycle_current_infra]]
  } else 0
  c_time_scheme <- 60 * (cycle_trip_km * cycle_prop_on_scheme) / cycle_speed_kmh
  c_amb_per_user <- (c_rate_diff / 100) * (c_time_scheme * annual_days)
  c_annual_amb <- cycle_trips_without * c_amb_per_user + (c_new_trips * c_amb_per_user) / 2

  w_rate_diff <- sum(walk_ambience_rates[walk_proposed_infra], na.rm = TRUE) - sum(walk_ambience_rates[walk_current_infra], na.rm = TRUE)
  w_time_scheme <- 60 * (walk_trip_km * walk_prop_on_scheme) / walk_speed_kmh
  w_amb_per_user <- (w_rate_diff / 100) * (w_time_scheme * annual_days)
  w_annual_amb <- walk_trips_without * w_amb_per_user + (w_new_trips * w_amb_per_user) / 2

  tot_annual_amb <- c_annual_amb + w_annual_amb
  ambience_pv <- sum((tot_annual_amb / 1000) * disc_nonhealth * in_appraisal * growth_mult * real_gdp_mult)

  return_factor <- (1 - return_prop) + (return_prop * 2)
  days_scale <- 7 * annual_days / 365

  c_yll <- 0
  if (c_new_users > 0) {
    c_u_m <- c_new_users * health_params$cycle_split_m
    c_u_f <- c_new_users * health_params$cycle_split_f
    c_scale <- cycle_trip_km / 5.71
    c_km_m <- return_factor * (health_params$cycle_dist_m * c_scale) * days_scale
    c_km_f <- return_factor * (health_params$cycle_dist_f * c_scale) * days_scale
    c_met_m <- 6.8 * (c_km_m / health_params$cycle_speed_m)
    c_met_f <- 6.8 * (c_km_f / health_params$cycle_speed_f)
    c_rr_m <- pmax(0.55, exp(log(0.90) / 11.25 * c_met_m))
    c_rr_f <- pmax(0.55, exp(log(0.90) / 11.25 * c_met_f))
    c_d_m <- c(0, (1 - c_rr_m)[2:5] * health_params$mortality_m[2:5] * c_u_m[2:5])
    c_d_f <- c(0, (1 - c_rr_f)[2:5] * health_params$mortality_f[2:5] * c_u_f[2:5])
    c_yll <- sum(c_d_m * health_params$yll_discounted_m) + sum(c_d_f * health_params$yll_discounted_f)
  }

  w_yll <- 0
  if (w_new_users > 0) {
    w_u_m <- w_new_users * health_params$walk_split_m
    w_u_f <- w_new_users * health_params$walk_split_f
    w_scale <- walk_trip_km / 1.18
    w_km_m <- return_factor * (health_params$walk_dist_m * w_scale) * days_scale
    w_km_f <- return_factor * (health_params$walk_dist_f * w_scale) * days_scale
    w_met_m <- 3.3 * (w_km_m / health_params$walk_speed_m)
    w_met_f <- 3.3 * (w_km_f / health_params$walk_speed_f)
    w_rr_m <- pmax(0.70, exp(log(0.90) / 11.25 * w_met_m))
    w_rr_f <- pmax(0.70, exp(log(0.90) / 11.25 * w_met_f))
    w_d_m <- c(0, (1 - w_rr_m)[2:5] * health_params$mortality_m[2:5] * w_u_m[2:5])
    w_d_f <- c(0, (1 - w_rr_f)[2:5] * health_params$mortality_f[2:5] * w_u_f[2:5])
    w_yll <- sum(w_d_m * health_params$yll_discounted_m) + sum(w_d_f * health_params$yll_discounted_f)
  }

  tot_yll <- c_yll + w_yll
  health_lag <- sapply(all_years, function(y) {
    if (y < opening_year) 0
    else min(1.0, (y - opening_year + 1) * 0.2)
  })
  death_pv <- sum((health_params$vol * tot_yll / 1000) * disc_health * in_appraisal * growth_mult * health_lag)

  deflator_mult <- sapply(all_years, function(y) {
    tag_growth$gdp_deflator[tag_growth$year == y] / 100
  })
  inv_vec <- sapply(all_years, function(y) {
    val <- invest_costs[[as.character(y)]]
    if (is.null(val)) 0 else val
  })
  op_vec <- sapply(all_years, function(y) {
    val <- oper_costs[[as.character(y)]]
    if (is.null(val)) 0 else val
  })

  invest_pv <- sum(inv_vec * (1 + optimism_bias) * (health_params$market_price_conversion / deflator_mult) * disc_nonhealth)
  oper_pv <- sum(op_vec * (health_params$market_price_conversion / deflator_mult) * disc_nonhealth)

  pvb <- congest_pv + accident_pv + air_pv + noise_pv + ghg_pv + ind_tax_pv + absent_pv + ambience_pv + death_pv
  pvc <- (invest_pv + oper_pv) - infra_pv
  bcr <- pvb / pvc
  npv <- pvb - pvc

  res_table <- data.frame(
    Category = c(
      "Economy: Congestion",
      "Economy: Infrastructure maintenance",
      "Economy: Accidents",
      "Environment: Air Quality",
      "Environment: Noise",
      "Environment: Greenhouse Gases",
      "Economy: Indirect Taxation",
      "Economy: Absenteeism",
      "Journey Ambience",
      "Health: Premature Death",
      "Costs: Investment (PVC)",
      "Costs: Operating (PVC)",
      "Present Value of Benefits (PVB)",
      "Present Value of Costs (PVC)",
      "Net Present Value (NPV)",
      "Benefit-Cost Ratio (BCR)"
    ),
    Value = c(
      congest_pv, infra_pv, accident_pv, air_pv, noise_pv, ghg_pv,
      ind_tax_pv, absent_pv, ambience_pv, death_pv,
      invest_pv, oper_pv, pvb, pvc, npv, bcr
    ),
    stringsAsFactors = FALSE
  )

  list(
    summary = c(PVB = pvb, PVC = pvc, NPV = npv, BCR = bcr),
    results = res_table
  )
}
