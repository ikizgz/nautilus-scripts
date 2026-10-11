#!/usr/bin/env bash
# ==============================================================================
# Script para Nautilus: Dividir PDF en páginas individuales
# Utiliza pdfseparate (poppler-utils)
# ==============================================================================

# Obtener la ruta del directorio actual y cargar funciones comunes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common-functions.sh"

# Verificar dependencias necesarias
check_dependency "pdfseparate" "poppler-utils"

# Recoger el archivo seleccionado en Nautilus
IFS=$'\n' read -d '' -r -a files <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"

# Validar que se haya seleccionado exactamente 1 archivo
if [ ${#files[@]} -ne 1 ]; then
    zenity --warning --title="Dividir PDF" --text="Por favor, selecciona únicamente un archivo PDF para dividir."
    exit 1
fi

file="${files[0]}"

# Validar extensión .pdf
if [[ "${file,,}" != *.pdf ]]; then
    zenity --error --title="Error" --text="El archivo seleccionado no es un PDF válido."
    exit 1
fi

dir_name="$(dirname "$file")"
base_name="$(basename "$file" .pdf)"

# Preguntar al usuario el prefijo o carpeta de salida para no saturar el directorio original
output_pattern="${dir_name}/${base_name}_pagina_%d.pdf"

# Ejecutar la división con pdfseparate (%d se reemplaza por el número de página)
if pdfseparate "$file" "$output_pattern"; then
    show_notification "PDF Dividido" "Se han extraído con éxito todas las páginas de:\n$base_name"
else
    zenity --error --title="Error" --text="Ocurrió un error al intentar dividir el archivo PDF."
    exit 1
fi