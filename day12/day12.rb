#!/usr/bin/env ruby

DIRECTIONS = {east: "E", west: "W", north: "N", south: "S"}

class Instruction
  attr_reader :action, :value

  def initialize(action:, value:)
    @action = action
    @value  = value
  end
end

class Rotate
  attr_reader :current_direction, :degrees

  def initialize(current_direction, degrees)
    @current_direction = current_direction
    @degrees           = degrees
  end
end

class RotateLeft < Rotate
  def call
    case current_direction
    when DIRECTIONS[:east]
      case degrees
      when 90
        DIRECTIONS[:north]
      when 180
        DIRECTIONS[:west]
      when 270
        DIRECTIONS[:south]
      end
    when DIRECTIONS[:west]
      case degrees
      when 90
        DIRECTIONS[:south]
      when 180
        DIRECTIONS[:east]
      when 270
        DIRECTIONS[:north]
      end
    when DIRECTIONS[:north]
      case degrees
      when 90
        DIRECTIONS[:west]
      when 180
        DIRECTIONS[:south]
      when 270
        DIRECTIONS[:east]
      end
    when DIRECTIONS[:south]
      case degrees
      when 90
        DIRECTIONS[:east]
      when 180
        DIRECTIONS[:north]
      when 270
        DIRECTIONS[:west]
      end
    end
  end
end

class RotateRight < Rotate
  def call
    case current_direction
    when DIRECTIONS[:east]
      case degrees
      when 90
        DIRECTIONS[:south]
      when 180
        DIRECTIONS[:west]
      when 270
        DIRECTIONS[:north]
      end
    when DIRECTIONS[:west]
      case degrees
      when 90
        DIRECTIONS[:north]
      when 180
        DIRECTIONS[:east]
      when 270
        DIRECTIONS[:south]
      end
    when DIRECTIONS[:north]
      case degrees
      when 90
        DIRECTIONS[:east]
      when 180
        DIRECTIONS[:south]
      when 270
        DIRECTIONS[:west]
      end
    when DIRECTIONS[:south]
      case degrees
      when 90
        DIRECTIONS[:west]
      when 180
        DIRECTIONS[:north]
      when 270
        DIRECTIONS[:east]
      end
    end
  end
end

class WayPoint
  INITIAL_FACTORS = {DIRECTIONS[:east] => 0, DIRECTIONS[:north] => 0, DIRECTIONS[:south] => 0, DIRECTIONS[:west] => 0}
  DEFAULT_FACTORS = {DIRECTIONS[:east] => 10, DIRECTIONS[:north] => 1}

  attr_reader :factors

  def initialize(factors: DEFAULT_FACTORS)
    @factors = INITIAL_FACTORS.merge(factors)
  end

  def move(direction, value)
    @factors[direction] += value
  end

  def rotate_left(degrees)
    @factors.dup.each do |direction, factor|
      new_direction = RotateLeft.new(direction, degrees).call
      @factors[new_direction] = factor
    end
  end

  def rotate_right(degrees)
    @factors.dup.each do |direction, factor|
      new_direction = RotateRight.new(direction, degrees).call
      @factors[new_direction] = factor
    end
  end

  def factor(direction)
    factors[direction].zero? ? nil : factors[direction]
  end
end

class Ship
  DEFAULT_DIRECTION = DIRECTIONS[:east].freeze

  attr_accessor :current_direction
  attr_reader :way_point

  def initialize(current_direction: DEFAULT_DIRECTION, way_point: nil)
    @current_direction = current_direction
    @way_point = way_point
    @current_values = {DIRECTIONS[:east] => 0, DIRECTIONS[:west] => 0, DIRECTIONS[:north] => 0, DIRECTIONS[:south] => 0}
  end

  def manhattan_distance
    (@current_values[DIRECTIONS[:east]] - @current_values[DIRECTIONS[:west]]).abs + (@current_values[DIRECTIONS[:north]] - @current_values[DIRECTIONS[:south]]).abs
  end

  def move(direction, value)
    if way_point
      way_point.move(direction, value)
    else
      @current_values[direction] += value
    end
  end

  def forward(value)
    if way_point
      DIRECTIONS.values.each do |direction|
        if (factor = way_point.factor(direction))
          @current_values[direction] += (way_point.factor(direction) * value)
        end
      end
    else
      @current_values[@current_direction] += value
    end
  end

  def rotate_left(degrees)
    if way_point
      way_point.rotate_left(degrees)
    else
      @current_direction = RotateLeft.new(@current_direction, degrees).call
    end
  end

  def rotate_right(degrees)
    if way_point
      way_point.rotate_right(degrees)
    else
      @current_direction = RotateRight.new(@current_direction, degrees).call
    end
  end
end

class Navigate
  ACTIONS = {left: "L", right: "R", forward: "F"}.freeze

  attr_reader :instructions
  def initialize(instructions, ship)
    @instructions = instructions
    @ship         = ship
  end

  def call
    while(!instructions.empty?) do
      instruction = instructions.shift
      navigate(instruction)
    end
    @ship.manhattan_distance
  end

  private

  def navigate(instruction)
    case instruction.action
    when ACTIONS[:left]
      @ship.rotate_left(instruction.value)
    when ACTIONS[:right]
      @ship.rotate_right(instruction.value)
    when ACTIONS[:forward]
      @ship.forward(instruction.value)
    when *DIRECTIONS.values
      @ship.move(instruction.action, instruction.value)
    else
      raise "Unrecognized Instruction"
    end
  end
end

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp)
instructions = []
input.each do |e|
  action, *value = e.chars
  instructions << Instruction.new(action: action, value: value.join.to_i)
end

navigate = Navigate.new(instructions.dup, Ship.new)
puts "Part 1: #{navigate.call}"

navigate = Navigate.new(instructions, Ship.new(way_point: WayPoint.new))
puts "Part 2: #{navigate.call}"
