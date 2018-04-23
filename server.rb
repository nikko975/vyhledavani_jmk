require 'webrick'

root = File.expand_path './public_html'
server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root

trap 'INT' do server.shutdown end

class Search < WEBrick::HTTPServlet::AbstractServlet
  def do_GET request, response
    response.status = 200
    response['Content-Type'] = 'text/plain'
    response.body = 'Hello, World!'
  end
end


server.mount '/search', Search

server.start
