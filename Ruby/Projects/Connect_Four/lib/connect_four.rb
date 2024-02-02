require 'io/console'

module Displayable
  def clear
    Gem.win_platform? ? (system "cls") : (system "clear")
  end
end

class WhiteToken
  attr_reader :color

  def initialize
    @color = "⚪"
  end

  def to_s
    color
  end
end

class BlackToken
  attr_reader :color

  def initialize
    @color = "⚫"
  end

  def to_s
    color
  end
end

class Player
  attr_accessor :token, :board, :player_name
  attr_reader :player_num

  @@class_count = 0

  def initialize(board)
    @token = token
    @board = board
    @@class_count += 1
    @player_num = @@class_count
  end

  def add_token(column)
    board[column - 1] = token
  end

  def valid_entry?(entry)
    if entry.to_i.between?(1, 7)
      true
    else
      puts "Invalid entry"
      false
    end
  end

  def set_token
    puts "Please select a token, #{player_name}.\n Enter 1 for white ⚪ and 2 for black ⚫"

    input = nil

    loop do
      input = gets.chomp.to_i

      break if input.between?(1, 2)
      puts "Not a valid entry."
    end

    self.token = input.to_i == 1 ? WhiteToken.new : BlackToken.new
  end

  def set_player_name
    puts "Please enter a name for player #{player_num}"

    self.player_name = gets.chomp
  end

  def retrieve_input
    input = nil

    puts "#{player_name} please enter a column to drop a token to:"
    loop do
      input = gets.chomp.to_i
      break if valid_entry?(input) && !board.column_full?(input)

      if board.column_full?(input)
        puts "Column is full. Enter a different column."
      end
    end

    input.to_i
  end

  def move
    column = retrieve_input
    add_token(column)
  end
end

class Board
  EMPTY_SLOT = '__'
  include Displayable

  attr_accessor :slots

  def initialize
    @slots = []
  end

  def create_slots
    6.times { @slots << create_row }
  end

  def create_row
    row = []
    7.times { row << EMPTY_SLOT }

    row
  end

  def draw_board
    clear
    puts "  C O N N E C T   F O U R"
    puts "_" * 30
    puts "  1   2   3   4   5   6   7"
    puts "―" * 30
    slots.each do |row|
      puts " "
      puts "‖ " + row.join("  ") + " ‖"
    end
    puts "―" * 30
  end

  def []=(column, token)
    row, column = next_available_slot(column)

    @slots[row][column] = token
  end

  def next_available_slot(column)
    5.downto(0) do |row|
      slot = slots[row][column]
      return [row, column] if slot == EMPTY_SLOT
    end
  end

  def reset_board
    @slots = []
    create_slots
  end

  def column_full?(column)
    slots[0][column - 1] != EMPTY_SLOT
  end

  def full?
    slots[0].none? { |slot| slot == EMPTY_SLOT }
  end

  def winner?
    horizontal_winner || vertical_winner || diagonal_winner
  end

  def horizontal_winner(board_slots = slots)
    check_slots_for_winner(board_slots)
  end

  def vertical_winner(_board_slots = slots)
    transposed = slots.transpose
    horizontal_winner(transposed)
  end

  def diagonal_winning_coords_top_half
    starter = 0
    row = 0
    column = 0
    coordinates = []

    loop do
      set = []

      loop do
        set << [row, column]
        row += 1
        column += 1
        if column > 6 || row > 5
          row = 0
          column = starter
          break
        end
      end

      coordinates << set
      set = []
      starter += 1
      column += 1
      break if starter == 4
    end

    coordinates
  end

  def diagonal_winning_coords_bottom_half
    diag_coords_top_half = diagonal_winning_coords_top_half

    diag_coords_top_half.each do |set|
      set.map!(&:reverse)
    end

    diag_coords_top_half[1..-1].each do |set|
      set.reject! { |row, _column| row >= 6 }
    end
  end

  def all_diagonal_winning_coords
    diagonal_winning_coords_top_half + diagonal_winning_coords_bottom_half
  end

  def convert_diagonal_win_coords_to_slots(board_slots = slots)
    coords = all_diagonal_winning_coords

    coords.each do |set|
      set.map! { |coord| board_slots[coord[0]][coord[1]] }
    end
  end

  def check_slots_for_winner(slots_to_check)
    slots_to_check.each do |row|
      row.each_cons(4) do |set|
        return "⚪" if set.all? do |slot|
                        slot.color == "⚪" if slot != EMPTY_SLOT
                      end
        return "⚫" if set.all? do |slot|
                        slot.color == "⚫" if slot != EMPTY_SLOT
                      end
      end
    end
    false
  end

  def diagonal_winner_normal
    slots_to_check = convert_diagonal_win_coords_to_slots

    check_slots_for_winner(slots_to_check)
  end

  def diagonal_winner_mirrored
    reversed_board = slots.map { |n| n.reverse }
    slots_to_check = convert_diagonal_win_coords_to_slots(reversed_board)

    check_slots_for_winner(slots_to_check)
  end

  def diagonal_winner
    diagonal_winner_normal || diagonal_winner_mirrored
  end
end

class ConnectFour
  include Displayable

  attr_accessor :board, :player_one, :player_two, :players

  def initialize
    @board = Board.new
    board.create_slots
    @player_one = Player.new(board)
    @player_two = Player.new(board)
    @players = [player_one, player_two]
  end

  def game_loop
    welcome_message
    begin_io

    loop do
      set_starting_conditions
      board.draw_board
      loop do
        current_player.move
        board.draw_board
        break if board.winner? || board.full?
        rotate_player
      end
      reveal_winner
      sleep 2
      break unless play_again?
      board.reset_board
    end
    quit_message
  end

  def set_starting_conditions
    board.draw_board
    player_one.set_player_name
    player_one.set_token
    board.draw_board
    player_two.set_player_name
    player_two_set_token
  end

  def quit_message
    puts "Thanks for playing!"
  end

  def current_player
    players.first
  end

  def play_again?
    puts "Play again? Enter 1 to play again or any other key to quit."

    input = gets.chomp.to_i
    input == 1
  end

  def rotate_player
    players.rotate!
  end

  def determine_winner
    board.winner? == player_one.token.color ? player_one : player_two
  end

  def reveal_winner
    winner = determine_winner
    if board.full?
      puts "Draw!"
    else
      puts "#{winner.player_name} is the winner!"
    end
  end

  def welcome_message
    clear
    puts "Welcome to Connect Four!"
  end

  def player_two_set_token
    player_two.token = player_one.token.color == "⚪" ? BlackToken.new : WhiteToken.new
  end

  def begin_io
    puts "\nPress any key start"
    $stdin.getch
    clear
  end
end

# game = ConnectFour.new
# game.game_loop
