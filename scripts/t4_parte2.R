
# T4 - Parte 2: Portafolio y figura compuesta (Semana 11)
# Autor: Francisca Quezada
# Fecha: 2026-11-03

# Pregunta general: ¿cómo se distribuyen el ingreso (CASEN) y la informalidad
# laboral (ENE) en Chile, y qué gráfico lo comunica mejor?

library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)
library(patchwork)
library(scales)

azul <- "#0072B2"; oro <- "#E69F00"; gris <- "grey70"     # Okabe-Ito
pesos <- label_currency(big.mark = ".", decimal.mark = ",")

# Tema propio como función
tema_t4 <- function(base = 12) {
  theme_minimal(base_size = base) +
    theme(plot.title       = element_text(face = "bold", color = "#222222"),
          plot.caption     = element_text(color = "grey40", hjust = 0),
          panel.grid.minor = element_blank(),
          panel.grid.major.y = element_blank(),
          legend.position  = "bottom")
}
theme_set(tema_t4())

dir.create("output/figuras", recursive = TRUE, showWarnings = FALSE)

# Media/mediana ponderada (para las horas)
wmediana <- function(x, w) {
  o <- order(x); x <- x[o]; w <- w[o]
  x[which(cumsum(w) >= sum(w) / 2)[1]]
}

## Datos
casen <- read.csv("data/raw/casen_reducido.csv") |>
  filter(!is.na(ingreso))

ene <- read.csv2("data/raw/ene-2026-06-mjj.csv")
names(ene) <- tolower(names(ene))

stopifnot(all(c("activ", "sexo", "ocup_form", "region", "habituales", "edad",
                "fact_cal") %in% names(ene)))

regiones <- c("1" = "Tarapacá", "2" = "Antofagasta", "3" = "Atacama",
              "4" = "Coquimbo", "5" = "Valparaíso", "6" = "O'Higgins",
              "7" = "Maule", "8" = "Biobío", "9" = "Araucanía",
              "10" = "Los Lagos", "11" = "Aysén", "12" = "Magallanes",
              "13" = "Metropolitana", "14" = "Los Ríos",
              "15" = "Arica y Parinacota", "16" = "Ñuble")

ocupados <- ene |>
  filter(activ == 1) |>
  mutate(sexo = factor(sexo, levels = c(1, 2), labels = c("Hombres", "Mujeres")),
         informal = ocup_form == 2,
         region_n = if (is.numeric(region)) unname(regiones[as.character(region)])
         else as.character(region)) |>
  filter(!is.na(sexo), !is.na(informal))

fuente_ene <- "Fuente: ENE, trimestre mayo-julio 2026. Solo ocupados. Ponderado con fact_cal."

# Tasa de informalidad nacional ponderada
nacional <- with(ocupados, sum(fact_cal[informal]) / sum(fact_cal))
nacional

### Gráfico 1: Scatter CASEN (referencia de estilo)
pend <- casen |>
  group_by(genero) |>
  summarise(pendiente = unname(coef(lm(ingreso ~ educ))[2]))

mayor <- pend$genero[which.max(pend$pendiente)]

g1 <- ggplot(casen, aes(educ, ingreso, color = genero)) +
  geom_point(size = 2, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1) +
  scale_color_manual(values = c(azul, oro)) +
  scale_y_continuous(labels = pesos) +
  labs(title = paste0("La escolaridad rinde más en el grupo ", mayor),
       x = "Años de escolaridad", y = "Ingreso mensual", color = "Género",
       caption = "Fuente: CASEN (subconjunto de 55 personas con ingreso). Sin ponderar.")
g1

ggsave("output/figuras/t4p2_g1_casen.png", g1, width = 8, height = 5, dpi = 300)

### Gráfico 2: Informalidad por región (ponderado, una región resaltada)
inf_region <- ocupados |>
  filter(!is.na(region_n)) |>
  group_by(region_n) |>
  summarise(tasa = sum(fact_cal[informal]) / sum(fact_cal), .groups = "drop") |>
  mutate(destacada = tasa == max(tasa))            # variable LÓGICA para resaltar

region_max <- inf_region$region_n[inf_region$destacada]

g2 <- ggplot(inf_region, aes(tasa, reorder(region_n, tasa), fill = destacada)) +
  geom_col(width = 0.75) +                         # barras: eje desde 0
  geom_text(aes(label = percent(tasa, accuracy = 0.1, decimal.mark = ",")),
            hjust = -0.15, size = 3.2) +           # valores escritos
  geom_vline(xintercept = nacional, linetype = "dashed", color = "black") +
  annotate("text", x = nacional, y = 1, label = paste0(" Nacional: ",
                                                       percent(nacional, accuracy = 0.1, decimal.mark = ",")),
           hjust = 0, vjust = 3, size = 3.2) +
  scale_fill_manual(values = c(`FALSE` = gris, `TRUE` = azul), guide = "none") +
  scale_x_continuous(labels = label_percent(), expand = expansion(mult = c(0, 0.12))) +
  labs(title = paste0(region_max, " es la región con mayor informalidad laboral"),
       subtitle = "Tasa de informalidad entre los ocupados, por región",
       x = NULL, y = NULL, caption = fuente_ene)
g2

ggsave("output/figuras/t4p2_g2_informalidad_region.png", g2, width = 8, height = 6, dpi = 300)

### Gráfico 3: Horas habituales por sexo (sin centinelas 888 y 999)
horas <- ocupados |>
  filter(!habituales %in% c(888, 999), !is.na(habituales)) |>
  mutate(w = fact_cal / sum(fact_cal), .by = sexo)     # pesos normalizados por sexo

med_horas <- horas |>
  group_by(sexo) |>
  summarise(mediana = wmediana(habituales, fact_cal))

med_horas

g3 <- ggplot(horas, aes(habituales, fill = sexo, weight = w)) +
  geom_density(alpha = 0.55, color = NA, adjust = 1.5) +
  geom_vline(data = med_horas, aes(xintercept = mediana, color = sexo),
             linetype = "dashed", linewidth = 0.9, show.legend = FALSE) +
  scale_fill_manual(values = c(azul, oro)) +
  scale_color_manual(values = c(azul, oro)) +
  scale_y_continuous(labels = NULL) +
  coord_cartesian(xlim = c(0, 90)) +                   # zoom SIN borrar datos
  labs(title = paste0("Los hombres trabajan una mediana de ",
                      med_horas$mediana[med_horas$sexo == "Hombres"], " horas y las mujeres, ",
                      med_horas$mediana[med_horas$sexo == "Mujeres"]),
       subtitle = "Distribución de horas habituales semanales (líneas = medianas)",
       x = "Horas habituales por semana", y = "Densidad", fill = NULL,
       caption = paste0(fuente_ene, " Sin códigos 888 y 999."))
g3

ggsave("output/figuras/t4p2_g3_horas_sexo.png", g3, width = 8, height = 5, dpi = 300)

# ¿Por qué densidad? (justificación)
# - La ENE tiene miles de observaciones por sexo: la densidad no sugiere una
# precisión que no existe (a diferencia de los 27–28 casos de la CASEN en el
# lab, donde era mejor mostrar puntos).
# - Muestra la FORMA completa: picos en jornadas típicas (40–45 h) y la cola de
# jornadas parciales, que un boxplot resume en cinco números y esconde.
# - Con dos grupos, la superposición con transparencia es legible; un violín
# agregaría simetría redundante y el boxplot ocultaría la bimodalidad.

### Gráfico 4: Informalidad hombres vs mujeres por región (ggrepel)
inf_sexo <- ocupados |>
  filter(!is.na(region_n)) |>
  group_by(region_n, sexo) |>
  summarise(tasa = sum(fact_cal[informal]) / sum(fact_cal), .groups = "drop") |>
  pivot_wider(names_from = sexo, values_from = tasa)

lim <- range(c(inf_sexo$Hombres, inf_sexo$Mujeres)) + c(-0.02, 0.02) #para darle un poco de margen

g4 <- ggplot(inf_sexo, aes(Hombres, Mujeres)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey40") +  # y = x
  geom_point(color = azul, size = 2.5) +
  geom_text_repel(aes(label = region_n), size = 3, seed = 123,
                  max.overlaps = Inf, box.padding = 0.4, color = "grey20") +
  scale_x_continuous(labels = label_percent()) +
  scale_y_continuous(labels = label_percent()) +
  coord_equal(xlim = lim, ylim = lim) +
  labs(title = "La informalidad masculina y la femenina van de la mano por región",
       subtitle = "Bajo la diagonal: más informalidad entre hombres · sobre ella: entre mujeres",
       x = "Informalidad de los hombres", y = "Informalidad de las mujeres",
       caption = fuente_ene)
g4

ggsave("output/figuras/t4p2_g4_hombres_vs_mujeres.png", g4, width = 7, height = 7, dpi = 300)

### Gráfico 5: Libre - ¿la informalidad tiene forma de U por edad?
inf_edad <- ocupados |>
  filter(!is.na(edad), edad >= 15) |>
  mutate(tramo = cut(edad, breaks = c(15, seq(20, 65, by = 5), Inf), right = FALSE,
                     labels = c("15–19", "20–24", "25–29", "30–34", "35–39", "40–44",
                                "45–49", "50–54", "55–59", "60–64", "65+"))) |>
  group_by(tramo) |>
  summarise(tasa = sum(fact_cal[informal]) / sum(fact_cal), .groups = "drop") |>
  mutate(minimo = tasa == min(tasa))

tramo_min <- as.character(inf_edad$tramo[inf_edad$minimo])

g5 <- ggplot(inf_edad, aes(tramo, tasa, group = 1)) +
  geom_line(color = gris, linewidth = 1) +
  geom_point(aes(color = minimo), size = 3) +
  geom_text(aes(label = percent(tasa, accuracy = 1)), vjust = -1, size = 3) +
  scale_color_manual(values = c(`FALSE` = gris, `TRUE` = azul), guide = "none") +
  scale_y_continuous(labels = label_percent(), expand = expansion(mult = c(0, 0.15))) +
  coord_cartesian(ylim = c(0, NA)) +
  labs(title = paste0("La informalidad es la más baja a los ", tramo_min,
                      " años y sube en los extremos"),
       subtitle = "Tasa de informalidad entre los ocupados, por tramo de edad",
       x = "Edad", y = NULL, caption = fuente_ene)
g5

ggsave("output/figuras/t4p2_g5_informalidad_edad.png", g5, width = 8, height = 5, dpi = 300)


### La figura compuesta
# Combina **tres** de tus gráficos en una figura con `patchwork`: A = región, 
# B = hombres/mujeres, C = edad
figura <- (g2 | (g4 / g5)) +
  plot_layout(widths = c(1, 1.1)) +
  plot_annotation(
    title = paste0("La informalidad laboral afecta a ", percent(nacional, accuracy = 1),
                   " de los ocupados: es mayor en ", region_max,
                   " y en los extremos de la edad"),
    caption = fuente_ene,
    tag_levels = "A")

# Títulos de panel más chicos para que quepan (con & afecta a todos los paneles)
figura <- figura & theme(plot.title = element_text(size = 10.5),
                         plot.subtitle = element_text(size = 9),
                         plot.caption = element_blank())

figura <- figura + plot_annotation(caption = fuente_ene)   # caption general
figura

ggsave("output/figuras/t4p2_figura_compuesta.png", figura, width = 14, height = 9, dpi = 300)
ggsave("output/figuras/t4p2_figura_compuesta.pdf", figura, width = 14, height = 9,
       device = cairo_pdf)   

### La reflexión (0,5 página)

# 1. De los cinco gráficos, ¿cuál comunica **mejor** su hallazgo y por qué?
# El gráfico 2 (barras por región): usa el color con función (gris para el
# contexto, un solo color para el mensaje), valores escritos y una línea de
# referencia (promedio nacional), de modo que se entiende sin explicación oral.
# Las barras parten en 0 (precisión) y el título declara el hallazgo. Tiene una
# alta razón datos/tinta: sin leyenda, sin grilla densa, sin chart junk.

# 2. En el gráfico 3, ¿por qué elegiste ese geom y no otro?
# Elegí densidad porque la ENE tiene miles de casos por sexo, así que la forma
# de la distribución es estable y no sugiere falsa precisión (con n pequeño
# sería más honesto mostrar puntos). La densidad deja ver los picos en jornadas
# de 40–45 horas y la cola de jornadas parciales; el boxplot los resumiría en
# cinco números y ocultaría esa estructura, y el violín repite la información
# con simetría redundante. Las medianas (líneas) dan el número de referencia.

# 3. ¿Qué agrega la figura compuesta que no dan los gráficos por separado?
# Muestra la informalidad desde tres ángulos (territorio, sexo, edad) bajo un
# mismo título-hallazgo, misma paleta y misma fuente. Eso permite comparar y
# descartar explicaciones (p. ej. que la brecha regional no es una brecha de
# sexo) en una sola lectura, algo que tres gráficos sueltos no logran. Los
# rótulos A–B–C permiten referirse a cada panel en el texto.