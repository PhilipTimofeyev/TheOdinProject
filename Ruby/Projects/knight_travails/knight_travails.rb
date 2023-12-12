class Node
  attr_accessor :adjacents, :visited, :draw_square
  attr :coordinate

  def initialize(x, y)
    @coordinate = [x, y]
    @adjacents = []
    @visited = false
    @draw_square = '_'
  end

  def add_adjacent(adjacent)
    @adjacents << adjacent
  end
end

class Chessboard
  LOWER_BOUND = 0
  UPPER_BOUND = 7

  attr :board

  def initialize
    @board = {}
  end

  def add_node(node)
    @board[node.coordinate] = node
  end

  def build_board
    (LOWER_BOUND..UPPER_BOUND).each do |column|
      (LOWER_BOUND..UPPER_BOUND).each do |row|
        add_node(Node.new(row, column))
      end
    end
    add_all_adjacent_squares
  end

  def draw_board
    clear
    row_count = UPPER_BOUND

    board.values.reverse.each_slice(UPPER_BOUND + 1) do |n| 
      puts "#{row_count}|#{n.reverse.map{|n| n.draw_square}.join("|")}|" 
      row_count -= 1
    end

    puts "  " + (0..UPPER_BOUND).map{|n| n.to_s}.join(" ") #labels column numbers
  end

  def find_adjacents(square)
    adjacent_squares = []
    x = square.coordinate.first
    y = square.coordinate.last

    x_moves = [2, 2, -2, -2, 1, -1, 1, -1] 
    y_moves = [1, -1, 1, -1, 2, 2, -2, -2]

    x_moves.each_with_index{|n, idx| adjacent_squares << [x + n, y + y_moves[idx]]}

    adjacent_squares.select {|n| within_bounds?(n)}
  end

  def add_all_adjacent_squares #convert adjacent coordinates back to node objects and add to node.adjacents
    board.each do |coord, square|
      find_adjacents(square).each do |adj_square|
        board[adj_square].add_adjacent(square)
      end
    end
  end

  def within_bounds?(coordinate)
    coordinate.none? {|n| n < Chessboard::LOWER_BOUND || n > Chessboard::UPPER_BOUND}
  end

  def find_shortest_path(starting_coordinate, final_coordinate)

    starting_node = board[starting_coordinate]
    final_node = board[final_coordinate]

    queue = [starting_node]
    previous_node_table = {}

    until queue.empty?
      current_node = queue.shift
      current_node.visited = true
      current_node.adjacents.each do |adjacent_square|
        unless adjacent_square.visited
          queue.push(adjacent_square)
          previous_node_table[adjacent_square.coordinate] = current_node.coordinate
        end
      end
    end

    shortest_path = []
    current_node_coordinate = final_node.coordinate

    while current_node_coordinate != starting_coordinate
      shortest_path << current_node_coordinate
      current_node_coordinate = previous_node_table[current_node_coordinate]
    end

    shortest_path << starting_coordinate

    shortest_path.reverse
  end

  def reset_board
    board.values.each {|square| square.visited = false}
  end

  def clear
    Gem.win_platform? ? (system "cls") : (system "clear")
  end

  def knight_moves(starting_coordinate, final_coordinate)
    build_board
    board[starting_coordinate].draw_square = "S"
    board[final_coordinate].draw_square = "E"

    path_arr = find_shortest_path(starting_coordinate, final_coordinate)
    draw_board

    path_arr.each_with_index do |step, idx|
      sleep(1)
      board[step].draw_square = "#{idx}" unless idx == 0
      draw_board
    end

    puts "You made it in #{path_arr.size - 1} moves! Here's your path:" 
    path_arr.each {|coord| p coord }

    reset_board
  end
end



chess = Chessboard.new
chess.knight_moves([0, 7], [7, 0]) 
