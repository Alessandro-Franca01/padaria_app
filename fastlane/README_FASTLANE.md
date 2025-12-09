# Guia de Build Multi-Cliente com Fastlane

Este projeto usa Fastlane para gerar builds customizados para diferentes clientes (padarias).

## Pré-requisitos

1. **Ruby** instalado (geralmente já vem com macOS/Linux, no Windows use RubyInstaller)
2. **Fastlane** instalado:
   ```bash
   gem install fastlane
   ```
3. **Flutter SDK** instalado e configurado
4. **Android SDK** configurado

## Estrutura de Configuração

O arquivo `clients_config.yaml` na raiz do projeto contém as configurações de cada cliente:
- Cores personalizadas
- Nome do app
- Package name
- Strings customizadas
- Caminhos dos ícones

## Como Gerar APKs

### Opção 1: Usando Fastlane (Recomendado)

#### Para Padaria Central:
```bash
fastlane build_central
```

#### Para Padaria Nordeste:
```bash
fastlane build_nordeste
```

#### Para qualquer cliente:
```bash
fastlane build_client client_name:padaria_central
```

### Opção 2: Manual (sem Fastlane)

Se preferir fazer manualmente:

1. **Gerar o arquivo de configuração JSON:**
   ```bash
   # Você precisará criar manualmente o arquivo assets/config/client_config.json
   # com base no clients_config.yaml
   ```

2. **Atualizar configurações Android:**
   - Editar `android/app/build.gradle` (applicationId e namespace)
   - Editar `android/app/src/main/res/values/strings.xml` (app_name)
   - Editar `android/app/src/main/res/values/colors.xml` (cores)

3. **Build Flutter:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

## O que o Fastlane faz automaticamente:

1. ✅ Lê o `clients_config.yaml`
2. ✅ Gera `assets/config/client_config.json` para o Flutter
3. ✅ Atualiza `android/app/build.gradle` (package name)
4. ✅ Atualiza `android/app/src/main/AndroidManifest.xml` (app name)
5. ✅ Atualiza `android/app/src/main/res/values/strings.xml` (app name)
6. ✅ Atualiza `android/app/src/main/res/values/colors.xml` (cores)
7. ✅ Copia ícones personalizados (se existirem)
8. ✅ Executa `flutter build apk --release`

## Localização do APK Gerado

Após o build, o APK estará em:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Adicionar Novo Cliente

1. Adicione a configuração no `clients_config.yaml`:
   ```yaml
   novo_cliente:
     app_name: "Novo Cliente"
     package_name: "com.padariaapp.novo"
     # ... outras configurações
   ```

2. Crie uma nova lane no `fastlane/Fastfile`:
   ```ruby
   lane :build_novo_cliente do
     build_client(client_name: "novo_cliente")
   end
   ```

3. Execute:
   ```bash
   fastlane build_novo_cliente
   ```

## Troubleshooting

### Erro: "fastlane: command not found"
- Instale o Fastlane: `gem install fastlane`

### Erro: "YAML file not found"
- Certifique-se de que `clients_config.yaml` está na raiz do projeto

### Erro: "Client not found"
- Verifique se o nome do cliente no comando corresponde ao nome no YAML

### APK não está customizado
- Verifique se o arquivo `assets/config/client_config.json` foi gerado
- Verifique se os arquivos Android foram atualizados corretamente
- Execute `flutter clean` antes de fazer o build novamente

## Notas Importantes

- ⚠️ O arquivo `assets/config/client_config.json` é gerado automaticamente e não deve ser commitado (já está no .gitignore)
- ⚠️ Os arquivos Android são modificados durante o build, então pode ser necessário fazer commit/restore após cada build
- ⚠️ Certifique-se de ter os ícones nas pastas corretas conforme especificado no YAML
