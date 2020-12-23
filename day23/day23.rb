#!/usr/bin/env ruby

class Cup
  attr_reader :label
  attr_accessor :next
  def initialize(label)
    @label = label
    @next = nil
  end
end

def print_cups(node, current_cup_label = nil)
  current_cup_label ||= node.label

  visited = [node]
  queue = [node]
  labels = []
  while !queue.empty? do
    node = queue.pop
    visited << node

    if node.label == current_cup_label
      labels << "(#{node.label})"
    else
      labels <<  node.label
    end
    queue << @cups_memo[node.next] unless visited.include?(@cups_memo[node.next])
  end
  puts labels.join(" ")
end

def generate_result(node)
  current_cup_label ||= node.label

  visited = [node]
  queue = [node]
  labels = []
  while !queue.empty? do
    node = queue.pop
    visited << node

    # skip the starting node with label "1"
    if node.label != current_cup_label
      labels <<  node.label
    end
    queue << @cups_memo[node.next] unless visited.include?(@cups_memo[node.next])
  end
  labels.join
end

def get_three_cups_clockwise(node)
  first = @cups_memo[node.next]
  second = @cups_memo[first.next]
  third =  @cups_memo[second.next]
  # adjust cup spacing
  node.next = third.next

  first_label  = first.label
  second_label = second.label
  third_label  = third.label

  # the meat is here, tracking the low and max
  # sorting always 3 elements
  # in O(1) time, N = 3 constant
  chosen_labels = [first_label, second_label, third_label].sort.reverse

  chosen_labels.each do |label|
    # if 5 was the current_low_destination
    # and anything else than 5 was taken in 3 cups
    # it remains unchanged
    # else
    # we need to find the next possible current_low_destination
    # that is not in the 3 cups
    # For e.g.,
    # current_low_destination -> 5
    # [6, 4, 2]
    # nothing changes
    # [6, 5, 1]
    # 4 becomes the new (5 - 1)
    # [6, 5, 4]
    # 3 becomes the new (5 - 1 - 1)
    # it can also become 0, if all possible low destination were taken
    # away into the 3 cups
    # current node -> 4
    # next possible - [3, 2, 1]
    # taken into 3 cups [3, 2, 1]
    # current_low_destination -> 0 (3 - 1 - 1 - 1)
    if label == @current_low_destination
      @current_low_destination -= 1
    end
  end
  # same for current_max_destination
  # if 9 is the current_max_destination
  # [7, 8, 1]
  # [9,8, 1]
  # 7 becomse the new
  # nothing changes
  # [9, 8, 7]
  # 6 becomes the new max
  chosen_labels.each do |label|
    if label == @current_max_destination
      @current_max_destination -= 1
    end
  end

  [first, second, third]
end

def get_destination_cup(node)
  start_label = node.label - 1

  # current_low_destination is zero, that means no possiblility of taking
  # the next lowest from the current node
  # current node -> 2
  # current_low_destination -> 1
  # taken into 3 cups [7, 6, 1]
  # current_low_destination -> 0 (1 - 1)
  # hence not possible, return destination from max
  return @cups_memo[@current_max_destination] if @current_low_destination == 0

  # if start_label is greater than current_low_destination
  # return the tracked current_low_destination node
  # else return current_max_destination
  # O(1) timespace
  if start_label >= @current_low_destination
    @cups_memo[@current_low_destination]
  else
    @cups_memo[@current_max_destination]
  end
end

def place_cups_clockwise(node, picked_cups)
  first, second, third = picked_cups
  fourth = @cups_memo[node.next]

  node.next = first.label
  first.next = second.label
  second.next = third.label
  third.next = fourth.label

  node
end
# test input
# input = "389125467".chars.map(&:to_i)
# puzzle input
input = "496138527".chars.map(&:to_i)

@cups_memo = {}

root_cup = nil
cups = []
input.each_with_index do |label, index|
  if (previous_cup = cups.pop)
    new_cup = Cup.new(label)
    previous_cup.next = new_cup.label
    cups << new_cup
    @cups_memo[label] = new_cup
  else
    root_cup = Cup.new(label)
    cups << root_cup
    @cups_memo[label] = root_cup
  end
end

last_cup = cups.pop
last_cup.next = root_cup.label
@current_low_destination = root_cup.label - 1
@current_max_destination  = 9

100.times do |i|
  puts "--- Move #{i.succ} ---"
  puts "Cups"
  print_cups(root_cup)

  puts "Pick up"
  three_cups = get_three_cups_clockwise(root_cup)
  puts three_cups.map(&:label).join(" ")

  puts "destination"

  destination_cup = get_destination_cup(root_cup)
  puts destination_cup.label

  place_cups_clockwise(destination_cup, three_cups)
  root_cup = @cups_memo[root_cup.next]
  @current_low_destination = root_cup.label - 1
  @current_max_destination = 9
end

label_one_cup = @cups_memo[1]
puts "Part 1: #{generate_result(label_one_cup)}"

puts "-" * 10

# test input
# input = "389125467".chars.map(&:to_i)
# puzzle input
input = "496138527".chars.map(&:to_i)

@cups_memo = {}
MAX_NUMBER = 1_000_000

root_cup = nil
cups = []
input.each_with_index do |label, index|
  if (previous_cup = cups.pop)
    new_cup = Cup.new(label)
    previous_cup.next = new_cup.label
    cups << new_cup
    @cups_memo[label] = new_cup
  else
    root_cup = Cup.new(label)
    cups << root_cup
    @cups_memo[label] = root_cup
  end
end

max_number = input.max
(max_number + 1).upto(MAX_NUMBER).each do |label|
  previous_cup = cups.pop
  new_cup = Cup.new(label)
  previous_cup.next = new_cup.label
  cups << new_cup
  @cups_memo[label] = new_cup
end

last_cup = cups.pop
last_cup.next = root_cup.label

@current_low_destination = root_cup.label - 1
@current_max_destination  = MAX_NUMBER
puts "Computing 2nd part..."
10_000_000.times do |i|
  three_cups = get_three_cups_clockwise(root_cup)
  destination_cup = get_destination_cup(root_cup)
  place_cups_clockwise(destination_cup, three_cups)
  root_cup = @cups_memo[root_cup.next]
  # the meat is here, tracking the low and max
  # in O(1) time, N = 3 constant
  @current_low_destination = root_cup.label - 1
  @current_max_destination = MAX_NUMBER
  puts "--Crab Move--: #{i+1}" if (i + 1) % 2_000_000 == 0
end

label_one_cup = @cups_memo[1]

first_neighbor = @cups_memo[label_one_cup.next]
second_neighbor = @cups_memo[first_neighbor.next]

puts "Part 2: #{first_neighbor.label * second_neighbor.label}"
