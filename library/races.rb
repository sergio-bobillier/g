require_relative "../race"

# This module contains a constant for each of the five races. Normally these
# would be loaded from a database but since this is conceptual game I want to
# keep it as simple as posible.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
module Races
  HUMAN = Race.new(Stats.new(
    {:con => 3, :str => 3, :dex => 3, :int => 3, :men => 3, :wit => 3}), [:light, :dark])

  ELF = Race.new(Stats.new(
    {:con => 2, :str => 2, :dex => 4, :int => 4, :men => 4, :wit => 5}), :water)

  DARK_ELF = Race.new(Stats.new(
    {:con => 1, :str => 2, :dex => 5, :int => 5, :men => 1, :wit => 4}), :wind)

  DWARF = Race.new(Stats.new(
    {:con => 5, :str => 4, :dex => 1, :int => 2, :men => 2, :wit => 2}), :earth)

  ORC = Race.new(Stats.new(
    {:con => 4, :str => 5, :dex => 2, :int => 1, :men => 5, :wit => 1}), :fire)
end
