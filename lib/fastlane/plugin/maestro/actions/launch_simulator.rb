require 'fastlane/action'
require 'fileutils'
require 'simctl'

module Fastlane
  module Actions
    class LaunchSimulatorAction < Action
      def self.run(params)
        device_type = SimCtl.devicetype(name: params[:device_name])
        device_name = "Maestro - #{params[:device_name]}"

        runtime_name = ''
        if params[:ios_version].nil? || params[:ios_version].empty?
          runtime_name = SimCtl.list_runtimes()[0].name
        else
          runtime_name = "iOS #{params[:ios_version]}"
        end
        runtime = SimCtl.runtime(name: runtime_name)
        UI.message("Creating device #{device_name} with runtime #{runtime_name}…")
        device = SimCtl.create_device(device_name, device_type, runtime)

        device.boot

        UI.message("Waiting for device to boot")
        device.wait { |d| d.state == :booted }

        unless params[:language].nil? || params[:language].empty?
          UI.message("Setting device language to #{params[:language]}")
          device.settings.set_language(params[:language])
          device.settings.set_locale(params[:language])
        end

        UI.message("Patching device settings for tests")
        time = Time.new(2007, 1, 9, 9, 41, 0)
        device.status_bar.clear
        device.status_bar.override(
          time: time.iso8601,
          dataNetwork: '5g',
          wifiMode: 'active',
          cellularMode: 'active',
          batteryState: 'charging',
          batteryLevel: 100
        )
        device.settings.disable_keyboard_helpers

        device.launch

        UI.message("Installing app #{params[:app_path]} on the simulator")
        device.install(params[:app_path])

        return device
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
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        [:ios].include?(platform)
      end
    end
  end
end
