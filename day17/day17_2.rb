#!/usr/bin/env ruby

def generate_neighbors(x, y, z, w)
  neighbors = []
  (w-1..w+1).each do |dw|
    (z-1..z+1).each do |dz|
      (y-1..y+1).each do |dy|
        (x-1..x+1).each do |dx|
          if ((dx != x) || (dy != y) || (dz != z)) || (dw != w)
            neighbors << [dx, dy, dz, dw]
          end
        end
      end
    end
  end
  neighbors
end
input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp).map(&:chars)

memo = {[0, 0] => input}

count = 0
while count < 6
  count += 1
  max_boundary = memo[[0, 0]].first.count + 2

  new_memo ={}
  memo.each do |key, value|
    new_memo[key] = Array.new(max_boundary) { Array.new(max_boundary) {"."} }
    value.each_with_index do |row, y|
      row.each_with_index do |v, x|
        new_memo[key][y+1][x+1] = memo[key][y][x]
      end
    end
  end

  all_keys = (-count..count).to_a
  key_gen = all_keys.repeated_permutation(2)
  possible_keys  = (all_keys.count**2).times.map{ key_gen.next}
  possible_keys.each do |k|
    next if new_memo[k]
    new_memo[k] = Array.new(max_boundary) { Array.new(max_boundary) {"."} }
  end

  flip_to_active = []
  flip_to_inactive = []
  new_memo.each do |key_pair, value|
    value.each_with_index do |row, y|
      row.each_with_index do |v, x|
        active_count = 0

        # count active neigbors
        generate_neighbors(x, y, *key_pair).each do |neighbor|
          x1, y1, *key_pair_1 = neighbor
          next if !new_memo[key_pair_1]
          next if !new_memo[key_pair_1][y1]
          next if !new_memo[key_pair_1][y1][x1]

          if new_memo[key_pair_1][y1][x1] == "#"
            active_count += 1
          end
        end

        current_value = new_memo[key_pair][y][x]

        if current_value == "#"
          if (active_count != 3) && (active_count != 2)
            flip_to_inactive << [key_pair, y, x]
          end
        else
          if active_count == 3
            flip_to_active << [key_pair, y, x]
          end
        end
      end
    end
  end

  flip_to_inactive.each do |cords|
    key_pair, y, x = cords
    new_memo[key_pair][y][x] = "."
  end

  flip_to_active.each do |cords|
    key_pair, y, x = cords
    new_memo[key_pair][y][x] = "#"
  end
  memo = new_memo
  puts "Count : #{count}"
end

puts "Part 2: #{new_memo.map {|_, v| v.flatten.count("#")}.sum}"
