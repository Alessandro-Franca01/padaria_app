# Ícone do Aplicativo

## Como adicionar o ícone personalizado:

1. **Crie ou obtenha uma imagem do ícone:**
   - Formato: PNG (recomendado) ou JPG
   - Tamanho recomendado: 1024x1024 pixels (mínimo 512x512)
   - Fundo transparente (PNG) funciona melhor
   - O ícone deve ser quadrado

2. **Salve a imagem:**
   - Nome do arquivo: `app_icon.png`
   - Localização: `assets/icon/app_icon.png`

3. **Ícone Adaptativo (Opcional - Android 8.0+):**
   - Se você tiver uma versão do ícone sem fundo, salve como: `app_icon_foreground.png`
   - Caso contrário, o mesmo ícone será usado para o foreground
   - O fundo adaptativo será a cor marrom (#8B4513) configurada no pubspec.yaml

4. **Gere os ícones:**
   Após adicionar a imagem, execute no terminal:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

5. **Teste:**
   - Desinstale o app do dispositivo/emulador
   - Execute: `flutter run`
   - O novo ícone deve aparecer

## Dicas:
- Use um editor de imagens para criar o ícone (Canva, Figma, Photoshop, etc.)
- Certifique-se de que o ícone seja legível em tamanhos pequenos
- Teste o ícone em diferentes tamanhos antes de publicar

