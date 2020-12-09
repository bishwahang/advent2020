#!/usr/bin/env ruby

class CodeBreaker
  attr_reader :preamble, :code_stream, :input
  def initialize(input, preamble_length)
    @input       = input
    @preamble    = input[0, preamble_length]
    @code_stream = input[preamble_length, input.count]
  end

  def call
    invalid_number = nil
    @lookup_table  = {}

    @preamble.each do |number|
      @lookup_table[number] = true
    end

    while !@code_stream.empty?
      number = @code_stream.shift

      if !check_valid(number)
         invalid_number = number
         break
      end

      number_to_remove = @preamble.shift
      @lookup_table.delete(number_to_remove)

      @preamble << number
      @lookup_table[number] = true
    end

    if invalid_number
      puts "Part 1: First Invalid number is #{invalid_number}"

      if (subset = find_contiguous_subset(invalid_number))
        puts "Part 2: Sum of min and max of contiguous subset is #{subset.min + subset.max}"
      else
        puts "No contiguous subset found for: #{invalid_number}"
      end
    else
      puts "No Invalid number found!"
    end
  end

  private

  def check_valid(sum)
    @preamble.each do |first_number|
      return true if @lookup_table[sum - first_number]
    end

    false
  end

  def find_contiguous_subset(number)
    sum         = 0
    left_index  = 0
    right_index = 1

    sum += input[left_index]
    sum += input[right_index]

    while(right_index < input.count - 1) do
      if left_index == right_index
        # both flag meet, so readjust as it must be sum of at least two numbers
        right_index += 1
        sum += input[right_index]
      end

      break if sum == number

      if sum > number
        sum -= input[left_index]
        left_index += 1
      else
        right_index += 1
        sum += input[right_index]
      end
    end

    if sum == number
      input[left_index, (right_index - left_index) + 1]
    else
      false
    end
  end
end

input = File.readlines("input.txt").map(&:chomp).map(&:to_i)

PREAMBLE_LIMIT = 25

CodeBreaker.new(input, PREAMBLE_LIMIT).call
