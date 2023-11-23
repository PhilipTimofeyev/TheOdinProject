def merge_sort(arr)
  
return arr if arr.size < 2 #Base Case
  puts "Mergesort called on #{arr}"
  half = (arr.size / 2)

  puts "Split into #{arr[0...half]} and #{arr[half..-1]}"

  left = merge_sort(arr[0...half])
  right = merge_sort(arr[half..-1])

  sorted = []

  i_left = 0
  i_right = 0

  while sorted.size < arr.size

    if left[i_left] < right[i_right]
      sorted << (left[i_left])
      i_left += 1
    else
      sorted << (right[i_right])
      i_right += 1
    end

    if i_left == left.size
      sorted += right[i_right..-1]
      break

    elsif i_right == right.size
      sorted += left[i_left..-1]
      break
    end
  end

  puts "Left: #{left} and right #{right} merge into #{sorted}"

  sorted
end

unsorted = [2, 9, 8, 5, 3, 4, 7, 6]


p merge_sort(unsorted)
