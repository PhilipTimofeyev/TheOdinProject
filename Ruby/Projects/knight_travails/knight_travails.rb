class Square

  attr_accessor :coordinate, :adjacents, :visited, :distance, :draw

  def initialize(coordinate)
    @coordinate = coordinate
    @adjacents = []
    @visited = false
    @draw = '_'
  end

  def add_adjacent(adjacent)
    @adjacents << adjacent
  end

  def to_s
    # "#{@name} -> [#{@adjacents.map(&:name).join(' ')}]"

  end

end


class Chessboard
  LOWER_BOUND = 0
  UPPER_BOUND = 7

  attr :board

  def initialize
    @board = {}
  end

  def add_square(square)
    @board[square.coordinate] = square
  end

  def add_adjacent(current, adjacent)
    @squares[current].add_adjacent(@squares[adjacent])
  end

  def build_board
    (LOWER_BOUND..UPPER_BOUND).each do |row|
      (LOWER_BOUND..UPPER_BOUND).each do |column|
        add_square(Square.new([row, column]))
      end
    end
  end

  def draw_board
    clear
    row_count = 7
    board.values.reverse.each_slice(8) {|n| puts "#{row_count}|#{n.reverse.map{|n| n.draw}.join("|")}|"; row_count -= 1}
    puts "  0 1 2 3 4 5 6 7"
  end

  def adjacents
    board.each do |k, v|
      possible_squares(v).each do |possible|
        board[possible].add_adjacent(v)
      end
    end
  end

  def within_bounds?(coordinate)
    coordinate.none? {|n| n < Chessboard::LOWER_BOUND || n > Chessboard::UPPER_BOUND}
  end

  def possible_squares(square)
    working = []
    x = square.coordinate.first
    y = square.coordinate.last

    working << [x + 2, y + 1]
    working << [x + 2, y - 1]
    working << [x - 2, y + 1]
    working << [x - 2, y - 1]
    working << [x + 1, y + 2]
    working << [x - 1, y + 2]
    working << [x + 1, y - 2]
    working << [x - 1, y - 2]
    working.select {|n| within_bounds?(n) && !board[n].visited}
  end

  # def possible_squares(current_square)
  #   min, max = current_square.coordinate.minmax
  #   to_permutate = ((min - 1)..(max + 1)).to_a
  #   all = to_permutate.repeated_permutation(2).select do |x, y|
  #     x.between?(current_square.coordinate.first - 1, current_square.coordinate.first + 1) && y.between?(current_square.coordinate.last - 1, current_square.coordinate.last + 1)
  #   end

  #   all.select do |square|
  #      within_bounds?(square) && !board.fetch(square, nil).visited && square != current_square.coordinate
  #   end
  # end

  def traverse(square, ending, visited_arr = [])
    return depth if square.coordinate == ending.coordinate

    queue = [square]
    depth = 0
    square.visited = true
    possible = possible_squares(square)

    while !queue.empty?

      for i in 0..queue.length - 1

        node = queue.shift
        node.visited = true
        return depth if node.coordinate == ending.coordinate
        node.coordinate
        visited_arr << node
        possible = possible_squares(node)
        possible.each {|n| queue.push(board[n])}
      end
      depth += 1
    end
  end

def find_shortest_path(starting_vertex, final_vertex, visited_vertices={})
  queue = Queue.new
  starting_vertex = board[starting_vertex]
  final_vertex = board[final_vertex]
  # As in Dijkstra's algorithm, we keep track in a table of each vertex
  # immediately preceding vertex.
  previous_vertex_table = {}

  # We employ breadth-first search:
  starting_vertex.visited = true
  queue.push(starting_vertex)

  while !queue.empty?
    current_vertex = queue.shift
    current_vertex.adjacents.each do |adjacent_vertex|
      if !adjacent_vertex.visited
        adjacent_vertex.visited = true
        queue.push(adjacent_vertex)
        # We store in the previous_vertex table the adjacent_vertex
        # as the key, and the current_vertex as the value. This
        # indicates that the current_vertex is the immediately
        # preceding vertex that leads to the adjacent_vertex.
        previous_vertex_table[adjacent_vertex.coordinate] = current_vertex.coordinate
      end
    end
  end

  # As in Dijkstra's algorithm, we work backwards through the
  # previous_vertex_table to build the shortest path;
  shortest_path = []
  current_vertex_value = final_vertex.coordinate

  while current_vertex_value != starting_vertex.coordinate
    shortest_path << current_vertex_value
    current_vertex_value = previous_vertex_table[current_vertex_value]
  end

  shortest_path << starting_vertex.coordinate

  return shortest_path.reverse
end

def clear
  Gem.win_platform? ? (system "cls") : (system "clear")
end

def draw_path(starting_vertex, final_vertex)
  board[starting_vertex].draw = "S"
  board[final_vertex].draw = "E"
  path_arr = find_shortest_path(starting_vertex, final_vertex)
  draw_board
  path_arr.each_with_index do |step, idx|
    sleep(1)
    board[step].draw = "#{idx}"
    draw_board
  end
  p path_arr
end


  def [](name)
    @nodes[name]
  end

end



chess = Chessboard.new
chess.build_board
chess.adjacents
chess.draw_path([0, 0], [7, 6]) 