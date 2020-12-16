#!/usr/bin/env ruby

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp)

my_line = false
valid_tickets = []
nearby_tickets = []
my_ticket = []
nearby_tickets = []

input.each do |line|
  case line
  when /-/
    match_regex = /(\d+)-(\d+)/
    numbers = []
    line.scan(match_regex).each do |lower, upper|
      numbers += (lower..upper).to_a.map(&:to_i)
    end
    valid_tickets << numbers
  when /your/
    my_line = true
  when /nearby/
    my_line = false
  when /,/
    if my_line
      my_ticket = line.split(",").map(&:to_i)
    else
      nearby_tickets << line.split(",").map(&:to_i)
    end
  end
end

puts "Part 1: #{(nearby_tickets.flatten - valid_tickets.flatten).sum}"

# get all the valid tickets and add own ticket to the list
valid_nearby_tickets = nearby_tickets.reject {|ticket| (ticket - valid_tickets.flatten).any?}
valid_nearby_tickets << my_ticket

# total ticket counts
row_max = valid_nearby_tickets.count
# total field/position counts
col_max = valid_nearby_tickets[0].count

truth_table = Array.new(row_max) { Array.new(col_max) {Array.new}}

# for each valid neary by ticket, create a truth table if the number satisfied the field constraints
valid_nearby_tickets.each_with_index do |row, row_index|
  row.each_with_index do |value, col_index|
    valid_tickets.each_with_index do |value_array, field_index|
      truth_table[row_index][col_index][field_index] = value_array.include?(value)
    end
  end
end

# count all the possible positions for the fields based on 'transposed' truth table

possible_field_to_position_map = Hash.new {|h,k| h[k] = []}

truth_table.transpose.each_with_index do |transposed_row, position|
  transposed_row.transpose.map(&:all?).each_with_index do |value, field|
    # a true value means that the current position satisfied the field constraints
    possible_field_to_position_map[field] << position if value
  end
end

field_to_position_map = {}

# sort the field key hash by number of possible position counts in ascending order
# (1 count first, 2 count second, 3 count third, and so on...)
# there should be exactly 1 possibilities, 2 possibilities, 3 possibilities, and so on to have a solution
# starts from the first 1 count position_index possibilities
possible_field_to_position_map.sort_by {|_,v| v.count}.each do |field_index, position_indicies|
  # eliminate (n - 1) position possibilities from (n) possibilities
  # This gives exact single position_index mapping for for current field_index
  field_to_position_map[field_index] = (position_indicies - field_to_position_map.values).first
end

# first 6 departure text are from 0 to 5 indices
product = (0..5).map do |field_index|
  my_ticket[field_to_position_map[field_index]]
end.reduce(:*)

puts "Part 2: #{product}"
