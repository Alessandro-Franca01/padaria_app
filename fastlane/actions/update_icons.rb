module Fastlane
    module Actions
      class UpdateIconsAction < Action
        def self.run(params)
          require 'yaml'
          require 'fileutils'
  
          client_name = params[:client_name]
          config_file = params[:config_file] || "clients_config.yaml"
          
          UI.message("🎨 Atualizando ícones para: #{client_name}")
          
          config = YAML.load_file(config_file)
          client_config = config['clients'][client_name]
          
          icons_config = client_config['icons']
          
          # Atualizar ícones Android
          if icons_config && icons_config['android']
            update_android_icons(icons_config['android'])
          else
            UI.message("  ⚠️  Caminho de ícones Android não configurado, pulando...")
          end
          
          UI.success("✅ Ícones atualizados!")
        end
  
        def self.update_android_icons(source_path)
          return unless Dir.exist?(source_path)
          
          target_dir = "android/app/src/main/res"
          
          # Mapeamento de densidades Android
          densities = {
            'mipmap-mdpi' => 'mdpi',
            'mipmap-hdpi' => 'hdpi',
            'mipmap-xhdpi' => 'xhdpi',
            'mipmap-xxhdpi' => 'xxhdpi',
            'mipmap-xxxhdpi' => 'xxxhdpi'
          }
          
          densities.each do |mipmap_dir, density|
            source_dir = File.join(source_path, density)
            target_mipmap = File.join(target_dir, mipmap_dir)
            
            if Dir.exist?(source_dir)
              FileUtils.mkdir_p(target_mipmap) unless File.directory?(target_mipmap)
              
              # Copiar ic_launcher.png
              source_icon = File.join(source_dir, "ic_launcher.png")
              target_icon = File.join(target_mipmap, "ic_launcher.png")
              
              if File.exist?(source_icon)
                FileUtils.cp(source_icon, target_icon)
                UI.message("  ✓ Ícone copiado: #{mipmap_dir}")
              end
            end
          end
        end
  
        def self.description
          "Atualiza ícones do app (Android e iOS)"
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
          true
        end
      end
    end
  end