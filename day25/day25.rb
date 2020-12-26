#!/usr/bin/env ruby

# https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange#Cryptographic_explanation
# PUBLIC_KEY_A = 5764801
# PUBLIC_KEY_B = 17807724
PUBLIC_KEY_A = 14082811
PUBLIC_KEY_B = 5249543
MODULUS_P = 20201227
g = 7

# https://en.wikipedia.org/wiki/Baby-step_giant-step#The_algorithm
def baystep_giantstep(g, h, mod)
  m = Math.sqrt(mod).ceil
  memo = {}
  e = 1
  0.upto(m - 1).each do |i|
    memo[e] = i
    e = (e * g) % mod
  end

  # https://ruby-doc.org/core-2.5.0/Integer.html#method-i-pow
  factor = g.pow(mod - m - 1, mod)
  e = h
  0.upto(m - 1).each do |i|
    if (memo[e])
      return (i * m + memo[e])
    end
    e = (e * factor) % mod
  end
  nil
end

a = baystep_giantstep(g, PUBLIC_KEY_A, MODULUS_P)
b = baystep_giantstep(g, PUBLIC_KEY_B, MODULUS_P)

if PUBLIC_KEY_B.pow(a, MODULUS_P) == PUBLIC_KEY_A.pow(b, MODULUS_P)
  puts "Found secret a:#{a}, b: #{b}, calculating private key..."
  puts "Part 1: #{PUBLIC_KEY_A.pow(b, MODULUS_P)}"
else
  raise "Secrets a and b couldn't be found"
end
