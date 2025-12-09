#!/bin/bash
# Ejecuta nf-core/sarek en modo SOMÁTICO (tumor-only).
# Uso:
#   A) Nombre de muestra automático:
#        bash sarek_somatic.sh R1.fastq.gz R2.fastq.gz /ruta/output
#   B) Nombre de muestra explícito:
#        bash sarek_somatic.sh R1.fastq.gz R2.fastq.gz /ruta/output nombre_muestra
#
# El script crea internamente un samplesheet CSV como requiere nf-core/sarek.

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo "Uso: bash sarek_somatic.sh R1.fastq.gz R2.fastq.gz /ruta/output [nombre_muestra]"
    exit 1
fi

R1="/home/bioinfo1/181004_curso_calidad_datos_NGS/fastq_raw/S6_R1.fastq.gz"
R2="/home/bioinfo1/181004_curso_calidad_datos_NGS/fastq_raw/S6_R2.fastq.gz"
OUT="../results/ss6"

mkdir -p "$OUT"

# Si se entrega un cuarto argumento, se usa como nombre de muestra
if [ "$#" -eq 4 ]; then
    SAMPLE=$4
else
    base=$(basename "$R1")

    sample=${base%%_R1.fastq.gz}
    sample=${sample%%_R1.fq.gz}
    sample=${sample%%_1.fastq.gz}
    sample=${sample%%_1.fq.gz}
    sample=${sample%%.fastq.gz}
    sample=${sample%%.fq.gz}

    SAMPLE=$sample
    echo "Detectado nombre de muestra automáticamente: ${SAMPLE}"
fi

# Rutas absolutas
if command -v readlink >/dev/null 2>&1; then
    R1_ABS=$(readlink -f "$R1")
    R2_ABS=$(readlink -f "$R2")
else
    R1_ABS="$R1"
    R2_ABS="$R2"
fi

SHEET="${OUT}/samplesheet_somatic_${SAMPLE}.csv"

echo "Creando samplesheet: $SHEET"
cat > "$SHEET" <<EOF
patient,sex,status,sample,lane,fastq_1,fastq_2
${SAMPLE},NA,1,${SAMPLE},L1,${R1_ABS},${R2_ABS}
EOF

echo "Lanzando nf-core/sarek en modo somático (tumor-only)..."
nextflow run nf-core/sarek \
    --input "$SHEET" \
    --genome GATK.GRCh38 \
--outdir "$OUT" \
    --tools mutect2 \
    -profile singularity \
    -c /home/bioinfo1/korostica/test_tutorial/code/local_sarek_8cpus.config \
    -resume

