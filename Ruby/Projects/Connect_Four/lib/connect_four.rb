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
	attr_accessor :slots

	def initialize
		@slots = []
	end

	def create_slots
		6.times {self.slots << create_row}
	end

	def create_row
		row = []
		7.times {row << '_'}

		row
	end




end