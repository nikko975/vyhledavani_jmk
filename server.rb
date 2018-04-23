# frozen_string_literal: true

require 'webrick'
require_relative 'nahled'

require 'optparse'

options = { daemon: false }

OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on('-d', '--daemon', 'Run as daemon') do |v|
    options[:daemon] = v
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end
end.parse!

root = File.expand_path './public_html'
server = WEBrick::HTTPServer.new Port: ENV.fetch('PORT') { 8000 }, DocumentRoot: root

trap 'INT' do server.shutdown end

server.mount '/search', Nahled

start = server.method(:start)

options[:daemon] ? WEBrick::Daemon.start(&start) : start.call
