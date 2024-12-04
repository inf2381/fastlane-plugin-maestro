require 'fastlane_core/print_table'

HighLine.track_eof = false
module Fastlane
  module Maestro
    class Runner

      def self.run(options)
        maestro_path = ENV["HOME"] + "/.maestro/bin/maestro"
        command = [maestro_path]

        unless options[:device].empty? || options[:device].nil?
          command.push("--device", options[:device])
          end

        command.push("test")

        # Flags with a value
        {
          config: "--config",
          debug_output: "--debug_output",
          exclude_tags: "--exclude_tags",
          report_type: "--format",
          include_tags: "--include_tags",
          output: "--output"
        }.each do |key, flag|
          value = options[key]
          next if value.nil? || value.empty?

          command.push(flag, value)

          # Make sure the directory exists for output files
          FileUtils.mkdir_p(File.dirname(value)) if [:debug_output, :output].include?(key)
        end

        # Boolean flags
        {
          continuous: "--continuous",
          flatten_debug_output: "--flatten_debug_output"
        }.each do |key, flag|
          value = options[key]
          next if value.nil? || value.empty? || value == false

          command.push(flag)
        end

        unless options[:env_vars].nil? || options[:env_vars].empty?
          options[:env_vars].each do |key, value|
            command.push("-e", "#{key}=#{value}")
          end
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

      def self.run_generic(cmd, flags)
        maestro_path = ENV["HOME"] + "/.maestro/bin/maestro"
        command = [maestro_path]
        command.push(cmd)
        command.push(flags)
      end

      def self.command?(name)
        `which #{name}`
        $?.success?
      end
    end
  end
end
