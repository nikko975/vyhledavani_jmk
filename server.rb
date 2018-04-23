# freeze_string_literals: true

require 'webrick'
require_relative 'nahled'

root = File.expand_path './public_html'
server = WEBrick::HTTPServer.new Port: ENV.fetch('PORT') { 8000 }, DocumentRoot: root

trap 'INT' do server.shutdown end

server.mount '/search', Nahled

server.start
