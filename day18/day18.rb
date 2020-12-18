#!/usr/bin/env ruby


OPERATORS = {plus: "+", multiplication: "*"}
PARENTHESES = {left: "(", right: ")"}

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp)

same_precedence = Proc.new do |operator|
  case operator
  when *OPERATORS.values
    1
  when PARENTHESES[:left]
    0
  end
end

different_precedence = Proc.new do |operator|
  case operator
  when OPERATORS[:plus]
    2
  when OPERATORS[:multiplication]
    1
  when PARENTHESES[:left]
    0
  end
end

def evaluate(expresion, precedence)
  operator_stack = []
  operand_stack  = []
  index          = 0

  while(index < expresion.length) do
    case expresion[index]
    when " "
    when PARENTHESES[:left]
      operator_stack << expresion[index]
    when PARENTHESES[:right]
      while(!operator_stack.empty? && operator_stack[-1] != PARENTHESES[:left]) do
        operand_2 = operand_stack.pop
        operand_1 = operand_stack.pop
        operator = operator_stack.pop

        operand_stack << eval("#{operand_1} #{operator} #{operand_2}")
      end
      # remove the left parentheses
      operator_stack.pop
    when *OPERATORS.values
      while(!operator_stack.empty? && precedence.call(operator_stack[-1]) >= precedence.call(expresion[index])) do
        operand_2 = operand_stack.pop
        operand_1 = operand_stack.pop
        operator  = operator_stack.pop

        operand_stack << eval("#{operand_1} #{operator} #{operand_2}")
      end
      operator_stack << expresion[index]
    else
      value = 0
      while(index  < expresion.length && expresion[index] =~ /\d/) do
        value = (value * 10) + expresion[index].to_i
        index += 1
      end
      operand_stack << value
      index -= 1
    end
    index += 1
  end
  while !operator_stack.empty? do
    operand_2 = operand_stack.pop
    operand_1 = operand_stack.pop
    operator  = operator_stack.pop

    operand_stack << eval("#{operand_1} #{operator} #{operand_2}")
  end
  operand_stack.pop
end

results_1 = []
results_2 = []

input.each do |expresion|
  results_1 << evaluate(expresion, same_precedence)
  results_2 << evaluate(expresion, different_precedence)
end

puts "Part 1: #{results_1.sum}"
puts "Part 1: #{results_2.sum}"
