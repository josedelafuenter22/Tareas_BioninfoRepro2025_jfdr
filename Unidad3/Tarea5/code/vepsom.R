# Carga de datos de la plataforma VEP
vepsom<-read.delim("vepsom.txt", header = TRUE, sep = "\t", quote = "", comment.char = "", check.names = FALSE)

# consecuencias funcionales más dañinas y no sinónimas

consecuencias_nonsyn1 <- c(
  "missense_variant",
  "stop_gained",
  "frameshift_variant",
  "start_lost",
  "stop_lost",
  "splice_acceptor_variant",
  "splice_donor_variant",
  "inframe_insertion",
  "inframe_deletion",
  "protein_altering_variant"
)
#patrón de búsqueda con grepl de consecuencias funcionales

pat_nonsyn1 <- paste(consecuencias_nonsyn1, collapse = "|")

# filtro de variantes no sinónimas. 
vep_som_nonsyn <- subset(vepsom, grepl(pat_nonsyn1, Consequence))




# Convertir CADD_PHRED a numérico (si existe)

if ("CADD_PHRED" %in% colnames(vep_som_nonsyn)) {
  vep_som_nonsyn$CADD_PHRED[vep_som_nonsyn$CADD_PHRED %in% c(".", "")] <- NA
  vep_som_nonsyn$CADD_PHRED <- as.numeric(vep_som_nonsyn$CADD_PHRED)
}

# Priorizar genes de cáncer 

cancer_genes <- c(
  "TP53","BRCA1","BRCA2","PTEN","FLT3","DNMT3A","NPM1","TET2","ASXL1",
  "IDH1","IDH2","RUNX1","CEBPA","NRAS","KRAS","JAK2","JAK3","KIT",
  "CALR","PDGFRB","KMT2A","PAX5","ABL1","CBL"
)

vep_som_cancer <- subset(vep_som_nonsyn, SYMBOL %in% cancer_genes)

# Si hay pocas en genes de cáncer, usamos todas las no sinónimas
if (nrow(vep_som_cancer) >= 10) {
  vep_som_prior <- vep_som_cancer
} else {
  vep_som_prior <- vep_som_nonsyn
}



# Quitar duplicados por variante (Location + Allele + SYMBOL)


vep_som_unique <- vep_som_prior[!duplicated(
  vep_som_prior[, c("Location", "Allele", "SYMBOL")]
), ]



# Ordenar por IMPACT y CADD_PHRED


if ("IMPACT" %in% colnames(vep_som_unique)) {
  impact_order <- c("HIGH", "MODERATE", "LOW", "MODIFIER")
  vep_som_unique$IMPACT <- factor(vep_som_unique$IMPACT, levels = impact_order)
  
  vep_som_unique <- vep_som_unique[order(
    vep_som_unique$IMPACT,
    -vep_som_unique$CADD_PHRED
  ), ]
} else if ("CADD_PHRED" %in% colnames(vep_som_unique)) {
  vep_som_unique <- vep_som_unique[order(-vep_som_unique$CADD_PHRED), ]
}

# Selección de variantes

n_sel <- min(20, nrow(vep_som_unique))

som_sel <- head(vep_som_unique, n_sel)


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

cols_reporte <- cols_reporte[cols_reporte %in% colnames(som_sel)]

tabla_somatica <- som_sel[, cols_reporte, drop = FALSE]

# Ver tabla
View(tabla_somatica)


# Guardar tabla final


write.table(
  tabla_somatica,
  "somatic_variants_selected.tsv",
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)
