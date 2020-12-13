#!/usr/bin/env ruby

# https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm#Modular_integers
def eea_inverse(a, n)
  t, newt = 0, 1
  r, newr= n, a

  while newr != 0 do
    quotient = r / newr
    t, newt = newt, t - quotient * newt
    r, newr = newr, r - quotient * newr
  end

  if r > 1
    puts "a is not invertible"
  end

  if t < 0
    t += n
  end

  t
end

# https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm#Pseudocode
# https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm#Example
def eea_gcd(a, b)
  s, old_s = 0, 1
  r, old_r = b, a

  while r != 0 do
    quotient = old_r / r
    old_r, r = r,  old_r - quotient * r
    old_s, s = s, old_s - quotient * s
  end

  # bezout sk
  s_k = old_s

  # bezout tk
  if b != 0
    t_k = (old_r - old_s * a) / b
  else
    t_k = 0
  end

  puts "Given numbers: (#{a}, #{b})"
  puts "bezout: sk: #{s_k}, tk: #{t_k}"
  puts "gcd: #{old_r}"
  if old_r == 1
    puts "The numbers a coprimes"
    puts "The inverse of #{a} mod (#{b}) is #{s_k % b}"
  end
end


puts eea_inverse(17, 43)
puts eea_gcd(240, 46)
puts eea_gcd(17, 43)
puts eea_gcd(17, 15)
puts eea_gcd(23, 17)
