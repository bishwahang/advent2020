#!/usr/bin/env ruby

input = [
  [0, 3, 6],
  [1, 3, 2],
  [2, 1, 3],
  [1, 2, 3],
  [2, 3, 1],
  [3, 2, 1],
  [3, 1, 2],
  [0, 1, 5, 10, 3, 12, 19]
]

def memory_game(start_numbers, end_count)
  memory = {}
  start_numbers.each_with_index do |value, index|
    memory[value] = [index.succ]
  end

  counter = start_numbers.count
  last_number = start_numbers[-1]

  while counter < end_count
    counter += 1
    positions = memory[last_number]
    if positions.count > 1
      last_number = positions[-1] - positions[-2]
    else
      last_number = 0
    end
    if memory[last_number]
      memory[last_number] << counter
    else
      memory[last_number] = [counter]
    end
  end
  last_number
end

puts "Part 1: #{memory_game(input[-1], 2020)}"
puts "Part 2: #{memory_game(input[-1], 30000000)}"
