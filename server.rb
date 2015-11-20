#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

require "socket"
require "json"

def display_400(client)
  client.print "HTTP/1.0 400 Bad Request\r\n"\
               "Content-Type: text/html\r\n"\
               "Content-Length: #{File.size?('./400.html')}\r\n\r\n"
  client.puts File.readlines("./400.html")
end

def display_404(client, version)
  client.print "#{version} 404 Not Found\r\n"\
               "Content-Type: text/html\r\n"\
               "Content-Length: #{File.size?('./404.html')}\r\n\r\n"
  client.puts File.readlines("./404.html")
end

def handle_get(client, path, version)
  if File.exist?(".#{path}")
    client.print "#{version} 200 OK\r\n"\
                 "Content-Type: text/html\r\n"\
                 "Content-Length: #{File.size?(".#{path}")}\r\n\r\n"
    client.puts File.readlines(".#{path}")
  else
    display_404(client, version)
  end
end

def fill_template(path, body)
  template = File.readlines(".#{path}").join("")
  whitespace = template.match(/([ \t]+)<%= yield %>/).captures.first

  params = JSON.parse(body)
  sub_array = []
  params.each do |_form_name, form_hash|
    form_hash.each do |field_name, contents|
      sub_array << "<li>#{field_name.capitalize}: #{contents}</li>"
    end
  end

  template.gsub("<%= yield %>", sub_array.join("\n#{whitespace}"))
end

def handle_post(client, path, version, body)
  if File.exist?(".#{path}")
    response_body = fill_template(path, body)
    client.print "#{version} 200 OK\r\n"\
                 "Content-Type: text/html\r\n"\
                 "Content-Length: #{response_body.length}\r\n\r\n"
    client.puts response_body
  else
    display_404(client, version)
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
    if line_match = line.match(/content-length:\s+(\d+)/i)
      content_length = line_match.captures.first.to_i
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
    display_400(client)
  end

  case verb
  when "GET" then handle_get(client, path, version)
  when "POST" then handle_post(client, path, version, body)
  else
    display_400(client)
  end

  client.close
end
