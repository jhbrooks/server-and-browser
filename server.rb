#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

require 'socket'

def handle_get(client, path, version)
  if File.exist?(".#{path}")
    client.print "#{version} 200 OK\r\n"\
                 "Content-Type: text/html\r\n"\
                 "Content-Length: #{File.size?(".#{path}")}\r\n\r\n"
    client.puts File.readlines(".#{path}")
  else
    client.print "#{version} 404 Not Found\r\n"\
                 "Content-Type: text/html\r\n"\
                 "Content-Length: #{File.size?("./404.html")}\r\n\r\n"
    client.puts File.readlines("./404.html")
  end
end

# A simple server
server = TCPServer.open(3000)
loop do
  client = server.accept

  request = client.gets

  headers = ""
  content_length = 0
  loop do
    line = client.gets
    break if line == "\r\n"
    if line_match = line.match(%r{content-length:\s+(\d+)}i)
      content_length = line_match.captures[0].to_i
    end
    headers << line
  end

  body = client.read(content_length)

  verb = ""
  if request_match = request.match(%r{\A([A-Z]+)\s+
                                      (/\S+)\s+
                                      ([A-Z]+/\d\.\d)\r\n}x)
    parts = request_match.captures
    verb = parts[0]
    path = parts[1]
    version = parts[2]
  else
    client.print "HTTP/1.0 400 Bad Request\r\n"\
                 "Content-Type: text/html\r\n"\
                 "Content-Length: #{File.size?("./400.html")}\r\n\r\n"
    client.puts File.readlines("./400.html")
  end

  case verb
  when "GET" then handle_get(client, path, version)
  end

  client.close
end
