require_relative '../lib/connect_four'

describe Board do
	subject(:board) {described_class.new}
	before { board.create_slots}

	describe 'creates board' do
		empty_slot = '__'

		it 'creates a row of 7 empty slots' do
			slots_in_a_row = 7

			row = board.create_row

			expect(row).to include(empty_slot).exactly(7).times
		end

		it 'creates a 42 slots' do
			correct_num_slots = 42

			board_slots = board.slots.flatten

			expect(board_slots).to include(empty_slot).exactly(42).times
		end

		it 'creates 6 rows' do
			correct_num_rows = 6

			num_rows = board.slots.size

			expect(num_rows).to be (correct_num_rows)
		end
	end

	describe 'find next available slot' do

		it 'when rows are empty' do
			selected_column = 3
			available_slot = board.next_available_slot(selected_column)
			correct_slot = [5, 3]

			expect(available_slot).to eq(correct_slot) 
		end

		it 'when column contains tokens' do
			selected_column = 5
			token = WhiteToken.new
			board.slots[5][5] = token
			board.slots[4][5] = token
			board.slots[3][5] = token

			correct_slot = [2, 5]
			available_slot = board.next_available_slot(selected_column)

			expect(available_slot).to eq(correct_slot) 
		end
	end

	describe 'add_token' do

		let(:board) {described_class.new}

		before do 
			board.create_slots
		end

		it 'adds correct token to specified slot when column empty' do

			selected_column = 5
			white_token = WhiteToken.new

			board[selected_column] = white_token
			correct_slot = board.slots[5][5]

			expect(correct_slot.color).to eq("⚪")
		end

		it 'adds correct token to specified slot when column not empty' do
			
			black_token = BlackToken.new
			white_token = WhiteToken.new

			board.slots[5][4] = black_token
			board.slots[4][4] = black_token

			selected_column = 4

			board[selected_column] = white_token
			correct_slot = board.slots[3][4]

			expect(correct_slot.color).to eq("⚪")
		end
	end

	describe 'resets_board' do
		it 'resets board to all empty slots' do
			token = WhiteToken.new

			board.slots.each_with_index do |row, row_idx|
				row.each_with_index {|column, column_idx| board.slots[row_idx][column_idx] = token}
			end

			board.reset_board
			slots = board.slots.flatten

			expect(slots).to all(eq(Board::EMPTY_SLOT))
		end
	end

	describe 'winning conditions' do
		let(:white_token) { WhiteToken.new }
		let(:black_token) { BlackToken.new }

		before do 
			board.create_slots 
		end

		example 'four adjacent horizontally' do
			board.slots[5][0] = white_token
			board.slots[5][1] = white_token
			board.slots[5][2] = white_token
			board.slots[5][3] = white_token

			expect(board.winner?).to eq("⚪")
		end

		example 'four adjacent vertically' do
			board.slots[5][0] = black_token
			board.slots[4][0] = black_token
			board.slots[3][0] = black_token
			board.slots[2][0] = black_token

			expect(board.winner?).to eq("⚫")
		end

		example 'bottom left to top right in a row' do
			board.slots[2][5] = WhiteToken.new
			board.slots[5][2] = WhiteToken.new
			board.slots[4][3] = WhiteToken.new
			board.slots[3][4] = WhiteToken.new

			expect(board.winner?).to eq("⚪")
		end

		example 'bottom left to top right not in a row' do
			board.slots[1][6] = WhiteToken.new
			board.slots[5][2] = WhiteToken.new
			board.slots[4][3] = WhiteToken.new
			board.slots[3][4] = WhiteToken.new

			expect(board.winner?).to be false
		end

		example '3 white and 1 black in a row' do
			board.slots[2][5] = BlackToken.new
			board.slots[5][2] = WhiteToken.new
			board.slots[4][3] = WhiteToken.new
			board.slots[3][4] = WhiteToken.new

			expect(board.winner?).to be false
		end

		example 'top left to bottom right 4 in a row' do
			board.slots[0][0] = WhiteToken.new
			board.slots[1][1] = WhiteToken.new
			board.slots[2][2] = WhiteToken.new
			board.slots[3][3] = WhiteToken.new

			expect(board.winner?).to eq("⚪")
		end

		example 'top left to bottom right 4 in a row top quadrant' do
			board.slots[0][3] = WhiteToken.new
			board.slots[1][4] = WhiteToken.new
			board.slots[2][5] = WhiteToken.new
			board.slots[3][6] = WhiteToken.new

			expect(board.winner?).to eq("⚪")
		end

		example 'top left to bottom right 3 in a row' do
			board.slots[1][0] = WhiteToken.new
			board.slots[2][1] = WhiteToken.new
			board.slots[3][2] = WhiteToken.new

			expect(board.winner?).to be false
		end

		example 'top left to bottom right 4 not in a row' do
			board.slots[1][0] = WhiteToken.new
			board.slots[2][1] = WhiteToken.new
			board.slots[3][2] = WhiteToken.new
			board.slots[5][4] = WhiteToken.new

			expect(board.winner?).to be false
		end

		example 'top left to bottom right 5 with one different token' do
			board.slots[1][0] = WhiteToken.new
			board.slots[2][1] = WhiteToken.new
			board.slots[3][2] = WhiteToken.new
			board.slots[4][3] = BlackToken.new
			board.slots[5][4] = WhiteToken.new

			expect(board.winner?).to be false
		end

		example 'white and black cross' do
			board.slots[1][0] = WhiteToken.new
			board.slots[2][1] = WhiteToken.new
			board.slots[3][2] = WhiteToken.new
			board.slots[4][3] = BlackToken.new
			board.slots[5][4] = WhiteToken.new
			board.slots[2][5] = BlackToken.new
			board.slots[3][4] = BlackToken.new
			board.slots[5][2] = BlackToken.new

			expect(board.winner?).to eq("⚫")
		end
	end
end


describe 'Tokens' do
	describe "White Token" do
		subject(:white) {WhiteToken.new}

		it 'is a white unicode symbol' do
			puts_token = "⚪\n"
			expect { puts white }.to output(puts_token).to_stdout
		end
	end

	describe "Black Token" do
		subject(:black) {BlackToken.new}

		it 'is a white unicode symbol' do
			puts_token = "⚫\n"
			expect { puts black }.to output(puts_token).to_stdout
		end
	end
end

describe Player do
	subject(:player) {described_class.new(board)}
	let(:board) {Board.new}

	before {board.create_slots}

	describe 'can add token to board' do
		it 'adds token to correct slot' do
			selected_column = 4
			player.token = WhiteToken.new
			player.add_token(selected_column)

			correct_slot = board.slots[5][3].color

			expect(correct_slot).to eq("⚪")
		end
	end

	describe 'player input only accepts 1-7' do
		it 'returns true on valid entry' do
			sample_entry = '4'
			expect(player.valid_entry?(sample_entry)).to be true
		end

		it 'raises an invalid entry error if not valid' do
			sample_entry = '12'
			output = "Invalid entry\n"
			expect { player.valid_entry?(sample_entry) }.to output(output).to_stdout
		end

		it 'raises an invalid entry error if entry is made of letters' do
			sample_entry = 'dog'
			output = "Invalid entry\n"
			expect { player.valid_entry?(sample_entry) }.to output(output).to_stdout
		end

		it 'raises an invalid entry error if entry is punctuation' do
			sample_entry = '../.'
			output = "Invalid entry\n"
			expect { player.valid_entry?(sample_entry) }.to output(output).to_stdout
		end

	end

end

describe ConnectFour do
	subject(:game) {described_class.new}
	# let(:player_one) {double('player_one', token: WhiteToken.new) }

	describe 'reveals correct winner' do
		it 'is black when black' do
			allow(game.board).to receive(:winner?).and_return("⚪")

			game.player_one.token = WhiteToken.new

			expect(game.determine_winner).to eq(game.player_one)
		end
	end

end








