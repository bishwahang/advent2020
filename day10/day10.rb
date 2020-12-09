#!/usr/bin/env ruby
require 'set'

class ConnectAdapters
  attr_reader :adapters

  def initialize(adapters)
    @adapters        = Set.new(adapters)
    @paths_count     = {}
    @charging_outlet = 0
    @my_adapter      = adapters.max + 3
  end

  def product_of_differences
    adapters_list = adapters.sort

    adapters_list.unshift(@charging_outlet)
    adapters_list << @my_adapter

    diffrences_count = adapters_list.each_cons(2).map {|elem| elem[1] - elem[0]}.tally
    diffrences_count[3] * diffrences_count[1]
  end

  def connection_paths
    calculate_total_paths(@charging_outlet, @my_adapter, @paths_count)
  end

  private

  def calculate_total_paths(node, target_jolt, paths_count)
    return 1 if node == target_jolt

    return paths_count[node] if paths_count[node]

    sum = 0
    (1..3).each do |diff|
      next_node = node + diff

      if adapters.include?(next_node) || next_node == target_jolt
        sum += calculate_total_paths(next_node, target_jolt, paths_count)
      end
    end

    paths_count[node] = sum
    sum
  end
end

input = File.readlines(File.expand_path("input.txt", __dir__)).map(&:chomp).map(&:to_i)

connect_adapters = ConnectAdapters.new(input)
puts "Part 1: #{connect_adapters.product_of_differences}"
puts "Part 1: #{connect_adapters.connection_paths}"
