# Carga de datos de la plataforma VEP
vepger<-read.delim("vepger.txt", header = TRUE, sep = "\t", quote = "", comment.char = "", check.names = FALSE)

# consecuencias funcionales más dañinas y no sinónimas
consecuencias_nonsyn <- c(
  "missense_variant",
  "stop_gained",
  "frameshift_variant",
  "start_lost",
  "stop_lost",
  "splice_acceptor_variant",
  "splice_donor_variant",
  "inframe_insertion",
  "inframe_deletion"
)
#patrón de búsqueda con grepl de consecuencias funcionales

pat_nonsyn <- paste(consecuencias_nonsyn, collapse = "|")

# filtro de variantes no sinónimas. 
vep_nonsyn <- subset(vepger, grepl(pat_nonsyn, Consequence))


if ("CADD_PHRED" %in% colnames(vep_nonsyn)) {
  
  # Reemplazar "." por NA
  vep_nonsyn$CADD_PHRED[vep_nonsyn$CADD_PHRED == "."] <- NA
  
  # Convertir a numérico
  vep_nonsyn$CADD_PHRED <- as.numeric(vep_nonsyn$CADD_PHRED)
  
  # Ordenar descendente
  vep_nonsyn <- vep_nonsyn[order(-vep_nonsyn$CADD_PHRED), ]
}

#selección de columnas para el reporte. 
cols_reporte <- c(
  "Location",
  "Allele",
  "SYMBOL",
  "Consequence",
  "IMPACT",
  "CADD_PHRED",
  "Clinical_significance",
  "HGVSp" , 
  "Existing_variation"  
)
#conservar las columnas que existen en el archivo original
cols_reporte <- cols_reporte[cols_reporte %in% colnames(vep_nonsyn)]

#creación de la tabla con dichas columnas. 
tabla_final <- vep_nonsyn[, cols_reporte, drop = FALSE]


#  eliminar duplicados
tabla_unique <- tabla_final[!duplicated(tabla_final[, c("Location", "Allele", "SYMBOL")]), ]

# guardado de las primeras 20 variantes en archivo .tsv
germline_sel <- head(tabla_unique, 20)

write.table(
  germline_sel,
  "germline_variants_selected.tsv",
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)
View(germline_sel)
