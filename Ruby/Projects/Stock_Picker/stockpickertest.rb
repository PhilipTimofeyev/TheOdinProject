require 'minitest/autorun'
require_relative'stockpicker'

class StockpickerTest < Minitest::Test

  def test_basic
    stocks = [17,3,6,9,15,8,6,1,10]
    assert_equal([1,4], stock_picker(stocks))
  end

  def test_multiple_days
    stocks = [17,29,3,6,9,15,8,6,1,10]
    assert_equal([[0, 1], [2, 5]], stock_picker(stocks))
  end 

  def test_one_day_error
    stocks = [1]
    assert_raises(RuntimeError) {stock_picker(stocks)}
  end

end