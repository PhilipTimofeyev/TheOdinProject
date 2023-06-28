def stock_picker(arr)
  raise "More than one day required" if arr.size < 2

  hsh_differences = Hash.new([])
  arr.each_with_index do |buy, day1|
    arr.each_with_index do |sell, day2|
      next if day2 <= day1
      hsh_differences[sell - buy] += [[day1, day2]]
    end
  end

  best_days = hsh_differences.max_by {|difference, stocks| difference}
  best_days.last.size > 1 ? best_days.last : best_days.last.flatten
end