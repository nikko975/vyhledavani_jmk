require 'minitest/autorun'
require_relative '../parse_html'

class ParseHTMLTest < Minitest::Test
  include ParseHTML

  def test_extract_links
    file = open('test/fixtures/index.html').read

    links = ParseHTML.extract_links(file)

    assert_equal %w[00 01 03], links
  end
end
