#!/usr/bin/env ruby

class BoardingPass
  ROW_BIT        = 7

  attr_reader :machine_code

  def initialize(machine_code)
    @machine_code = machine_code
  end

   def row_code
     @machine_code[0...ROW_BIT]
   end

  def column_code
    @machine_code[ROW_BIT..-1]
  end
end

class DecodeBoardingPass
  ROW_MULTIPLIER = 8

  attr_reader :boarding_pass

  def initialize(boarding_pass)
    @boarding_pass = boarding_pass
  end

  def call
    (find_row * ROW_MULTIPLIER) + find_column
  end

  private

  def find_row
    row_code = boarding_pass.row_code
    min_row = 0
    max_row = (2 ** row_code.length) - 1

    row_code.chars.each do |code|
      if code == "F"
        max_row = (min_row + max_row) / 2
        return max_row if max_row == min_row
      else
        min_row  = (min_row + max_row) / 2 + 1
        return min_row if max_row == min_row
      end
    end
    [min_row, max_row].min
  end

  def find_column
    column_code = boarding_pass.column_code
    min_column = 0
    max_column = (2 ** column_code.length) - 1

    column_code.chars.each do |code|
      if code == "L"
        max_column = (min_column + max_column) / 2
        return max_column if min_column == max_column
      else
        min_column = (min_column + max_column) / 2 + 1
        return min_column if min_column == max_column
      end
    end
    [min_column, max_column].min
  end
end


inputs = File.readlines("input.txt").map(&:chomp)

current_max = 0
seat_ids    = []

inputs.each do |machine_code|
  boarding_pass = BoardingPass.new(machine_code)
  seat_id       = DecodeBoardingPass.new(boarding_pass).call

  seat_ids << seat_id

  if seat_id > current_max
    current_max = seat_id
  end
end

puts "Part 1: #{current_max}"

seat_ids.sort!

my_seat_id = nil

(0...seat_ids.count.pred).each do |index|
  if (seat_ids[index] - seat_ids[index.succ]).abs != 1
    my_seat_id = seat_ids[index].succ
    break
  end
end

puts "Part 2: #{my_seat_id}"
