class Rule
  POSITIONS = {floor: ".", empty: "L", occupied: "#", out_of_bound: 0}

  attr_reader :max_occupation_allowed

  def initialize(max_occupation_allowed:)
    @max_occupation_allowed = max_occupation_allowed
  end

  def count_seats(grid)
    seats_count = 0
    grid.each do |row|
      row.each do |elem|
        seats_count += 1 if elem == POSITIONS[:occupied]
      end
    end
    seats_count
  end

  def apply
    raise "Not Implemented Error"
  end

  private

  def resize_grid(grid)
    max_coloumn = grid[0].count

    solved_grid = grid.dup.map(&:dup)
    solved_grid.each {|e| e.unshift(0); e << 0;}
    solved_grid.unshift(Array.new(max_coloumn + 2, 0))
    solved_grid << Array.new(max_coloumn + 2, 0)
  end
end

class ImmediateAdjacentOccupancyRule < Rule
  def apply(grid)
    solved_grid = resize_grid(grid)

    round = 0
    while true do
      round += 1
      moves = 0

      working_grid = solved_grid.dup.map(&:dup)
      solved_grid.each_with_index do |row, row_index|
        row.each_with_index do |value, column_index|
          next if value == POSITIONS[:out_of_bound]
          if instruction(row_index, column_index, working_grid, solved_grid)
            moves += 1
          end
        end
      end

      break if moves == 0 # no more moves
    end
    puts "Solution found in #{round} rounds"
    solved_grid
  end

  private

  def instruction(row, column, working_grid, grid)
    seat = working_grid[row][column]

    return false if seat == POSITIONS[:floor]

    right      = working_grid[row][column + 1]
    left       = working_grid[row][column - 1]
    up         = working_grid[row - 1][column]
    down       = working_grid[row + 1][column]
    up_left    = working_grid[row - 1] [column - 1]
    up_right   = working_grid[row - 1] [column + 1]
    down_left  = working_grid[row + 1] [column - 1]
    down_right = working_grid[row + 1] [column + 1]

    occupied_count = 0
    [right, left, up, down, up_left, up_right, down_left, down_right].each do |adjacent|
      if (adjacent == POSITIONS[:occupied])
        occupied_count += 1
      end
    end

    if seat == POSITIONS[:empty] && occupied_count == 0
      grid[row][column] = POSITIONS[:occupied]
      return true
    elsif seat == POSITIONS[:occupied] && occupied_count >= max_occupation_allowed
      grid[row][column] = POSITIONS[:empty]
      return true
    end

    return false
  end
end

class AdjacentOccupancyRule < Rule
  def apply(grid)
    solved_grid = resize_grid(grid)

    round = 0
    while true do
      round += 1
      moves = 0

      working_grid = solved_grid.dup.map(&:dup)
      solved_grid.each_with_index do |row, row_index|
        row.each_with_index do |value, column_index|
          next if value == POSITIONS[:out_of_bound]
          if instruction(row_index, column_index, working_grid, solved_grid)
            moves += 1
          end
        end
      end

      break if moves == 0 # no more moves
    end
    puts "Solution found in #{round} rounds"
    solved_grid
  end

  private

  def instruction(row, column, working_grid, grid)
    seat = working_grid[row][column]

    return false if seat == POSITIONS[:floor]

    occupied_count = 0

    # move up straight
    row_pointer = row - 1
    col_pointer = column
    while true do
      current_seat = working_grid[row_pointer][col_pointer]
      case current_seat
      when POSITIONS[:out_of_bound]
        break
      when POSITIONS[:occupied]
        occupied_count += 1
        break
      when POSITIONS[:empty]
        break
      end

      row_pointer -= 1
    end

    # move down straight
    row_pointer = row + 1
    col_pointer = column
    while true do
      current_seat = working_grid[row_pointer][col_pointer]
      case current_seat
      when POSITIONS[:out_of_bound]
        break
      when POSITIONS[:occupied]
        occupied_count += 1
        break
      when POSITIONS[:empty]
        break
      end

      row_pointer += 1
    end

    # move left straight
    col_pointer = column - 1
    row_pointer = row
    while true do
      current_seat = working_grid[row_pointer][col_pointer]
      case current_seat
      when POSITIONS[:out_of_bound]
        break
      when POSITIONS[:occupied]
        occupied_count += 1
        break
      when POSITIONS[:empty]
        break
      end

      col_pointer -= 1
    end

    # move right straight
    col_pointer = column + 1
    row_pointer = row
    while true do
      current_seat = working_grid[row_pointer][col_pointer]
      case current_seat
      when POSITIONS[:out_of_bound]
        break
      when POSITIONS[:occupied]
        occupied_count += 1
        break
      when POSITIONS[:empty]
        break
      end

      col_pointer += 1
    end

    # move left diagonol up
    row_pointer = row - 1
    col_pointer = column - 1
    while (occupied_count < max_occupation_allowed) do
      current_seat = working_grid[row_pointer][col_pointer]
      case current_seat
      when POSITIONS[:out_of_bound]
        break
      when POSITIONS[:occupied]
        occupied_count += 1
        break
      when POSITIONS[:empty]
        break
      end

      row_pointer -= 1
      col_pointer -= 1
    end

    # move left diagonol down
    row_pointer = row + 1
    col_pointer = column - 1
    while (occupied_count < max_occupation_allowed) do
      current_seat = working_grid[row_pointer][col_pointer]
      case current_seat
      when POSITIONS[:out_of_bound]
        break
      when POSITIONS[:occupied]
        occupied_count += 1
        break
      when POSITIONS[:empty]
        break
      end

      row_pointer += 1
      col_pointer -= 1
    end

    # move right diagonol up
    row_pointer = row - 1
    col_pointer = column + 1
    while (occupied_count < max_occupation_allowed) do
      current_seat = working_grid[row_pointer][col_pointer]
      case current_seat
      when POSITIONS[:out_of_bound]
        break
      when POSITIONS[:occupied]
        occupied_count += 1
        break
      when POSITIONS[:empty]
        break
      end

      row_pointer -= 1
      col_pointer += 1
    end

    # move right diagonol down
    row_pointer = row + 1
    col_pointer = column + 1
    while (occupied_count < max_occupation_allowed) do
      current_seat = working_grid[row_pointer][col_pointer]
      case current_seat
      when POSITIONS[:out_of_bound]
        break
      when POSITIONS[:occupied]
        occupied_count += 1
        break
      when POSITIONS[:empty]
        break
      end

      row_pointer += 1
      col_pointer += 1
    end

    if seat == POSITIONS[:empty] && occupied_count == 0
      grid[row][column] = POSITIONS[:occupied]
      return true
    elsif seat == POSITIONS[:occupied] && occupied_count >= max_occupation_allowed
      grid[row][column] = POSITIONS[:empty]
      return true
    end

    return false
  end
end

class Board
  attr_reader :grid, :rule

  def initialize(grid: , rule: )
    @grid = grid
    @rule = rule
  end

  def fill
    if (solved_grid = rule.apply(grid))
      rule.count_seats(solved_grid)
    else
      nil
    end
  end
end

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp).map {|e| e.split("")}


rule = ImmediateAdjacentOccupancyRule.new(max_occupation_allowed: 4)

board = Board.new(grid: input, rule: rule)
puts "Part 1: #{board.fill}"
rule = AdjacentOccupancyRule.new(max_occupation_allowed: 5)
board = Board.new(grid: input, rule: rule)
puts "Part 2: #{board.fill}"
