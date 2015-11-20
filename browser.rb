#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

require "socket"
require "json"

def engage_server(host, port, request)
  socket = TCPSocket.open(host, port)
  socket.print(request)
  response = socket.readlines

  puts response
end

def gather_get_input
  puts "Please input a path."
  path = gets.chomp!
  path = "/" + path if path[0] != "/"
  path
end

def handle_get(host, port)
  path = gather_get_input
  request = "GET #{path} HTTP/1.0\r\n"\
            "From: jhbrooks@uchicago.edu\r\n\r\n"
  engage_server(host, port, request)
end

def gather_post_input
  puts "You'll be submitting info about a viking."
  puts "Please input a name."
  name = gets.chomp!
  puts "Please input an email address."
  email = gets.chomp!
  puts "Please input a battlecry."
  battlecry = gets.chomp!
  { viking: { name: name,
              email: email,
              battlecry: battlecry } }
end

def handle_post(host, port)
  viking = gather_post_input
  json_viking = viking.to_json
  request = "POST /thanks.html HTTP/1.0\r\n"\
            "From: jhbrooks@uchicago.edu\r\n"\
            "Content-Type: text/json\r\n"\
            "Content-Length: #{json_viking.length}\r\n\r\n"
  request << json_viking
  engage_server(host, port, request)
end

# A simple browser
host = "localhost"
port = 3000

puts "Welcome to the browser."
input = ""
until input == "QUIT"
  puts "Would you like to GET, POST, or QUIT?"
  input = gets.upcase.chomp!
  case input
  when "QUIT" then puts "Goodbye!"
  when "GET" then handle_get(host, port)
  when "POST" then handle_post(host, port)
  else
    puts "Sorry, I don't know how to #{input}."
  end
end
