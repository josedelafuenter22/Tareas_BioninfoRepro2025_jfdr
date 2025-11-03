<p align="justify">

# Tarea: Exploración e interpretación de datos genómicos en cBioPortal

## Parte 1: Selección del estudio 
 - **Nombre del estudio:** Cervical Cancer (MSK, Clin Cancer Res 2023)
 - **Número total de pacientes:** 177
 - **Institución responsable:** Memorial Sloan Kettering Cancer Center (MSK).

 ¿Por qué seleccioné este estudio?: Porque es el cuarto cáncer más común en mujeres, donde para el año 2022 se detectaron más de 660.000 casos nuevos, con aproximadamente 350.000 muertes, además de ser un cáncer que presenta la mayor tasas de incidencias en paises de bajos y medianos ingresos, reflejando desigualdad en la falta de acceso a programas de vacunación contra el VPH y tratamientos en general [(Sitio WHO).](https://www.who.int/news-room/fact-sheets/detail/cervical-cancer)

![Sumary data](summary.png)*Summary del estudio Cervical Cancer.*

 ---
 ## Parte 2: Análisis genómico:

 Los 5 genes con mayor frecuencia de mutación en este estudio son: 

 | #   | Gen | N° de mutaciones | N° de pacientes | Frecuencia (%) |
| --- | --- | ---------------- | --------------- | -------------- |
| 1   |    PICK3CA |      50            |  44               |  24.9%               |
| 2   |    KMT2D |          33        |      24           |     13.6%           |
| 3   |   KRAS  |             21     |         21        |      11.9%          |
| 4   |    TP53 |               22   |           20      |      11.3%          |
| 5   |    KMT2C |             23     |            19     |     10.7%           |


De la tabla anterior, seleccionaré al gen PICK3CA.

Responde:

- ¿Cuántos pacientes presentan esa mutación? En total 44 pacientes presentan la mutación.

- ¿Qué tipo de mutación es más frecuente (missense, nonsense, frameshift)? La mutación más frecuente es  del tipo Missense.

¿Qué vías de señalización aparecen alteradas en la pestaña Pathways? Se ve afectada la vía de señalización PIK3, encargada de la proliferación y crecimiento celular.


![Clincal data](clinicaldata.png)*Clinical data del estudio Cervical Cancer.* 

---
## Parte 3: Análisis clínico:

- Distribución por sexo: el 100% de los casos corresponde a mujeres.
- Distribución por edad: desde los 20 a los 80 años.
- Distribución por raza: un 74% corresponde a blancos, un 7,9% a negros o africanos, 6,8 a asiáticos, 6,2 a otro tipo de raza, 0,6% a nativos americanos y un 4,5% no entrega información.

Calcula: 
- Rango de edad: el rango en este estudio es de 60 años.
- Mediana de edad: la mediana de edades corresponde a 49 años.

Interpretación de los resultados: 
- ¿Existe una predominancia por sexo o edad?: Como el estudio escogido corresponde a cáncer cervical, la predominancia corresponde al sexo femenino. En cuanto a la edad, como se muestra la figura, existe una tendencia a ser identificado entre los 45 y 50 años. 

![Grafico barras por edades](grafico_barras_edad.png) *Grafico de barra por edades.*

- ¿Qué implicancias podría tener esa distribución para el estudio del cáncer elegido?

Desde la figura que se presenta a continuación, se puede notar que de las 177 personas participantes en el estudio, 102 de ellas fallecieron posterior a la secuenciación. 

![Supervicencia](sobrevida.png) *Grafico de supervivencia.*

Además, desde el gráfico de Kaplan-Meier, se puede notar que existe una disminución progresiva de la supervicencia de las pacientes a lo largo del tiempo, lo que podría sugerir que este tipo de cáncer tiene un comportamiento agresivo debido que la supervicencia cae al 50% transcurrido un tercio del tiempo del seguimiento de los pacientes, dando un pronóstico reservado, sobre todo en etapas avanzadas de este cáncer. 

![Grafico Kaplan-Meier](kmplot.png) *Gráfico Kaplan-Meier.*

---

## Parte 4: Análisis interpretativo.

Redacta un breve comentario (5–10 líneas) respondiendo:

¿Qué relación observas entre las mutaciones más frecuentes y las características clínicas del grupo?
¿Por qué podría ser relevante este gen como biomarcador o diana terapéutica?

Las mutaciones más frecuentes en el estudio, como PIK3CA, TP53 y KMT2D, se relacionan estrechamente con las características clínicas observadas, ya que participan en vías clave del crecimiento, reparación y supervivencia celular.
La presencia de alteraciones en PIK3CA, por ejemplo, podría explicar la menor supervivencia observada, al promover una proliferación tumoral sostenida y resistencia a la apoptosis. Este gen es clínicamente relevante porque su activación aberrante en la vía PI3K/AKT/mTOR lo convierte en una diana terapéutica potencial, susceptible a inhibidores específicos ya en evaluación clínica. 

Por su parte, TP53 y KMT2D podrían funcionar como biomarcadores pronósticos, asociados con mayor agresividad tumoral y respuesta desfavorable al tratamiento.
</p>