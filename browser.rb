#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

require 'socket'

# A simple browser
host = "www.google.com"
port = 80
path = "/"

request = "GET #{path} HTTP/1.0\r\n\r\n"

socket = TCPSocket.open(host, port)
socket.print(request)
response = socket.read

header_body_pair = response.split("\r\n\r\n", 2)
print header_body_pair[1]
