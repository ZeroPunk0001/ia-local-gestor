#!/data/data/com.termux/files/usr/bin/bash

# ============================================
# 🧠 IA LOCAL GESTOR - INSTALACIÓN COMPLETA
# ============================================
# Creado por @ZeroPunk0001 para la comunidad Termux
# GitHub: https://github.com/ZeroPunk0001/ia-local-gestor
# ============================================
# EJECUTAR UNA SOLA VEZ:
#   curl -sSL https://tinyurl.com/ia-local | bash
# ============================================

VERDE='\033[0;32m'
AZUL='\033[0;34m'
AMARILLO='\033[0;33m'
ROJO='\033[0;31m'
NC='\033[0m'

# === DETECTAR SISTEMA ===
detectar_sistema() {
    echo -e "${AZUL}🔍 Detectando sistema...${NC}"
    
    if [ -d "/data/data/com.termux" ]; then
        echo -e "${VERDE}📱 Termux detectado${NC}"
        SISTEMA="termux"
        PAQUETE="pkg"
        BIN_DIR="$PREFIX/bin"
        return 0
    elif [ -f "/etc/os-release" ]; then
        echo -e "${VERDE}🐧 Linux detectado${NC}"
        SISTEMA="linux"
        BIN_DIR="/usr/local/bin"
        
        if command -v apt &> /dev/null; then
            PAQUETE="sudo apt"
        elif command -v pacman &> /dev/null; then
            PAQUETE="sudo pacman -S"
        elif command -v dnf &> /dev/null; then
            PAQUETE="sudo dnf"
        else
            echo -e "${ROJO}❌ Gestor de paquetes no reconocido${NC}"
            echo -e "Instala ollama manualmente: https://ollama.com"
            exit 1
        fi
    else
        echo -e "${ROJO}❌ Sistema no soportado${NC}"
        exit 1
    fi
}

# === INSTALAR OLLAMA ===
instalar_ollama() {
    echo -e "${AZUL}📦 Instalando ollama...${NC}"
    
    if command -v ollama &> /dev/null; then
        echo -e "${VERDE}✅ Ollama ya está instalado${NC}"
        return 0
    fi
    
    case $SISTEMA in
        termux)
            pkg update -y
            pkg install -y ollama
            ;;
        linux)
            echo -e "${AMARILLO}⬇️ Descargando ollama desde web oficial...${NC}"
            curl -fsSL https://ollama.com/install.sh | sh
            ;;
    esac
    
    if command -v ollama &> /dev/null; then
        echo -e "${VERDE}✅ Ollama instalado correctamente${NC}"
    else
        echo -e "${ROJO}❌ Error instalando ollama${NC}"
        exit 1
    fi
}

# === INSTALAR DEPENDENCIAS BÁSICAS ===
instalar_deps() {
    echo -e "${AZUL}📦 Instalando dependencias básicas...${NC}"
    
    case $SISTEMA in
        termux)
            pkg install -y curl wget git nano
            ;;
        linux)
            if command -v apt &> /dev/null; then
                sudo apt update
                sudo apt install -y curl wget git nano
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm curl wget git nano
            fi
            ;;
    esac
    
    echo -e "${VERDE}✅ Dependencias instaladas${NC}"
}

# === CREAR EL COMANDO "ia" ===
crear_comando_ia() {
    echo -e "${AZUL}🔧 Creando comando 'ia'...${NC}"
    
    # Aquí va el contenido COMPLETO de tu script gestor.sh
    cat > "$BIN_DIR/ia" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# ============================================
# 🧠 GESTOR DE IAS LOCAL
# Creado por @ZeroPunk0001
# GitHub: https://github.com/ZeroPunk0001/ia-local-gestor
# ============================================

VERDE='\033[0;32m'
AZUL='\033[0;34m'
AMARILLO='\033[0;33m'
ROJO='\033[0;31m'
NC='\033[0m'

mostrar_banner() {
    clear
    echo -e "${VERDE}╔════════════════════════════════════╗${NC}"
    echo -e "${VERDE}║     🧠  GESTOR DE IAS LOCAL  🧠    ║${NC}"
    echo -e "${VERDE}╚════════════════════════════════════╝${NC}"
    echo -e "${AZUL}   Por @ZeroPunk0001 para la comunidad${NC}"
    echo ""
}

iniciar_servidor() {
    echo -e "${AZUL}🔍 Verificando servidor Ollama...${NC}"
    if ! pgrep -f "ollama serve" > /dev/null; then
        echo -e "${AMARILLO}🚀 Iniciando servidor Ollama (modo silencioso)...${NC}"
        ollama serve > /dev/null 2>&1 &
        sleep 3
        echo -e "${VERDE}✅ Servidor iniciado (sin logs molestos)${NC}"
    else
        echo -e "${VERDE}✅ Servidor ya está corriendo${NC}"
    fi
}

listar_modelos() {
    echo -e "\n${AZUL}📦 Modelos instalados:${NC}"
    modelos=($(ollama list | tail -n +2 | awk '{print $1}'))
    
    if [ ${#modelos[@]} -eq 0 ]; then
        echo -e "${ROJO}❌ No hay modelos instalados${NC}"
        return 1
    else
        for i in "${!modelos[@]}"; do
            echo -e "${VERDE}$((i+1)). ${modelos[$i]}${NC}"
        done
    fi
    return 0
}

instalar_modelo() {
    echo -e "\n${AZUL}📥 Modelos disponibles para instalar:${NC}"
    echo -e "${VERDE}1. phi3      (rápido, 2.3GB)${NC}"
    echo -e "${VERDE}2. mistral   (balance, 4.1GB)${NC}"
    echo -e "${VERDE}3. llama3    (poderoso, 4.7GB)${NC}"
    echo -e "${VERDE}4. codellama (programación, 4GB)${NC}"
    echo -e "${VERDE}5. gemma:2b  (ultra rápido, 1.5GB)${NC}"
    echo -e "${VERDE}6. deepseek-coder-v2 (programación avanzada, 8.9GB)${NC}"
    echo -e "${AMARILLO}7. Otro (especificar nombre)${NC}"
    echo -e "${ROJO}8. Cancelar${NC}"
    
    read -p "Elige opción: " opcion_instalar
    
    case $opcion_instalar in
        1) modelo="phi3" ;;
        2) modelo="mistral" ;;
        3) modelo="llama3" ;;
        4) modelo="codellama" ;;
        5) modelo="gemma:2b" ;;
        6) modelo="deepseek-coder-v2:16b-lite" ;;
        7) read -p "Nombre del modelo: " modelo ;;
        8) return ;;
        *) echo -e "${ROJO}Opción inválida${NC}"; return ;;
    esac
    
    echo -e "${AMARILLO}⬇️ Descargando $modelo...${NC}"
    ollama pull "$modelo"
}

main() {
    mostrar_banner
    iniciar_servidor
    
    while true; do
        echo -e "\n${AZUL}════════════════════════════════════${NC}"
        listar_modelos
        echo -e "${AZUL}════════════════════════════════════${NC}"
        echo -e "${VERDE}a. Ejecutar IA${NC}"
        echo -e "${AMARILLO}i. Instalar nueva IA${NC}"
        echo -e "${ROJO}s. Salir${NC}"
        echo -e "${AZUL}════════════════════════════════════${NC}"
        
        read -p "Opción: " opcion
        
        case $opcion in
            [aA])
                modelos=($(ollama list | tail -n +2 | awk '{print $1}'))
                if [ ${#modelos[@]} -eq 0 ]; then
                    echo -e "${ROJO}❌ No hay modelos. Instala uno primero.${NC}"
                    sleep 2
                    continue
                fi
                
                echo -e "\n${AZUL}Elige modelo:${NC}"
                for i in "${!modelos[@]}"; do
                    echo -e "${VERDE}$((i+1)). ${modelos[$i]}${NC}"
                done
                
                read -p "Número: " num
                if [ "$num" -ge 1 ] && [ "$num" -le ${#modelos[@]} ]; then
                    modelo_elegido="${modelos[$((num-1))]}"
                    echo -e "${VERDE}🎯 Iniciando $modelo_elegido...${NC}"
                    echo -e "${AMARILLO}(Escribe 'exit' para salir del chat)${NC}\n"
                    ollama run "$modelo_elegido"
                else
                    echo -e "${ROJO}Número inválido${NC}"
                    sleep 2
                fi
                ;;
                
            [iI])
                instalar_modelo
                ;;
                
            [sS])
                echo -e "${VERDE}👋 ¡Hasta luego!${NC}"
                exit 0
                ;;
                
            *)
                echo -e "${ROJO}Opción inválida${NC}"
                sleep 2
                ;;
        esac
    done
}

trap 'echo -e "\n${ROJO}⚠️  Interrumpido${NC}"; exit 0' INT

main "$@"
EOF

    chmod +x "$BIN_DIR/ia"
    echo -e "${VERDE}✅ Comando 'ia' creado en $BIN_DIR/ia${NC}"
}

# === MENSAJE FINAL ===
mensaje_final() {
    echo -e "\n${VERDE}═══════════════════════════════════════════${NC}"
    echo -e "${VERDE}✅ INSTALACIÓN COMPLETADA EXITOSAMENTE${NC}"
    echo -e "${VERDE}═══════════════════════════════════════════${NC}"
    echo -e "${AZUL}Creado por @ZeroPunk0001${NC}"
    echo -e "\n${AMARILLO}📝 Para usar el gestor, solo escribe:${NC}"
    echo -e "${VERDE}   ia${NC}"
    echo -e "\n${AMARILLO}📥 Para instalar modelos:${NC}"
    echo -e "${VERDE}   ia  →  i  →  elige número${NC}"
    echo -e "\n${VERDE}═══════════════════════════════════════════${NC}"
    
    # Preguntar si quiere ejecutar el gestor ahora
    echo -e "\n${AZUL}¿Quieres ejecutar el gestor ahora? (s/n)${NC}"
    read ejecutar
    if [ "$ejecutar" = "s" ] || [ "$ejecutar" = "S" ]; then
        ia
    fi
}

# === EJECUCIÓN PRINCIPAL ===
main_instalador() {
    echo -e "${AZUL}╔════════════════════════════════════╗${NC}"
    echo -e "${AZUL}║   🧠 INSTALADOR DE GESTOR DE IAS   ║${NC}"
    echo -e "${AZUL}║      por @ZeroPunk0001             ║${NC}"
    echo -e "${AZUL}╚════════════════════════════════════╝${NC}"
    echo ""
    
    detectar_sistema
    instalar_deps
    instalar_ollama
    crear_comando_ia
    mensaje_final
}

# === INICIO ===
main_instalador
