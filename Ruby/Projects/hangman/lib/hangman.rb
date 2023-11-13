require 'io/console'
require 'yaml'

GUESSES_ALLOWED = 7

module Displayable
  def display_welcome
    clear
    puts <<~WELCOME
Welcome to Hangman! Figure out the hidden word by guessing letters. 
If you think you know the word, try guessing it! 
You can only make 7 mistakes or else you lose!
            WELCOME
    start_options
  end

  def clear
    Gem.win_platform? ? (system 'cls') : (system 'clear')
  end

  def start_options
    puts "Please enter an option:"
    puts "\n1 - New Game"
    puts "2 - Load Game (#{save_file_date})" if save_file_date

    response = nil

    loop do
      response = gets.chomp
      if response == '1'
        break
      elsif response == '2' && save_file_date
        load_game
        break
      else
        puts "Please enter a corresponding number for an option."
      end
    end
  end

  def save_file_date
    if File.exist?('save_game/hangman_save.yaml')
      file = File.open('save_game/hangman_save.yaml')
      File.mtime(file).strftime("%d/%m/%Y, %H:%M:%S")
    end
  end

  def turn_options
    puts <<~TURN
      Please enter a single letter to guess a letter, or a word to guess the word, or enter:
        1: Save Game
        2: Load Game (#{save_file_date})
        3. New Game
        4. Quit Game
    TURN
  end
end

class Hangman
  include Displayable

  attr_accessor :board, :player

  def initialize
    @board = Board.new
    @player = Player.new(board)
  end

  def play
    display_welcome
    loop do
      board.draw_board
      player_turn
      break if board.winner? || board.loser?
    end
    board.draw_board
    puts board.winner? ? "\nYou win!" : "\nYou lose!"
  end

  def player_turn
    response = player.retrieve_guess

    case response
    when /^[a-z]{1}$/
      board.add_letter(response)
    when /^[a-z]{2,}/
      board.add_word(response)
    when '1'
      save_game
    when '2'
      begin
        load_game
      rescue
        puts "No previous save, please select a different option."
        sleep 3
      end
    when '3'
      new_game
    when '4'
      quit_game
    end
  end

  def new_game
    puts "Loading new game..."
    sleep 2
    self.board = Board.new
    self.player = Player.new(board)
  end

  def quit_game
    puts "Thanks for playing!"
    exit
  end

  def load_game
    file = File.open('save_game/hangman_save.yaml')
    from_yaml(file)
  end

  def save_game
    Dir.mkdir('save_game') unless Dir.exist?('save_game')

    filename = "save_game/hangman_save.yaml"
    save_state = to_yaml

    File.open(filename, 'w') do |file|
      file.puts save_state
    end

    puts "Game Saved!"
    sleep 2
  end

  def to_yaml
    YAML.dump({
                board: @board,
                player: @player
              })
  end

  def from_yaml(string)
    data = YAML.load string
    self.board = data[:board]
    self.player = data[:player]
  end
end

class Player
  include Displayable

  attr_reader :board

  def initialize(board)
    @board = board
  end

  def retrieve_guess
    turn_options
    guess = nil

    loop do
      guess = gets.chomp.downcase

      if board.letter_used?(guess)
        puts "You've already used #{guess}. Please enter a different letter."
      elsif board.word_used?(guess.scan(/[a-z]/).join)
        puts "You've already guessed #{guess}. Please enter a different word."
      else
        break
      end
    end
    guess
  end
end

class Word
  attr_reader :new_word

  def initialize
    @new_word = new_word
  end

  def open_dictionary
    file = File.open("google-10000-english-no-swears.txt", 'r')
    file.readlines.map(&:chomp)
  end

  def random_word
    open_dictionary.select { |word| word.size.between?(5, 12) }.sample.downcase
  end
end

class Board
  include Displayable

  attr_accessor :board, :guesses, :mistakes, :word_guesses
  attr_reader :word

  def initialize
    @board = board
    @word = Word.new.random_word
    @guesses = []
    @word_guesses = []
    @mistakes = 0
  end

  def draw_board
    clear
    puts "H-A-N-G-M-A-N"
    puts ""
    puts winner? || loser? ? word : show_guessed_letters
    puts "\nGuessed letter: [#{guesses.sort.join(', ')}]"
    puts "Guessed words: [#{word_guesses.join(', ')}]"
    puts "\nMistakes: #{mistakes}"
    puts ""
  end

  def letter_used?(letter)
    guesses.include?(letter)
  end

  def word_used?(guess)
    word_guesses.include?(guess)
  end

  def add_letter(guess)
    guesses << guess
    self.mistakes += 1 unless correct_letter?(guess)
  end

  def add_word(guess)
    word_guesses << guess
    self.mistakes += 1 unless correct_word?
  end

  def correct_letter?(guess)
    word.include?(guess)
  end

  def loser?
    mistakes == GUESSES_ALLOWED
  end

  def winner?
    correct_letters? || correct_word?
  end

  def correct_letters?
    word.chars.all? { |letter| guesses.include? letter }
  end

  def correct_word?
    word_guesses.any? { |guess| guess == word }
  end

  def show_guessed_letters
    word.chars.map do |letter|
      if guesses.include?(letter)
        letter
      else
        "_"
      end
    end.join
  end
end

Hangman.new.play
