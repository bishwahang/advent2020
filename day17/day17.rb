#!/usr/bin/env ruby

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp).map(&:chars)

# for (int dz = z - 1; dz <= z + 1; ++dz)
# {
#   for (int dy = y - 1; dy <= y + 1; ++dy)
#   {
#     for (int dx = x - 1; dx <= x + 1; ++dx)
#     {
#       // all 27
#       if ((dx != x) || (dy != y) || (dz != z))
#       {
#         // just the 26 neighbors
#       }
#     }
#   }
# }
#


def generate_neighbors(x, y, z)
  neighbors = []
  (z-1..z+1).each do |dz|
    (y-1..y+1).each do |dy|
      (x-1..x+1).each do |dx|
        if ((dx != x) || (dy != y) || (dz != z))
          neighbors << [dx, dy, dz]
        end
      end
    end
  end
  neighbors
end

grid_array = input.each_with_index.map do |value, index|
  [index, value]
end.map do |key, value|
  hash = value.each_with_index.map {|v, k| [k, v]}.to_h
  hash.each do |k, v|
    hash[k] = {0 => v}
  end
  {key => hash}
end


grid = {}
grid_array.each do |h|
  grid = grid.merge(h)
end

count = 0
active = 0
p grid
while count <= 6
  count += 1
  new_grid = grid.dup.map do |x_key, x_value|
    # x
    new_x_value = {}
    x_value.dup.map do |y_key, y_value|
      #y
      new_y_value = {}
      y_value.dup.map do |z_key, z_value|
        #z
        new_y_value[z_key] = z_value
      end
      new_x_value[y_key] = new_y_value
    end
    {x_key => new_x_value}
  end.each_with_object({}) do |h, res|
    res.merge!(h)
  end

  grid.keys.sort.each do |x|
    y_value = grid[x]

    y_value.keys.sort.each do |y|
      z_value = grid[x][y]

      z_value.keys.sort.each do |z|
        puts "x, y, z : #{x}, #{y}, #{z}"
        generate_neighbors(x,y,z).each do |neighbor|
          x1, y1, z1 = neighbor
          if !new_grid[x1]
            new_grid[x1] = {}
            new_grid[x1][y1] = {}
            new_grid[x1][y1][z1] = "."
            next
          end

          if !new_grid[x1][y1]
            new_grid[x1][y1] = {}
            new_grid[x1][y1][z1] = "."
            next
          end

          if !new_grid[x1][y1][z1]
            new_grid[x1][y1][z1] = "."
            next
          end
        end
      end
    end
  end

  new_grid.keys.sort.each do |x|
    y_value = new_grid[x]

    y_value.keys.sort.each do |y|
      z_value = new_grid[x][y]

      active_count = 0
      z_value.keys.sort.each do |z|
        puts "x, y, z : #{x}, #{y}, #{z}"
        generate_neighbors(x,y,z).each do |neighbor|
          x1, y1, z1 = neighbor
          if !new_grid[x1]
            next
          end

          if !new_grid[x1][y1]
            next
          end

          if !new_grid[x1][y1][z1]
            next
          end

          if new_grid[x1][y1][z1] == "#"
            active_count += 1
          end
          break if active_count > 3
        end

        if new_grid[x][y][z] == "#"
          if (active_count != 2) && (active_count != 3)
            new_grid[y][x][z] == "."
            active -= 1
          end
        else
          if active_count == 3
            new_grid[x][y][z] == "#"
            active += 1
          end
        end
      end
    end
  end
  grid = new_grid
  break
end
p new_grid

count = 0
new_grid.keys.each do |x|
  y_value = grid[x]
  y_value.keys.each do |y|
    z_value = grid[x][y]
    z_value.keys.each do |z|
      count += 1 if grid[x][y][z] == "#"
    end
  end
end

puts count
