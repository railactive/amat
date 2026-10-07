# amat: Active Mode Appraisal Toolkit in R

A fast, lightweight, pure base-R implementation of the UK Department for Transport (DfT) **Active Mode Appraisal Toolkit (AMAT)** following Transport Analysis Guidance (TAG).

## Key Features

- **Pure Base R**: Zero external runtime dependencies. Runs immediately on any standard R installation.

- **Exact Numerical Match**: Validated against the latest official DfT AMAT spreadsheet release (May 2026 TAG release / 2023 price base) with 100% agreement down to floating-point precision on all appraisal metrics.

- **Full TAG Benefit Coverage**:

  - Decongestion & Traffic Externalities (Congestion, Infrastructure maintenance, Accidents, Air Quality, Noise, Greenhouse Gases, Indirect Taxation)

  - Health & Mortality (Relative risk, MET hours, preventable deaths, discounted Years of Life Lost [YLL])

  - Workplace Absenteeism (Short-term sickness absence reduction valued at labour market output)

  - Journey Ambience & Quality (Rule of a half, amenity valuation for segregated infrastructure)

  - Capital & Operating Cost discounting (Optimism bias, GDP deflator re-basing, 3.5%/1.5% social discounting)

- **Vectorised & Scriptable**: Appraise thousands of corridor interventions or network links in milliseconds—ideal for automated pipelines (e.g. `targets`) and spatial active travel models (e.g. PCT).

## Installation

Install the package directly from GitHub:

```r
# install.packages("remotes")
remotes::install_github("railactive/amat")
```

## Quick Start

Run an appraisal using default parameters from the official DfT AMAT user guidance worked example (Clifton Road Active Mode Corridor):

```r
library(amat)

res <- amat_run()

print(res$summary)
#>         PVB         PVC         NPV         BCR 
#> 1611.403662  567.361968 1044.041694    2.840169

print(res$results)
#>                               Category        Value
#> 1                  Economy: Congestion   78.5067215
#> 2  Economy: Infrastructure maintenance    0.3883051
#> 3                   Economy: Accidents    8.2848838
#> 4             Environment: Air Quality    0.4374432
#> 5                   Environment: Noise    0.5336334
#> 6        Environment: Greenhouse Gases    6.6647745
#> 7           Economy: Indirect Taxation    0.2107613
#> 8                 Economy: Absenteeism  132.6750340
#> 9                     Journey Ambience  739.0628653
#> 10             Health: Premature Death  645.0275454
#> 11             Costs: Investment (PVC)  540.7532193
#> 12              Costs: Operating (PVC)   26.9970543
#> 13     Present Value of Benefits (PVB) 1611.4036625
#> 14        Present Value of Costs (PVC)  567.3619685
#> 15             Net Present Value (NPV) 1044.0416940
#> 16            Benefit-Cost Ratio (BCR)    2.8401686
```

## Golden File Validation

This implementation is continuously verified against golden benchmarks extracted from official DfT spreadsheets:

```r
source("tests/test_golden.R")
#> All golden benchmark tests passed successfully!
```

| Metric | Official AMAT Excel | `amat::amat_run()` | Absolute Difference |
| :--- | :--- | :--- | :--- |
| **Congestion** | £78,506.72 | £78,506.72 | £0.00 |
| **Infrastructure Maintenance** | £388.31 | £388.31 | £0.00 |
| **Accidents** | £8,284.88 | £8,284.88 | £0.00 |
| **Air Quality** | £437.44 | £437.44 | £0.00 |
| **Noise** | £533.63 | £533.63 | £0.00 |
| **Greenhouse Gases** | £6,664.77 | £6,664.77 | £0.00 |
| **Indirect Taxation** | £210.76 | £210.76 | £0.00 |
| **Absenteeism** | £132,675.03 | £132,675.03 | £0.00 |
| **Journey Ambience** | £739,062.87 | £739,062.87 | £0.00 |
| **Premature Death** | £645,027.55 | £645,027.55 | £0.00 |
| **Investment Costs (PVC)** | £540,753.22 | £540,753.22 | £0.00 |
| **Operating Costs (PVC)** | £26,997.05 | £26,997.05 | £0.00 |
| **Present Value of Benefits (PVB)** | £1,611,403.66 | £1,611,403.66 | £0.00 |
| **Present Value of Costs (PVC)** | £567,361.97 | £567,361.97 | £0.00 |
| **Benefit Cost Ratio (BCR)** | **2.840169** | **2.840169** | **0.00** |

## License

MIT License. Developed as part of the `railactive` active travel research initiative.
