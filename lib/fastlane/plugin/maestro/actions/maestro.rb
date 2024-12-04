require 'fastlane/action'
require 'fileutils'

require_relative '../helper/runner'

module Fastlane
  module Actions
    class MaestroAction < Action
      def self.run(params)
        case params[:command]
        when "install"
          Maestro::Runner.install
        when "download_samples"
          Maestro::Runner.download_samples
        when "test"
          Maestro::Runner.run(params)
        else
          Maestro::Runner.run_generic(params[:command], params[:flags])
        end
      end

      def self.description
        'Runs the Maestro CLI'
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
                                       description: 'Command to be executed (`download_samples`, `install`)',
                                       type: String,
                                       default_value: 'test',
                                       verify_block: proc do |value|
                                         unless ["download_samples", "install", "test"].include?(value)
                                           UI.user_error!("Unsupported value '#{value}' for parameter ':command'! \nAvailable options: `download_samples`, `install`, `test`")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :flags,
                                       description: 'Allows to pass additional flags',
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
