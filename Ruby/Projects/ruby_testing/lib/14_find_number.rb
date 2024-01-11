# frozen_string_literal: true

# class for computer to find random number
class FindNumber
  attr_reader :min, :max, :answer, :guess

  def initialize(min, max, answer = RandomNumber.new(min, max), guess = nil)
    @min = min
    @max = max
    # The RandomNumber class will have an instance variable '@value'
    @answer = answer.value
    @guess = guess
  end

  def make_guess
    ((min + max) / 2).floor
  end

  def game_over?
    answer == guess
  end

  def update_range
    case guess
    when answer..max
      @max = guess - 1
    when min..answer
      @min = guess + 1
    end
  end
end
