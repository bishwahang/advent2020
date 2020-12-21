#!/usr/bin/env ruby

# helper methods
def rotate(matrix)
  matrix.dup.map(&:dup).transpose.map {|e| e.reverse}
end

def flip(matrix)
  matrix.dup.map(&:dup).reverse
end

def print_matrix(matrix)
  matrix.each do |k|
    puts k.join(" ")
  end
  puts "*" * 10
end

def generate_orientations(matrix)
  input_matrix = matrix.dup.map(&:dup)
  orientations = []
  (0..1).each do |i|
    if i == 1
      input_matrix = flip(input_matrix)
    end
    (0..3).each do |j|
      # rotate 0 to 3 times
      result = input_matrix.dup.map(&:dup)
      j.times do
        result = rotate(result)
      end
      orientations << result
    end
  end
  orientations
end

# a = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
# a = [[1, 3], [2, 0], [3, 1], [2, 0], [0, 2], [3, 1], [0, 2], [1, 3]]
# orientations = generate_orientations(a)

input = File.read(File.join(__dir__, "input.txt")).split("\n\n").map {|e| e.lines.map(&:chomp)}.map do |tile|
  key = tile.first.match(/(\d+)/).captures.first.to_i
  [key, tile[1..-1].map{|e| e.lines.first.chars}]
end.to_h

# get the boundary elenmets
boundary_memo = {}
input.each do |key, image_matrix|
  boundary_top       = image_matrix.first
  boundary_bottm     = image_matrix[-1]
  boundary_right     = image_matrix.map {|e| e[-1]}
  boundary_left      = image_matrix.map {|e| e[0]}
  boundary_memo[key] = [boundary_top, boundary_right, boundary_bottm, boundary_left]
end

adjacency_keys       = Hash.new {|h,k| h[k] = []}
boundary_memo.each do |key, boundaries|
  # for each image check how many boundaries match with other image
  boundaries.each_with_index do |boundary, index|
    other_keys  = boundary_memo.keys - [key]
    other_keys.each do |other_key|
      boundary_memo[other_key].each_with_index do |other_boundary, other_index|
        [boundary, boundary.reverse].product([other_boundary, other_boundary.reverse]).each do |pairs|
          if pairs[0] == pairs[1]
            adjacency_keys[key] << other_key
            break
          end
        end
      end
    end
  end
end

corner_keys = adjacency_keys.select {|k, v| v.count == 2}.keys
puts "Part 1: #{corner_keys.reduce(:*)}"
# end of first part

# pre-compute all possible orientation for the small grid
possible_orientations = {}
input.each do |key, image_matrix|
  possible_orientations[key] = generate_orientations(image_matrix)
end

# find top right corder
puts "Corner keys: #{corner_keys}"
top_right_corner_key = nil
right_neighbor_key = nil
bottom_neighbor_key = nil
found = false
corner_keys.each do |corner_key|
  neighbor_keys = adjacency_keys[corner_key]
  neighbor_keys.permutation.each do | key_pair|
    right_neighbor_key, bottom_neighbor_key  = key_pair
    possible_orientations[corner_key]. each do |fixed_orientation|
      fixed_right = fixed_orientation.map {|e| e[-1]}
      fixed_bottom = fixed_orientation[-1]
      possible_orientations[right_neighbor_key].each do |right_neigbor|
        neighbor_left = right_neigbor.map {|e| e[0]}
        if fixed_right == neighbor_left
          possible_orientations[bottom_neighbor_key].each do |bottom_neighbor|
            neighbor_top = bottom_neighbor[0]
            if fixed_bottom == neighbor_top
              # for one of the corner,we found the correct orientation
              # that matches its right neighbor and bottom neighbor
              found = true
              input[corner_key]          = fixed_orientation.dup.map(&:dup)
              input[right_neighbor_key]  = right_neigbor.dup.map(&:dup)
              input[bottom_neighbor_key] = bottom_neighbor.dup.map(&:dup)
              top_right_corner_key = corner_key
              right_neighbor_key = right_neighbor_key
              bottom_neighbor_key = bottom_neighbor_key
              break
            end
          end
        end
        break if found
      end
      break if found
    end
    break if found
  end
  break if found
end

raise "No Top Right Corner Found" unless top_right_corner_key

visited = {}
adjacency_keys.keys.each do |key|
  visited[key] = false
end
n = Integer.sqrt(adjacency_keys.keys.count)
full_grid = Array.new(n) { Array.new(n) {"xxxx"}}

full_grid[0][0] = top_right_corner_key
full_grid[0][1] = right_neighbor_key
full_grid[1][0] = bottom_neighbor_key

visited[top_right_corner_key] = true
right_neighbor_queue = [[right_neighbor_key, 0, 1]]
queue = []
queue << [bottom_neighbor_key, 1, 0]

# start by filling top to bottom
# and then take right element, and start top to bottom again
while !right_neighbor_queue.empty? do
  # start by filling top to bottom
  while !queue.empty? do
    current_key, y, x = queue.pop
    visited[current_key] = true
    if y == n - 1
      full_grid[y][x] = current_key
      next
    end
    bottom_neighbor_keys = adjacency_keys[current_key].select {|k| !visited[k]}
    # first column
    bottom_neighbor_key = if x == 0
                            bottom_neighbor_keys.sort_by {|k| adjacency_keys[k].count}.reverse.last
                            # second last column
                          elsif x == n - 2
                            bottom_neighbor_keys.sort_by {|k| adjacency_keys[k].count}.last
                          else
                            bottom_neighbor_keys.sort_by {|k| adjacency_keys[k].select {|k| visited[k]}.count}.last
                          end
    # current key is always oriented
    # orient the bottom according to current
    fixed_bottom = input[current_key].dup.map(&:dup)[-1]
    possible_orientations[bottom_neighbor_key].each do |bottom_neighbor|
      neighbor_top = bottom_neighbor[0]
      if neighbor_top == fixed_bottom
        input[bottom_neighbor_key] = bottom_neighbor.dup.map(&:dup)
        full_grid[y + 1][x] = bottom_neighbor_key
        queue << [bottom_neighbor_key, y + 1, x]
        break
      end
    end
  end

  # queue empty means y column has been filled
  # pop the right_neighbor from top, and find bottom, right neighbor again
  current_key, y, x = right_neighbor_queue.pop
  visited[current_key] = true
  possible_neighbor_keys = adjacency_keys[current_key].select {|k| !visited[k]}.sort_by do |k|
    adjacency_keys[k].select {|k| visited[k]}.count
  end

  if possible_neighbor_keys.count > 1
    right_neighbor_key, bottom_neighbor_key = possible_neighbor_keys
  else
    bottom_neighbor_key = possible_neighbor_keys.first
    right_neighbor_key = nil
  end

  fixed_orientation = input[current_key].dup.map(&:dup)
  fixed_bottom = fixed_orientation[-1]
  # find the bottom neighbor and fix it's orientation
  possible_orientations[bottom_neighbor_key].each do |bottom_neighbor|
    neighbor_top = bottom_neighbor[0]
    if neighbor_top == fixed_bottom
      input[bottom_neighbor_key] = bottom_neighbor.dup.map(&:dup)
      full_grid[y + 1][x] = bottom_neighbor_key
      queue << [bottom_neighbor_key, y + 1, x]
      break
    end
  end
  # find the right neighbor and fix it's orientation
  # right_neighbor_key is nil for last column: top right element
  if right_neighbor_key
    fixed_right = fixed_orientation.map {|e| e[-1]}
    possible_orientations[right_neighbor_key].each do |right_neigbor|
      neighbor_left = right_neigbor.map {|e| e[0]}
      if fixed_right == neighbor_left
        input[right_neighbor_key] = right_neigbor.dup.map(&:dup)
        full_grid[y][x+1] = right_neighbor_key
        right_neighbor_queue << [right_neighbor_key, y, x + 1]
        break
      end
    end
  end
end
# process last column
while !queue.empty? do
  current_key, y, x = queue.pop
  visited[current_key] = true
  if y == n - 1
    full_grid[y][x] = current_key
    next
  end
  bottom_neighbor_key = adjacency_keys[current_key].select {|k| !visited[k]}.sort_by do |k|
    adjacency_keys[k].select {|k| visited[k]}.count
  end.last
  # current key is always oriented
  # orient the bottom according to current
  fixed_bottom = input[current_key].dup.map(&:dup)[-1]
  possible_orientations[bottom_neighbor_key].each do |bottom_neighbor|
    neighbor_top = bottom_neighbor[0]
    if neighbor_top == fixed_bottom
      input[bottom_neighbor_key] = bottom_neighbor.dup.map(&:dup)
      full_grid[y + 1][x] = bottom_neighbor_key
      queue << [bottom_neighbor_key, y + 1, x]
      break
    end
  end
end

final_grid = Array.new(8 * n) {Array.new(8 * n) {"#"}}

# remove the outer boundary
input.keys.each do |key|
  input[key] = input[key][1..-2].map {|e| e[1..-2]}
end

# join the smaller grid to form big grid
full_grid.each_with_index do |row, y_factor|
  row.each_with_index do |key, x_factor|
    input[key].each_with_index do |inner_row, y|
      inner_row.each_with_index do |value, x|
        final_grid[y + (y_factor * 8)][x + (x_factor * 8)] = value
      end
    end
  end
end

# sea monster
sea_monster = [
  "                  # ",
  "#    ##    ##    ###",
  " #  #  #  #  #  #   "
].map(&:chars)

def find_monster(grid, sea_monster, max)
  grid = grid.dup.map(&:dup)
  sea_monster_count = 0
  (0...max).each do |row|
    (0...max).each do |col|
      if row + 3 < max && col + 20 < max
        possible_index = []
        found = true
        count = 0
        grid[row, 3].each_with_index do |inner_row, y|
          inner_row[col, 20].each_with_index do |value, x|
            if sea_monster[y][x] == "#"
              if value == "#"
                count += 1
                possible_index << [row+y, col+x]
              else
                found = false
                break
              end
            end
          end
        end
        if found
          sea_monster_count += 1
          possible_index.each do |y, x|
            grid[y][x] = "O"
          end
        end
      end
    end
  end
  [grid, sea_monster_count]
end

result_grid = nil

max_sea_monster_count = 0
new_grid_orientations = generate_orientations(final_grid)
new_grid_orientations.each do |grid_possible|
  sea_monster_grid , sea_monster_count = find_monster(grid_possible, sea_monster, n * 8)
  if sea_monster_count > max_sea_monster_count
    max_sea_monster_count = sea_monster_count
    result_grid = sea_monster_grid
  end
end

puts "Part2: #{result_grid.flatten.count("#")}"
