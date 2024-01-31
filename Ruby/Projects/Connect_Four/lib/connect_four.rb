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
		puts "_" * 30
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
		horizontal_winner || vertical_winner || diagonal_winner || diagonal_winner_transposed

	end

	def horizontal_winner(board_slots = slots)
		board_slots.each do |row|
			row.each_cons(4) do |set|
				return "⚪" if set.all? { |slot| slot.token == "⚪" if slot != EMPTY_SLOT }
				return "⚫" if set.all? { |slot| slot.token == "⚫" if slot != EMPTY_SLOT }
			end
		end
		false
	end

	def vertical_winner(board_slots = slots)
		 transposed = slots.transpose
		 horizontal_winner(transposed)
	end

	def diagonal_left_right_winner
		starter = 0
		row = 0
		column = 0
		result = []

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

			result << set
			set = []
			starter += 1
			column += 1
			break if starter == 4
		end	

		result
	end

	def diagonal_right_left_winner
		diag_line = diagonal_left_right_winner.dup

		diag_line.each do |n| 
			n.map! do |a| 
				a.reverse
			end
		end

		diag_line[1..-1].each do |set|
			set.reject! {|row, column| row >= 6}
		end
	end

	def diagonal_winner(board_slots = slots)
		diag = diagonal_left_right_winner + diagonal_right_left_winner

		diag.each {|n| n}
		diag.each do |set|
			set.map! { |n| board_slots[n[0]][n[1]] }
		end
		# p diag
		diag.each do |row|
			row.each_cons(4) do |set|
				return "⚪" if set.all? { |slot| slot.token == "⚪" if slot != EMPTY_SLOT }
				return "⚫" if set.all? { |slot| slot.token == "⚫" if slot != EMPTY_SLOT }
			end
		end
		false
	end

	def diagonal_winner_transposed
		diag = diagonal_left_right_winner + diagonal_right_left_winner
		reversed_board = slots.map {|n| n.reverse}

		diag.each {|n| n}
		diag.each do |set|
			set.map! { |n| reversed_board[n[0]][n[1]] }
		end
		# p diag
		diag.each do |row|
			row.each_cons(4) do |set|
				return "⚪" if set.all? { |slot| slot.token == "⚪" if slot != EMPTY_SLOT }
				return "⚫" if set.all? { |slot| slot.token == "⚫" if slot != EMPTY_SLOT }
			end
		end
		false
	end

end



 board = Board.new
 board.create_slots
 # x.draw_board
# x.slots[2][0] = WhiteToken.new
# x.slots[3][1] = WhiteToken.new
# x.slots[4][2] = WhiteToken.new
# x.slots[5][3] = WhiteToken.new

board.slots[1][0] = WhiteToken.new
board.slots[2][1] = WhiteToken.new
board.slots[3][2] = WhiteToken.new
board.slots[4][3] = BlackToken.new
board.slots[5][4] = WhiteToken.new


 board.draw_board
p board.diagonal_left_right_winner
# x.diagonal_right_left_winner
# p x.diagonal_winner
# p x.diagonal_winner_transposed
 p board.winner?

# p x.vertical_winner
# x.draw_board


# x = [1, 1, 1, 2]
# p x.all? {|n| n == 1 || n == 2}
