require 'io/console'

PEGS = [1, 2, 3, 4, 5, 6]
FEEDBACK_COLORS = { 1 => 'B', 2 => 'W', 3 => '_' }

module Displayable
  def clear
    Gem.win_platform? ? (system 'cls') : (system 'clear')
  end

  def display_welcome_message
    clear
    puts <<~WELCOME
    'Welcome to Mastermind!'
    \nThe purpose of the game is to guess your opponent's secret code within 12 tries.
    \nAfter each guess, you will receive feedback in the form of black and white pegs:
    \n- A black peg indicates that you have a correct number that is in the correct spot.
    - A white peg indicates that you have a correct number but in an incorrect spot.
    WELCOME
  end

  def display_ask_what_role
    puts "\nWill you be the Codebreaker or Codemaker?"
    puts "Enter 1 for Codebreaker and 2 for Codemaker"
  end

  def display_board
    clear
    what_to_display_computer_side
    board.draw_board
    if codebreaker.class == Computer
      puts "........ #{codemaker.code.interpret.join(' ')} ........"
    end
  end

  def what_to_display_computer_side
    return unless codebreaker.class == Human

    if codemaker.reveal_code
      puts "......#{codemaker.code.interpret}......"
    else
      puts '.........? ? ? ?.........'
    end
  end

  def display_goodbye_message
    puts 'Thanks for playing Mastermind! Goodbye!'
  end
end

class Board
  attr_accessor :board, :player, :current_guess_row, :code

  def initialize(player = :computer)
    @board = new_board
    @player = player.to_sym
    @code = %w([_ _ _ _])
    @current_guess_row = 1
  end

  def add_code(mastercode)
    self.code = mastercode.interpret
  end

  def add_guess(new_guess)
    board[current_guess_row][:guesses] = new_guess.interpret

    self.current_guess_row += 1
  end

  def add_fb(new_fb)
    set_up_fb = new_fb.interpret

    left_fb, right_fb = set_up_fb[0..1], set_up_fb[2..3]

    board[current_guess_row - 1][:left] = left_fb
    board[current_guess_row - 1][:right] = right_fb
  end

  def draw_board
    puts '_________________________'
    board_orientation.each do |_row_num, row|
      left_fb = translate_to_fb(row[:left])
      guesses = translate_to_num(row[:guesses])
      right_fb = translate_to_fb(row[:right])
      puts "| #{left_fb} || #{guesses} || #{right_fb} |"
    end
    puts '_________________________'
  end

  def latest_row
    board[current_guess_row - 1]
  end

  private

  def new_board
    board = {}
    (1..12).to_a.each { |n| board[n] = board_row }

    board
  end

  def board_row
    { left: %w(_ _), guesses: %w(_ _ _ _), right: %w(_ _) }
  end

  def board_orientation
    player == :computer ? board : Hash[board.to_a.reverse]
  end

  def translate_to_num(num)
    num.join(' ')
  end

  def translate_to_fb(num)
    fb = num.map { |n| n =~ /\D/ ? n : FEEDBACK_COLORS[n] }
    fb.join(' ')
  end
end

class Guess
  attr_reader :guesses

  def initialize(guesses)
    @guesses = guesses
  end

  def interpret
    guesses
  end
end

class Feedback
  attr_reader :fb

  def initialize(feedback)
    @fb = feedback
  end

  def place_in_order
    @fb = fb.sort
  end

  def interpret
    place_in_order
  end
end

class Player
  attr_accessor :feedback_arr, :latest_guess, :code, :board
  attr_reader :name

  def initialize(board)
    @board = board
    @feedback_arr = []
    @latest_guess = nil
  end

  def add_guess_to_board
    board.add_guess(retrieve_guess)
  end

  def give_feedback
    self.latest_guess = board.latest_row[:guesses]
    determine_feedback_pegs
    board.add_fb(Feedback.new(feedback_arr))
    reset_feedback_arr
  end

  private

  def determine_feedback_pegs
    determine_black_pegs.times { feedback_arr << 1 }
    determine_white_pegs.times { feedback_arr << 2 }
    determine_blank_pegs.times { feedback_arr << 3 }
  end

  def reset_feedback_arr
    self.feedback_arr = []
  end

  def determine_black_pegs
    code.interpret.zip(latest_guess).count { |i| i.inject(:eql?) }
  end

  def determine_white_pegs
    latest_guess.uniq.count { |i| code.interpret.include?(i) } - determine_black_pegs
  end

  def determine_blank_pegs
    4 - feedback_arr.size
  end

  def determine_fb
    [determine_black_pegs, determine_white_pegs]
  end
end

class Human < Player
  def initialize(board)
    super
    @name = 'Player'
  end

  def set_code
    @code = retrieve_guess
  end

  private

  def retrieve_guess
    puts "Please enter four numbers between #{PEGS.first} and #{PEGS.last} without repeating any numbers:"

    guess = nil
    loop do
      guess = gets.chomp
      break if valid_guess?(guess)
    end
    guess = Guess.new(guess.chars.map(&:to_i))
  end

  def valid_guess?(guess)
    if guess.chars.any? { |n| n.match?(/\D/) }
      puts 'Please only enter numbers.'
    elsif guess.length != 4
      puts 'Please enter four numbers'
    elsif guess.chars.any? { |n| n.to_i > PEGS.max }
      puts "Please only enter numbers between 1 and #{PEGS.max}"
    else
      true
    end
  end
end

class Computer < Player
  attr_accessor :guess_arr, :reveal_code

  def initialize(board)
    super
    @name = 'Computer'
    @guess_arr = guess_pool
    @reveal_code = false
  end

  def set_code
    self.code = Guess.new(PEGS.sample(4))
  end

  private

  def retrieve_guess
    if board.current_guess_row == 1
      self.latest_guess = Guess.new([1, 1, 2, 2]).interpret
      Guess.new([1, 1, 2, 2])
    else
      Guess.new(determine_guess)
    end
  end

  def guess_pool
    PEGS.repeated_permutation(4).to_a
  end

  def determine_guess
    black = latest_feedback.count(1)
    white = latest_feedback.count(2)

    self.guess_arr = guess_arr.select do |test_code|
                    self.code = Guess.new(test_code)
                    determine_fb == [black, white]
    end
    self.latest_guess = guess_arr.sample
  end

  def latest_feedback
    board.latest_row[:left] + board.latest_row[:right]
  end

  def clear_feedback
    self.feedback_arr = []
  end

  def add_code
    board.add_code(retrieve_guess)
  end
end

class PlayGame
  attr_accessor :board, :codebreaker, :codemaker

  include Displayable

  def initialize
    @board = Board.new
    display_welcome_message
    play
    display_goodbye_message
  end

  def play
    loop do
      board.player = starting_settings
      codemaker.set_code
      display_board
      board_loop
      announce_result unless winner?
      break unless play_again?

      reset_board
    end
  end

  private

  def board_loop
    until board.current_guess_row > 12
      codebreaker.add_guess_to_board
      display_board if codebreaker.class == Computer
      codemaker.give_feedback
      sleep 0.8 if codebreaker.class == Computer
      display_board
      if winner?
        announce_result
        break
      end
    end
  end

  def starting_settings
    display_ask_what_role
    response = gets.chomp.to_i

    if response == 1
      @codebreaker, @codemaker = Human.new(board), Computer.new(board)
    else
      @codemaker, @codebreaker = Human.new(board), Computer.new(board)
    end
  end

  def reset_board
    self.board = Board.new
    codebreaker.board = board
    codemaker.board = board
  end

  def play_again?
    puts 'Would you like to play another round? (y/n)'
    answer = gets.chomp.downcase
    answer == 'y'
  end

  def winner?
    board.latest_row[:guesses] == codemaker.code.interpret
  end

  def announce_result
    clear
    codemaker.reveal_code = true if codemaker.class == Computer
    display_board
    puts winner? ? "#{codebreaker.name} won!" : "#{codebreaker.name} lost!"
  end
end

PlayGame.new
