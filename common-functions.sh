#!/usr/bin/env bash
# ==============================================================================
# Nombre: common-functions.sh
# Descripción: Funciones comunes para los scripts de Nautilus de Ignacio
# ==============================================================================

# Comprobar si una herramienta del sistema está instalada.
# Si no está, pregunta al usuario si desea instalarla mediante apt.
check_dependency() {
    local cmd="$1"
    local pkg="${2:-$cmd}" # Si no se pasa el nombre del paquete, usa el del comando

    if ! command -v "$cmd" &>/dev/null; then
        if zenity --question --title="Dependencia faltante" \
            --text="La herramienta necesaria <b>'$cmd'</b> (paquete '$pkg') no está instalada.\n¿Deseas instalarla ahora?"; then
            pkexec apt update && pkexec apt install -y "$pkg"
        else
            zenity --error --title="Operación cancelada" --text="No se puede continuar sin la dependencia '$cmd'."
            exit 1
        fi
    fi
}

# Mostrar notificación de escritorio
show_notification() {
    local title="$1"
    local message="$2"
    local type="${3:-normal}" # normal, critical
    notify-send -u "$type" -i "dialog-information" "$title" "$message"
}