require 'socket'

module Rspec
  module Bash
    class StubServer
      def initialize(call_log_manager, call_conf_manager)
        @call_log_manager = call_log_manager
        @call_conf_manager = call_conf_manager
      end
      def start
        @tcp_server = TCPServer.new('localhost', 0)
        @tcp_server.addr[1]
      end
      def accept
        tcp_socket = @tcp_server.accept

        client_message = Marshal.load(tcp_socket)
        server_message = process_stub_call(client_message)

        tcp_socket.write(Marshal.dump(server_message))
        tcp_socket.close
      end
      def stop
        @tcp_server.close
      end
      def process_stub_call(stub_call)
        @call_log_manager.add_log(
          stub_call[:command],
          stub_call[:stdin],
          stub_call[:args]
        )
        @call_conf_manager.get_best_call_conf(
          stub_call[:command],
          stub_call[:args]
        )
      end
    end
  end
end
