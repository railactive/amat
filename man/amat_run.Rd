\name{amat_run}
\alias{amat_run}
\title{Run Active Mode Appraisal Toolkit Analysis}
\usage{
amat_run(
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
)
}
\arguments{
\item{cycle_trips_without}{Number of daily cycling trips without scheme.}
\item{cycle_trips_with}{Number of daily cycling trips with scheme.}
\item{cycle_trip_km}{Average cycling trip length in kilometres.}
\item{cycle_prop_on_scheme}{Proportion of cycling trip using the scheme.}
\item{cycle_current_infra}{Current cycling infrastructure provision.}
\item{cycle_proposed_infra}{Proposed cycling infrastructure provision.}
\item{walk_trips_without}{Number of daily walking trips without scheme.}
\item{walk_trips_with}{Number of daily walking trips with scheme.}
\item{walk_trip_km}{Average walking trip length in kilometres.}
\item{walk_prop_on_scheme}{Proportion of walking trip using the scheme.}
\item{walk_current_infra}{Current walking infrastructure elements.}
\item{walk_proposed_infra}{Proposed walking infrastructure elements.}
\item{appraisal_year}{Appraisal base year.}
\item{opening_year}{Scheme opening year.}
\item{appraisal_period}{Appraisal period in years (e.g. 20).}
\item{annual_days}{Annualisation days factor (e.g. 253 for weekdays).}
\item{user_growth}{Annual user growth rate.}
\item{growth_yrs}{Number of years demand growth applies.}
\item{invest_costs}{Named list of investment capital costs by year in thousands GBP.}
\item{oper_costs}{Named list of operating costs by year in thousands GBP.}
\item{optimism_bias}{Optimism bias uplift rate (e.g. 0.23).}
\item{car_divert}{Proportion of trips diverted from private car.}
\item{car_occ}{Average car occupancy rate.}
\item{taxi_divert}{Proportion of trips diverted from taxi/other.}
\item{taxi_occ}{Average taxi occupancy rate.}
\item{prop_employed}{Proportion of users in employment.}
\item{return_prop}{Proportion of return trips.}
\item{cycle_speed_kmh}{Average cycling speed in km/h.}
\item{walk_speed_kmh}{Average walking speed in km/h.}
}
\value{
A list containing:
\item{summary}{Named vector with PVB, PVC, NPV, and BCR.}
\item{results}{Data frame with itemised economic appraisal categories.}
}
\description{
Appraises active travel schemes following the UK Department for Transport
Active Mode Appraisal Toolkit (AMAT) and Transport Analysis Guidance (TAG).
}
\examples{
res <- amat_run()
res$summary
}
