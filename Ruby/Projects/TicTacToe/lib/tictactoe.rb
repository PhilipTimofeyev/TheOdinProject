require 'io/console'

module Displayable
  def clear
    Gem.win_platform? ? (system "cls") : (system "clear")
  end

  def display_welcome_message
    clear
    puts "Welcome to Tic Tac Toe!"
    puts "\nThe goal is to fill an entire line with your marker."
    puts "First one to win 3 rounds wins the match."
    begin_io
  end

  def display_board
    display_stats
    display_whos_turn if computer.class == HumanOpponent
    puts ""
    board.draw
    puts ""
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_stats
    puts "You are#{human.marker} and #{computer.name} is#{computer.marker}."
    puts "\nRound: #{round}"
    puts "\n#{human.name}: #{human.score}   #{computer.name}: #{computer.score}"
  end

  def display_whos_turn
    puts "\nIt is #{players.first.name}'s' turn."
  end

  def display_round_winner
    clear_screen_and_display_board
    case board.winning_marker
    when human.marker then puts "#{human.name} is the round winner!"
    when computer.marker then puts "#{computer.name} won!"
    else puts "It's a tie!"
    end
    puts ""
  end

  def display_match_winner
    puts "#{who_is_match_winner.name} is the match winner!"
    puts "\n#{human.name} won #{human.score} rounds."
    puts "#{computer.name} won #{computer.score} rounds."
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end
end

module HumanMoveset
  def move
    puts "Choose a square between (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = marker
  end

  private

  def choose_marker
    puts "\nEnter any single character to set #{self.class::PLAYER}'s marker"
    puts "that is not a number, W, J, or Ʃ."
    mark = nil
    loop do
      mark = ' ' + gets.chomp.strip
      break unless marker_validation(mark)
      puts "Sorry, must be single character that is not a number, W, J, or Ʃ. "
    end
    mark
  end

  def ask_for_name
    puts "\nEnter a name for #{self.class::PLAYER}:"
    player_name = nil
    loop do
      player_name = gets.chomp
      p player_name
      break unless name_validation(player_name)
      puts "Sorry, please enter a name between 1 and 12 characters."
    end
    player_name
  end

  def same_name?(player_name)
    player_name.downcase == human.name.downcase if self.class == HumanOpponent
  end

  def name_validation(player_name)
    player_name.length >= 12 ||
    player_name.empty? ||
    same_name?(player_name)
  end

  def same_markers?(mark)
    mark.downcase == human_marker.downcase if self.class == HumanOpponent
  end

  def marker_validation(mark)
    mark.length != 2 ||
      [' W', ' J', ' Ʃ'].include?(mark.upcase) ||
      same_markers?(mark) ||
      mark.match?(/[0-9]/)
  end

  def joinor(open_squares, delimiter=', ', word='or')
    case open_squares.size
    when 0 then ''
    when 1 then open_squares.first
    when 2 then open_squares.join(" #{word} ")
    else
      open_squares[-1] = "#{word} #{open_squares.last}"
      open_squares.join(delimiter)
    end
  end
end

# Opponent Movesets

module EasyMoveset
  def move
    board[board.unmarked_keys.sample] = marker
  end
end

module MediumMoveset
  def move
    best_square = computer_turn
    board[best_square] = marker
  end

  private

  def find_winning_lines(marker)
    board.winning_lines.select do |line|
      squares = board.squares.values_at(*line).collect(&:marker)
      squares.count(marker) == (Math.sqrt(board.size) - 1) &&
        squares.any?(Square::INITIAL_MARKER)
    end
  end

  def find_winning_squares(marker)
    find_winning_lines(marker).flatten.select do |line|
      board.squares[line].marker == Square::INITIAL_MARKER
    end
  end

  def determine_strategic_square(marker)
    return unless find_winning_lines(marker).any?
    find_winning_squares(marker).sample
  end

  def determine_center_square
    return unless board.size.odd? &&
                  board.squares[(board.size / 2) + 1].marker ==
                  Square::INITIAL_MARKER
    (board.size / 2) + 1
  end

  def computer_turn
    offense = determine_strategic_square(marker)
    defense = determine_strategic_square(human_marker)
    center = determine_center_square
    random = board.unmarked_keys.sample

    [offense, defense, center, random].compact.first
  end
end

module HardMoveset
  # rubocop:disable Metrics/MethodLength

  def move
    best_score = -Float::INFINITY
    best_move = nil
    board.unmarked_keys.each do |key|
      board[key] = marker
      score = minimax(0, -Float::INFINITY, Float::INFINITY, false)
      board[key] = Square::INITIAL_MARKER
      if score > best_score
        best_score = score
        best_move = key
      end
    end
    board[best_move] = marker
  end

  # rubocop:enable Metrics/MethodLength

  private

  def minimax(depth, alpha, beta, is_maximizing)
    if board.someone_won? || depth >= max_depth
      return minimax_score(depth)
    end
    if is_maximizing
      maximizing(depth, alpha, beta)
    else
      minimizing(depth, alpha, beta)
    end
  end

  def maximizing(depth, alpha, beta)
    best_score = -Float::INFINITY
    board.unmarked_keys.each do |key|
      board[key] = marker
      score = minimax(depth + 1, alpha, beta, false)
      board[key] = Square::INITIAL_MARKER
      best_score = [score, best_score].max
      alpha = [alpha, score].max
      break if beta <= alpha
    end
    best_score
  end

  def minimizing(depth, alpha, beta)
    best_score = Float::INFINITY
    board.unmarked_keys.each do |key|
      board[key] = human_marker
      score = minimax(depth + 1, alpha, beta, true)
      board[key] = Square::INITIAL_MARKER
      best_score = [score, best_score].min
      beta = [beta, score].min
      break if beta <= alpha
    end
    best_score
  end

  def minimax_score(depth)
    case board.winning_marker
    when marker
      10 - depth
    when human_marker
      depth - 10
    else
      0
    end
  end

  def max_depth
    case board.size
    when 9 then 7
    when 16 then 6
    when 25 then 5
    end
  end
end

class Board
  attr_reader :squares, :board_size

  def initialize
    @board_size = prompt_what_size
    @squares = {}
    reset
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Layout/LineLength

  def draw
    root = board_length
    row_multiple = root - 2
    output = ''

    squares.each do |k, _v|
      if k % root > 0
        output <<  "|-------+#{('-------+' * row_multiple)}-------|\n" unless k > 1
        output <<  "|       |#{('       |' * row_multiple)}       |\n" unless k > 1
        output << "|  #{squares[k]}   "
      elsif k % root == 0
        output << "|  #{squares[k]}   |\n"
        output << "|       |#{('       |' * row_multiple)}       |\n"
        output << "|-------+#{('-------+' * row_multiple)}-------|\n"
        output << "|       |#{('       |' * row_multiple)}       |\n" unless k == board_size
      end
    end
    puts output
  end

  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Layout/LineLength

  def size
    squares.size
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    winning_lines.each do |line|
      squares = @squares.values_at(*line)
      if identical_marker_line?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..board_size).each { |key| squares[key] = Square.new }
    Square.reset
  end

  def winning_lines
    winning_rows +
      winning_columns +
      winning_diagonals
  end

  private

  def prompt_what_size
    puts "Enter a board size of either: 3, 4, or 5."
    answer = nil
    loop do
      answer = gets.chomp.to_f
      break if [3, 4, 5].include?(answer)
      puts "Sorry, that's not a valid choice."
      puts "Please enter either 3, 4, or 5."
    end
    answer**2
  end

  def board_length
    Math.sqrt(board_size).to_i
  end

  def winning_rows
    (1..board_size).each_slice(board_length).with_object([]) do |square, rows|
      rows << square
    end
  end

  def winning_columns
    winning_rows.transpose
  end

  def winning_diagonal_l_to_r
    across_slice_l_to_r = board_length + 1
    diag_right = []

    diag_right << (1..board_size).to_a
                                 .each_slice(across_slice_l_to_r)
                                 .map(&:first)
  end

  def winning_diagonal_r_to_l
    across_slice_r_to_l = board_length - 1
    diag_left = []

    diag_left << (1..board_size).to_a
                                .rotate(across_slice_r_to_l)
                                .each_slice(across_slice_r_to_l)
                                .map(&:first)[0...-2]
  end

  def winning_diagonals
    winning_diagonal_l_to_r + winning_diagonal_r_to_l
  end

  def identical_marker_line?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != Math.sqrt(board_size).to_i
    markers.uniq.size == 1
  end
end

class Square
  INITIAL_MARKER = ' '

  @@square_num = 1

  attr_accessor :marker
  attr_reader :num

  def initialize
    @marker = INITIAL_MARKER
    @num = convert_to_two_chars
    @@square_num += 1
  end

  def to_s
    marker == INITIAL_MARKER ? num : marker
  end

  def self.reset
    @@square_num = 1
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end

  private

  def convert_to_two_chars
    @@square_num < 10 ? " #{@@square_num}" : @@square_num.to_s
  end
end

class Player
  attr_accessor :board, :score
  attr_reader :marker, :name

  def initialize(board)
    @board = board
    @score = 0
  end

  def reset_score
    @score = 0
  end
end

class Human < Player
  PLAYER = 'Player 1'
  include HumanMoveset

  def initialize(board)
    @name = ask_for_name
    @marker = choose_marker
    super
  end
end

class Computer < Player
  OPPONENTS = ['(1) Human (PvP)',
               '(2) Wall-E (Easy)',
               '(3) Jarvis (Medium)',
               '(4) Ex Machina (Hard)']

  attr_reader :human, :human_marker

  def initialize(board, human)
    super(board)
    @human = human
    @human_marker = human.marker
  end
end

class HumanOpponent < Computer
  PLAYER = 'Player 2'
  include HumanMoveset

  def initialize(board, human_marker)
    super
    @name = ask_for_name
    @marker = choose_marker
  end
end

class WallE < Computer
  include EasyMoveset

  def initialize(board, human_marker)
    super
    @name = "WALL-E"
    @marker = ' W'
  end
end

class Jarvis < Computer
  include MediumMoveset

  def initialize(board, human_marker)
    super
    @name = "J.A.R.V.I.S"
    @marker = ' J'
  end
end

class ExMachina < Computer
  include HardMoveset

  def initialize(board, human_marker)
    super
    @name = "Ex Machina"
    @marker = ' Ʃ'
  end
end

class TTTGame
  WINNING_SCORE = 3

  include Displayable

  attr_accessor :round
  attr_reader :board, :human, :computer, :players

  def initialize
    display_welcome_message
    @board = Board.new
    @human = Human.new(board)
    @computer = select_opponent
    @players = set_who_goes_first
    @round = 1
  end

  def play
    play_match
    display_goodbye_message
  end

  private

  def begin_io
    puts "\nPress any key start!"
    $stdin.getch
    clear
  end

  def start_match_io
    puts "\nWe're ready to go! Press any key to start the match!"
    $stdin.getch
  end

  def play_match
    loop do
      start_match_io
      main_game
      display_match_winner if match_winner?
      break unless another_match?
      reset_match
    end
  end

  def main_game
    loop do
      clear
      display_board
      player_move
      set_score
      display_round_winner
      break if match_winner? || ask_to_play_next_round
      reset_round
    end
  end

  def match_winner?
    !!who_is_match_winner
  end

  def who_is_match_winner
    if human.score == WINNING_SCORE
      human
    elsif computer.score == WINNING_SCORE
      computer
    end
  end

  def another_match?
    answer = ''
    loop do
      puts "Would you like to play a new match? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Sorry, must be y or n."
    end
    answer == 'y'
  end

  def ask_who_goes_first
    puts "\nWho should go first?: (1) #{human.name}
                      (2) #{computer.name}
                      (3) Random"

    choice = nil
    loop do
      choice = gets.chomp.to_i
      break if [1, 2, 3].include?(choice)
      puts "Sorry, that's not a valid choice."
    end
    choice
  end

  def set_who_goes_first
    case ask_who_goes_first
    when 1
      [human, computer]
    when 2
      [computer, human]
    when 3
      [human, computer].shuffle
    end
  end

  def list_opponents
    if board.size == 9
      Computer::OPPONENTS.join(', ')
    else
      Computer::OPPONENTS[0..2].join(' or ')
    end
  end

  def opponent_options_arr(choice)
    if board.size == 9
      [1, 2, 3, 4].include?(choice)
    else
      [1, 2, 3].include?(choice)
    end
  end

  def ask_which_opponent
    puts "\nPlease select an opponent: #{list_opponents}"
    choice = nil
    loop do
      choice = gets.chomp.to_i
      break if opponent_options_arr(choice)
      puts "Sorry, that's not a valid choice."
    end
    choice
  end

  def select_opponent
    case ask_which_opponent
    when 1 then HumanOpponent.new(board, human)
    when 2 then WallE.new(board, human)
    when 3 then Jarvis.new(board, human)
    when 4 then ExMachina.new(board, human)
    end
  end

  def ask_to_play_next_round
    answer = ''
    loop do
      puts "Would you like to start the next round? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Sorry, must be y or n."
    end
    answer == 'n'
  end

  def current_player
    players.first
  end

  def rotate_player
    players.rotate!
  end

  def player_move
    loop do
      current_player.move
      rotate_player
      break if board.someone_won? || board.full?
      clear_screen_and_display_board
    end
  end

  def set_score
    case board.winning_marker
    when human.marker then human.score += 1
    when computer.marker then computer.score += 1
    end
  end

  def reset_round
    board.reset
    increment_round_num
    @players = set_who_goes_first
  end

  def increment_round_num
    self.round += 1
  end

  def reset_round_num
    self.round = 0
  end

  def reset_match
    board.reset
    reset_round_num
    reset_scores
    clear
    @computer = select_opponent
    @players = set_who_goes_first
  end

  def reset_scores
    human.score = 0
    computer.score = 0
  end
end

# game = TTTGame.new
# game.play
