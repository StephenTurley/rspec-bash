require 'yaml'

module Rspec
  module Bash
    class CallConfiguration
      attr_accessor :call_configuration

      def initialize
        @call_configuration = []
      end

      def set_exitcode(exitcode, args = [])
        current_conf = create_or_get_conf(args)
        current_conf[:exitcode] = exitcode
      end

      def add_output(content, target, args = [])
        current_conf = create_or_get_conf(args)
        current_conf[:outputs] << {
          target: target,
          content: content
        }
      end

      def get_best_call_conf(args = [])
        call_conf_arg_matcher = Util::CallConfArgumentListMatcher.new(@call_configuration)
        call_conf_arg_matcher.get_best_call_conf(*args)
      end

      private

      def create_or_get_conf(args)
        new_conf = {
          args: args,
          exitcode: 0,
          outputs: []
        }
        current_conf = @call_configuration.select { |conf| conf[:args] == args }
        @call_configuration << new_conf if current_conf.empty?
        current_conf.first || new_conf
      end
    end
  end
end
