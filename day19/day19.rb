#!/usr/bin/env ruby

input = File.read(File.join(__dir__, "input.txt"))

rules_memo, messages = input.split("\n\n")
rules_memo           = rules_memo.split("\n").map(&:chomp)
messages             = messages.split("\n").map(&:chomp)

rules_memo = rules_memo.map do |rule|
  key, rule = rule.split(":")
  [key.strip, rule.strip.gsub('"', '')]
end.to_h

def expand_token(token)
  return token if token =~ /(\(|\)|\|)/
  return token if token =~ /\A[a-z]\z/
  return token if token =~ /\A\?:\z/

  rule = @rules_memo[token]
  case rule
  when /\A[a-z]\z/
    # ending rule "a" or "b"
    rule
  when /\|/
    # singe or multiple rule with |
    # 12 70 | 23 30
    "( ?: #{rule} )"
  when /\A\d+( \d+)?\z/
    # singe or multiple rule without the or |
    # 12 23
    rule
  else
    raise "What is this token and rule: #{token}, #{rule}"
  end
end

def expand_rule(rule)
  new_rule = ""
  rule.split.each do |token|
    if @expanded[token]
      expanded_token = @expanded[token]
    else
      expanded_token = expand_token(token)
      @expanded[token] = expanded_token
    end

    new_rule << expanded_token
    new_rule << " "
  end
  rule = new_rule.strip
end

def count_valid_messages(messages, rule, rules_memo)
  @rules_memo = rules_memo
  @expanded   = {}

  valid_count = 0
  round       = 0
  while true do
    # if there are no numbers on the rule
    # this means we have succesfully expanded and created the final regex
    break unless rule =~ /\d+/

    puts "Round: #{round += 1}"
    rule = expand_rule(rule)
    # check if new rule changes the number of valid messages
    new_valid_message_count = messages.map do |msg|
      new_rule = rule.gsub(" ", '')
      new_regex = /\A#{new_rule}\z/
      !new_regex.match(msg).nil?
    end.count(true)
    # puts "Valid messages so far: #{new_valid_message_count}"
    # if not !=0 since valid grammar will match atleast 1
    if new_valid_message_count != 0 && new_valid_message_count == valid_count
      # the regex is on loop
      # further expanding (*) regex doesn't give any more valid messages
      valid_count = new_valid_message_count
      break
    end
    valid_count = new_valid_message_count
  end
  valid_count
end

rule = rules_memo["0"]
puts "Part 1: #{count_valid_messages(messages, rule, rules_memo)}"

rules_memo["8"] = "42 | 42 8"
rules_memo["11"] = "42 31 | 42 11 31"
puts "Part 2: #{count_valid_messages(messages, rule, rules_memo)}"
