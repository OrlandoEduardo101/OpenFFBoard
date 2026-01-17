#!/bin/bash

# Script para corrigir permissões do OpenFFBoard no macOS
# Execute com: bash fix_macos_permissions.sh

APP_PATH="/Users/orlandoeduardo101/Projects/arduino/OpenFFBoard/Configurator/OpenFFBoard/OpenFFBoard"
APP_DIR="/Users/orlandoeduardo101/Projects/arduino/OpenFFBoard/Configurator/OpenFFBoard"

echo "🔧 Corrigindo permissões do OpenFFBoard no macOS..."
echo ""

# 1. Remover quarentena de todos os arquivos
echo "1. Removendo atributos de quarentena..."
find "$APP_DIR" -type f -exec xattr -d com.apple.quarantine {} \; 2>/dev/null
find "$APP_DIR" -type f -exec xattr -d com.apple.provenance {} \; 2>/dev/null
echo "   ✅ Quarentena removida"
echo ""

# 2. Dar permissão de execução
echo "2. Configurando permissões de execução..."
chmod +x "$APP_PATH"
find "$APP_DIR/_internal" -type f -name "Python" -exec chmod +x {} \; 2>/dev/null
find "$APP_DIR/_internal" -type f -name "*.so" -exec chmod +x {} \; 2>/dev/null
echo "   ✅ Permissões configuradas"
echo ""

# 3. Tentar adicionar exceção no Gatekeeper (requer sudo)
echo "3. Tentando adicionar exceção no Gatekeeper..."
echo "   (Isso pode pedir sua senha)"
sudo spctl --add "$APP_PATH" 2>/dev/null && echo "   ✅ Exceção adicionada" || echo "   ⚠️  Não foi possível adicionar exceção (pode precisar fazer manualmente)"
echo ""

# 4. Re-assinar todas as bibliotecas e executáveis
echo "4. Re-assinando bibliotecas e executáveis..."
echo "   (Isso pode demorar um pouco...)"

# Re-assinar o executável principal
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null && echo "   ✅ Executável principal re-assinado" || echo "   ⚠️  Erro ao re-assinar executável"

# Re-assinar Python
if [ -f "$APP_DIR/_internal/Python" ]; then
    codesign --force --deep --sign - "$APP_DIR/_internal/Python" 2>/dev/null && echo "   ✅ Python re-assinado" || echo "   ⚠️  Erro ao re-assinar Python"
fi

# Re-assinar bibliotecas .so
find "$APP_DIR/_internal" -name "*.so" -exec codesign --force --sign - {} \; 2>/dev/null
echo "   ✅ Bibliotecas .so re-assinadas"

# Re-assinar bibliotecas .dylib (se houver)
find "$APP_DIR/_internal" -name "*.dylib" -exec codesign --force --sign - {} \; 2>/dev/null
echo "   ✅ Bibliotecas .dylib re-assinadas"

# Re-assinar frameworks Qt
find "$APP_DIR/_internal" -name "Qt*" -type f -executable -exec codesign --force --sign - {} \; 2>/dev/null
echo "   ✅ Bibliotecas Qt re-assinadas"
echo ""

# 5. Verificar assinatura
echo "5. Verificando assinatura de código..."
codesign -vvv "$APP_PATH" 2>&1 | head -3
echo ""

echo "✨ Processo concluído!"
echo ""
echo "📝 Se ainda houver problemas (segmentation fault), tente:"
echo "   1. Executar: sudo spctl --master-disable"
echo "   2. Executar o programa"
echo "   3. Reabilitar: sudo spctl --master-enable"
echo ""
echo "🚀 Para executar o programa:"
echo "   $APP_PATH"
echo ""
echo "💡 Dica: Se o problema persistir, pode ser incompatibilidade do PyQt6."
echo "   Considere baixar uma versão mais recente do configurador."

