# Tarea 2, Unidad 2
# José de la Fuente.

## Ejercicios:

Responda las siguientes preguntas:

* ¿Cómo se llaman los archivos que contienen las tasas de datos perdidos por SNP y por muestra?

**R: los archivos que tienen tasas de datos perdidos por SNP se llama  `plink.lmiss`** y por muestra se llama `plink.imiss`. 
* ¿Cuántas variantes se eliminaron por tener una tasa de datos perdidos mayor a 0.2?

**R: despues de correr el comando `plink --bfile $C/chilean_all48_hg19 --geno 0.2 --make-bed --out chilean_all48_hg19_2`, se removieron 4680 variantes**

* ¿Cuántos individuos tenían una tasa de datos perdidos mayor a 0.02?

**R: con el comando `plink --bfile chilean_all48_hg19_4 --mind 0.02 --make-bed --out chilean_all48_hg19_5` no se eliminaron individuos con el filtro.**

* Basados en los histogramas y en sus cálculos, ¿qué valores umbrales de datos perdidos para muestras y SNPs sugeriría?

**R: Desde el histograma de los individuos, se puede observar que la mayoría de las se encuentra bajo el 2,5%, por lo que en ese caso sugeriría ese valor como umbral. En el caso de los SNPs, se puede notar que las mediciones se encuentran agrupadas bajo el 10%, por lo que fijaría dicho valor como umbral.**

---

* ¿Cuántos individuos fueron eliminados por discrepancia de sexo?

**R: al correr la linea `plink --bfile chilean_all48_hg19_5 --check-sex` se observan 3 individuos que presentan problemas, por lo que al correr la linea `plink --bfile chilean_all48_hg19_5 --remove sex_discrepancy.txt --make-bed --out chilean_all48_hg19_6` se removieron esos 3 individuos.**
* ¿Qué riesgo(s) se corre(n) si no se eliminaran?

**R: se puede generar sesgos estadísticos, si es que el análisis está vinculado al sexo de los individuos. Además de generar problemas en la identificación de las muestras y en el cálculo asociado a MAF.**

---
* ¿Cuál es el nombre del primer conjunto de datos que solo contiene SNPs en autosomas?

**R:`chilean_all48_hg19_7`**
* ¿Cuántos SNPs se encontraban en cromosomas sexuales?

**R: al ejecutar la línea `plink --bfile chilean_all48_hg19_5 --remove sex_discrepancy.txt --make-bed --out chilean_all48_hg19_6 ` quedan 574.624 variantes. Luego, al ejecutar la línea para dejar solamente los cromosomas autosomales quedan 557922, por lo que la diferencia de 16.702, son los SNPs que se encontraban en cromosomas sexuales.**

* ¿Como calcularía el número de cromosomas que porta cada uno de los alelos para cada SNP?

**R:como se generó el archivo MAF_check.frq, en ese archivo se encuentran las columnas MAF y NCHROBS. Para calcular el número de cromosomas que porta cada uno de los alelos para cada SNP, usaría la siguiente linea de código:**

```bash
awk 'NR==1{print $0"\tA1_CT\tA2_CT"; next} \
{a1 = int($5*$6 + 0.5); a2 = $6 - a1; print $0"\t"a1"\t"a2}' MAF_check.frq > MAF_check_counts.txt
```
**La cual generará un archivo .txt el qeu contendrá dos columnas nuevas (A1_CT y A2_CT) las cuales se calcularán de la siguiente forma. Para A1_CT se tomará la quinta columna del archivo .frq, el cual es MAF y se le hará el producto con la sexta columna, que es NCHROBS y generará un numero entero que corresponderá al valor del número de cromosomas con el alelo menor. La columna A2_CT se completa con la diferencia del valor de NCHROBS con el valor de A1_CT, dando así el valor del número de coromosomas con el alelo mayor.**

---
* ¿Cuál es el nombre del archivo con los resultados de la prueba de HWE?

**R:** `plink.hwe` **es el nombre del archivo**
* ¿Basándose en la distribución de los valores de p, le parece el umbral usado razonable o propondría otro valor?

**R:al analizar el segundo gráfico de aquellos SNP fuertemente desviados, se puede notar que hay valores de p muy cercanos a 0 y luego comienza a caer hacia el umbral utilizado 1*10<sup>-6</sup>, por lo que el umbral parece razonable.**

---

* ¿Cuántos SNPs en aparente equilibrio de ligamiento se encontraron?

**R: al usar el comando ```wc -l indepSNP.prune.in``` quedan 103.214**
* ¿Cuántos SNPs se eliminaron por estar en regiones de inversiones conocidas?

**R:al correr la linea de comando```link --bfile chilean_all48_hg19_9 --exclude $T/inversion.txt --range --indep-pairwise 50 5 0.2 --out indepSNP``` se eliminaron 7915 SNPs**
* ¿Cuántos individuos quedaron luego del filtro de parentesco?

**R: Luego de usar el comando ```plink -bfile chilean_all48_hg19_9 -remove to_romeve_by_relatedness.txt -make-bed --out chilean_all48_hg19_10``` quedaron 42 individuos.**
* ¿Cuál fue el mayor coeficiente de parentesco efectivamente aceptado?

**R: primero se corre la siguiente linea de comando ```plink --bfile chilean_all48_hg19_10 --extract indepSNP.prune.in --genome --out pihat_final``` para obtener un archivo que contenga los valores de pi_hat luego del filtro. Después se aplica la línea ```awk '{if ($1!="FID1") print $10}' pihat_final.genome | sort -nr | head -1``` y se obtiene que el mayor valor de pi_hat aceptado es de 0.2049.**

---
* ¿Cuántos SNPs quedaron luego del filtro?

**R: Quedaron seleccionados 103.214 SNPs, según se observa en el conteo de líneas del archivo ```indepSNP.prune.in```**.

* ADMIXTURE asume que los individuos no están emparentados. Sin embargo, no realizamos ningún filtro. ¿Por qué?

**R: No se aplicó un filtro adicional de individuos relacionados para la fase de ADMIXTURE, ya que en el control de calidad previo del conjunto ChileGenómico-HapMap se eliminaron aquellos con PI_HAT ≥ 0.2 (parientes cercanos). Los individuos conservados presentan una relación genética baja o inexistente, lo que asegura que los resultados de inferencia de ancestría por máxima verosimilitud no se vean sesgados por parentesco oculto.**