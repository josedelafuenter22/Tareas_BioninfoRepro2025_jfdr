############################################################
# Comparación variantes germinal vs somáticas usando VEP
# Archivos: vepger.txt (germinal), vepsom.txt (somático)
############################################################

## ==== 0. PARÁMETROS DE ENTRADA ==== ##
germ_file <- "vepger.txt"   # VEP germinal
som_file  <- "vepsom.txt"   # VEP somático

# Prefijo para archivos de salida
out_prefix <- "comparacion_vep_germ_som"


## ==== 1. LIBRERÍAS ==== ##
suppressPackageStartupMessages({
  library(dplyr)
})


## ==== 2. FUNCIÓN PARA LEER ARCHIVOS VEP TXT ==== ##
leer_vep <- function(archivo) {
  lineas <- readLines(archivo)
  
  # Buscar la línea con los nombres de columnas
  idx_header <- grep("^#Uploaded_variation", lineas)
  if (length(idx_header) == 0) {
    stop("No se encontró '#Uploaded_variation' en: ", archivo)
  }
  
  header_line <- sub("^#", "", lineas[idx_header])
  header <- strsplit(header_line, "\t")[[1]]
  
  # Leer datos, ignorando líneas que empiezan con "#"
  vep <- read.delim(
    archivo,
    header       = FALSE,
    sep          = "\t",
    quote        = "",
    comment.char = "#",
    stringsAsFactors = FALSE,
    check.names  = FALSE
  )
  
  if (ncol(vep) != length(header)) {
    warning("Columnas de datos (", ncol(vep),
            ") != columnas de header (", length(header),
            ") en archivo: ", archivo)
  } else {
    colnames(vep) <- header
  }
  
  vep
}


## ==== 3. LEER ARCHIVOS GERMINAL Y SOMÁTICO ==== ##
vep_germ <- leer_vep(germ_file)
vep_som  <- leer_vep(som_file)

cat("Filas germinal (anotaciones VEP):", nrow(vep_germ), "\n")
cat("Filas somático (anotaciones VEP):", nrow(vep_som), "\n")


## ==== 4. EXTRAER CHROM Y POS DESDE Location ==== ##
extraer_pos <- function(df) {
  loc_split <- strsplit(df$Location, "[:-]")
  df$CHROM <- sapply(loc_split, `[`, 1)
  df$POS   <- suppressWarnings(as.integer(sapply(loc_split, `[`, 2)))
  df
}

vep_germ <- extraer_pos(vep_germ)
vep_som  <- extraer_pos(vep_som)


## ==== 5. CLASIFICAR CONSECUENCIAS EN TIPOS (TypeGroup) ==== ##
clasificar_tipo <- function(consequence) {
  if (grepl("missense_variant", consequence)) {
    "missense"
  } else if (grepl("stop_gained", consequence)) {
    "nonsense"
  } else if (grepl("frameshift_variant", consequence)) {
    "frameshift_indel"
  } else if (grepl("synonymous_variant", consequence)) {
    "synonymous"
  } else if (grepl("inframe_insertion|inframe_deletion", consequence)) {
    "inframe_indel"
  } else if (grepl("splice_acceptor_variant|splice_donor_variant", consequence)) {
    "splice_site"
  } else {
    "other"
  }
}

vep_germ$TypeGroup <- vapply(vep_germ$Consequence, clasificar_tipo, character(1))
vep_som$TypeGroup  <- vapply(vep_som$Consequence,  clasificar_tipo, character(1))


## ==== 6. NÚMERO TOTAL DE VARIANTES (ANOTACIONES) ==== ##
n_germ_total <- nrow(vep_germ)
n_som_total  <- nrow(vep_som)

cat("\nNúmero total de anotaciones germinales (VEP):", n_germ_total, "\n")
cat("Número total de anotaciones somáticas (VEP):",  n_som_total, "\n")


## ==== 7. DISTRIBUCIÓN DE TIPOS ==== ##
dist_germ <- table(vep_germ$TypeGroup)
dist_som  <- table(vep_som$TypeGroup)

cat("\nDistribución de tipos (germinal):\n")
print(dist_germ)
cat("\nDistribución de tipos (somático):\n")
print(dist_som)

write.table(as.data.frame(dist_germ),
            paste0(out_prefix, "_dist_tipos_germinal.tsv"),
            sep = "\t", row.names = FALSE, quote = FALSE)

write.table(as.data.frame(dist_som),
            paste0(out_prefix, "_dist_tipos_somatico.tsv"),
            sep = "\t", row.names = FALSE, quote = FALSE)


## ==== 8. GRÁFICO DE BARRAS COMPARATIVO ==== ##
tipos <- sort(unique(c(names(dist_germ), names(dist_som))))
germ_counts <- as.numeric(dist_germ[tipos]); germ_counts[is.na(germ_counts)] <- 0
som_counts  <- as.numeric(dist_som[tipos]);  som_counts[is.na(som_counts)]  <- 0

png(paste0(out_prefix, "_barplot_tipos.png"), width = 900, height = 600)
par(mar = c(8, 5, 4, 2))
barplot(rbind(germ_counts, som_counts),
        beside = TRUE,
        names.arg = tipos,
        las = 2,
        ylab = "Número de anotaciones",
        main = "Distribución de tipos de variantes (germinal vs somático)")
legend("topright",
       legend = c("Germinal", "Somático"),
       fill   = c("gray70", "gray30"))
dev.off()


## ==== 9. DEDUPLICAR VARIANTES (UNA POR CHROM+POS+ALLELE) ==== ##
vep_germ_unique <- vep_germ %>%
  distinct(CHROM, POS, Allele, .keep_all = TRUE)

vep_som_unique <- vep_som %>%
  distinct(CHROM, POS, Allele, .keep_all = TRUE)

cat("\nVariantes únicas germinales (CHROM+POS+Allele):", nrow(vep_germ_unique), "\n")
cat("Variantes únicas somáticas (CHROM+POS+Allele):",  nrow(vep_som_unique), "\n")


## ==== 10. VARIANTES COMPARTIDAS ==== ##
### 10.1 A nivel de gen
genes_germ <- unique(vep_germ_unique$SYMBOL)
genes_som  <- unique(vep_som_unique$SYMBOL)

genes_compartidos <- intersect(genes_germ, genes_som)
genes_solo_germ   <- setdiff(genes_germ, genes_som)
genes_solo_som    <- setdiff(genes_som, genes_germ)

cat("\nGenes con variantes germinales:", length(genes_germ), "\n")
cat("Genes con variantes somáticas:",  length(genes_som), "\n")
cat("Genes presentes en ambas (compartidos):", length(genes_compartidos), "\n")

write.table(data.frame(Gene = genes_compartidos),
            paste0(out_prefix, "_genes_compartidos.tsv"),
            sep = "\t", row.names = FALSE, quote = FALSE)

write.table(data.frame(Gene = genes_solo_germ),
            paste0(out_prefix, "_genes_solo_germinal.tsv"),
            sep = "\t", row.names = FALSE, quote = FALSE)

write.table(data.frame(Gene = genes_solo_som),
            paste0(out_prefix, "_genes_solo_somatico.tsv"),
            sep = "\t", row.names = FALSE, quote = FALSE)


### 10.2 A nivel de variante exacta (CHROM + POS + Allele, ya deduplicadas)

germ_min <- vep_germ_unique[, c("CHROM", "POS", "Allele", "SYMBOL", "Consequence", "TypeGroup")]
som_min  <- vep_som_unique[,  c("CHROM", "POS", "Allele", "SYMBOL", "Consequence", "TypeGroup")]

shared_variants <- inner_join(
  germ_min, som_min,
  by = c("CHROM", "POS", "Allele"),
  suffix = c("_germ", "_som")
)

cat("\nNúmero de variantes exactas compartidas (misma posición + alelo):",
    nrow(shared_variants), "\n")

write.table(shared_variants,
            paste0(out_prefix, "_variantes_exactas_compartidas.tsv"),
            sep = "\t", row.names = FALSE, quote = FALSE)


## ==== 11. RESUMEN EN CONSOLA ==== ##
cat("\n===== RESUMEN COMPARACIÓN GERMINAL vs SOMÁTICO (VEP) =====\n")
cat("Total anotaciones germinal (VEP):", n_germ_total, "\n")
cat("Total anotaciones somático (VEP):", n_som_total, "\n\n")

cat("Variantes únicas germinales (CHROM+POS+Allele):", nrow(vep_germ_unique), "\n")
cat("Variantes únicas somáticas (CHROM+POS+Allele):",  nrow(vep_som_unique), "\n\n")

cat("Distribución de tipos (germinal, anotaciones):\n")
print(dist_germ)
cat("\nDistribución de tipos (somático, anotaciones):\n")
print(dist_som)

cat("\nGenes compartidos:\n")
print(genes_compartidos)

if (nrow(shared_variants) > 0) {
  cat("\nEjemplo de variantes exactas compartidas:\n")
  print(head(shared_variants, 10))
} else {
  cat("\nNo se detectaron variantes exactas compartidas.\n")
}

cat("\nArchivos de salida generados con prefijo:", out_prefix, "\n")
############################################################
# Fin del script
############################################################
