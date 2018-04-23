# frozen_string_literal: true

require 'webrick'
require 'net/http'
require_relative 'parse_html'

class Nahled < WEBrick::HTTPServlet::AbstractServlet

  attr_reader :backend_url, :http

  module CustomErrorResponse
    attr_accessor :request

    def create_error_page
      ico = request.query['ico']

      @body = <<~HTML
        <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">
        <HTML>
          <HEAD><TITLE>Nastala chyba</TITLE></HEAD>
          <BODY>
            <H1>Nebylo nalezeno ICO: #{ico}</H1>
            <HR>
            <P>Custom error page!</P>
          </BODY>
        </HTML>
      HTML
    end
  end

  def initialize(*)
    super

    @backend_url = URI.parse(ENV.fetch('BACKEND_URL')).freeze
    @http = Net::HTTP.new(backend_url.hostname, backend_url.port)
    @http.set_debug_output($stderr)
    @http.start
  end

  ENCODING = Encoding.find('ISO-8859-2')

  def do_GET(request, response)
    components = [
      current_period(Date.today.month),
      request.query.fetch('ico')
    ]
    document = find_document(components)

    response.status = 200
    response['Content-Type'] = "text/plain, charset=#{ENCODING.name}"
    response.body = document
  rescue StandardError
    response.extend(CustomErrorResponse)
    response.request = request
    raise
  end

  MONTH_LOOKUP = {
    1..2 => '12',
    3..5 => '03',
    6..8 => '06',
    9..11 => '09',
    12..12 => '12'
  }.freeze

  def current_period(month)
    period = MONTH_LOOKUP.find { |(range, _)| range.cover?(month) } or raise KeyError, 'month outside range'

    period.fetch(1)
  end

  def find_document(components)
    date = get_max_date(components)
    components << date.strftime(DATE_FORMAT)

    time = get_max_time(date, components)
    components << time.strftime(TIME_FORMAT)

    components << 'VYKAUT.TXT'

    get(components)
  end

  DATE_FORMAT = '%Y%m%d'
  TIME_FORMAT = '%H%M%S45'

  def get_max_date(components)
    links = ParseHTML.extract_links(get(components))

    links.map(&method(:parse_date_component)).compact.max
  end

  def get_max_time(date, components)
    time_converter = method(:parse_time_component).curry.call(date)
    links = ParseHTML.extract_links(get(components))

    links.map(&time_converter).compact.max
  end

  def url(components)
    URI.join(backend_url, components.join('/'))
  end

  def parse_time_component(now, time)
    Time.strptime(time, TIME_FORMAT, now.to_time)
  rescue ArgumentError
    # invalid time
  end

  def parse_date_component(date)
    Date.parse(date, DATE_FORMAT)
  rescue ArgumentError
    # invalid date
  end

  def get(components)
    fetch_http(url(components))
  end

  def fetch_http(url)
    case res = http.get(url)
    when Net::HTTPSuccess
      res.body
    when Net::HTTPRedirection
      fetch_http(URI(res['Location']))
    else
      raise InvalidResponseError, res
    end
  end

  class InvalidResponseError < StandardError; end
end
