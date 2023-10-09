require 'fastlane/action'
require 'fileutils'

require_relative '../helper/runner'

module Fastlane
  module Actions
    class MaestroAction < Action
      def self.run(params)
        params.load_configuration_file("Maestrofile")
        FastlaneCore::PrintTable.print_values(config: params,
                                              title: "Summary for maestro #{Fastlane::Maestro::VERSION}")

        case params[:command]
        when "install"
          Maestro::Runner.install
        when "test"
          platform = (ENV['FASTLANE_PLATFORM_NAME'] ? ENV['FASTLANE_PLATFORM_NAME'].to_s : '')
          if platform == 'ios'
            self.check_ios_dependencies!
          end
          Maestro::Runner.run(params)
        when "download_samples"
          Maestro::Runner.download_samples
        end
      end

      def self.check_ios_dependencies!
        UI.message("Making sure you installed the dependencies to run Maestro…")

        return if Maestro::Runner.command?("idb_companion")

        UI.error("You have to install idb companion to use `maestro` with iOS simulators")
        UI.error("")
        UI.error("Install it via brew:")
        UI.command("brew tap facebook/fb")
        UI.command("brew install idb-companion")

        UI.error("If you don't have homebrew, visit https://github.com/facebook/idb")

        UI.user_error!("Please install idb companion and start your lane again.")
      end

      def self.description
        'Runs Maestro test'
      end

      def self.authors
        ['Marc Bormeth']
      end

      def self.return_value
      end

      def self.details
        'Installs / updates Maestro or runs maestro test depending on the parameter `:command`'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :command,
                                       env_name: 'FL_MAESTRO_COMMAND',
                                       description: 'Command to be executed (`download_samples`, `install`, or `test`)',
                                       type: String,
                                       default_value: 'test',
                                       verify_block: proc do |value|
                                         unless ["download_samples", "install", "test"].include?(value)
                                           UI.user_error!("Unsupported value '#{value}' for parameter ':command'! \nAvailable options: `download_samples`, `install`, `test`")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :report_type,
                                       env_name: 'FL_MAESTRO_FORMAT',
                                       description: 'Format of the generated report (`junit`)',
                                       optional: true,
                                       type: String,
                                       default_value: '',
                                       verify_block: proc do |value|
                                         unless ["", "junit"].include?(value)
                                           UI.user_error!("Unsupported value '#{value}' for parameter ':format'! Available options: `junit`")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :output,
                                       env_name: 'FL_MAESTRO_OUTPUT',
                                       description: 'Allows to override the report filename. Requires parameter :format to be set as well',
                                       optional: true,
                                       type: String,
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :debug_output,
                                       env_name: 'FL_MAESTRO_DEBUG_OUTPUT',
                                       description: 'Configures the debug output in this path, instead of default',
                                       optional: true,
                                       type: String,
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :device,
                                       env_name: 'FL_MAESTRO_DEVICE',
                                       description: 'iOS UDID or Android device name to be used for running the tests ',
                                       optional: true,
                                       type: String,
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :tests,
                                       env_name: 'FL_MAESTRO_TESTS',
                                       description: 'Maestro flow (or folder containing flows) to be executed',
                                       optional: true,
                                       type: String,
                                       verify_block: proc do |value|
                                         v = File.expand_path(value.to_s)
                                         UI.user_error!("No file or directory found with path '#{v}'") unless File.exist?(v)
                                       end),
          FastlaneCore::ConfigItem.new(key: :env_vars,
                                       env_name: 'FL_MAESTRO_ENV_VARIABLES',
                                       description: 'Allows to pass variables that the flow(s) might be using',
                                       optional: true,
                                       type: Hash),
          FastlaneCore::ConfigItem.new(key: :include_tags,
                                       env_name: 'FL_MAESTRO_INCLUDE_TAGS',
                                       description: 'List of tags that will remove the Flows that does not have the provided tags',
                                       optional: true,
                                       type: String,
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :exclude_tags,
                                       env_name: 'FL_MAESTRO_EXCLUDE_TAGS',
                                       description: 'List of tags that will remove the Flows containing the provided tags',
                                       optional: true,
                                       type: String,
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :test_suite_name,
                                       env_name: 'FL_MAESTRO_TEST_SUITE_NAME',
                                       description: 'Test suite name',
                                       optional: true,
                                       type: String,
                                       default_value: '')
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        [:ios, :android].include?(platform)

      end

      def self.category
        :testing
      end
    end
  end
end
