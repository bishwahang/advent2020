#!/usr/bin/env ruby

require 'set'
class RecursionError < StandardError
end

class Deck
  attr_reader :id, :cards

  def initialize(id, cards)
    @id    = id
    @cards = cards
    @history = Set.new
  end

  def draw
    raise "Empty draw" if cards.empty?
    if repetiton?
      raise RecursionError, "Recursing for player #{id}"
    end
    record_history
    cards.shift
  end

  def place_at_bottom(won_card, lost_cord)
    @cards += [won_card, lost_cord]
  end

  def lost?
    cards.empty?
  end

  def can_recurse_combat?(value)
    cards.count >= value
  end

  def get_recrusive_player(value)
    self.class.new(id, cards.dup[0, value])
  end

  private

  def repetiton?
    @history.include?(cards)
  end

  def record_history
    @history << cards.dup
  end
end

decks = []

File.read(File.join(__dir__, "input.txt")).split("\n\n").each do |player_deck|
  cards = []
  id = nil
  player_deck.lines.each do |line|
    if captures = line.match(/Player (\d+)/)
      id = captures[1].to_i
    else
      cards << line.to_i
    end
  end
  decks << [id, cards]
end

def fight(game_no:, round_no:, player_1:, player_2:, recursive_combat: false)
  puts "Playing Game: #{game_no}, Round: #{round_no}"

  return player_2 if player_1.lost?
  return player_1 if player_2.lost?

  begin
    player_1_card = player_1.draw
    player_2_card = player_2.draw
  rescue RecursionError => e
    puts e
    return player_1
  end

  if  recursive_combat && player_1.can_recurse_combat?(player_1_card) && player_2.can_recurse_combat?(player_2_card)
    puts "Spinning another sub game..."
    winner_player = fight(
      game_no: game_no + 1,
      round_no: 1,
      player_1: player_1.get_recrusive_player(player_1_card),
      player_2: player_2.get_recrusive_player(player_2_card),
      recursive_combat: true
    )
  else
    winner_player = if player_1_card > player_2_card
                      player_1
                    else
                      player_2
                    end
  end

  if winner_player.id == 1
    player_1.place_at_bottom(*[player_1_card, player_2_card])
  else
    player_2.place_at_bottom(*[player_2_card, player_1_card])
  end
  fight(
    game_no: game_no,
    round_no: round_no + 1,
    player_1: player_1,
    player_2: player_2,
    recursive_combat: recursive_combat
  )
end

player_1, player_2 = decks.map {|e| Deck.new(e[0].dup, e[1].dup)}
winner_1 = fight(game_no: 1, round_no: 1, player_1: player_1, player_2: player_2)

total_score_1 = winner_1.cards.reverse.each_with_index.inject(0) do |sum, (card_value, index)|
  sum += (card_value * index.succ)
end

player_1, player_2 = decks.map {|e| Deck.new(e[0].dup, e[1].dup)}
winner_2 = fight(game_no: 1, round_no: 1, player_1: player_1, player_2: player_2, recursive_combat: true)

total_score_2 = winner_2.cards.reverse.each_with_index.inject(0) do |sum, (card_value, index)|
  sum += (card_value * index.succ)
end

puts "Part 1: #{total_score_1}"
puts "Part 2: #{total_score_2}"
