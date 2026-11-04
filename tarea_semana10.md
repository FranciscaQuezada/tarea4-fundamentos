# T4 — Portafolio de visualización con ggplot2
### Módulo III · Semanas 10 y 11 · **Tarea calificada — 14 % de la nota final (7 % + 7 %)**
#### Fundamentos de Programación para Análisis Económico · UdeC-EAN

**Tipo:** calificada, en dos partes.
**Entrega:** scripts `.R` comentados + figuras exportadas + `README.md`, en tu
repositorio de GitHub.
**Vienes preparado si hiciste:** [A4 (S9, crítica de un gráfico real)](tarea_semana9.md),
[A3 (S6, limpieza de la ENE)](tarea_semana6.md) y la [T3 (S8, regresión)](tarea_semana8.md).
**Uso de IA:** restringido (ver el final de este documento).

| Parte | Semana | Peso | Esqueleto | Qué se entrega |
|---|---|---:|---|---|
| **Parte 1** | 10 | 7 % | [`labs/semana10_tarea3_esqueleto.R`](../labs/semana10_tarea3_esqueleto.R) | 3 gráficos con tres bases distintas |
| **Parte 2** | 11 | 7 % | [`labs/semana11_tarea3p2_esqueleto.R`](../labs/semana11_tarea3p2_esqueleto.R) | 5 gráficos + 1 figura compuesta + reflexión |

> Los esqueletos se llaman `tarea3` por razones históricas: corresponden a la **T4**.

---

## Objetivo

Construir con código los gráficos que en la Semana 9 aprendiste a **juzgar**.
Cada gráfico tiene que responder una pregunta económica, ser **honesto** y
poder leerse sin explicación oral.

Lo que se evalúa no es que el gráfico "se vea bonito", sino que cada decisión
—qué geom, qué color, qué resaltar, qué título— tenga una razón, y que la sepas
decir.

> Datos (todos ya conocidos):
>
> - `data/raw/casen_reducido.csv` — 60 personas; **5 `NA` en `ingreso`**.
> - `data/raw/salario_minimo_chile.csv` — ingreso mínimo nominal e IPC, 2014–2025
>   (Semana 2).
> - `data/raw/ene-2026-06-mjj.csv` — Encuesta Nacional de Empleo, mayo-julio 2026
>   (Semana 6). Recuerda: `read.csv2()`, solo ocupados (`activ == 1`), centinelas
>   `888` y `999` en `habituales`, y **ponderar con `fact_cal`**.

---

## El checklist que rige toda la tarea

Cada gráfico de las dos partes se corrige contra esta lista (Semana 9):

- [ ] El **título dice el hallazgo**, no las variables ("Ñuble, segunda región más
      informal", no "Informalidad por región").
- [ ] **Barras y áreas desde 0.** En líneas no es obligatorio, pero el eje se
      rotula. Si haces zoom, con `coord_cartesian()`, nunca con `ylim()`.
- [ ] **Rango completo** o justificado: nada de elegir la ventana que conviene.
- [ ] **Paleta accesible:** viridis, ColorBrewer (*colorblind safe*) u Okabe-Ito.
      Nada de `rainbow()` ni rojo contra verde como único contraste.
- [ ] **El color tiene función:** gris para el contexto, un color para el mensaje.
- [ ] **Etiquetas directas** (`geom_text()`, ggrepel) en vez de leyendas largas,
      y **líneas de referencia** cuando dan contexto (`geom_hline()`/`geom_vline()`).
- [ ] **Sin chart junk:** sin 3D, sin fondos, sin grillas densas.
- [ ] **Ejes legibles y con unidades:** `scales::label_currency(big.mark = ".",
      decimal.mark = ",")` para pesos, `label_number(scale = 1e-3, suffix = " mil", …)`
      para miles y `label_percent()` para proporciones (S10S2).
- [ ] **Fuente** en la `caption`, con la base y si está ponderada.
- [ ] **Exportado** con `ggsave()` a 300 dpi, al tamaño en que se va a usar.

---

## Parte 1 — Tres gráficos, tres bases (Semana 10 · 7 %)

Trabaja sobre el esqueleto
[`labs/semana10_tarea3_esqueleto.R`](../labs/semana10_tarea3_esqueleto.R):
completa los `____` y responde las preguntas que aparecen como comentarios.

> **Antes, en el mismo laboratorio (sin nota, ~40 min):**
> [`labs/semana10_lab_grafico_horrible.R`](../labs/semana10_lab_grafico_horrible.R).
> Sabotear un gráfico a propósito y redimirlo con escalas, `scales`, paleta,
> facetas y `theme()` es el calentamiento para esta parte.

### Gráfico 1 · CASEN: educación e ingreso por género

Scatter con puntos coloreados por género y **una recta por género**. Se evalúa
que entiendas la **herencia de `aes()`**: dónde va `color` para obtener una recta
por grupo o una sola.

> Responde: ¿qué pregunta responde este gráfico que no respondería la versión con
> una sola recta?

### Gráfico 2 · Ingreso mínimo: nominal contra real

Dos líneas (nominal y real, en pesos de 2010), con los datos en **formato largo**
(`pivot_longer()`, Semana 6). La leyenda se reemplaza por **etiquetas directas**
al final de cada línea, y las series se distinguen por **color y tipo de línea**
(codificación redundante).

> Responde: ¿por qué aquí el eje Y no necesita partir en 0 y en un gráfico de
> barras sí? ¿Qué ganas usando color **y** tipo de línea?

### Gráfico 3 · ENE: en qué trabajan hombres y mujeres

Barras de composición por sexo según categoría ocupacional, **ponderadas**
(`aes(weight = fact_cal)`) y en proporción (`position = "fill"`), con una paleta
accesible.

> Responde: ¿en qué categoría está la mayor diferencia entre hombres y mujeres, y
> en cuál casi no hay? Da las cifras. ¿Qué cambiaría si borras `weight = fact_cal`?

### Rúbrica de la Parte 1 (100 puntos = 7 %)

| Criterio | Puntos |
|---|---:|
| **Gráfico 1:** herencia de `aes()` correcta (una recta por género), título-hallazgo, eje en pesos legible | 15 |
| **Gráfico 2:** formato largo correcto, etiquetas directas sin leyenda, color + tipo de línea | 20 |
| **Gráfico 3:** ponderado con `fact_cal`, `position = "fill"`, paleta accesible, eje en % | 20 |
| **Respuestas** a las preguntas del esqueleto: correctas, con cifras y con los conceptos de la S9–S10 | 25 |
| **Checklist** aplicado en los tres gráficos (títulos, fuente, sin junk, 300 dpi) | 10 |
| Script reproducible (corre de principio a fin sin editar) + commits claros | 10 |
| **Total** | **100** |

---

## Parte 2 — Portafolio y figura compuesta (Semana 11 · 7 %)

Trabaja sobre el esqueleto
[`labs/semana11_tarea3p2_esqueleto.R`](../labs/semana11_tarea3p2_esqueleto.R).
La pregunta general: **¿cómo se distribuyen el ingreso (CASEN) y la informalidad
laboral (ENE) en Chile, y qué gráfico lo comunica mejor?**

### Los cinco gráficos

| # | Gráfico | Requisito |
|---|---|---|
| 1 | Scatter CASEN (modelo completo en el esqueleto) | úsalo como referencia de estilo |
| 2 | Barras de informalidad por región (ENE) | ponderado; **una** región resaltada; valores escritos; línea del promedio nacional |
| 3 | Distribución de horas habituales por sexo (ENE) | sin los centinelas 888 y 999; **elige** el geom (densidad, boxplot o violín) y justifícalo |
| 4 | Informalidad de hombres contra mujeres por región (ENE) | etiquetas con **ggrepel**; diagonal y = x como referencia |
| 5 | **Gráfico libre** | una pregunta **tuya**, con CASEN o la ENE. Ideas: la U de informalidad por edad, composición por categoría, facetas por región, incertidumbre con `geom_pointrange()` |

### La figura compuesta

Combina **tres** de tus gráficos en una figura con `patchwork`:

- paneles rotulados (`plot_annotation(tag_levels = "A")`);
- un **título general** que diga el hallazgo de la figura completa;
- la **fuente** en la caption;
- exportada en **PNG (300 dpi) y PDF** (vectorial).

> ⚠️ **Precedencia:** en R, `+` se evalúa antes que `|` y `/`. Escribe
> `(a | (b / c)) + plot_layout(...) + plot_annotation(...)`, con paréntesis
> **externos**. Sin ellos, el título y los rótulos no aparecen, y R no avisa.

### La reflexión (0,5 página)

Responde, usando el vocabulario de la Semana 9:

1. De los cinco gráficos, ¿cuál comunica **mejor** su hallazgo y por qué?
2. En el gráfico 3, ¿por qué elegiste ese geom y no otro?
3. ¿Qué agrega la figura compuesta que no dan los gráficos por separado?

### Rúbrica de la Parte 2 (100 puntos = 7 %)

| Criterio | Puntos |
|---|---:|
| **Gráfico 2:** ponderación, resaltado con una variable lógica, valores, línea de referencia | 12 |
| **Gráfico 3:** centinelas limpiados, geom elegido y justificado | 10 |
| **Gráfico 4:** ggrepel bien usado (todas las etiquetas visibles, `seed` fijo), diagonal de referencia | 10 |
| **Gráfico 5:** pregunta propia, geom adecuado a la pregunta, título-hallazgo | 15 |
| **Figura compuesta:** tres paneles, rótulos A-B-C, título general, caption, PNG y PDF | 15 |
| **Checklist** aplicado en los cinco gráficos (paleta accesible, barras desde 0, fuente, sin junk) | 10 |
| **Reflexión:** argumenta con conceptos (no con gustos), responde las tres preguntas | 18 |
| Script reproducible + commits claros | 10 |
| **Total** | **100** |

---

## Descuentos (ambas partes)

| Falta | Descuento |
|---|---:|
| El script no corre de cero en otra máquina (rutas absolutas, `setwd()`, objetos inexistentes) | −15 |
| Gráfico de barras con el eje truncado | −5 por gráfico |
| Uso de `rainbow()` o de rojo contra verde como único contraste | −5 por gráfico |
| Cifras de la ENE sin ponderar presentadas como si fueran de Chile | −5 por gráfico |
| Gráfico exportado con captura de pantalla en vez de `ggsave()` | −5 por gráfico |

> Pruébalo antes de entregar: cierra R, ábrelo desde el `.Rproj` y corre el script
> completo.

---

## Entrega

Para **cada** parte:

1. El script completo en tu repositorio (`scripts/t4_parte1.R` y
   `scripts/t4_parte2.R`, o los esqueletos completados con ese nombre).
2. Las figuras en `output/figuras/`.
3. En el `README.md`, una línea por figura: qué muestra y cuál es su hallazgo.
4. **Avanza por commits** (no subas todo en uno): el historial es tu evidencia de
   trabajo.
5. Pega el enlace del repositorio en Canvas.

---

## Para consultar mientras trabajas

| Recurso | Para qué |
|---|---|
| [Cheatsheet de ggplot2](https://rstudio.github.io/cheatsheets/html/data-visualization.html) (Posit) | la gramática en una hoja |
| [r-charts · ggplot2](https://r-charts.com/ggplot2/) | recetas por elemento: ejes, leyendas, anotaciones |
| [R Graph Gallery](https://r-graph-gallery.com) y su [Palette Finder](https://r-graph-gallery.com/color-palette-finder) | ejemplos con código y paletas con simulación de daltonismo |
| [ggrepel: ejemplos](https://ggrepel.slowkow.com/articles/examples.html) | etiquetas que no se pisan |
| [patchwork](https://patchwork.data-imaginist.com) | componer figuras |
| [Temas de ggplot2](https://ggplot2.tidyverse.org/reference/ggtheme.html) y [ggthemes](https://jrnold.github.io/ggthemes/) | partir de un tema hecho y ajustarlo con `theme()` |
| [scales](https://scales.r-lib.org/reference/) | ejes en pesos, miles o % (`label_currency()`, `label_number()`, `label_percent()`) |
| [Coblis](https://www.color-blindness.com/coblis-color-blindness-simulator/) | ver tu gráfico como lo vería una persona daltónica |
| [Wilke, *Fundamentals of Data Visualization*](https://clauswilke.com/dataviz/) | los principios detrás de cada regla del checklist |

La lista completa está en [`materiales/recursos_y_lecturas.md`](../materiales/recursos_y_lecturas.md).

---

## Declaración de autoría y uso de IA

Copia este bloque al final de tu `README.md` y complétalo:

```markdown
## Declaración de autoría y uso de IA
- Herramienta utilizada: ____ (o «ninguna»)
- Para qué la usé: ____ (ej.: entender por qué no aparecía el título de patchwork)
- Qué hice yo: ____ (ej.: elegí los gráficos, los colores y escribí la reflexión)
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.
```

**Uso permitido:** pedir que te expliquen un error, preguntar qué hace una función
o un argumento (`weight`, `position`, `max.overlaps`), pedir alternativas a un
código que ya escribiste, revisar la redacción de la reflexión.

**Uso no permitido:** pegar este enunciado y entregar lo que devuelva; entregar
código que no puedes explicar línea por línea; pedirle que **elija** el mejor
gráfico o que **escriba** la reflexión — esas decisiones son lo que se evalúa.

Un aviso concreto: ggplot2 cambia entre versiones (la actual es la 4.0) y los
chatbots suelen proponer argumentos obsoletos (`size` en vez de `linewidth` para
líneas, por ejemplo). **Verifica en el cheatsheet o en la documentación.**

Declarar el uso **no baja la nota**; ocultarlo constituye falta a la ética
académica (Guía de uso ético de tecnologías digitales, UdeC).
