#!/usr/bin/env ruby

def generate_neighbors(x, y, z, w = nil)
  neighbors = []
  (y-1..y+1).each do |dy|
    (x-1..x+1).each do |dx|
      (z-1..z+1).each do |dz|
        if w.nil?
          if ((dx != x) || (dy != y) || (dz != z))
            neighbors << [dx, dy, dz]
          end
        else
          (w-1..w+1).each do |dw|
            if ((dx != x) || (dy != y) || (dz != z)) || (dw != w)
              neighbors << [dx, dy, dz, dw]
            end
          end
        end
      end
    end
  end
  neighbors
end

def compute_cycle(grid, total_cycles)
  total_cycles.times do |cycle|
    initial_key  = grid.keys.first
    max_boundary = grid[initial_key].first.count + 2
    new_grid     = {}

    # resize array for neibouring x,y plane based on key (z) or (z,w)
    grid.each do |key, value|
      new_grid[key] = Array.new(max_boundary) { Array.new(max_boundary) {"."} }
      value.each_with_index do |row, y|
        row.each_with_index do |v, x|
          new_grid[key][y+1][x+1] = grid[key][y][x]
        end
      end
    end

    all_keys      = (-cycle.succ..cycle.succ).to_a
    key_gen       = all_keys.repeated_permutation(initial_key.count)
    possible_keys = (all_keys.count**initial_key.count).times.map{ key_gen.next}

    possible_keys.each do |k|
      next if new_grid[k]
      new_grid[k] = Array.new(max_boundary) { Array.new(max_boundary) {"."} }
    end

    flip_to_active = []
    flip_to_inactive = []
    new_grid.each do |key_pair, value|
      value.each_with_index do |row, y|
        row.each_with_index do |v, x|
          active_count = 0

          # count active neigbors
          generate_neighbors(x, y, *key_pair).each do |neighbor|
            x1, y1, *key_pair_1 = neighbor
            next if !new_grid[key_pair_1]
            next if !new_grid[key_pair_1][y1]
            next if !new_grid[key_pair_1][y1][x1]

            if new_grid[key_pair_1][y1][x1] == "#"
              active_count += 1
            end
          end

          current_value = new_grid[key_pair][y][x]

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
      new_grid[key_pair][y][x] = "."
    end

    flip_to_active.each do |cords|
      key_pair, y, x = cords
      new_grid[key_pair][y][x] = "#"
    end

    grid = new_grid
    puts "Cycle: #{cycle.succ}"
  end
  grid
end

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp).map(&:chars)

grid = {[0] => input}
puts "Part 1: #{compute_cycle(grid, 6).map{|_,v| v.flatten.count("#")}.sum}"

grid = {[0, 0] => input}
puts "Part 2: #{compute_cycle(grid, 6).map{|_,v| v.flatten.count("#")}.sum}"
