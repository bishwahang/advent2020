#!/usr/bin/env ruby

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp)
earliest_timestamp = input.first.to_i
bus_ids = input[1].split(",").reject {|e| e == "x"}.map(&:to_i)

found = false
current_timestamp =  earliest_timestamp
current_bus_id = nil
while true do
  bus_ids.each do |bus_id|
    if current_timestamp % bus_id == 0
      current_bus_id = bus_id
      found = true
      break
    end
  end
  break if found

  current_timestamp += 1
end

puts "Part 1: #{(current_timestamp - earliest_timestamp) * current_bus_id}"

bus_ids = input[1].split(",")

ids  = []
differences = []
bus_ids.each_with_index do |value, index|
  next if value == "x"

  value = value.to_i
  ids << value
  differences << -index
end

# puts "ids: #{ids}"
# puts "differences: #{differences}"

def inverse_multiplicative(a, m)
  a = a % m
  (1...m).each do |i|
    if (a * i) % m == 1
      return i
    end
  end
  return 1
end

product_ids = ids.reduce(:*)
result = 0

ids.each_with_index do |elem, index|
  product = product_ids / elem
  result += differences[index] * product * inverse_multiplicative(product, elem)
end

result %= product_ids


puts "Part 2: #{result}"
