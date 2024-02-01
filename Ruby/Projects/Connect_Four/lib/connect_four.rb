class WhiteToken
	attr_reader :token

	def initialize
		@token = "⚪"
	end

	def to_s
		token
	end
end

class BlackToken
	attr_reader :token

	def initialize
		@token = "⚫"
	end

	def to_s
		token
	end
end

class Player
	attr_accessor :token, :board

	def initialize(board)
		@token = WhiteToken.new
		@board = board
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

	def retrieve_input
		input = nil

		loop do
			puts "Please enter a number between 1 and 7"
			input = gets.chomp
			break if valid_entry?(input)
		end

		input.to_i
	end

	def player_move
		column = retrieve_input
		add_token(column)
	end


end

class Board
	EMPTY_SLOT = '__'
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

	def winner?
		horizontal_winner || vertical_winner || diagonal_winner

	end

	def horizontal_winner(board_slots = slots)
		check_slots_for_winner(board_slots)
	end

	def vertical_winner(board_slots = slots)
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
			set.reject! {|row, column| row >= 6}
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
				return "⚪" if set.all? { |slot| slot.token == "⚪" if slot != EMPTY_SLOT }
				return "⚫" if set.all? { |slot| slot.token == "⚫" if slot != EMPTY_SLOT }
			end
		end
		false
	end

	def diagonal_winner_normal
		slots_to_check = convert_diagonal_win_coords_to_slots

		check_slots_for_winner(slots_to_check)
	end

	def diagonal_winner_mirrored
		reversed_board = slots.map {|n| n.reverse}
		slots_to_check = convert_diagonal_win_coords_to_slots(reversed_board)

		check_slots_for_winner(slots_to_check)
	end

	def diagonal_winner
		diagonal_winner_normal || diagonal_winner_mirrored
	end

end



 board = Board.new
 player = Player.new(board)

 # player.retrieve_input
 # board.create_slots
 # board.draw_board


