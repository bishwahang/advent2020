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

valid_nearby_tickets = nearby_tickets.reject {|ticket| (ticket - valid_tickets.flatten).any?}
valid_nearby_tickets << my_ticket

ticket_lookup_table = valid_tickets.map.with_index { |x, i| [i, x] }.to_h


row_max = valid_nearby_tickets.count
col_max = valid_nearby_tickets[0].count

truth_table = Array.new(row_max) { Array.new(col_max) {Array.new}}
valid_nearby_tickets.each_with_index do |row, row_index|
  row.each_with_index do |value, col_index|
    ticket_lookup_table.each do |key, value_array|
      truth_table[row_index][col_index][key] = value_array.include?(value)
    end
  end
end

total_fields = ticket_lookup_table.keys.count

found_count = 0
already_found_fields = {}
while found_count < total_fields do
  found_count +=1
  truth_table.transpose.each_with_index do |transposed_row, position|
    found_1 = false
    true_counts_array = Array.new(total_fields, 0)

    transposed_row.each do |truth_array|
      truth_array.each_with_index do |value, i|
        true_counts_array[i] += 1 if value
      end
    end

    true_counts_array.map! {|e| e % row_max}
    if true_counts_array.count(0) == found_count
      true_counts_array.each_with_index do |value, index|
        if value == 0
          unless already_found_fields.include?(index)
            already_found_fields[index] = position
          end
        end
      end
      found_1 = true
    end
    break if found_1
  end
end

product = 1
(0..6).each do |field|
  position = already_found_fields[field]
  product *= my_ticket[position]
end

puts "Part 2: #{product}"
