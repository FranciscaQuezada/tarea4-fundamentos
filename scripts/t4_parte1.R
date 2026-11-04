
# T4 - Parte 1: Tres gráficos, tres bases (Semana 10)
# Autor: Francisca Quezada
# Fecha: 2026-11-03

# Gráfico 1: CASEN, educación e ingreso por género (herencia de aes())
# Gráfico 2: ingreso mínimo nominal contra real (formato largo + etiquetas directas)
# Gráfico 3: ENE, categoría ocupacional por sexo (ponderado, position = "fill")

library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

## Parte 1 — Tres gráficos, tres bases (Semana 10 · 7 %)
azul <- "#0072B2"; oro <- "#e69b0a"; gris <- "grey45"
pesos <- label_currency(accuracy = 1, big.mark = ".", decimal.mark = ",")
pct0  <- label_percent(accuracy = 1, decimal.mark = ",")

tema_t4 <- function(base = 12) {
  theme_minimal(base_size = base) +
    theme(plot.title        = element_text(face = "bold"),
          plot.caption      = element_text(color = "grey40", hjust = 0),
          panel.grid.minor  = element_blank(),
          legend.position   = "bottom")
}
theme_set(tema_t4())
dir.create("output/figuras", recursive = TRUE, showWarnings = FALSE)

## Gráfico 1 · CASEN: educación e ingreso por género
casen <- read.csv("data/raw/casen_reducido.csv") |>
  filter(!is.na(ingreso))                            # las 5 personas sin ingreso quedan fuera
nrow(casen)

# Pendiente -> pesos extra por año de escolaridad de cada genero
pend <- casen |>
  group_by(genero) |>
  summarise(n = n(),
            pendiente = unname(coef(lm(ingreso ~ educ))[2]))

pend

mayor <- pend$genero[which.max(pend$pendiente)]

g1 <- ggplot(casen, aes(x = educ, y = ingreso, color = genero)) +
  geom_point(size = 2, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1) +
  scale_color_manual(values = c(azul, oro)) +
  scale_y_continuous(labels = pesos) +
  labs(title = paste0("Cada año de escolaridad se asocia a más ingreso en el grupo ", mayor),
       subtitle = paste0("Pendiente (pesos por año de escolaridad): ",
                         paste(pend$genero, pesos(round(pend$pendiente)),
                               sep = " = ", collapse = " . ")),
       x = "Años de escolaridad", y = "Ingreso mensual", color = "Genero",
       caption = "Fuente: CASEN (subconjunto de 55 personas con ingreso). Sin ponderar.")

g1

ggsave("output/figuras/t4p1_g1_casen_educ_ingreso.png", g1, width = 8, height = 5, dpi = 300)

# HERENCIA DE aes(): color = genero está dentro de ggplot(), así que TODAS las
# capas lo heredan. geom_smooth() dibuja entonces una recta por género.
# Si color estuviera solo en geom_point(aes(color = genero)), geom_smooth()
# no lo heredaría y trazaría UNA sola recta para todos.

# ¿Qué pregunta responde este gráfico que no respondería la versión con una sola recta? 
# Una sola recta responde "¿cuánto aumenta el ingreso, en promedio, por año de
# escolaridad?". Con una recta por género respondemos "¿el retorno a la
# educación es distinto entre hombres y mujeres?" comparamos pendientes
# (rendimiento por año) y también niveles (intercepto). Una recta común puede
# esconder que las pendientes difieren (efecto de interacción educ × género). 
# En esta muestra, cada año de escolaridad se asocia a $46.862 más de ingreso
# en las mujeres y a $38.295 más en los hombres.

## Gráfico 2: Ingreso mínimo: nominal contra real
sm <- read.csv("data/raw/salario_minimo_chile.csv")
names(sm)    

col_anio <- "anio"
col_nominal <- "salario_minimo"
col_ipc <- "ipc"

stopifnot(all(c(col_anio, col_nominal, col_ipc) %in% names(sm)))

sm <- sm |>
  rename(anio = all_of(col_anio), nominal = all_of(col_nominal), ipc = all_of(col_ipc)) |>
  mutate(real = nominal / (ipc / 100))    # pesos de 2010

# Formato LARGO (S6): una fila por año y serie
sm_largo <- sm |>
  pivot_longer(cols = c(nominal, real), names_to = "serie", values_to = "monto") |>
  mutate(serie = factor(serie, levels = c("nominal", "real"),
                        labels = c("Nominal", "Real (pesos de 2010)")))

ultimo <- sm_largo |> filter(anio == max(anio))   # para las etiquetas directas

# Crecimiento total del período, para el título
primero_ult <- sm |> filter(anio %in% c(min(anio), max(anio))) |> arrange(anio)
crec_nom  <- primero_ult$nominal[2] / primero_ult$nominal[1] - 1
crec_real <- primero_ult$real[2]    / primero_ult$real[1]    - 1
c(nominal = crec_nom, real = crec_real)

g2 <- ggplot(sm_largo, aes(anio, monto, color = serie, linetype = serie)) +
  geom_line(linewidth = 1.1) +
  geom_text(data = ultimo, aes(label = serie), hjust = -0.1, fontface = "bold",
            show.legend = FALSE) +                       # etiqueta directa, sin leyenda
  scale_color_manual(values = c(oro, azul)) +            # color.
  scale_linetype_manual(values = c("solid", "dashed")) + # tipo de línea
  scale_x_continuous(breaks = seq(min(sm$anio), max(sm$anio), by = 2),
                     expand = expansion(mult = c(0.02, 0.28))) +   # espacio para etiquetas
  scale_y_continuous(labels = pesos) +
  labs(title    = paste0("El mínimo nominal subió ", percent(crec_nom, accuracy = 1),
                         " desde ", min(sm$anio), ", pero el real solo ",
                         percent(crec_real, accuracy = 1)),
       subtitle = "Ingreso mínimo mensual, nominal y en pesos de 2010",
       x = NULL, y = "Pesos por mes",
       caption = "Fuente: salario_minimo_chile.csv (ingreso mínimo e IPC), 2014–2025.") +
  theme(legend.position = "none")

g2

ggsave("output/figuras/t4p1_g2_salario_minimo.png", g2, width = 8, height = 5, dpi = 300)


# a) ¿Por qué el eje Y no necesita partir en 0 aquí y en barras sí?
# En un gráfico de líneas el mensaje está en la POSICIÓN y la PENDIENTE de los
# puntos (la tendencia), no en la longitud de un área. En barras, el largo
# (el área) codifica el valor, así que truncar el eje exagera visualmente las
# diferencias (el factor de engaño). En la línea el eje igual se rotula con
# claridad para no confundir. Aquí, entre 2014 y 2025 el mínimo nominal subió 
# 135 % y el real 44 %: lo que importa es esa diferencia de trayectoria, no 
# cuánto mide la línea desde cero

# b) ¿Qué ganas con color Y tipo de línea?
# Codificación redundante: si el gráfico se imprime en blanco y negro o lo
# ve una persona daltónica, las series siguen distinguiéndose por el trazo
# (continuo vs. punteado); el color refuerza la lectura en pantalla.Así, aunque 
# el nominal y el real están a niveles distintos, cada serie se reconoce por su 
# color y por su trazo (continuo y punteado).

### Gráfico 3 · ENE: en qué trabajan hombres y mujeres
ene <- read.csv2("data/raw/ene-2026-06-mjj.csv")
names(ene) <- tolower(names(ene))

stopifnot(all(c("activ", "sexo", "categoria_ocupacion", "fact_cal") %in% names(ene)))

ocupados <- ene |>
  filter(activ == 1) |>
  mutate(sexo = factor(sexo, levels = c(1, 2), labels = c("Hombres", "Mujeres")),
         categoria = factor(categoria_ocupacion, levels = 1:7,
                            labels = c("Empleador", "Cuenta propia",
                                       "Asalariado privado", "Asalariado público",
                                       "Servicio doméstico (p. adentro)",
                                       "Servicio doméstico (p. afuera)",
                                       "Familiar no remunerado"))) |>
  filter(!is.na(categoria), !is.na(sexo))

# Tabla de composición PONDERADA (para responder con cifras)
comp <- ocupados |>
  count(sexo, categoria, wt = fact_cal, name = "personas") |>
  group_by(sexo) |>
  mutate(prop = personas / sum(personas)) |>
  ungroup() |>
  select(sexo, categoria, prop) |>
  pivot_wider(names_from = sexo, values_from = prop) |>
  mutate(brecha_pp = (Mujeres - Hombres) * 100) |>
  arrange(desc(abs(brecha_pp)))
comp

sin_pond <- ocupados |>
  count(sexo, categoria) |>
  group_by(sexo) |> mutate(prop = n / sum(n)) |> ungroup() |>
  select(-n) |>
  pivot_wider(names_from = sexo, values_from = prop) |>
  mutate(brecha_pp = (Mujeres - Hombres) * 100)
sin_pond

mayor_dif <- comp$categoria[1]
menor_dif <- comp$categoria[which.min(abs(comp$brecha_pp))]

g3 <- ggplot(ocupados, aes(x = sexo, fill = categoria, weight = fact_cal)) +
  geom_bar(position = "fill", width = 0.65) +
  scale_fill_viridis_d(option = "D", end = 0.95) +
  scale_y_continuous(labels = label_percent(), expand = expansion(mult = c(0, 0.02))) +
  labs(title    = paste0("Hombres y mujeres se ocupan distinto: la mayor brecha está en «",
                         mayor_dif, "»"),
       subtitle = "Composición de los ocupados por categoría ocupacional, según sexo",
       x = NULL, y = "Porcentaje de los ocupados de cada sexo", fill = NULL,
       caption = "Fuente: ENE, trimestre mayo-julio 2026. Solo ocupados. Ponderado con fact_cal.") +
  guides(fill = guide_legend(nrow = 3))

g3

ggsave("output/figuras/t4p1_g3_ene_categoria_sexo.png", g3, width = 9, height = 6, dpi = 300)

# a) La mayor diferencia está en Asalariado privado: 64,9 % de los hombres
# contra 53,9 % de las mujeres (10,9 puntos porcentuales). Casi no hay
# diferencia en Cuenta propia: 21,1 % de los hombres contra 21,2 % de las
# mujeres (0,08 puntos).

# b) Sin weight = fact_cal, el porcentaje de mujeres asalariadas privadas
# pasaría de 53,9 % a 50,4 %. Sin ponderar, los porcentajes describen a los 
# encuestados y no a Chile, porque cada registro representa a un número distinto
# de personas.