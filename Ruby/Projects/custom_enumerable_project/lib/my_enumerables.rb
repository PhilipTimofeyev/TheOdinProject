module Enumerable

  def my_each_with_index
    iteration = 0

    until iteration == self.size
      yield(self[iteration], iteration)
      iteration += 1
    end

    self
  end

  def my_select

    result = []
    self.my_each{|i| result << i if yield i}

    result
  end

  def my_all?
    self.my_each{|i| return false unless yield i}
    true
  end

  def my_any?
    self.my_each { |i| return true if yield i}
    false
  end

  def my_none?
    self.my_each { |i| return false if yield i}
    true
  end

  def my_count
    return self.size unless block_given?

    result = 0
    self.my_each { |i| result += 1 if yield i}

    result
  end

  def my_map
    result = []
    self.my_each { |i| result << (yield i)}

    result
  end

  def my_inject(initial_value)
    result = initial_value
    
    self.my_each {|i| result = yield(result, i)}

    result
  end
end

class Array
  def my_each
    iteration = 0

    until iteration == self.size
      yield self[iteration]
      iteration += 1
    end

    self
  end
end
