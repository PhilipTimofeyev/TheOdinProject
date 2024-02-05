

class HashMap
	LOAD_FACTOR = 0.75
	attr_accessor :buckets, :divisor

	def initialize
		@buckets = Array.new(16)
		@divisor = @buckets.size
	end

	def hash(string)
	  string_to_number(string)
	end

	def string_to_number(string)
	  hash_code = 0
	  prime_number = 31

	  string.each_char { |char| hash_code = prime_number * hash_code + char.ord }

	  hash_code % divisor
	end

	class HashNode
		attr_accessor :key, :value, :next_node

		def initialize(key, value, next_node = nil)
			@key = key
			@value = value
			@next_node = next_node
		end

		def get_value
			value.count == 1 ? value.first : value.flatten
		end
	end

	def set(key, *value)
		node = HashNode.new(key, value)
		hash_key = hash(key)
		raise IndexError if hash_key.negative? || hash_key >= @buckets.length

		expand_hash if overload?

		if !buckets[hash_key].nil?
			if key_already_exists?(key, hash_key)
				buckets[hash_key].value << value
			else
				first_node = buckets[hash_key]
				last_node = find_end_node(first_node)
				
				last_node.next_node = node
			end
		else
			buckets[hash_key] = node
		end
	end

	def key_already_exists?(new_key, hash_key)
		new_key == buckets[hash_key].key
	end

	def find_end_node(first_node)
		return first_node if first_node.next_node.nil?

		find_end_node(first_node.next_node)
	end

	def list_nodes(first_node)
		nodes = []

		current_node = first_node

		loop do 
			nodes << current_node
			break if current_node.next_node.nil?
			current_node = current_node.next_node
		end

		nodes
	end

	def expand_hash
		new_size = buckets.size * 2
		self.divisor = new_size

		old_hash = buckets
		self.buckets = Array.new(new_size)

		old_hash.each do |bucket|
			if bucket.nil?
				next
			else
				key = bucket.key
				hash_key = hash(key)
				buckets[hash_key] = bucket
			end
		end
	end

	def get(key)
		hash_key = hash(key)
		raise IndexError if hash_key.negative? || hash_key >= @buckets.length

		buckets[hash_key]
	end

	def key?(key)
		!!get(key)
	end

	def remove(key)
		return nil unless key?(key)
		to_remove = get(key)

		hash_key = hash(key)
		buckets[hash_key] = nil
	end

	def keys
		list_all_nodes.map(&:key)
	end

	def list_all_head_nodes
		head_nodes = buckets.reject {|bucket| bucket.nil?}
	end

	def list_all_nodes
		all_nodes = []
		list_all_head_nodes.each do |head_node|
			# p head_node
			list_nodes(head_node).each {|node| all_nodes << node}
		end

		all_nodes
	end

	def values
		list_all_nodes.map(&:get_value)
	end

	def length
		buckets.count {|bucket| !bucket.nil?}
	end

	def clear
		buckets.map! {|bucket| nil}
	end

	def overload?
		num_empty_buckets = buckets.select(&:nil?).size.to_f

		(num_empty_buckets / divisor) < LOAD_FACTOR
	end	

	def entries
		keys.zip(values)
	end

end


