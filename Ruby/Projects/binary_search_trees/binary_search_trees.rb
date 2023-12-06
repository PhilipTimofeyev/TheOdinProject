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
    if node.nil?
      return nil
    elsif value < node.value
      node.left = delete(value, node.left)
      return node
    elsif  value > node.value
      node.right = delete(value, node.right)
      return node
    elsif value == node.value
      if node.left.nil?
        return node.right
      elsif node.right.nil?
        return node.left
      else
        node.right = lift(node.right, node)
        return node
      end
    end
  end

  def lift(node, node_to_delete)
    if node.left
      node.left = lift(node.left, node_to_delete)
      return node
    else
      node_to_delete.value = node.value
      return node.right
    end
  end

  def find(value, node = root)

    return nil if node.nil?

    if value < node.value
      find(value, node.left)
    elsif value > node.value
      find(value, node.right)
    elsif node.value == value
      return node
    end
  end

  def level_order_iterative
    return if root.nil?

    queue = [root]
    arr_of_values = []

    until queue.empty?
      current = queue.first
      arr_of_values << current.value
      yield current if block_given?
      queue << current.left if current.left
      queue << current.right if current.right
      queue.shift
    end

    arr_of_values unless block_given?
  end

  def level_order_recursive(queue = [root], result = [], &block)
    return if root.nil?

    if queue.empty? && !block_given?
      return result
    elsif queue.empty?
      return
    end

    current = queue.first
    result << current.value
    yield current if block_given?
    queue.push(current.left) if current.left
    queue.push(current.right) if current.right
    queue.shift
    level_order_recursive(queue, result, &block)
  end

  def preorder(node = root, result = [], &block)
    if node.nil? && !block_given?
      return result
    elsif node.nil?
      return
    end

    yield node if block_given?
    result << node.value

    preorder(node.left, result, &block)
    node
    preorder(node.right, result, &block)

  end

  def postorder(node = root, result = [], &block)
    if node.nil? && !block_given?
      return result
    elsif node.nil?
      return
    end

    postorder(node.left, result, &block)
    node
    postorder(node.right, result, &block)

    yield node if block_given?
    result << node.value

  end

  def inorder(node = root, result = [], &block)
    if node.nil? && !block_given?
      return result
    elsif node.nil?
      return
    end

    inorder(node.left, result, &block)
    node
    yield node if block_given?
    result << node.value
    inorder(node.right, result, &block)

  end

  def height(node = root)
    return -1 if node.nil?

    left = height(node.left)
    right = height(node.right)

    [left, right].max + 1

  end

  def depth(node, root_node = root)
    return nil if node.nil?
    return 0 if node == root_node

    if node < root_node
      depth(node, root_node.left) + 1
    elsif node > root_node
      depth(node, root_node.right) + 1
    end
  end

  def balanced?(node = root)
    return true if node.nil?

    left_height = height(node.left)
    right_height = height(node.right)

    if ((left_height - right_height).abs <= 1) && balanced?(node.left) && balanced?(node.right)
      return true
    end

    return false
  end

  def rebalance
    self.arr = inorder(root)
    build_tree(prepare_arr)
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.value}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end  

end

binary_tree = Tree.new((Array.new(15) { rand(1..100) }))
binary_tree.build_tree

p binary_tree.balanced?
p binary_tree.preorder
p binary_tree.postorder
p binary_tree.inorder
binary_tree.insert(124)
binary_tree.insert(182)
binary_tree.insert(243)
binary_tree.insert(345)
p binary_tree.balanced?
binary_tree.rebalance
p binary_tree.balanced?
p binary_tree.preorder
p binary_tree.postorder
p binary_tree.inorder