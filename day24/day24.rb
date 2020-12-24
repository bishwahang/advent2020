#!/usr/bin/env ruby

def fill_up_tiles(instructions, direction_coordinates, tiles_memo)
  instructions.each do |tile_instruction|
    prefix = ""
    current_reference = [0, 0]
    direction_cordinate = []
    tile_instruction.chars.each do |char|
      case char
      when "w"
        case prefix
        when "n"
          # puts "Moving North-West"
          direction_cordinate = direction_coordinates["nw"]
        when "s"
          # puts "Moving South-West"
          direction_cordinate = direction_coordinates["sw"]
        else
          # puts "Moving West"
          direction_cordinate = direction_coordinates["w"]
        end
      when "e"
        case prefix
        when "n"
          # puts "Moving North-East"
          direction_cordinate = direction_coordinates["ne"]
        when "s"
          # puts "Moving South-East"
          direction_cordinate = direction_coordinates["se"]
        else
          # puts "Moving East"
          direction_cordinate = direction_coordinates["e"]
        end
      when "n"
        prefix = "n"
      when "s"
        prefix = "s"
      end

      if !direction_cordinate.empty?
        current_reference = [current_reference, direction_cordinate].transpose.map(&:sum)
        direction_cordinate = []
        prefix = ""
      end
    end

    # flip the final destination tile
    tiles_memo[current_reference] = !tiles_memo[current_reference]
  end
end

# https://www.redblobgames.com/grids/hexagons/#neighbors-doubled
direction_coordinates = {
  "w" => [-2 , 0],
  "nw" => [-1 , -1],
  "sw" => [-1 , +1],
  "e" => [2, 0],
  "ne" => [1, -1],
  "se" => [1, 1]
}

input = File.readlines(File.join(__dir__,"input.txt")).map(&:chomp)

# false = white
# true = black
tiles_memo = Hash.new { |h,k| h[k] = false }

fill_up_tiles(input, direction_coordinates, tiles_memo)

puts "Part 1: #{tiles_memo.select {|k, v| v}.count}"

100.times do |i|
  black_tiles_count = Hash.new { |h,k| h[k] = 0 }
  tiles_memo.each do |tile_coordinate, black|
    next unless black
    direction_coordinates.values.each do |direction_cordinate|
      neighbour_tile = [tile_coordinate, direction_cordinate].transpose.map(&:sum)
      black_tiles_count[neighbour_tile] += 1
    end
  end

  keys = tiles_memo.keys + black_tiles_count.keys
  keys.uniq.each do |k|
    color = tiles_memo[k]
    if black_tiles_count[k] == 0 || black_tiles_count[k] > 2
      tiles_memo[k] = color && false
    elsif black_tiles_count[k] == 2
      tiles_memo[k] = color || true
    end
  end

  puts "Round : #{i.succ}" if (i.succ % 25) == 0
end

puts "Part 1: #{tiles_memo.select {|k, v| v}.count}"
