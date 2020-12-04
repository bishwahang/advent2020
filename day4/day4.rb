#!/usr/bin/env ruby


class Passport
  STRICT_FILEDS = %w[byr iyr eyr hgt hcl ecl pid]
  OPTIONAL_FILEDS = %w[cid]
  VALID_EYE_COLORS = %w[amb blu brn gry grn hzl oth]

  attr_reader :attributes

  def initialize(attributes = {})
    @attributes = attributes
  end

  def valid?(strict: false)
    return false unless (STRICT_FILEDS - attributes.keys).empty?

    return true unless strict

    valid_birth_year? && valid_issue_year? && valid_expiration_year? &&
      valid_height? && valid_hair_color? && valid_eye_color? && valid_passport_id?
  end

  private

  # byr (Birth Year) - four digits; at least 1920 and at most 2002.
  def valid_birth_year?
    byr = attributes["byr"]
    within_length?(number: byr, length: 4) && within_range?(number: byr, min: 1920, max: 2002)
  end

  # iyr (Issue Year) - four digits; at least 2010 and at most 2020.
  def valid_issue_year?
    iyr = attributes["iyr"]
    within_length?(number: iyr, length: 4) && within_range?(number: iyr, min: 2010, max: 2020)
  end

  # eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
  def valid_expiration_year?
    eyr = attributes["eyr"]
    within_length?(number: eyr, length: 4) && within_range?(number: eyr, min: 2020, max: 2030)
  end

  # hgt (Height) - a number followed by either cm or in:
  #   If cm, the number must be at least 150 and at most 193.
  #   If in, the number must be at least 59 and at most 76.

  def valid_height?
    height = attributes["hgt"]
    if (match = height.match(/\A(\d+)(cm|in)\z/))
      value, unit = match.captures
      case unit
      when "cm"
        within_range?(number: value, min: 150, max: 193)
      when "in"
        within_range?(number: value, min: 59, max: 76)
      end
    else
      return false
    end
  end

  # hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
  def valid_hair_color?
    hcl = attributes["hcl"]
    !!hcl.match(/\A#[a-f0-9]{6}\z/)
  end

  # ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
  def valid_eye_color?
    ecl = attributes["ecl"]
    VALID_EYE_COLORS.include?(ecl)
  end

  # pid (Passport ID) - a nine-digit number, including leading zeroes.
  def valid_passport_id?
    pid = attributes["pid"]
    within_length?(number: pid, length: 9)
  end

  def within_length?(number:, length:)
    !!number.match(/\A\d{#{length}}\z/)
  end

  def within_range?(number:, min:, max:)
    number = number.to_i
    number >= min && number <= max
  end
end


input = File.readlines("input.txt").map(&:chomp)

options   = {}
passports = []

input.each do |line|
  attributes = line.split(" ")
  if attributes.empty?
    passports << Passport.new(options)
    options = {}
  end
  attributes.each do |attribute|
    key, value = attribute.split(":")
    options[key] = value
  end
end

passports << Passport.new(options)

puts "Part 1:"
p passports.select(&:valid?).count
puts "Part 2:"
p passports.select {|e| e.valid?(strict: true)}.count
