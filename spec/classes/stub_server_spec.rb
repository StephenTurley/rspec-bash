require 'spec_helper'
require 'socket'
include Rspec::Bash

describe 'StubServer' do
  let(:call_log_manager) {double(CallLogManager)}
  let(:call_conf_manager) {double(CallConfigurationManager)}
  subject {StubServer.new(call_log_manager, call_conf_manager)}

  context('#start') do
    it('returns the random dynamic port that it is listening on') do
      tcp_server = double(TCPServer)
      allow(tcp_server).to receive(:addr)
        .and_return(['AF_INET', 12345])
      expect(TCPServer).to receive(:new)
        .with('localhost', 0)
        .and_return(tcp_server)
      expect(subject.start).to eql(12345)
    end
  end
  context('#start and #accept') do
    it('accepts connections on the socket from start') do
      client_message = {
        command: 'first_command',
        stdin:   'stdin',
        args:    %w(first_argument second_argument)
      }
      server_message = {
        args:     %w(first_argument second_argument),
        exitcode: 0,
        outputs:  []
      }
      tcp_server = double(TCPServer)
      tcp_socket = double(TCPSocket)
      expect(call_log_manager).to receive(:add_log)
        .with('first_command', 'stdin', %w(first_argument second_argument))
      expect(call_conf_manager).to receive(:get_best_call_conf)
        .with('first_command', %w(first_argument second_argument))
        .and_return(server_message)
      allow(tcp_server).to receive(:addr)
        .and_return(['AF_INET', 12345])
      allow(TCPServer).to receive(:new)
        .with('localhost', 0)
        .and_return(tcp_server)
      expect(tcp_server).to receive(:accept)
        .and_return(tcp_socket)
      allow(tcp_socket).to receive(:to_str)
        .and_return(Marshal.dump(client_message))
      expect(tcp_socket).to receive(:write)
        .with(Marshal.dump(server_message))
      expect(tcp_socket).to receive(:close)

      subject.start
      subject.accept

    end
  end
  context('#start and #stop') do
    it('closes the socket it started') do
      tcp_server = double(TCPServer)
      allow(tcp_server).to receive(:addr)
        .and_return(['AF_INET', 12345])
      allow(TCPServer).to receive(:new)
        .with('localhost', 0)
        .and_return(tcp_server)
      expect(tcp_server).to receive(:close)

      subject.start
      subject.stop
    end
  end
  context('#process_stub_call') do
    it('logs the call for the command') do
      expect(call_log_manager).to receive(:add_log)
        .with('first_command', 'stdin', %w(first_argument second_argument))
      allow(call_conf_manager).to receive(:get_best_call_conf)

      subject.process_stub_call({
        command: 'first_command',
        stdin:   'stdin',
        args:    %w(first_argument second_argument)
      })
    end
    it('returns the best matching call configuration for the command') do
      allow(call_log_manager).to receive(:add_log)
      allow(call_conf_manager).to receive(:get_best_call_conf)
        .with('first_command', %w(first_argument second_argument))
        .and_return(
          {
            args:     %w(first_argument second_argument),
            exitcode: 0,
            outputs:  []
          }
        )

      expect(subject.process_stub_call({
        command: 'first_command',
        stdin:   'stdin',
        args:    %w(first_argument second_argument)
      })).to eql(
        {
          args:     %w(first_argument second_argument),
          exitcode: 0,
          outputs:  []
        })
    end
  end
end
