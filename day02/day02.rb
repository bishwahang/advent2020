#!/usr/bin/env ruby

class OldRule
  attr_reader :character, :min, :max

  def initialize(character:, min:, max:)
    @character = character
    @min       = min
    @max       = max
  end

  def call(password)
    valid = false
    character_count = 0
    password.chars.each do |char|
      if char == character
        character_count += 1
        valid = is_valid?(character_count)
      end
    end
    valid
  end

  private

  def is_valid?(count)
    @min <= count && count <= @max
  end
end

class NewRule
  attr_reader :character, :first_position, :second_position

  def initialize(character:, first_position:, second_position:)
    @character       = character
    @first_position  = first_position
    @second_position = second_position
  end

  def call(password)
    count = 0
    password.chars.each_with_index do |char, index|
      if correct_character?(char) && correct_positon?(index.succ)
        count += 1
      end
      return false if count > 1
    end
    count.zero? ? false : true
  end

  private

  def correct_character?(current_character)
    current_character == character
  end

  def correct_positon?(current_position)
    first_position == current_position || second_position == current_position
  end

  def is_valid?(count)
    @min <= count && count <= @max
  end
end

class CheckValidity
  attr_reader :password, :rule
  def initialize(password: , rule: )
    @password = password
    @rule     = rule
  end

  def call
    rule.call(password)
  end
end

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp)

total_valid_count = 0
input.each do |line|
  arguments = line.split(" ")
  min, max = arguments[0].split("-").map(&:to_i)
  character = arguments[1].split(":").first
  password = arguments[2]
  rule = OldRule.new(character: character, min: min, max: max)
  check_validity = CheckValidity.new(password: password, rule: rule)
  total_valid_count += 1 if check_validity.call
end

p "First part: #{total_valid_count}"

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp)

total_valid_count = 0
input.each do |line|
  arguments = line.split(" ")
  first_position, second_position = arguments[0].split("-").map(&:to_i)
  character = arguments[1].split(":").first
  password = arguments[2]
  rule = NewRule.new(character: character, first_position: first_position, second_position: second_position)
  check_validity = CheckValidity.new(password: password, rule: rule)
  total_valid_count += 1 if check_validity.call
end

p "Second part: #{total_valid_count}"
