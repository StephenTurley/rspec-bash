#!/usr/bin/env bash
function first_command {
ruby_command=$(which ruby)
  ${ruby_command} -e '
    require "socket"
    sock = TCPSocket.new("localhost", 12345)
    call_from_client = {
      command: "first_command",
      stdin:   STDIN.tty? ? "" : $stdin.read,
      args:    ARGV
    }
    sock.write(Marshal.dump(call_from_client))
    conf_from_server = Marshal.load(sock.read)

    exit 0 if conf_from_server.empty?

    (conf_from_server[:outputs] || []).each do |data|
      $stdout.print data[:content] if data[:target] == :stdout
      $stderr.print data[:content] if data[:target] == :stderr
    end
    exit conf_from_server[:exitcode] || 0
  ' "${@}"
}
