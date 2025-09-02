 <div style="text-align: justify;">
 
 ```bash
 #!/bin/bash 

src=$HOME/research/project 

files=”sample_01 
sample_02 
sample_03” 

#
# Align with GSnap and convert to BAM
# 
for file in $files
do
    gsnap -t 36 -n 1 -m 5 -i 2 --min-coverage=0.90 \
            -A sam -d gac_gen_broads1_e64 \
            -D ~/research/gsnap/gac_gen_broads1_e64 \
            $src/samples/${file}.fq > $src/aligned/${file}.sam
    samtools view -b -S -o $src/aligned/${file}.bam $src/aligned/${file}.sam 
    rm $src/aligned/${file}.sam 
done

#
# Run Stacks on the gsnap data; the i variable will be our ID for each sample we process.
# 
i=1 
for file in $files 
do 
    pstacks -p 36 -t bam -m 3 -i $i \
              -f $src/aligned/${file}.bam \
              -o $src/stacks/ 
    let "i+=1"; 
done 

# 
# Use a loop to create a list of files to supply to cstacks.
# 
samp="" 
for file in $files 
do 
    samp+="-s $src/stacks/$file "; 
done 

# 
# Build the catalog; the "&>>" will capture all output and append it to the Log file.
# 
cstacks -g -p 36 -b 1 -n 1 -o $src/stacks $samp &>> $src/stacks/Log 

for file in $files 
do 
    sstacks -g -p 36 -b 1 -c $src/stacks/batch_1 \
             -s $src/stacks/${file} \ 
             -o $src/stacks/ &>> $src/stacks/Log 
done 

#
# Calculate population statistics and export several output files.
# 
populations -t 36 -b 1 -P $src/stacks/ -M $src/popmap \
              -p 9 -f p_value -k -r 0.75 -s --structure --phylip --genepop
```

¿Cuántos pasos tiene este script?

**R:** Este script tiene 4 pasos en total, donde 3 de ellos son loops

¿Si quisieras correr este script y que funcionara en tu propio equipo, qué línea deberías cambiar y a qué?

**R:** Debo cambiar la variable src, a la dirección dentro de mi computador donde trabajaré en el proyecto. En mi caso, sería /home/ppts

¿A qué equivale $HOME?  
**R:** Es la carpeta personal del usuario del codigo.

¿Qué paso del análisis hace el programa gsnap?
 **R:** Realiza la conversión de los de los archivos .fq  a uno .sam, que será la entrada para samtools. 

¿Qué hace en términos generales cada uno de los loops? 

**R:** El primer loop en cada file en files, ejecuta gsnap para convertir cada archivo .sam a uno .bam y luego borra cada archivo .sam generado.
El segundo loop genera la id para cada una de las muestras, tomando como fuente un archivo .bam y guardandolo en la carpeta stacks. El tercer loop construye una lista de archivos (samp) para que pueda ser usado por cstacks. El cuarto loop corre sstacks para comparar las muestras con el catálogo.
