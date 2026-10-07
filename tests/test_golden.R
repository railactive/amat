library(amat)

gold_path <- system.file("extdata", "golden_clifton.rds", package = "amat")
if (!nzchar(gold_path)) {
  gold_path <- "inst/extdata/golden_clifton.rds"
}
gold <- readRDS(gold_path)

res <- amat_run()

tol <- 1e-4

stopifnot(abs(res$summary["BCR"] - gold$bcr) < tol)
stopifnot(abs(res$summary["PVB"] - gold$pvb) < tol)
stopifnot(abs(res$summary["PVC"] - gold$pvc) < tol)

vals <- setNames(res$results$Value, res$results$Category)

stopifnot(abs(vals["Economy: Congestion"] - gold$congestion) < tol)
stopifnot(abs(vals["Economy: Infrastructure maintenance"] - gold$infra_maint) < tol)
stopifnot(abs(vals["Economy: Accidents"] - gold$accident) < tol)
stopifnot(abs(vals["Environment: Air Quality"] - gold$air_quality) < tol)
stopifnot(abs(vals["Environment: Noise"] - gold$noise) < tol)
stopifnot(abs(vals["Environment: Greenhouse Gases"] - gold$greenhouse_gas) < tol)
stopifnot(abs(vals["Economy: Indirect Taxation"] - gold$indirect_tax) < tol)
stopifnot(abs(vals["Economy: Absenteeism"] - gold$absenteeism) < tol)
stopifnot(abs(vals["Journey Ambience"] - gold$journey_ambience) < tol)
stopifnot(abs(vals["Health: Premature Death"] - gold$premature_death) < tol)
stopifnot(abs(vals["Costs: Investment (PVC)"] - gold$investment_costs) < tol)
stopifnot(abs(vals["Costs: Operating (PVC)"] - gold$operating_costs) < tol)

cat("All golden benchmark tests passed successfully!\n")
