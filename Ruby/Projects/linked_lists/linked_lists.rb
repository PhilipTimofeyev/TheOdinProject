class LinkedList
  attr_accessor :first_node

  def initialize(first_node)
    @first_node = first_node
  end

  def append(value)
    new_node = Node.new(value)

    current = first_node  

    until current.next_node.nil?
      current = current.next_node
    end

    puts "Appending #{new_node.value}"
    current.next_node = new_node

  end

  def prepend(value)
    new_node = Node.new(value)

    new_node.next_node = first_node
    puts "Prepending #{new_node.value}"
    self.first_node = new_node
  end

  def size
    count = 1
    current = first_node  

    until current.next_node.nil?
      count += 1
      current = current.next_node
    end

    puts "Linked list contains #{count} nodes."

    count
  end

  def head
    puts "The head is #{first_node.value}"
    first_node
  end

  def tail
    current = first_node  

    until current.next_node.nil?
      current = current.next_node
    end

    puts "The tail is #{current.value}"

    tail = current
  end

  def at(idx)
    current = first_node
    current_idx = 0

    loop do
      if current_idx == idx
        return current
      elsif current_idx > idx
        return nil
      end

      current = current.next_node
      current_idx += 1
    end
  end

  def pop
    current = first_node  

    until current.next_node.next_node.nil?
      current = current.next_node
    end

    puts "Removing #{current.next_node.value}"

    current.next_node = nil
  end

  def contains?(value)
    current = first_node  

    until current.next_node.nil?
      return true if current.value == value
      current = current.next_node
    end

    false
  end

  def find(value)
    current = first_node 
    idx = 0

    loop do
      if current.value == value
        puts "#{current.value} at index #{idx}"
        return idx
      elsif current.next_node.nil?
        break
      end
      current = current.next_node
      idx += 1
    end

    nil
  end

  def to_s
    result = []
    current = first_node  

    until current.next_node.nil?
      result << current.value
      current = current.next_node
    end

    result << current.value
    result.join(' -> ') << "-> nil"
  end

  def insert_at(value, idx)
    return prepend(value) if idx == 0
    subsequent_node = at(idx)
    previous_node = at(idx - 1)

    new_node = Node.new(value, subsequent_node)
    previous_node.next_node = new_node
  end

  def remove_at(idx)
    return self.first_node = first_node.next_node if idx == 0

    previous_node = at(idx - 1)
    remove_node = at(idx)
    subsequent_node = at(idx + 1)

    remove_node.next_node = nil
    previous_node.next_node = subsequent_node

  end
end


class Node
  attr_accessor :value, :next_node

  def initialize(value = nil, next_node = nil)
    @value = value
    @next_node = next_node
  end

end


new_list = LinkedList.new(Node.new("Dog"))
new_list.append("Cat")
new_list.prepend("Lion")
new_list.head
new_list.tail
new_list.size
p new_list.at(2)
new_list.pop
p new_list.contains?('Lion')
p new_list.contains?('Tiger')
new_list.append("Mouse")
p new_list
new_list.find('Lion')
puts new_list
new_list.insert_at("Ant", 2)
puts new_list
new_list.remove_at(2)
puts new_list