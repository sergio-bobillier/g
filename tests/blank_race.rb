require_relative "../race"

# A race with no particular attributes (for tests).
BLANK_RACE = Race.new(Stats.new({:con => 0, :str => 0, :dex => 0, :int => 0, :men => 0, :wit => 0}))
