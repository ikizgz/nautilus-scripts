#!/usr/bin/env bash
# ==============================================================================
# Script para Nautilus: Comprimir y optimizar PDF
# Utiliza Ghostscript (gs)
# ==============================================================================

# Obtener la ruta del directorio actual y cargar funciones comunes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common-functions.sh"

# Verificar dependencias necesarias
check_dependency "gs" "ghostscript"

# Recoger el archivo seleccionado en Nautilus
IFS=$'\n' read -d '' -r -a files <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"

# Validar que se haya seleccionado exactamente 1 archivo
if [ ${#files[@]} -ne 1 ]; then
    zenity --warning --title="Comprimir PDF" --text="Por favor, selecciona únicamente un archivo PDF para comprimir."
    exit 1
fi

file="${files[0]}"

# Validar extensión .pdf
if [[ "${file,,}" != *.pdf ]]; then
    zenity --error --title="Error" --text="El archivo seleccionado no es un PDF válido."
    exit 1
fi

# Preguntar al usuario el nivel de compresión mediante un selector gráfico
quality=$(zenity --list --title="Optimizar PDF" \
    --text="Selecciona el nivel de compresión deseado:" \
    --radiolist --column="Selección" --column="Nivel" --column="Descripción" \
    FALSE "screen" "Pantalla (Baja calidad, tamaño muy pequeño - 72 dpi)" \
    TRUE "ebook" "E-book (Calidad estándar, equilibrado - 150 dpi)" \
    FALSE "printer" "Impresión (Alta calidad, menor compresión - 300 dpi)")

# Si el usuario cancela, salimos
[ -z "$quality" ] && exit 0

dir_name="$(dirname "$file")"
base_name="$(basename "$file" .pdf)"
output_file="${dir_name}/${base_name}_optimizado.pdf"

# Ejecutar Ghostscript para comprimir el PDF
if gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS="/$quality" \
    -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$output_file" "$file"; then

    # Calcular tamaños para mostrar información del ahorro
    original_size=$(du -h "$file" | cut -f1)
    new_size=$(du -h "$output_file" | cut -f1)

    show_notification "PDF Optimizado" "Completado con éxito.\nTamaño original: $original_size\nNuevo tamaño: $new_size"
else
    zenity --error --title="Error" --text="Ocurrió un error al intentar comprimir el archivo PDF."
    exit 1