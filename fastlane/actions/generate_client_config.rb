module Fastlane
    module Actions
      module SharedValues
        CLIENT_CONFIG = :CLIENT_CONFIG
      end
  
      class GenerateClientConfigAction < Action
        def self.run(params)
          require 'yaml'
          require 'json'
  
          client_name = params[:client_name]
          config_file = params[:config_file] || "clients_config.yaml"
          
          UI.message("📖 Lendo arquivo de configuração: #{config_file}")
          
          unless File.exist?(config_file)
            UI.user_error!("Arquivo de configuração não encontrado: #{config_file}")
          end
  
          config = YAML.load_file(config_file)
          
          unless config['clients'] && config['clients'][client_name]
            UI.user_error!("Cliente '#{client_name}' não encontrado no arquivo de configuração")
          end
  
          client_config = config['clients'][client_name]
  
          # Preparar configuração final
          final_config = {
            'app_name' => client_config['app_name'],
            'package_name' => client_config['package_name'],
            'colors' => client_config['colors'],
            'strings' => client_config['strings']
          }
  
          # Criar diretório se não existir
          output_dir = "assets/config"
          FileUtils.mkdir_p(output_dir) unless File.directory?(output_dir)
  
          # Salvar JSON
          output_file = File.join(output_dir, "client_config.json")
          File.write(output_file, JSON.pretty_generate(final_config))
  
          UI.success("✅ Configuração gerada: #{output_file}")
          
          Actions.lane_context[SharedValues::CLIENT_CONFIG] = final_config
          
          return final_config
        end
  
        def self.description
          "Gera client_config.json a partir do clients_config.yaml"
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