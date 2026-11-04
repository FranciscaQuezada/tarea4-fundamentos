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

# Declaración de autoría y uso de IA
- Herramienta utilizada: Claude 
- Para qué la usé: obtener un borrador inicial de los scripts a partir del enunciado 
y de los laboratorios, entender y corregir errores de R, revisar mis scripts contra 
la rúbrica y armar la estructura del README.
- Qué hice yo: ejecuté el código con mis datos, comprobé que cada título y comentario 
coincidiera con mis resultados, completé las cifras de las respuestas, corregí detalles de los gráficos, ordené el repositorio y los commits, y [escribí la reflexión con mis palabras / revisé y reescribí la reflexión].
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.
