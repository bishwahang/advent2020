input = File.read(File.join(__dir__, "input2.txt")).split("\n\n").map {|e| e.lines.map(&:chomp)}.map do |tile|
  key = tile.first.match(/(\d+)/).captures.first.to_i
  [key, tile[1..-1].map{|e| e.lines.first.chars}]
end.to_h

# get the boundary elenmets
boundary_memo = {}
input.each do |key, image_matrix|
  boundary_top       = image_matrix.first
  boundary_bottm     = image_matrix[-1]
  boundary_right     = image_matrix.map {|e| e[-1]}
  boundary_left      = image_matrix.map {|e| e[0]}
  boundary_memo[key] = [boundary_top, boundary_right, boundary_bottm, boundary_left]
end

adjacency_keys = Hash.new {|h,k| h[k] = []}
boundary_memo.each do |key, boundaries|
  # for each image check how many boundaries match with other image
  boundaries.each do |boundary|
    other_keys  = boundary_memo.keys - [key]
    other_keys.each do |other_key|
      boundary_memo[other_key].each do |other_boundary|
        [boundary, boundary.reverse].product([other_boundary, other_boundary.reverse]).each do |pairs|
          if pairs[0] == pairs[1]
            adjacency_keys[key] << other_key
            break
          end
        end
      end
    end
  end
end

puts "Part 1: #{adjacency_keys.select {|k, v| v.count == 2}.keys.reduce(:*)}"
