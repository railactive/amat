library(xml2)
s19 <- read_xml("amat/inst/extdata/unzipped_gold/xl/worksheets/sheet19.xml")
cells <- xml_find_all(s19, ".//d1:c", xml_ns(s19))
df <- data.frame(
  ref = xml_attr(cells, "r"),
  col = gsub("[0-9]", "", xml_attr(cells, "r")),
  row = as.numeric(gsub("[A-Z]", "", xml_attr(cells, "r"))),
  val = sapply(cells, function(c) {
    v <- xml_find_first(c, "./d1:v", xml_ns(s19))
    if (!is.na(v)) xml_text(v) else ""
  }),
  stringsAsFactors = FALSE
)

# Extract row 20 to 27
m2 <- df[df$row %in% 20:27, ]
# Group by column to build data frame
cols <- unique(m2$col[m2$row == 20])
res <- lapply(cols, function(c_name) {
  sub <- m2[m2$col == c_name, ]
  yr <- as.numeric(sub$val[sub$row == 20])
  if (is.na(yr)) return(NULL)
  data.frame(
    year = yr,
    congestion = as.numeric(sub$val[sub$row == 21]),
    infrastructure = as.numeric(sub$val[sub$row == 22]),
    accident = as.numeric(sub$val[sub$row == 23]),
    air_quality = as.numeric(sub$val[sub$row == 24]),
    noise = as.numeric(sub$val[sub$row == 25]),
    greenhouse_gases = as.numeric(sub$val[sub$row == 26]),
    indirect_tax = as.numeric(sub$val[sub$row == 27])
  )
})
mecc2_df <- do.call(rbind, res)
mecc2_df <- mecc2_df[order(mecc2_df$year), ]
cat("mecc2 extracted:\n")
print(head(mecc2_df, 10))
print(tail(mecc2_df, 5))
saveRDS(mecc2_df, "amat/inst/extdata/mecc2.rds")
