#!/usr/bin/env ruby

class Instruction
  CHANGEBLE_INSTRUCTIONS = %w[nop jmp].freeze
  attr_reader :command, :argument
  def initialize(command, argument)
    @command  = command
    @argument = argument
  end

  def changeble?
    CHANGEBLE_INSTRUCTIONS.include?(command)
  end

  def flip_command
    case command
    when "nop"
      "jmp"
    when "jmp"
      "nop"
    end
  end
end

class Assembler
  attr_reader :instructions

  def initialize(instructions = [])
    @instructions        = instructions
    @accumulator         = 0
    @instruction_pointer = instructions.count.pred
  end

  def call(fix_corrupt: false)
    result = compute(instructions.dup)
    return result unless fix_corrupt # part 1, without fixing

    attempt = 0
    while @instruction_pointer != -1
      fixed_instructions = fix_instructions(attempt += 1)
      result = compute(fixed_instructions)
    end

    result
  end

  private

  def fix_instructions(attempt)
    copy_instructions = instructions.dup
    find_count = 0
    find_index = nil

    instructions.each_with_index do |instruction, index|
      find_index = index
      find_count += 1 if instruction.changeble?

      break if find_count == attempt
    end

    instruction_to_change = instructions[find_index]
    copy_instructions[find_index] = Instruction.new(instruction_to_change.flip_command, instruction_to_change.argument)
    copy_instructions
  end

  def compute(copy_instructions)
    # reset before starting to compute
    @instruction_pointer = copy_instructions.count.pred
    @accumulator = 0

    while (instruction = copy_instructions[@instruction_pointer])
      copy_instructions[@instruction_pointer] = nil # visited
      case instruction.command
      when "nop"
        @instruction_pointer -= 1
      when "acc"
        @accumulator += instruction.argument
        @instruction_pointer -= 1
      when "jmp"
        @instruction_pointer -= instruction.argument
      end
      break if @instruction_pointer < 0 # finishes processing correctly
    end
    @accumulator
  end

end


input = File.readlines("input.txt").map(&:chomp)

instructions = []
input.each do |line|
  command, argument = line.split(" ")
  instructions << Instruction.new(command, argument.to_i)
end

assembler = Assembler.new(instructions.reverse) # 0 index last instruction, length of array first instruction
puts "Part 1 #{assembler.call}"
puts "Part 2 #{assembler.call(fix_corrupt:true)}"
