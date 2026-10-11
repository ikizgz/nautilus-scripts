#!/usr/bin/env bash
# ==============================================================================
# Script para Nautilus: Combinar PDFs seleccionados
# Utiliza pdfunite (poppler-utils)
# ==============================================================================

# Cargar funciones comunes (asumiendo que common-functions.sh está en la raíz)
# Obtener la ruta absoluta del directorio donde se encuentra el script actual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Cargar common-functions.sh subiendo un nivel desde la carpeta de la categoría
source "$SCRIPT_DIR/../common-functions.sh"

# Verificar dependencias necesarias
check_dependency "pdfunite" "poppler-utils"

# Recoger los archivos seleccionados en Nautilus
# Nautilus pasa los archivos separados por saltos de línea en $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
# o como argumentos posicionales ($@) dependiendo de cómo se invoque.
IFS=$'\n' read -d '' -r -a files <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"

# Validar que haya al menos 2 archivos seleccionados
if [ ${#files[@]} -lt 2 ]; then
    zenity --warning --title="Combinar PDFs" --text="Por favor, selecciona al menos dos archivos PDF para combinar."
    exit 1
fi

# Pedir al usuario el nombre del archivo resultante usando Zenity
output_name=$(zenity --entry --title="Combinar PDFs" \
    --text="Introduce el nombre para el PDF combinado:" \
    --entry-text="documento_combinado.pdf")

# Si el usuario cancela, salimos
[ -z "$output_name" ] && exit 0

# Obtener el directorio de trabajo del primer archivo seleccionado
target_dir="$(dirname "${files[0]}")"
output_path="$target_dir/$output_name"

# Asegurar extensión .pdf
[[ "$output_path" != *.pdf ]] && output_path="${output_path}.pdf"

# Ejecutar pdfunite pasando los archivos seleccionados y la ruta final
# Usamos un array temporal para los archivos
if pdfunite "${files[@]}" "$output_path"; then
    show_notification "PDFs Combinados" "El archivo se ha creado con éxito en:\n$output_path"
else
    zenity --error --title="Error" --text="Hubo un fallo al intentar combinar los archivos PDF."
    exit 1
fi