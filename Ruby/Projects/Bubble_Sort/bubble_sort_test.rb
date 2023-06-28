require 'minitest/autorun'
require_relative 'bubble_sort'

class BubbleSortTest < Minitest::Test

  def test_integer
    arr = [4,3,78,2,0,2]
    assert_equal([0,2,2,3,4,78], bubble_sort(arr))
  end

  def test_negative_integers
    arr = [27, 999, 4, -999, -2, 0]
    assert_equal(arr.sort, bubble_sort(arr))
  end

  def test_letters
    arr = ['z','x','b','a','j']
    assert_equal(arr.sort, bubble_sort(arr))
  end

  def test_words
    arr = ['John', 'apple', 'Zebra', 'bubble']
    assert_equal(arr.sort, bubble_sort(arr))
  end

end