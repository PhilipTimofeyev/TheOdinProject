class Node
  include Comparable
  attr_accessor :value, :left, :right

  def initialize(value, left = nil, right = nil)
    @value = value
    @left = left
    @right = right
  end

  def <=>(other_node)
    value <=> other_node.value
  end
end

class Tree
  attr_accessor :arr, :root

  def initialize(arr)
    @arr = arr
  end

  def build_tree(arr = prepare_arr)
    return nil if arr.size < 1
    
    mid = arr.size / 2

    
    root = Node.new(arr[mid])
    
    root.left = build_tree(arr[0...mid])
    root.right = build_tree(arr[mid + 1..-1])
    
    self.root = root
  end

  def prepare_arr
    arr.uniq.sort
  end

  def insert(value, node = root)
    if value < node.value
      if node.left.nil?
        node.left = Node.new(value)
      else 
        insert(value, node.left)
      end
    elsif value > node.value
      if node.right.nil?
        node.right = Node.new(value)
      else
        insert(value, node.right)
      end
    end
  end

  def delete(value, node = root)
    return nil if node.nil?
    # 
    if value == node.value
          succeeding_node = next_succeeding(node.right)
          delete(succeeding_node.value)
          succeeding_node.right = node.right
          succeeding_node.left = node.left
          node = succeeding_node
          self.root = node
    elsif value < node.value
      if node.left.value == value
        if node.left.left.nil? && node.left.right.nil?
          node.left = nil
        elsif node.left.right.nil?
          node.left = node.left.left
        elsif node.left.left.nil?
          node.left = node.left.right
        else
          succeeding_node = next_succeeding(node.left.right)
          delete(succeeding_node.value)
          succeeding_node.left = node.left.left
          succeeding_node.right = node.left.right
          node.left = succeeding_node
        end
      else 
        delete(value, node.left)
      end
    elsif value > node.value
      if node.right.value == value
        if node.right.right.nil? && node.right.left.nil?
          node.right = nil
        elsif node.right.left.nil?
          node.right = node.right.right
        elsif node.right.right.nil?
          node.left = node.right.left
        else
          succeeding_node = next_succeeding(node.right.right)
          delete(succeeding_node.value)
          succeeding_node.left = node.right.left
          succeeding_node.right = node.right.right
          node.right = succeeding_node
        end
      else 
        delete(value, node.right)
      end
    end
  end

  def next_succeeding(node)
    node.left.nil? ? node : next_succeeding(node.left)
  end


  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.value}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end  

end

# array = (1..24).to_a
array = [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]


binary_tree = Tree.new(array)
binary_tree.build_tree
# binary_tree.pretty_print
# binary_tree.insert(0)
binary_tree.insert(21)
binary_tree.pretty_print
puts ""
puts ""
puts ""

binary_tree.delete(8)
binary_tree.pretty_print
# p binary_tree.next_succeeding(binary_tree.root.right)