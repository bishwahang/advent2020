#!/usr/bin/env ruby

class Answer
  attr_reader :answer

  def initialize(answer)
    @answer = answer.chars
  end
end

class Group
  attr_reader :answers

  def initialize(answers)
    @answers = answers
  end

  def unique_union_count
    answers.map {|answer| answer.answer}.reduce(&:|).count
  end

  def unique_intersection_count
    answers.map {|answer| answer.answer}.reduce(&:&).count
  end
end


input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp)

answers = []
groups  = []

input.each do |answer|
  if answer.empty?
    groups << Group.new(answers)
    answers = []
  else
    answers << Answer.new(answer)
  end
end

groups << Group.new(answers) unless answers.empty?

puts "Part 1"
p groups.map { |group| group.unique_union_count }.sum

puts "Part 2"
p groups.map { |group| group.unique_intersection_count }.sum
