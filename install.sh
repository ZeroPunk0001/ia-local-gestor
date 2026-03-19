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
# 🧠 IA LOCAL GESTOR v2.0.0
# ============================================
# Creado por @ZeroPunk0001 para la comunidad
# Fecha: Marzo 2026
# ============================================

VERDE='\033[0;32m'
AZUL='\033[0;34m'
AMARILLO='\033[0;33m'
ROJO='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

VERSION="2.0.0"
CONFIG_FILE="$HOME/.ia-config"

# ============================================
# 🌐 DEFINICIÓN DE IDIOMAS
# ============================================

declare -A MSG

# ===== ESPAÑOL (es) =====
cargar_espanol() {
    MSG[bienvenida]="╔════════════════════════════════════╗"
    MSG[titulo]="║     🧠  GESTOR DE IAS LOCAL v$VERSION  ║"
    MSG[creador]="║      por @ZeroPunk0001              ║"
    MSG[borde]="╚════════════════════════════════════╝"
    
    MSG[menu_a]="a. Ejecutar IA"
    MSG[menu_i]="i. Instalar nueva IA"
    MSG[menu_b]="b. Borrar IA"
    MSG[menu_v]="v. Ver información del modelo"
    MSG[menu_s]="s. Salir"
    MSG[menu_idioma]="Cambiar idioma"
    
    MSG[instalar_titulo]="📥 Modelos disponibles para instalar:"
    MSG[instalar_op1]="1. phi3 (rápido, 2.3GB)"
    MSG[instalar_op2]="2. mistral (balance, 4.1GB)"
    MSG[instalar_op3]="3. llama3 (poderoso, 4.7GB)"
    MSG[instalar_op4]="4. codellama (programación, 4GB)"
    MSG[instalar_op5]="5. gemma:2b (ultra rápido, 1.5GB)"
    MSG[instalar_op6]="6. deepseek-coder-v2 (programación avanzada, 8.9GB)"
    MSG[instalar_op7]="7. Otro (especificar nombre)"
    MSG[instalar_op8]="8. Cancelar"
    MSG[instalar_elegir]="Elige opción: "
    MSG[instalar_nombre]="Nombre del modelo: "
    MSG[instalar_descargando]="⬇️ Descargando %s..."
    MSG[instalar_ok]="✅ Modelo instalado correctamente"
    
    MSG[borrar_titulo]="📦 Modelos instalados para borrar:"
    MSG[borrar_elegir]="Elige número a borrar (0 para cancelar): "
    MSG[borrar_confirmar]="⚠️ ¿Borrar PERMANENTEMENTE '%s'? (s/n): "
    MSG[borrar_cancelar]="❌ Operación cancelada"
    MSG[borrar_ok]="✅ Modelo eliminado correctamente"
    MSG[borrar_advertencia]="⚠️ ¡CUIDADO! Vas a borrar una IA permanentemente\n   Esta acción NO SE PUEDE DESHACER\n   ¿Seguro que quieres continuar? (s/n): "
    
    MSG[info_titulo]="📦 Modelos instalados:"
    MSG[info_elegir]="Elige modelo para ver detalles (0 para cancelar): "
    MSG[info_cargando]="📊 Cargando información..."
    MSG[info_no_disponible]="ℹ️ Información detallada no disponible"
    
    MSG[error_opcion]="❌ Opción inválida"
    MSG[error_sin_modelos]="❌ No hay modelos instalados"
    MSG[error_no_existe]="❌ El modelo no existe"
    MSG[error_seleccion]="❌ Selección inválida"
    MSG[error_servidor]="❌ Error con el servidor Ollama"
    MSG[salir]="👋 ¡Hasta luego!"
    MSG[interrumpido]="⚠️ Interrumpido"
    
    MSG[idioma_titulo]="🌐 SELECCIONA TU IDIOMA / SELECT YOUR LANGUAGE"
    MSG[idioma_op1]="1. Español"
    MSG[idioma_op2]="2. English"
    MSG[idioma_op3]="3. Português"
    MSG[idioma_op4]="4. Français"
    MSG[idioma_op5]="5. 中文"
    MSG[idioma_op6]="6. 日本語"
    MSG[idioma_op7]="7. Русский"
    MSG[idioma_elegir]="Elige opción: "
    MSG[idioma_guardado]="✅ Idioma guardado."
}

# ===== ENGLISH (en) =====
cargar_english() {
    MSG[bienvenida]="╔════════════════════════════════════╗"
    MSG[titulo]="║     🧠  LOCAL AI MANAGER v$VERSION   ║"
    MSG[creador]="║      by @ZeroPunk0001               ║"
    MSG[borde]="╚════════════════════════════════════╝"
    
    MSG[menu_a]="a. Run AI"
    MSG[menu_i]="i. Install new AI"
    MSG[menu_b]="b. Delete AI"
    MSG[menu_v]="v. View model info"
    MSG[menu_s]="s. Exit"
    MSG[menu_idioma]="Change language"
    
    MSG[instalar_titulo]="📥 Available models to install:"
    MSG[instalar_op1]="1. phi3 (fast, 2.3GB)"
    MSG[instalar_op2]="2. mistral (balanced, 4.1GB)"
    MSG[instalar_op3]="3. llama3 (powerful, 4.7GB)"
    MSG[instalar_op4]="4. codellama (programming, 4GB)"
    MSG[instalar_op5]="5. gemma:2b (ultra fast, 1.5GB)"
    MSG[instalar_op6]="6. deepseek-coder-v2 (advanced programming, 8.9GB)"
    MSG[instalar_op7]="7. Other (specify name)"
    MSG[instalar_op8]="8. Cancel"
    MSG[instalar_elegir]="Choose option: "
    MSG[instalar_nombre]="Model name: "
    MSG[instalar_descargando]="⬇️ Downloading %s..."
    MSG[instalar_ok]="✅ Model installed successfully"
    
    MSG[borrar_titulo]="📦 Installed models to delete:"
    MSG[borrar_elegir]="Choose number to delete (0 to cancel): "
    MSG[borrar_confirmar]="⚠️ Permanently delete '%s'? (y/n): "
    MSG[borrar_cancelar]="❌ Operation cancelled"
    MSG[borrar_ok]="✅ Model deleted successfully"
    MSG[borrar_advertencia]="⚠️ WARNING! You are about to permanently delete an AI\n   This action CANNOT BE UNDONE\n   Are you sure you want to continue? (y/n): "
    
    MSG[info_titulo]="📦 Installed models:"
    MSG[info_elegir]="Choose model to view details (0 to cancel): "
    MSG[info_cargando]="📊 Loading information..."
    MSG[info_no_disponible]="ℹ️ Detailed information not available"
    
    MSG[error_opcion]="❌ Invalid option"
    MSG[error_sin_modelos]="❌ No models installed"
    MSG[error_no_existe]="❌ Model does not exist"
    MSG[error_seleccion]="❌ Invalid selection"
    MSG[error_servidor]="❌ Ollama server error"
    MSG[salir]="👋 Goodbye!"
    MSG[interrumpido]="⚠️ Interrupted"
    
    MSG[idioma_titulo]="🌐 SELECT YOUR LANGUAGE / SELECCIONA TU IDIOMA"
    MSG[idioma_op1]="1. Español"
    MSG[idioma_op2]="2. English"
    MSG[idioma_op3]="3. Português"
    MSG[idioma_op4]="4. Français"
    MSG[idioma_op5]="5. 中文"
    MSG[idioma_op6]="6. 日本語"
    MSG[idioma_op7]="7. Русский"
    MSG[idioma_elegir]="Choose option: "
    MSG[idioma_guardado]="✅ Language saved."
}

# ===== PORTUGUÊS (pt) =====
cargar_portugues() {
    MSG[bienvenida]="╔════════════════════════════════════╗"
    MSG[titulo]="║     🧠  GESTOR DE IAS LOCAL v$VERSION  ║"
    MSG[creador]="║      por @ZeroPunk0001              ║"
    MSG[borde]="╚════════════════════════════════════╝"
    
    MSG[menu_a]="a. Executar IA"
    MSG[menu_i]="i. Instalar nova IA"
    MSG[menu_b]="b. Apagar IA"
    MSG[menu_v]="v. Ver informações do modelo"
    MSG[menu_s]="s. Sair"
    MSG[menu_idioma]="Mudar idioma"
    
    MSG[instalar_titulo]="📥 Modelos disponíveis para instalar:"
    MSG[instalar_op1]="1. phi3 (rápido, 2.3GB)"
    MSG[instalar_op2]="2. mistral (equilibrado, 4.1GB)"
    MSG[instalar_op3]="3. llama3 (poderoso, 4.7GB)"
    MSG[instalar_op4]="4. codellama (programação, 4GB)"
    MSG[instalar_op5]="5. gemma:2b (ultra rápido, 1.5GB)"
    MSG[instalar_op6]="6. deepseek-coder-v2 (programação avançada, 8.9GB)"
    MSG[instalar_op7]="7. Outro (especificar nome)"
    MSG[instalar_op8]="8. Cancelar"
    MSG[instalar_elegir]="Escolha uma opção: "
    MSG[instalar_nombre]="Nome do modelo: "
    MSG[instalar_descargando]="⬇️ Baixando %s..."
    MSG[instalar_ok]="✅ Modelo instalado com sucesso"
    
    MSG[borrar_titulo]="📦 Modelos instalados para apagar:"
    MSG[borrar_elegir]="Escolha número para apagar (0 para cancelar): "
    MSG[borrar_confirmar]="⚠️ Apagar PERMANENTEMENTE '%s'? (s/n): "
    MSG[borrar_cancelar]="❌ Operação cancelada"
    MSG[borrar_ok]="✅ Modelo eliminado com sucesso"
    MSG[borrar_advertencia]="⚠️ CUIDADO! Você vai apagar uma IA permanentemente\n   Esta ação NÃO PODE SER DESFEITA\n   Tem certeza que quer continuar? (s/n): "
    
    MSG[info_titulo]="📦 Modelos instalados:"
    MSG[info_elegir]="Escolha modelo para ver detalhes (0 para cancelar): "
    MSG[info_cargando]="📊 Carregando informações..."
    MSG[info_no_disponible]="ℹ️ Informação detalhada não disponível"
    
    MSG[error_opcion]="❌ Opção inválida"
    MSG[error_sin_modelos]="❌ Nenhum modelo instalado"
    MSG[error_no_existe]="❌ O modelo não existe"
    MSG[error_seleccion]="❌ Seleção inválida"
    MSG[error_servidor]="❌ Erro no servidor Ollama"
    MSG[salir]="👋 Até logo!"
    MSG[interrumpido]="⚠️ Interrompido"
    
    MSG[idioma_titulo]="🌐 SELECIONE SEU IDIOMA / SELECT YOUR LANGUAGE"
    MSG[idioma_op1]="1. Español"
    MSG[idioma_op2]="2. English"
    MSG[idioma_op3]="3. Português"
    MSG[idioma_op4]="4. Français"
    MSG[idioma_op5]="5. 中文"
    MSG[idioma_op6]="6. 日本語"
    MSG[idioma_op7]="7. Русский"
    MSG[idioma_elegir]="Escolha uma opção: "
    MSG[idioma_guardado]="✅ Idioma salvo."
}

# ===== FRANÇAIS (fr) =====
cargar_frances() {
    MSG[bienvenida]="╔════════════════════════════════════╗"
    MSG[titulo]="║     🧠  GESTIONNAIRE IA v$VERSION     ║"
    MSG[creador]="║      par @ZeroPunk0001               ║"
    MSG[borde]="╚════════════════════════════════════╝"
    
    MSG[menu_a]="a. Exécuter IA"
    MSG[menu_i]="i. Installer nouvelle IA"
    MSG[menu_b]="b. Supprimer IA"
    MSG[menu_v]="v. Voir infos modèle"
    MSG[menu_s]="s. Quitter"
    MSG[menu_idioma]="Changer langue"
    
    MSG[instalar_titulo]="📥 Modèles disponibles à installer:"
    MSG[instalar_op1]="1. phi3 (rapide, 2.3GB)"
    MSG[instalar_op2]="2. mistral (équilibré, 4.1GB)"
    MSG[instalar_op3]="3. llama3 (puissant, 4.7GB)"
    MSG[instalar_op4]="4. codellama (programmation, 4GB)"
    MSG[instalar_op5]="5. gemma:2b (ultra rapide, 1.5GB)"
    MSG[instalar_op6]="6. deepseek-coder-v2 (programmation avancée, 8.9GB)"
    MSG[instalar_op7]="7. Autre (spécifier nom)"
    MSG[instalar_op8]="8. Annuler"
    MSG[instalar_elegir]="Choisissez une option: "
    MSG[instalar_nombre]="Nom du modèle: "
    MSG[instalar_descargando]="⬇️ Téléchargement %s..."
    MSG[instalar_ok]="✅ Modèle installé avec succès"
    
    MSG[borrar_titulo]="📦 Modèles installés à supprimer:"
    MSG[borrar_elegir]="Choisissez le numéro à supprimer (0 pour annuler): "
    MSG[borrar_confirmar]="⚠️ Supprimer DÉFINITIVEMENT '%s'? (o/n): "
    MSG[borrar_cancelar]="❌ Opération annulée"
    MSG[borrar_ok]="✅ Modèle supprimé avec succès"
    MSG[borrar_advertencia]="⚠️ ATTENTION! Vous allez supprimer définitivement une IA\n   Cette action NE PEUT PAS ÊTRE ANNULÉE\n   Êtes-vous sûr de vouloir continuer? (o/n): "
    
    MSG[info_titulo]="📦 Modèles installés:"
    MSG[info_elegir]="Choisissez un modèle pour voir les détails (0 pour annuler): "
    MSG[info_cargando]="📊 Chargement des informations..."
    MSG[info_no_disponible]="ℹ️ Informations détaillées non disponibles"
    
    MSG[error_opcion]="❌ Option invalide"
    MSG[error_sin_modelos]="❌ Aucun modèle installé"
    MSG[error_no_existe]="❌ Le modèle n'existe pas"
    MSG[error_seleccion]="❌ Sélection invalide"
    MSG[error_servidor]="❌ Erreur du serveur Ollama"
    MSG[salir]="👋 Au revoir!"
    MSG[interrumpido]="⚠️ Interrompu"
    
    MSG[idioma_titulo]="🌐 CHOISISSEZ VOTRE LANGUE / SELECT YOUR LANGUAGE"
    MSG[idioma_op1]="1. Español"
    MSG[idioma_op2]="2. English"
    MSG[idioma_op3]="3. Português"
    MSG[idioma_op4]="4. Français"
    MSG[idioma_op5]="5. 中文"
    MSG[idioma_op6]="6. 日本語"
    MSG[idioma_op7]="7. Русский"
    MSG[idioma_elegir]="Choisissez une option: "
    MSG[idioma_guardado]="✅ Langue enregistrée."
}

# ===== 中文 (zh) =====
cargar_chino() {
    MSG[bienvenida]="╔════════════════════════════════════╗"
    MSG[titulo]="║     🧠  AI管理器 v$VERSION           ║"
    MSG[creador]="║      作者 @ZeroPunk0001             ║"
    MSG[borde]="╚════════════════════════════════════╝"
    
    MSG[menu_a]="a. 运行AI"
    MSG[menu_i]="i. 安装新AI"
    MSG[menu_b]="b. 删除AI"
    MSG[menu_v]="v. 查看模型信息"
    MSG[menu_s]="s. 退出"
    MSG[menu_idioma]="更改语言"
    
    MSG[instalar_titulo]="📥 可安装的模型:"
    MSG[instalar_op1]="1. phi3 (快速, 2.3GB)"
    MSG[instalar_op2]="2. mistral (平衡, 4.1GB)"
    MSG[instalar_op3]="3. llama3 (强大, 4.7GB)"
    MSG[instalar_op4]="4. codellama (编程, 4GB)"
    MSG[instalar_op5]="5. gemma:2b (超快, 1.5GB)"
    MSG[instalar_op6]="6. deepseek-coder-v2 (高级编程, 8.9GB)"
    MSG[instalar_op7]="7. 其他 (指定名称)"
    MSG[instalar_op8]="8. 取消"
    MSG[instalar_elegir]="选择选项: "
    MSG[instalar_nombre]="模型名称: "
    MSG[instalar_descargando]="⬇️ 正在下载 %s..."
    MSG[instalar_ok]="✅ 模型安装成功"
    
    MSG[borrar_titulo]="📦 已安装的模型:"
    MSG[borrar_elegir]="选择要删除的编号 (0取消): "
    MSG[borrar_confirmar]="⚠️ 永久删除 '%s'? (是/否): "
    MSG[borrar_cancelar]="❌ 操作已取消"
    MSG[borrar_ok]="✅ 模型删除成功"
    MSG[borrar_advertencia]="⚠️ 警告！您将要永久删除一个AI\n   此操作无法撤销\n   确定要继续吗？ (是/否): "
    
    MSG[info_titulo]="📦 已安装的模型:"
    MSG[info_elegir]="选择要查看详情的模型 (0取消): "
    MSG[info_cargando]="📊 正在加载信息..."
    MSG[info_no_disponible]="ℹ️ 详细信息不可用"
    
    MSG[error_opcion]="❌ 无效选项"
    MSG[error_sin_modelos]="❌ 没有安装任何模型"
    MSG[error_no_existe]="❌ 模型不存在"
    MSG[error_seleccion]="❌ 无效选择"
    MSG[error_servidor]="❌ Ollama服务器错误"
    MSG[salir]="👋 再见！"
    MSG[interrumpido]="⚠️ 中断"
    
    MSG[idioma_titulo]="🌐 选择您的语言 / SELECT YOUR LANGUAGE"
    MSG[idioma_op1]="1. Español"
    MSG[idioma_op2]="2. English"
    MSG[idioma_op3]="3. Português"
    MSG[idioma_op4]="4. Français"
    MSG[idioma_op5]="5. 中文"
    MSG[idioma_op6]="6. 日本語"
    MSG[idioma_op7]="7. Русский"
    MSG[idioma_elegir]="选择选项: "
    MSG[idioma_guardado]="✅ 语言已保存。"
}

# ===== 日本語 (ja) =====
cargar_japones() {
    MSG[bienvenida]="╔════════════════════════════════════╗"
    MSG[titulo]="║     🧠  AIマネージャー v$VERSION      ║"
    MSG[creador]="║      作者 @ZeroPunk0001              ║"
    MSG[borde]="╚════════════════════════════════════╝"
    
    MSG[menu_a]="a. AIを実行"
    MSG[menu_i]="i. 新しいAIをインストール"
    MSG[menu_b]="b. AIを削除"
    MSG[menu_v]="v. モデル情報を見る"
    MSG[menu_s]="s. 終了"
    MSG[menu_idioma]="言語を変更"
    
    MSG[instalar_titulo]="📥 インストール可能なモデル:"
    MSG[instalar_op1]="1. phi3 (高速, 2.3GB)"
    MSG[instalar_op2]="2. mistral (バランス, 4.1GB)"
    MSG[instalar_op3]="3. llama3 (強力, 4.7GB)"
    MSG[instalar_op4]="4. codellama (プログラミング, 4GB)"
    MSG[instalar_op5]="5. gemma:2b (超高速, 1.5GB)"
    MSG[instalar_op6]="6. deepseek-coder-v2 (高度なプログラミング, 8.9GB)"
    MSG[instalar_op7]="7. その他 (名前を指定)"
    MSG[instalar_op8]="8. キャンセル"
    MSG[instalar_elegir]="オプションを選択: "
    MSG[instalar_nombre]="モデル名: "
    MSG[instalar_descargando]="⬇️ %sをダウンロード中..."
    MSG[instalar_ok]="✅ モデルが正常にインストールされました"
    
    MSG[borrar_titulo]="📦 インストール済みモデル:"
    MSG[borrar_elegir]="削除する番号を選択 (0でキャンセル): "
    MSG[borrar_confirmar]="⚠️ '%s'を完全に削除しますか？ (y/n): "
    MSG[borrar_cancelar]="❌ 操作がキャンセルされました"
    MSG[borrar_ok]="✅ モデルが削除されました"
    MSG[borrar_advertencia]="⚠️ 警告！AIを完全に削除しようとしています\n   この操作は元に戻せません\n   続行してもよろしいですか？ (y/n): "
    
    MSG[info_titulo]="📦 インストール済みモデル:"
    MSG[info_elegir]="詳細を表示するモデルを選択 (0でキャンセル): "
    MSG[info_cargando]="📊 情報を読み込んでいます..."
    MSG[info_no_disponible]="ℹ️ 詳細情報は利用できません"
    
    MSG[error_opcion]="❌ 無効なオプション"
    MSG[error_sin_modelos]="❌ モデルがインストールされていません"
    MSG[error_no_existe]="❌ モデルが存在しません"
    MSG[error_seleccion]="❌ 無効な選択"
    MSG[error_servidor]="❌ Ollamaサーバーエラー"
    MSG[salir]="👋 さようなら！"
    MSG[interrumpido]="⚠️ 中断されました"
    
    MSG[idioma_titulo]="🌐 言語を選択 / SELECT YOUR LANGUAGE"
    MSG[idioma_op1]="1. Español"
    MSG[idioma_op2]="2. English"
    MSG[idioma_op3]="3. Português"
    MSG[idioma_op4]="4. Français"
    MSG[idioma_op5]="5. 中文"
    MSG[idioma_op6]="6. 日本語"
    MSG[idioma_op7]="7. Русский"
    MSG[idioma_elegir]="オプションを選択: "
    MSG[idioma_guardado]="✅ 言語が保存されました。"
}

# ===== РУССКИЙ (ru) =====
cargar_ruso() {
    MSG[bienvenida]="╔════════════════════════════════════╗"
    MSG[titulo]="║     🧠  МЕНЕДЖЕР ИИ v$VERSION        ║"
    MSG[creador]="║      от @ZeroPunk0001               ║"
    MSG[borde]="╚════════════════════════════════════╝"
    
    MSG[menu_a]="a. Запустить ИИ"
    MSG[menu_i]="i. Установить новый ИИ"
    MSG[menu_b]="b. Удалить ИИ"
    MSG[menu_v]="v. Информация о модели"
    MSG[menu_s]="s. Выход"
    MSG[menu_idioma]="Сменить язык"
    
    MSG[instalar_titulo]="📥 Доступные модели для установки:"
    MSG[instalar_op1]="1. phi3 (быстрый, 2.3GB)"
    MSG[instalar_op2]="2. mistral (сбалансированный, 4.1GB)"
    MSG[instalar_op3]="3. llama3 (мощный, 4.7GB)"
    MSG[instalar_op4]="4. codellama (программирование, 4GB)"
    MSG[instalar_op5]="5. gemma:2b (ультрабыстрый, 1.5GB)"
    MSG[instalar_op6]="6. deepseek-coder-v2 (продвинутое программирование, 8.9GB)"
    MSG[instalar_op7]="7. Другая (указать название)"
    MSG[instalar_op8]="8. Отмена"
    MSG[instalar_elegir]="Выберите опцию: "
    MSG[instalar_nombre]="Название модели: "
    MSG[instalar_descargando]="⬇️ Загрузка %s..."
    MSG[instalar_ok]="✅ Модель успешно установлена"
    
    MSG[borrar_titulo]="📦 Установленные модели для удаления:"
    MSG[borrar_elegir]="Выберите номер для удаления (0 для отмены): "
    MSG[borrar_confirmar]="⚠️ Навсегда удалить '%s'? (д/н): "
    MSG[borrar_cancelar]="❌ Операция отменена"
    MSG[borrar_ok]="✅ Модель успешно удалена"
    MSG[borrar_advertencia]="⚠️ ВНИМАНИЕ! Вы собираетесь навсегда удалить ИИ\n   Это действие НЕЛЬЗЯ ОТМЕНИТЬ\n   Вы уверены, что хотите продолжить? (д/н): "
    
    MSG[info_titulo]="📦 Установленные модели:"
    MSG[info_elegir]="Выберите модель для просмотра деталей (0 для отмены): "
    MSG[info_cargando]="📊 Загрузка информации..."
    MSG[info_no_disponible]="ℹ️ Детальная информация недоступна"
    
    MSG[error_opcion]="❌ Неверная опция"
    MSG[error_sin_modelos]="❌ Нет установленных моделей"
    MSG[error_no_existe]="❌ Модель не существует"
    MSG[error_seleccion]="❌ Неверный выбор"
    MSG[error_servidor]="❌ Ошибка сервера Ollama"
    MSG[salir]="👋 До свидания!"
    MSG[interrumpido]="⚠️ Прервано"
    
    MSG[idioma_titulo]="🌐 ВЫБЕРИТЕ ЯЗЫК / SELECT YOUR LANGUAGE"
    MSG[idioma_op1]="1. Español"
    MSG[idioma_op2]="2. English"
    MSG[idioma_op3]="3. Português"
    MSG[idioma_op4]="4. Français"
    MSG[idioma_op5]="5. 中文"
    MSG[idioma_op6]="6. 日本語"
    MSG[idioma_op7]="7. Русский"
    MSG[idioma_elegir]="Выберите опцию: "
    MSG[idioma_guardado]="✅ Язык сохранен."
}

# ============================================
# 🎯 FUNCIONES DEL GESTOR
# ============================================

seleccionar_idioma() {
    clear
    echo -e "${CYAN}${MSG[idioma_titulo]}${NC}"
    echo ""
    echo -e "${VERDE}${MSG[idioma_op1]}${NC}"
    echo -e "${VERDE}${MSG[idioma_op2]}${NC}"
    echo -e "${VERDE}${MSG[idioma_op3]}${NC}"
    echo -e "${VERDE}${MSG[idioma_op4]}${NC}"
    echo -e "${VERDE}${MSG[idioma_op5]}${NC}"
    echo -e "${VERDE}${MSG[idioma_op6]}${NC}"
    echo -e "${VERDE}${MSG[idioma_op7]}${NC}"
    echo ""
    echo -e -n "${AMARILLO}${MSG[idioma_elegir]}${NC}"
    read opcion_idioma
    
    case $opcion_idioma in
        1) echo "es" > "$CONFIG_FILE" ;;
        2) echo "en" > "$CONFIG_FILE" ;;
        3) echo "pt" > "$CONFIG_FILE" ;;
        4) echo "fr" > "$CONFIG_FILE" ;;
        5) echo "zh" > "$CONFIG_FILE" ;;
        6) echo "ja" > "$CONFIG_FILE" ;;
        7) echo "ru" > "$CONFIG_FILE" ;;
        *) echo "es" > "$CONFIG_FILE" ;;
    esac
    
    echo -e "${VERDE}${MSG[idioma_guardado]}${NC}"
    sleep 1
}

cargar_idioma() {
    if [ ! -f "$CONFIG_FILE" ]; then
        # Temporalmente cargamos español para el selector
        cargar_espanol
        seleccionar_idioma
    fi
    
    IDIOMA=$(cat "$CONFIG_FILE" 2>/dev/null || echo "es")
    
    case $IDIOMA in
        es) cargar_espanol ;;
        en) cargar_english ;;
        pt) cargar_portugues ;;
        fr) cargar_frances ;;
        zh) cargar_chino ;;
        ja) cargar_japones ;;
        ru) cargar_ruso ;;
        *) cargar_espanol ;;
    esac
}

mostrar_banner() {
    clear
    echo -e "${VERDE}${MSG[bienvenida]}${NC}"
    echo -e "${VERDE}${MSG[titulo]}${NC}"
    echo -e "${VERDE}${MSG[creador]}${NC}"
    echo -e "${VERDE}${MSG[borde]}${NC}"
    echo ""
}

iniciar_servidor() {
    echo -e "${AZUL}🔍 Verificando servidor Ollama...${NC}"
    if ! pgrep -f "ollama serve" > /dev/null; then
        echo -e "${AMARILLO}🚀 Iniciando servidor Ollama...${NC}"
        ollama serve > /dev/null 2>&1 &
        sleep 3
        echo -e "${VERDE}✅ Servidor listo${NC}"
    else
        echo -e "${VERDE}✅ Servidor ya está corriendo${NC}"
    fi
}

listar_modelos() {
    echo -e "\n${AZUL}${MSG[info_titulo]}${NC}"
    modelos=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    
    if [ ${#modelos[@]} -eq 0 ]; then
        echo -e "${ROJO}${MSG[error_sin_modelos]}${NC}"
        return 1
    else
        for i in "${!modelos[@]}"; do
            echo -e "${VERDE}$((i+1)). ${modelos[$i]}${NC}"
        done
    fi
    return 0
}

instalar_modelo() {
    echo -e "\n${AZUL}${MSG[instalar_titulo]}${NC}"
    echo -e "${VERDE}${MSG[instalar_op1]}${NC}"
    echo -e "${VERDE}${MSG[instalar_op2]}${NC}"
    echo -e "${VERDE}${MSG[instalar_op3]}${NC}"
    echo -e "${VERDE}${MSG[instalar_op4]}${NC}"
    echo -e "${VERDE}${MSG[instalar_op5]}${NC}"
    echo -e "${VERDE}${MSG[instalar_op6]}${NC}"
    echo -e "${AMARILLO}${MSG[instalar_op7]}${NC}"
    echo -e "${ROJO}${MSG[instalar_op8]}${NC}"
    
    echo -e -n "${AMARILLO}${MSG[instalar_elegir]}${NC}"
    read opcion_instalar
    
    case $opcion_instalar in
        1) modelo="phi3" ;;
        2) modelo="mistral" ;;
        3) modelo="llama3" ;;
        4) modelo="codellama" ;;
        5) modelo="gemma:2b" ;;
        6) modelo="deepseek-coder-v2:16b-lite" ;;
        7) 
            echo -e -n "${AMARILLO}${MSG[instalar_nombre]}${NC}"
            read modelo
            [ -z "$modelo" ] && { echo -e "${ROJO}${MSG[error_seleccion]}${NC}"; return; }
            ;;
        8) return ;;
        *) echo -e "${ROJO}${MSG[error_opcion]}${NC}"; sleep 2; return ;;
    esac
    
    printf "${AMARILLO}${MSG[instalar_descargando]}${NC}\n" "$modelo"
    ollama pull "$modelo"
    
    if [ $? -eq 0 ]; then
        echo -e "${VERDE}${MSG[instalar_ok]}${NC}"
    else
        echo -e "${ROJO}${MSG[error_servidor]}${NC}"
    fi
    sleep 2
}

borrar_modelo() {
    # NIVEL 1: Advertencia inicial
    echo -e "${ROJO}${MSG[borrar_advertencia]}${NC}"
    read respuesta
    [[ "$respuesta" != "s" && "$respuesta" != "S" && "$respuesta" != "y" && "$respuesta" != "Y" ]] && { 
        echo -e "${AMARILLO}${MSG[borrar_cancelar]}${NC}"
        sleep 2
        return
    }
    
    # NIVEL 2: Listar modelos y seleccionar
    modelos=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    if [ ${#modelos[@]} -eq 0 ]; then
        echo -e "${ROJO}${MSG[error_sin_modelos]}${NC}"
        sleep 2
        return
    fi
    
    echo -e "\n${AZUL}${MSG[borrar_titulo]}${NC}"
    for i in "${!modelos[@]}"; do
        echo -e "${VERDE}$((i+1)). ${modelos[$i]}${NC}"
    done
    
    echo -e -n "${AMARILLO}${MSG[borrar_elegir]}${NC}"
    read num
    
    [[ "$num" == "0" ]] && { echo -e "${AMARILLO}${MSG[borrar_cancelar]}${NC}"; sleep 2; return; }
    [ "$num" -ge 1 ] && [ "$num" -le ${#modelos[@]} ] || { 
        echo -e "${ROJO}${MSG[error_seleccion]}${NC}"
        sleep 2
        return
    }
    
    modelo_elegido="${modelos[$((num-1))]}"
    
    # NIVEL 3: Confirmación final
    printf "${ROJO}${MSG[borrar_confirmar]}${NC}" "$modelo_elegido"
    read confirmacion
    if [[ "$confirmacion" == "s" || "$confirmacion" == "S" || "$confirmacion" == "y" || "$confirmacion" == "Y" ]]; then
        ollama rm "$modelo_elegido" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${VERDE}${MSG[borrar_ok]}${NC}"
        else
            echo -e "${ROJO}${MSG[error_servidor]}${NC}"
        fi
    else
        echo -e "${AMARILLO}${MSG[borrar_cancelar]}${NC}"
    fi
    sleep 2
}

ver_info_modelo() {
    modelos=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    if [ ${#modelos[@]} -eq 0 ]; then
        echo -e "${ROJO}${MSG[error_sin_modelos]}${NC}"
        sleep 2
        return
    fi
    
    echo -e "\n${AZUL}${MSG[info_titulo]}${NC}"
    for i in "${!modelos[@]}"; do
        echo -e "${VERDE}$((i+1)). ${modelos[$i]}${NC}"
    done
    
    echo -e -n "${AMARILLO}${MSG[info_elegir]}${NC}"
    read num
    
    [[ "$num" == "0" ]] && return
    [ "$num" -ge 1 ] && [ "$num" -le ${#modelos[@]} ] || { 
        echo -e "${ROJO}${MSG[error_seleccion]}${NC}"
        sleep 2
        return
    }
    
    modelo_elegido="${modelos[$((num-1))]}"
    
    echo -e "\n${CYAN}📊 ${MSG[info_cargando]}${NC}"
    ollama show "$modelo_elegido" 2>/dev/null || echo -e "${AMARILLO}${MSG[info_no_disponible]}${NC}"
    echo ""
    read -p "Presiona Enter para continuar..."
}

main() {
    # Primero cargar idioma, luego todo lo demás
    cargar_idioma
    mostrar_banner
    iniciar_servidor
    
    while true; do
        echo -e "\n${AZUL}════════════════════════════════════${NC}"
        listar_modelos
        echo -e "${AZUL}════════════════════════════════════${NC}"
        echo -e "${VERDE}${MSG[menu_a]}${NC}"
        echo -e "${VERDE}${MSG[menu_i]}${NC}"
        echo -e "${VERDE}${MSG[menu_b]}${NC}"
        echo -e "${VERDE}${MSG[menu_v]}${NC}"
        echo -e "${ROJO}${MSG[menu_s]}${NC}"
        echo -e "${CYAN}c. ${MSG[menu_idioma]}${NC}"  # <--- CORREGIDO: ahora tiene la letra c
        echo -e "${AZUL}════════════════════════════════════${NC}"
        
        echo -e -n "${AMARILLO}${MSG[instalar_elegir]}${NC}"
        read opcion
        
        case $opcion in
            [aA])
                modelos=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
                if [ ${#modelos[@]} -eq 0 ]; then
                    echo -e "${ROJO}${MSG[error_sin_modelos]}${NC}"
                    sleep 2
                    continue
                fi
                
                echo -e "\n${AZUL}${MSG[info_titulo]}${NC}"
                for i in "${!modelos[@]}"; do
                    echo -e "${VERDE}$((i+1)). ${modelos[$i]}${NC}"
                done
                
                echo -e -n "${AMARILLO}${MSG[instalar_elegir]}${NC}"
                read num
                if [ "$num" -ge 1 ] && [ "$num" -le ${#modelos[@]} ]; then
                    modelo_elegido="${modelos[$((num-1))]}"
                    echo -e "${VERDE}🎯 Iniciando $modelo_elegido...${NC}"
                    echo -e "${AMARILLO}(Escribe 'exit' para salir)${NC}\n"
                    ollama run "$modelo_elegido"
                else
                    echo -e "${ROJO}${MSG[error_seleccion]}${NC}"
                    sleep 2
                fi
                ;;
                
            [iI])
                instalar_modelo
                ;;
                
            [bB])
                borrar_modelo
                ;;
                
            [vV])
                ver_info_modelo
                ;;
                
            [sS])
                echo -e "${VERDE}${MSG[salir]}${NC}"
                exit 0
                ;;
                
            c|C|🌐)  # <--- CORREGIDO: ahora acepta c, C o el emoji
                seleccionar_idioma
                cargar_idioma
                mostrar_banner
                ;;
                
            *)
                echo -e "${ROJO}${MSG[error_opcion]}${NC}"
                sleep 2
                ;;
        esac
    done
}

trap 'echo -e "\n${ROJO}${MSG[interrumpido]}${NC}"; exit 0' INT

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
