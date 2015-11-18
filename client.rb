#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

require 'socket'

# A simple client
hostname = "localhost"
port = 3000

socket = TCPSocket.open(hostname, port)

while line = socket.gets
  puts line.chomp
end
socket.close
