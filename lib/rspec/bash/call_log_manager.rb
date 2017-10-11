module Rspec
  module Bash
    class CallLogManager
      def initialize()
        @call_logs = Hash.new { |hash, key| hash[key] = CallLog.new(key) }
      end
      def add_log(command, stdin, arguments)
        @call_logs[command]
          .add_log(stdin, arguments)
      end
      def stdin_for_args(command, arguments)
        return @call_logs[command]
          .stdin_for_args(arguments)
      end
    end
  end
end
