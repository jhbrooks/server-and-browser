#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

require 'socket'

# A simple browser
host = "localhost"
port = 3000
path = "/index.html"

request = "GET #{path} HTTP/1.0\r\n\r\n"

socket = TCPSocket.open(host, port)
socket.print(request)
response = socket.read

puts response
