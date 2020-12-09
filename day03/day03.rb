#!/usr/bin/env ruby


class Grid
  attr_reader :y_max, :x_max, :matrix
  TREE = "#".freeze

  def initialize(y_max, x_max)
    @x_max = x_max
    @y_max = y_max
    @matrix = Array.new(y_max) { Array.new(x_max) }
  end

  def insert(y, x, value)
    matrix[y][x] = value
  end

  def calculate_number_of_trees(delta_x:, delta_y:)
    count = 0
    current_y = 0
    current_x = 0
    while (current_y < y_max) do
      if matrix[current_y][current_x % x_max] == TREE
        count += 1
      end
      current_y += delta_y
      current_x += delta_x
    end
    count
  end
end

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp)

y_max = input.count
x_max = input.first.length
grid = Grid.new(y_max, x_max)

input.each_with_index do |row, y|
  row.chars.each_with_index do |elem, x|
    grid.insert(y, x, elem)
  end
end

puts "First part: #{grid.calculate_number_of_trees(delta_x: 3, delta_y: 1)}"

number_of_trees = 1
[[1,1], [3, 1], [5, 1], [7, 1], [1, 2]].each do |deltas|
  number_of_trees *= grid.calculate_number_of_trees(delta_x: deltas[0], delta_y: deltas[1])
end

puts "Second part: #{number_of_trees}"
