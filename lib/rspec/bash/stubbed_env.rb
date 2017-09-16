require 'tmpdir'
require 'English'
require 'open3'
require 'fileutils'
require 'pathname'
require 'digest'

module Rspec
  # Define stubbed environment to set and assert expectations
  module Bash
    def create_stubbed_env
      StubbedEnv.new
    end

    # A shell environment that can manipulate behaviour
    # of executables
    class StubbedEnv
      attr_reader :dir

      def initialize
        @dir = Dir.mktmpdir
        at_exit { cleanup }
      end

      def cleanup
        FileUtils.remove_entry_secure @dir if Pathname.new(@dir).exist?
      end

      def stub_command(command)
        sha = Digest::SHA1.hexdigest File.basename(command)
        hashed_command = "#{sha}-#{File.basename(command)}"
        write_function_override_file_for_command(command, hashed_command)
        StubbedCommand.new(command, hashed_command, @dir)
      end

      def execute(command, env_vars = {})
        full_command = get_wrapped_execution_with_function_overrides(
          <<-multiline_script
            source #{command}
          multiline_script
        )

        Open3.capture3(env_vars, full_command)
      end

      def execute_function(script, command, env_vars = {})
        full_command = get_wrapped_execution_with_function_overrides(
          <<-multiline_script
            source #{script}
            #{command}
          multiline_script
        )

        Open3.capture3(env_vars, full_command)
      end

      def execute_inline(command_string, env_vars = {})
        temp_command_path = Dir::Tmpname.make_tmpname("#{@dir}/inline-", nil)
        File.write(temp_command_path, command_string)
        execute(temp_command_path, env_vars)
      end

      private

      def write_function_override_file_for_command(original_command, hashed_command)
        function_command_binding_for_template = original_command

        function_command_path_binding_for_template = File.join(@dir, hashed_command)

        function_override_file_path = File.join(@dir, "#{hashed_command}_overrides.sh")
        function_override_file_template = ERB.new(
          File.new(function_override_template_path).read, nil, '%'
        )
        function_override_file_content = function_override_file_template.result(binding)

        File.write(function_override_file_path, function_override_file_content)
      end

      def get_wrapped_execution_with_function_overrides(execution_snippet)
        execution_binding_for_template = execution_snippet
        function_override_path_binding_for_template = "#{@dir}/*_overrides.sh"
        wrapped_error_path_binding_for_template = "#{@dir}/errors"

        function_override_wrapper_template = ERB.new(
          File.new(function_override_wrapper_template_path).read, nil, '%'
        )

        function_override_wrapper_template.result(binding)
      end

      def function_override_template_path
        project_root.join('bin', 'function_override.sh.erb')
      end

      def function_override_wrapper_template_path
        project_root.join('bin', 'function_override_wrapper.sh.erb')
      end

      def project_root
        Pathname.new(File.dirname(File.expand_path(__FILE__))).join('..', '..', '..')
      end
    end
  end
end
