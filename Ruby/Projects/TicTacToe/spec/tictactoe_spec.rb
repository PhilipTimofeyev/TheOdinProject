require_relative '../lib/tictactoe'

describe Square do
	subject (:square) {described_class.new}

	describe 'initialization' do
		context 'when Square is initialized' do
			it 'marker is set to an empty space' do
				expect(square.marker).to eq(' ')
			end

			it 'is unmarked' do
				expect(square.unmarked?).to be true
			end
		end
	end
end

describe Player do
	context 'resetting score' do
		let(:board) { double('board') }
		subject(:player) { described_class.new(board) }

		it 'resets score to 0' do
			player.score = 5
			reset_score = 0
			player.reset_score

			expect(player.score).to be(reset_score)
		end
	end
end

describe Board do

	before (:each) do
		allow_any_instance_of(Board).to receive(:prompt_what_size).and_return(9)
		@board = Board.new
	end

	context '#initialize' do 
		it 'contains 9 squares when initialized to 9' do
			expect(@board.size).to be(9)
		end

		it 'contains all unmarked squares' do
			num_of_unmarked = @board.unmarked_keys.size
			expect(num_of_unmarked).to be(9)
		end
	end

	context 'board situations' do
		it 'marks specific square' do
			square_to_mark = 5
			@board[square_to_mark] = 'X'

			expect(@board.unmarked_keys).not_to include(square_to_mark)
		end

		it 'does not detect winner when no winner' do
			@board[8] = 'X'
			@board[5] = 'X'
			@board[3] = 'X'

			expect(@board.someone_won?).to be false
		end

		it 'detects a winner when horizontal' do
			@board[1] = 'X'
			@board[2] = 'X'
			@board[3] = 'X'

			expect(@board.someone_won?).to be true
		end

		it 'detects a winner when vertical' do
			@board[1] = 'X'
			@board[4] = 'X'
			@board[7] = 'X'

			expect(@board.someone_won?).to be true
		end

		it 'detects a winner when across' do
			@board[1] = 'X'
			@board[5] = 'X'
			@board[9] = 'X'

			expect(@board.someone_won?).to be true
		end
	end

	describe '#reset' do
		before do
			@board[1] = 'X'
			@board[2] = 'X'
			@board[3] = 'X'
			@board[4] = 'X'
			@board[5] = 'X'
			@board[6] = 'X'
			@board[7] = 'X'
			@board[8] = 'X'
			@board[9] = 'X'
		end

		it 'detects board is full' do
			expect(@board.full?).to be true
		end

		it 'resets board' do
			@board.reset
			num_of_unmarked = @board.unmarked_keys.size
			board_size = @board.size

			expect(num_of_unmarked).to be(board_size)
		end
	end
end

describe WallE do

	before (:each) do
		allow_any_instance_of(Board).to receive(:prompt_what_size).and_return(9)
	end

	let(:human) { double('human', marker: 'X') }
	let(:board) {Board.new}
	subject(:walle) {WallE.new(board, human)}

	context 'Wall-E move set' do

		it 'places marker randomly' do
			walle.move
			num_of_unmarked = board.unmarked_keys.size

			expect(num_of_unmarked).to be 8
		end
	end
end

describe Jarvis do

	before (:each) do
		allow_any_instance_of(Board).to receive(:prompt_what_size).and_return(9)
	end

	let(:human) { double('human', marker: 'X') }
	let(:board) {Board.new}
	subject(:jarvis) {Jarvis.new(board, human)}

	context 'Jarvis move set' do

		it 'places marker correctly even when clear solution' do
			board[1] = human.marker
			board[2] = human.marker

			jarvis.move
			unmarked = board.unmarked_keys
			
			expect(unmarked).not_to include(3)
		end
	end
end

describe ExMachina do

	before (:each) do
		allow_any_instance_of(Board).to receive(:prompt_what_size).and_return(9)
	end

	let(:human) { double('human', marker: 'X') }
	let(:board) {Board.new}
	subject(:exmachina) {ExMachina.new(board, human)}

	context 'ExMachina move set' do

		it 'places marker correctly even when clear solution' do
			board[7] = human.marker
			board[3] = human.marker
			board[1] = exmachina.marker
			board[2] = exmachina.marker

			exmachina.move
			unmarked = board.unmarked_keys
			
			expect(unmarked).not_to include(5)
		end
	end
end

describe TTTGame do

	subject(:game) {described_class.allocate}

	let(:human_dbl) { double('human', marker: 'X') }
	let(:computer_dbl) { double('computer', marker: 'O') }

	before (:each) do
		allow_any_instance_of(Board).to receive(:prompt_what_size).and_return(9)
		game.instance_variable_set(:@board, Board.new) 
		game.instance_variable_set(:@human, human_dbl) 
	end

	describe '#select_opponent' do

		it 'returns WallE based on input' do
			allow(game).to receive(:ask_which_opponent).and_return 2

			expected_opponent_class = WallE
			selected_opponent_class = game.select_opponent.class
			expect(selected_opponent_class).to be(expected_opponent_class)
		end

		it 'returns Jarvis based on input' do
			allow(game).to receive(:ask_which_opponent).and_return 3

			expected_opponent_class = Jarvis
			selected_opponent_class = game.select_opponent.class
			expect(selected_opponent_class).to be(expected_opponent_class)
		end

		it 'returns Ex Machina based on input' do
			allow(game).to receive(:ask_which_opponent).and_return 4

			expected_opponent_class = ExMachina
			selected_opponent_class = game.select_opponent.class
			expect(selected_opponent_class).to be(expected_opponent_class)
		end

	end

	describe '#sets_who_goes_first' do

		before(:each) {game.instance_variable_set(:@computer, computer_dbl) }

		it 'makes human first when 1' do
			allow(game).to receive(:ask_who_goes_first).and_return 1

			expected_first = [human_dbl, computer_dbl]
			expect(game.set_who_goes_first).to eq(expected_first)
		end

		it 'makes computer first when 2' do
			allow(game).to receive(:ask_who_goes_first).and_return 2

			expected_first = [computer_dbl, human_dbl]
			expect(game.set_who_goes_first).to eq(expected_first)
		end
	end

	describe '#rotate_player' do
		it 'rotates whose turn it is' do
			game.instance_variable_set(:@players, [human_dbl, computer_dbl])

			first_player = game.players.first
			second_player = game.players.last

			game.rotate_player

			expect(game.players.first).to be(second_player)
		end
	end
end




