#!/usr/bin/env ruby

BITMASK_BITS = 36

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp)
memory = {}

mask = 0.to_s(2).rjust(BITMASK_BITS, "0")
input.each do |line|
  case line
  when /mask/
    match_regex = /\Amask\s=\s(\w+)\z/
    mask = line.match(match_regex).captures.first
    # puts "Mask: #{mask}"
  when /mem/
    match_regex = /mem\[(\d+)\]\s=\s(\d+)/
    mem_index, value = line.match(match_regex).captures.map(&:to_i)
    # puts "Mem: #{mem_index}"
    # puts "Value: #{value}"
    bin_value = value.to_s(2).rjust(BITMASK_BITS, "0")
    mask.chars.each_with_index do |char, index|
      next if char == "X"
      bin_value[index] = char
    end
    dec_value = bin_value.to_i(2)
    memory[mem_index] = dec_value
  else
    raise "Not a valid input"
  end
end

puts "Part 1: #{memory.values.sum}"

memory = {}

# max number of x in string is 9
MAX_X = 9
f = [0,1].repeated_permutation(MAX_X)
lookup_table = (2**MAX_X).times.map{ f.next}

mask = 0.to_s(2).rjust(BITMASK_BITS, "0")
max_count = 0
input.each do |line|
  case line
  when /mask/
    match_regex = /\Amask\s=\s(\w+)\z/
    mask = line.match(match_regex).captures.first
    # puts "Mask: #{mask}"
    if mask.count("X") > max_count
      max_count = mask.count("X")
    end
  when /mem/
    match_regex = /mem\[(\d+)\]\s=\s(\d+)/
    mem_index, value = line.match(match_regex).captures.map(&:to_i)
    # puts "Mem: #{mem_index}"
    # puts "Value: #{value}"

    bin_index = mem_index.to_s(2).rjust(BITMASK_BITS, "0")
    index_of_x = []
    mask.chars.each_with_index do |char, index|
      case char
      when "1"
        bin_index[index] = char
      when "X"
        index_of_x << index
      end
    end

    # puts "Bin index: #{bin_index}"
    number_of_x = mask.count("X")
    possible_combinations = 2 ** number_of_x
    # puts "possible_combinations: #{possible_combinations}"
    (0...possible_combinations).each_with_index do |idx|
      combination = lookup_table[idx][-number_of_x, number_of_x]
      new_address = bin_index.dup
      (0...number_of_x).each_with_index do |i|
        new_address[index_of_x[i]] = combination[i].to_s
      end
      memory[new_address.to_i(2)] = value
    end
  else
    raise "Not a valid input"
  end
end

puts "Part 2: #{memory.values.sum}"
