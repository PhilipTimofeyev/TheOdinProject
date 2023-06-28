require 'minitest/autorun'
require_relative 'caesar_cipher'

class CaesarCipherTest < MiniTest::Test

  def test_sample_1
    assert_equal("Bmfy f xywnsl!", caesar_cipher("What a string!", 5))
  end

  def test_sample_2
    assert_equal("Uf ime ftq nqef ar fuyqe, uf ime ftq iadef ar fuyqe.", caesar_cipher("It was the best of times, it was the worst of times.", 12))
  end

  def test_other_characters
    assert_equal("1'p /vlqjlqj/ 1q w3h ud1q", caesar_cipher("1'm /singing/ 1n t3e ra1n", 3))
  end

  def test_empty_string
    assert_equal("", caesar_cipher("", 3))
  end

  def test_no_shift_given
    assert_equal("The rain in Spain.", caesar_cipher("The rain in Spain."))
  end

  def test_negative_shift
    assert_equal("Y'aop hw rea.", caesar_cipher("C'est la vie.", -4))
  end

  def test_large_shift
    assert_equal("Kv'u ycddkv ugcuqp.", caesar_cipher("It's wabbit season.", 50000))
  end

end