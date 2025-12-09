module Fastlane
    module Actions
      class UpdateAndroidConfigAction < Action
        def self.run(params)
          require 'yaml'
  
          client_name = params[:client_name]
          config_file = params[:config_file] || "clients_config.yaml"
          
          UI.message("🤖 Atualizando configurações Android para: #{client_name}")
          
          config = YAML.load_file(config_file)
          client_config = config['clients'][client_name]
          
          # 1. Atualizar build.gradle
          update_build_gradle(client_config)
          
          # 2. Atualizar AndroidManifest.xml
          update_android_manifest(client_config)
          
          # 3. Atualizar strings.xml
          update_strings_xml(client_config)
          
          # 4. Atualizar colors.xml
          update_colors_xml(client_config)
          
          UI.success("✅ Configurações Android atualizadas!")
        end
  
        def self.update_build_gradle(client_config)
          gradle_file = "android/app/build.gradle"
          return unless File.exist?(gradle_file)
          
          content = File.read(gradle_file)
          package_name = client_config['package_name']
          
          # Substituir applicationId
          content.gsub!(/applicationId\s*=\s*"[^"]*"/, "applicationId = \"#{package_name}\"")
          content.gsub!(/namespace\s*=\s*"[^"]*"/, "namespace = \"#{package_name}\"")
          
          File.write(gradle_file, content)
          UI.message("  ✓ build.gradle atualizado")
        end
  
        def self.update_android_manifest(client_config)
          manifest_file = "android/app/src/main/AndroidManifest.xml"
          return unless File.exist?(manifest_file)
          
          content = File.read(manifest_file)
          app_name = client_config['app_name']
          
          # Substituir android:label se não estiver usando @string/app_name
          unless content.include?("@string/app_name")
            content.gsub!(/android:label="[^"]*"/, "android:label=\"#{app_name}\"")
          end
          
          File.write(manifest_file, content)
          UI.message("  ✓ AndroidManifest.xml atualizado")
        end
  
        def self.update_strings_xml(client_config)
          strings_dir = "android/app/src/main/res/values"
          FileUtils.mkdir_p(strings_dir) unless File.directory?(strings_dir)
          
          strings_file = File.join(strings_dir, "strings.xml")
          app_name = client_config['app_name']
          
          strings_content = <<~XML
            <?xml version="1.0" encoding="utf-8"?>
            <resources>
                <string name="app_name">#{app_name}</string>
            </resources>
          XML
          
          File.write(strings_file, strings_content)
          UI.message("  ✓ strings.xml atualizado")
        end
  
        def self.update_colors_xml(client_config)
          colors_dir = "android/app/src/main/res/values"
          FileUtils.mkdir_p(colors_dir) unless File.directory?(colors_dir)
          
          colors_file = File.join(colors_dir, "colors.xml")
          colors = client_config['colors']
          
          colors_content = <<~XML
            <?xml version="1.0" encoding="utf-8"?>
            <resources>
                <color name="colorPrimary">#{colors['primary']}</color>
                <color name="colorPrimaryDark">#{colors['primary_dark']}</color>
                <color name="colorAccent">#{colors['accent']}</color>
                <color name="colorSecondary">#{colors['secondary']}</color>
            </resources>
          XML
          
          File.write(colors_file, colors_content)
          UI.message("  ✓ colors.xml atualizado")
        end
  
        def self.description
          "Atualiza configurações Android (package, nome, cores)"
        end
  
        def self.available_options
          [
            FastlaneCore::ConfigItem.new(
              key: :client_name,
              description: "Nome do cliente",
              optional: false
            ),
            FastlaneCore::ConfigItem.new(
              key: :config_file,
              description: "Caminho do arquivo clients_config.yaml",
              optional: true,
              default_value: "clients_config.yaml"
            )
          ]
        end
  
        def self.is_supported?(platform)
          [:android].include?(platform)
        end
      end
    end
  end