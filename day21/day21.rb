#!/usr/bin/env ruby


input = File.readlines(File.join(__dir__, "input.txt"))

ingredients_counts = Hash.new {|h, k| h[k] = 0}
allergens_to_ingredients  = Hash.new {|h, k| h[k] = []}
input.each do |line|
  captures    = line.match(/(.*)\(contains (.*)\)/)
  ingredients = captures[1].strip.split(" ").map(&:strip)
  allergens    = captures[2].strip.split(",").map(&:strip)
  ingredients.each do |ingredient|
    ingredients_counts[ingredient] += 1
  end
  allergens.each do |allergy|
    allergens_to_ingredients[allergy] << ingredients
  end
end

reduced_allergens_mapping = {}
allergens_to_ingredients.each do |k, value|
  reduced_allergens_mapping[k] = value.reduce(:&)
end

found_allergy = reduced_allergens_mapping.select {|k, v| v.count == 1}.keys

visited = {}
while !found_allergy.empty? do
  current_allergen = found_allergy.pop
  visited[current_allergen] = true
  reduced_allergens_mapping.keys.each do |target_allergy|
    next if target_allergy == current_allergen
    reduced_allergens_mapping[target_allergy] -= reduced_allergens_mapping[current_allergen]
  end
  reduced_allergens_mapping.select {|k, v| v.count == 1}.keys.each do |allergen|
    found_allergy << allergen unless visited[allergen]
  end
end

ingredients_without_allergies = ingredients_counts.keys - reduced_allergens_mapping.values.flatten

total_appearance = ingredients_without_allergies.inject(0) do |sum, ingredient|
  sum += ingredients_counts[ingredient]
end

puts "Part 1: #{total_appearance}"

puts "Part 2: #{reduced_allergens_mapping.sort_by {|k, v| k}.map {|e| e[1]}.flatten.join(",")}"
