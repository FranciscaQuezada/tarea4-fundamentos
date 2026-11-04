## T4 — Portafolio de visualización con ggplot2

Autor: Francisca Quezada 
Fecha: 2026-11-03
Qué hace: Este repositorio contiene mi entrega de la T4: gráficos construidos con ggplot2 que responden preguntas económicas con datos de la CASEN, el ingreso mínimo y la Encuesta Nacional de Empleo (ENE). Cada gráfico sigue el checklist de la Semana 9 (título que dice el hallazgo, paleta accesible, fuente en la caption, ejes con unidades, sin chart junk y exportado a 300 dpi).

# Cómo reproducir
Abrir el proyecto desde el archivo .Rproj (las rutas son relativas).
Instalar los paquetes, si hace falta:

install.packages(c("dplyr", "tidyr", "ggplot2", "scales", "ggrepel", "patchwork"))
   
Correr cada script completo (Source o Ctrl + Enter):
scripts/t4_parte1.R
scripts/t4_parte2.R
Las figuras se guardan en output/figuras/.