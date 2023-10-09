require 'fastlane_core/print_table'

HighLine.track_eof = false
module Fastlane
  module Maestro
    class Runner

      def self.run(options)
        # TODO: add possibility to specify maestro path
        maestro_path = ENV["HOME"] + "/.maestro/bin/maestro"

        command = [maestro_path]

        unless options[:device].empty? || options[:device].nil?
          command.push("--device", options[:device])
        end

        command.push("test")

        unless options[:report_type].empty? || options[:report_type].nil?
          command.push("--format", options[:report_type])
        end
        unless options[:output].empty? || options[:output].nil?
          command.push("--output", options[:output])
          # Make sure that the output folder is available
          FileUtils.mkdir_p(File.dirname(options[:output]))
        end
        unless options[:debug_output].empty? || options[:debug_output].nil?
          command.push("--debug-output", options[:debug_output])
          # Make sure that the debug output folder is available
          FileUtils.mkdir_p(File.dirname(options[:debug_output]))
        end
        unless options[:env_vars].nil? || options[:env_vars].empty?
          options[:env_vars].each do |key, value|
            command.push("-e", "#{key}=#{value}")
          end
        end
        unless options[:include_tags].empty? || options[:include_tags].nil?
          command.push("--include-tags", options[:include_tags])
        end
        unless options[:exclude_tags].empty? || options[:exclude_tags].nil?
          command.push("--exclude-tags", options[:exclude_tags])
        end
        unless options[:test_suite_name].empty? || options[:test_suite_name].nil?
          command.push("--test-suite-name", options[:test_suite_name])
        end

        command.push("#{options[:tests]}")
        command_string = command.join(" ")
        UI.message("Running command: #{command_string}")
        Dir.chdir(ENV["PWD"]) do
          # TODO: set exception based on parameter `failRun`
          system(command_string, out: $stdout, err: :out, exception: true)
        end
      end

      def self.install
        system("curl -Ls 'https://get.maestro.mobile.dev' | bash", out: $stdout, err: :out, exception: true)
      end

      def self.download_samples
        maestro_path = ENV["HOME"] + "/.maestro/bin/maestro"
        Dir.chdir(ENV["PWD"]) do
          system("#{maestro_path} download-samples", out: $stdout, err: :out, exception: true)
        end
      end

      def self.command?(name)
        `which #{name}`
        $?.success?
      end
    end
  end
end
