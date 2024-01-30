require_relative '../lib/connect_four'

describe Board do
	subject(:board) {described_class.new}

	describe 'creates board' do
		empty_slot = '_'

		it 'creates a row of 7 empty slots' do
			slots_in_a_row = 7

			row = board.create_row

			expect(row).to include(empty_slot).exactly(7).times
		end

		it 'creates a 42 slots' do
			correct_num_slots = 42

			board.create_slots
			board_slots = board.slots.flatten

			expect(board_slots).to include(empty_slot).exactly(42).times
		end

		it 'creates 6 rows' do
			correct_num_rows = 6

			board.create_slots
			num_rows = board.slots.size

			expect(num_rows).to be (correct_num_rows)
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