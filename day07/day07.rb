#!/usr/bin/env ruby

class Bag
  attr_reader :contains, :color
  def initialize(color, contains = [])
    @color = color
    @contains = contains
  end

  def contains?(other_bag)
    return true if self == other_bag

    return false if contains.empty?
    return true if contains.include?(other_bag)

    contains.uniq.each do |bag|
      return true if bag.contains?(other_bag)
    end
    return false
  end

  def total_bags_needed
    return 0 if contains.empty?
    count = 0
    contains.each do |bag|
      count += 1
      count += bag.total_bags_needed
    end
    count
  end

  def ==(other_bag)
    self.color == other_bag.color
  end
end


input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp)

container = {}

# parsing of input
input.each do |line|
  hue, color, * = line.split(" ")
  color_name = "#{hue}_#{color}"

  bag = if container[color_name]
          container[color_name]
        else
          bag = Bag.new(color_name, [])
          container[color_name] = bag
        end

  case line
  when /contain no other bags/
    # no other bags
    # faded blue bags contain no other bags.
    # bag.contains = []
  when /, \d{1}/
    # contains multiple colored other bags
    # dark olive bags contain 3 faded blue bags, 4 dotted black bags.
    line.split("contain")[1].split(",").each do |other_bag_info|
      times, hue, color, * = other_bag_info.split(" ")
      other_color_name = "#{hue}_#{color}"
      other_bag = if container[other_color_name]
                    container[other_color_name]
                  else
                    container[other_color_name] = Bag.new(other_color_name, [])
                  end
      times.to_i.times do
        bag.contains << other_bag
      end
    end
  else
    # one single other bag
    # bright white bags contain 1 shiny gold bag.
    times, hue, color, * = line.split("contain")[1].split(" ")
    other_color_name = "#{hue}_#{color}"
    other_bag = if container[other_color_name]
            container[other_color_name]
          else
            container[other_color_name] = Bag.new(other_color_name, [])
          end
    times.to_i.times do
      bag.contains << other_bag
    end
  end
end

shiny_gold_bag = container["shiny_gold"]

puts "Part 1: #{container.values.reject { |e| e == shiny_gold_bag }.select { |e| e.contains?(shiny_gold_bag) }.count}"

puts "Part 2: #{shiny_gold_bag.total_bags_needed}"
