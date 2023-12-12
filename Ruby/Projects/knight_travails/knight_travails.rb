
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

class Knight
  def moveset(current_square)
    adjacent_squares = []
    x = current_square.coordinate.first
    y = current_square.coordinate.last

    x_moves = [2, 2, -2, -2, 1, -1, 1, -1] 
    y_moves = [1, -1, 1, -1, 2, 2, -2, -2]

    x_moves.each_with_index{|n, idx| adjacent_squares << [x + n, y + y_moves[idx]]}

    adjacent_squares
  end
end

class Chessboard
  LOWER_BOUND = 0
  UPPER_BOUND = 7

  attr :board, :knight

  def initialize
    @board = {}
    @knight = Knight.new
    build_board
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
  end

  def draw_board
    clear
    row_count = UPPER_BOUND

    board.values.reverse.each_slice(UPPER_BOUND + 1) do |row| 
      puts "#{row_count}|#{row.reverse.map{|square| square.draw_square}.join("|")}|" 
      row_count -= 1
    end

    puts "  " + (0..UPPER_BOUND).map{|n| n.to_s}.join(" ") #labels column numbers
  end

  def validate_moves(moveset)
    moveset.select {|coord| within_bounds?(coord)}.map{|coord| board[coord]}
  end

  def within_bounds?(coordinate)
    coordinate.none? {|xy| xy < Chessboard::LOWER_BOUND || xy > Chessboard::UPPER_BOUND}
  end

  def find_shortest_path(starting_coordinate, final_coordinate)
    starting_node = board[starting_coordinate]
    final_node = board[final_coordinate]

    queue = [starting_node]
    previous_node_table = {}

    until queue.empty?
      current_node = queue.shift
      current_node.visited = true
      validate_moves(knight.moveset(current_node)).each do |adjacent_square|
        unless adjacent_square.visited
          queue.push(adjacent_square)
          previous_node_table[adjacent_square.coordinate] = current_node.coordinate
        end
      end
    end

    shortest_path = []
    current_node_coordinate = final_node.coordinate

    while current_node_coordinate != starting_coordinate
      shortest_path.prepend(current_node_coordinate)
      current_node_coordinate = previous_node_table[current_node_coordinate]
    end
    shortest_path.prepend(starting_coordinate)
  end

  def reset_board
    board.values.each do |square| 
      square.visited = false
      square.draw_square = '_'
    end
  end

  def clear
    Gem.win_platform? ? (system "cls") : (system "clear")
  end

  def knight_moves(starting_coordinate, final_coordinate)
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
chess.knight_moves([0, 0], [7, 7]) 
