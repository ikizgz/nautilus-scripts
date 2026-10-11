#!/usr/bin/env bash
# ==============================================================================
# Script para Nautilus: Reconocimiento de Texto (OCR en Español)
# Utiliza ocrmypdf y tesseract-ocr
# ==============================================================================

# Obtener la ruta del directorio actual y cargar funciones comunes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common-functions.sh"

# Verificar dependencias necesarias
check_dependency "ocrmypdf" "ocrmypdf"
check_dependency "tesseract" "tesseract-ocr-spa"

# Recoger los archivos seleccionados en Nautilus
IFS=$'\n' read -d '' -r -a files <<< "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"

# Validar que se haya seleccionado al menos un archivo
if [ ${#files[@]} -eq 0 ]; then
    zenity --warning --title="OCR en PDF" --text="Por favor, selecciona al menos un archivo PDF."
    exit 1
fi

# Preguntar al modo de procesamiento
ocr_mode=$(zenity --list --title="Opciones de OCR" \
    --text="Selecciona el modo de procesamiento OCR:" \
    --radiolist --column="Selección" --column="Modo" --column="Descripción" \
    TRUE "redo" "Rehacer OCR (Procesa todas las páginas aunque tengan texto)" \
    FALSE "skip" "Omitir páginas con texto (Más rápido, solo escaneados sin texto)")

[ -z "$ocr_mode" ] && exit 0

# Configurar el parámetro según la opción
if [ "$ocr_mode" == "redo" ]; then
    OCR_FLAG="--force-ocr"
else
    OCR_FLAG="--skip-text"
fi

# Procesar cada archivo seleccionado
total=${#files[@]}
current=0

(
for file in "${files[@]}"; do
    ((current++))
    percent=$(( current * 100 / total ))

    dir_name="$(dirname "$file")"
    base_name="$(basename "$file" .pdf)"
    output_file="${dir_name}/${base_name}_OCR.pdf"

    echo "$percent"
    echo "# Procesando ($current/$total): $(basename "$file")..."

    # Ejecutar OCRmyPDF en español (spa)
    ocrmypdf -l spa $OCR_FLAG "$file" "$output_file" &>/dev/null
done
) | zenity --progress --title="Procesando OCR" --text="Iniciando OCR..." --percentage=0 --auto-close --auto-kill

if [ $? -eq 0 ]; then
    show_notification "OCR Completado" "Se han procesado $total archivo(s) correctamente con texto reconocible."
else
    zenity --error --title="Error" --text="El proceso de OCR fue cancelado o finalizó con errores."
    exit 1
fi
