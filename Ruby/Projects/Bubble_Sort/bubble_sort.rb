def bubble_sort(arr)
  sorted = nil

  loop do
    arr.each_cons(2).with_index do |(a, b), idx|
      if a > b
        arr[idx], arr[idx + 1] = arr[idx + 1], arr[idx]
        sorted = false
      end
    end
    
    return arr if sorted == true
    sorted = true
  end
end

p "lol"