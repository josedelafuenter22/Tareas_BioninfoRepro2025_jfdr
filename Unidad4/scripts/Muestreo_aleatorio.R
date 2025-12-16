set.seed(12)

# Leer archivos completos
Data.Full  <- read.delim("Illum_data.txt", check.names = FALSE)
Annot.Full <- read.delim("MouseRef-8_annot_full.txt", check.names = FALSE)

# Alinear anotación con datos de expresión
Annot.Full <- Annot.Full[match(Data.Full$PROBE_ID, Annot.Full$ProbeID), ]

# Verificación de seguridad
stopifnot(all(Data.Full$PROBE_ID == Annot.Full$ProbeID))

# Muestreo aleatorio de 5000 PROBE_ID
ids5000 <- sample(Data.Full$PROBE_ID, size = 5000, replace = FALSE)

# Subconjuntar SOLO por filas (sondas)
Data.Sample  <- Data.Full[Data.Full$PROBE_ID %in% ids5000, ]
Annot.Sample <- Annot.Full[Annot.Full$ProbeID %in% ids5000, ]

# Reordenar para mantener correspondencia exacta
Data.Sample  <- Data.Sample[order(Data.Sample$PROBE_ID), ]
Annot.Sample <- Annot.Sample[match(Data.Sample$PROBE_ID, Annot.Sample$ProbeID), ]

# Guardar archivos listos para el pipeline original
write.table(Data.Sample,
            file = "Illum_data_sample5000.txt",
            sep = "\t", quote = FALSE, row.names = FALSE)

write.table(Annot.Sample,
            file = "MouseRef-8_annot_sample5000.txt",
            sep = "\t", quote = FALSE, row.names = FALSE)
