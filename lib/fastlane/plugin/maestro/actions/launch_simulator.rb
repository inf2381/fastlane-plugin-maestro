require 'fastlane/action'
require 'fileutils'
require 'simctl'

module Fastlane
  module Actions
    class LaunchSimulatorAction < Action
      def self.run(params)
        FastlaneCore::PrintTable.print_values(config: params,
                                              title: "Summary for launch_simulator #{Fastlane::Maestro::VERSION}")
        device_name = "Maestro - #{params[:device_name]}"
        runtime_name = params[:ios_version].nil? || params[:ios_version].empty? ? SimCtl.list_runtimes()[0].name : "iOS #{params[:ios_version]}"
        runtime = SimCtl.runtime(name: runtime_name)

        # Verify runtime identifier
        if runtime.nil?
          UI.user_error!("Could not find a runtime matching #{runtime_name}")
        end

        # List available devices
        available_devices = SimCtl.list_devices

        # Manually filter devices
        existing_device = available_devices.find { |d| d.name == device_name && d.os == runtime.identifier }
        if existing_device
          if existing_device.state == :booted
            UI.message("Device #{device_name} is already running. Patching settings…")
            patch_device_settings(existing_device, params)
            return existing_device
          elsif existing_device.state == :shutdown
            UI.message("Device #{device_name} is shutdown. Booting device…")
            existing_device.boot
            existing_device.wait { |d| d.state == :booted }
            patch_device_settings(existing_device, params)
            return existing_device
          end
        end

        # Create and boot the device if it doesn't exist
        UI.message("Creating device #{device_name} with runtime #{runtime_name}…")
        device_type = SimCtl.devicetype(name: params[:device_name])
        device = SimCtl.create_device(device_name, device_type, runtime)
        device.boot

        UI.message("Waiting for device to boot")
        device.wait { |d| d.state == :booted }
        patch_device_settings(device, params)

        UI.message("Installing app #{params[:app_path]} on the simulator")
        device.install(params[:app_path])

        return device
      end

      def self.patch_device_settings(device, params)
        unless params[:language].nil? || params[:language].empty?
          UI.message("Setting device language to #{params[:language]}")
          device.settings.set_language(params[:language])
          device.settings.set_locale(params[:language])
        end

        UI.message("Patching device settings for tests")
        device.status_bar.clear
        device.status_bar.override(
          time: '9:41', # ISO 8601 time not possible as of iOS 18.2
          dataNetwork: '5g',
          wifiMode: 'active',
          cellularMode: 'active',
          batteryState: 'charging',
          batteryLevel: 100
        )
        device.settings.disable_keyboard_helpers
        device.launch
      end

      def self.description
        'Prepares an iOS simulator for Maestro testing'
      end

      def self.authors
        ['Marc Bormeth']
      end

      def self.return_value
        "Object of [SimCtl::Device](https://www.rubydoc.info/gems/simctl/SimCtl/Device)"
      end

      def self.details
        'Creates a simulator for the given `:ios_version` and `:device`. \nAfterwards, it patches the language, locale & status bar and installs the given :app on it.'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :app_path,
                                        env_name: "FL_APP_PATH",
                                        description: "Path to the .app file for simulators",
                                        type: String,
                                        default_value: ""),
          FastlaneCore::ConfigItem.new(key: :ios_version,
                                        description: "iOS runtime version to be used for the simulator",
                                        short_option: "-i", # same as for scan
                                        optional: true,
                                        default_value: ''),
          FastlaneCore::ConfigItem.new(key: :language,
                                        description: "The language which should be used",
                                        short_option: "-g", # same as for scan
                                        type: String,
                                        default_value: 'en-US',
                                        optional: true),
          FastlaneCore::ConfigItem.new(key: :device_name,
                                        short_option: "-a", # same as for scan
                                        optional: false,
                                        type: String,
                                        env_name: "MAESTRO_DEVICE",
                                        description: "The name of the simulator type you want to run tests on (e.g. 'iPhone 14' or 'iPhone SE (2nd generation) (14.5)')")
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
