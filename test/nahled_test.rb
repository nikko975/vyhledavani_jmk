require 'minitest/autorun'
require_relative '../nahled'

class NahledTest < Minitest::Test

  def test_current_period
    nahled = Nahled.new({})

    assert_equal '03', nahled.current_period(3)
    assert_equal '03', nahled.current_period(4)
    assert_equal '03', nahled.current_period(5)

    assert_equal '12', nahled.current_period(12)
    assert_equal '12', nahled.current_period(1)
    assert_equal '12', nahled.current_period(2)

    assert_raises(KeyError) { nahled.current_period(13) }
  end

  def test_find_document
    nahled = Nahled.new({})

    assert nahled.find_document(%w[03 173843])
  end

end
