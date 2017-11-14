require 'tmpdir'
require 'English'
require 'open3'

include Rspec::Bash::Wrapper

# TODO: add tests for stubs (make an abstract class too) and for wrapper
# TODO: add tests for isolating wrapper and stub utilities
# TODO: make all tests more consistent
# TODO: clean up tests you touched
# TODO: get ruby stub tests trued up to what is in bash stub tests
# TODO: enforce the nil call log args that just kind of works for bash stub
# TODO: look into converting wrapper to not use ERB
# TODO: get better testing around target interpolation stuff

module Rspec
  module Bash
    def create_stubbed_env(stub_type = StubbedEnv::BASH_STUB)
      StubbedEnv.new(stub_type)
    end

    class StubbedEnv
      RUBY_STUB = :ruby_stub
      BASH_STUB = :bash_stub
      STUB_MARSHALLER_MAPPINGS = {
        RUBY_STUB => RubyStubMarshaller,
        BASH_STUB => BashStubMarshaller
      }.freeze
      STUB_FUNCTION_MAPPINGS = {
        RUBY_STUB => RubyStubFunction,
        BASH_STUB => BashStubFunction
      }.freeze
      DISALLOWED_COMMANDS = %w(/usr/bin/env bash readonly function).freeze

      def initialize(stub_type = StubbedEnv::BASH_STUB)
        @stub_type = stub_type
        start_stub_server
      end

      def start_stub_server
        tcp_server = create_tcp_server
        stub_server = create_stub_server
        stub_server.start(tcp_server)
      end

      def stub_command(command)
        check_if_command_is_allowed(command)
        add_override_for_command(command)
        create_stubbed_command(command)
      end

      def execute(command, env_vars = {})
        script_runner = "source #{command}"
        script_wrapper = wrap_script(script_runner)
        execute_script(env_vars, script_wrapper)
      end

      def execute_function(script, command, env_vars = {})
        script_runner = "source #{script}\n#{command}"
        script_wrapper = wrap_script(script_runner)
        execute_script(env_vars, script_wrapper)
      end

      def execute_inline(command_string, env_vars = {})
        temp_command_path = create_file('inline-')
        write_file(temp_command_path, command_string)
        stdout, stderr, status = execute(temp_command_path, env_vars)
        delete_file(temp_command_path)
        [stdout, stderr, status]
      end

      private

      def create_tcp_server
        tcp_server = TCPServer.new('localhost', 0)
        @stub_server_port = tcp_server.addr[1]
        tcp_server
      end

      def create_stub_server
        stub_marshaller = STUB_MARSHALLER_MAPPINGS[@stub_type].new

        @call_log_manager = CallLogManager.new
        @call_conf_manager = CallConfigurationManager.new
        @stub_wrapper = BashWrapper.new(@stub_server_port)

        StubServer.new(
          @call_log_manager,
          @call_conf_manager,
          stub_marshaller
        )
      end

      def create_stubbed_command(command)
        StubbedCommand.new(
          command,
          @call_log_manager,
          @call_conf_manager
        )
      end

      def execute_script(env_vars, script)
        Open3.capture3(env_vars, script)
      end

      def wrap_script(script)
        @stub_wrapper.wrap_script(script)
      end

      def create_file(prefix)
        Dir::Tmpname.make_tmpname(File.join(Dir.tmpdir, prefix), nil)
      end

      def delete_file(file_path)
        File.delete(file_path)
      end

      def write_file(file_path, contents)
        File.write(file_path, contents)
      end

      def check_if_command_is_allowed(command)
        if DISALLOWED_COMMANDS.include? command
          raise("Not able to stub command #{command}. Reserved for use by test wrapper.")
        end
      end

      def add_override_for_command(command)
        stub_function = STUB_FUNCTION_MAPPINGS[@stub_type].new(command, @stub_server_port)
        function_override = stub_function.to_s.chomp
        @stub_wrapper.add_override(function_override)
      end
    end
  end
end
