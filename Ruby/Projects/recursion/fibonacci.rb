def fibs(n)
  result = []
  0.upto(n - 1) do |i|
    if i < 2
      result << i
    else
      result << result[-1] + result[-2]
    end
  end
  result
end

def fibs_rec(n, result = [])
  if n == 2
    result << 0 << 1
    return
  end

  fibs_rec(n - 1, result)

  result << result[-1] + result[-2]
end

puts "Iterative result: #{fibs(10)}" 
puts "Recursive result: #{fibs_rec(10)}" 
