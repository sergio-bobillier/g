require "minitest/autorun"

require_relative "../character_modifier"

# Test cases fot the CharacterModifier class.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class TestCharacterModifier < Minitest::Unit::TestCase

  # Tests the initialize method to make sure an exception is raised when an
  # invalid stats parameter is given and that the resulting Stats object within
  # the Character_Modifier has all the stats sets correctly.
  def test_initializer
    assert_raises ArgumentError do
      CharacterModifier.new                       # No stats argument
    end

    assert_raises ArgumentError do
      CharacterModifier.new("hello")              # Invalid stats argument
    end

    character_modifier = CharacterModifier.new(Stats.new({:con => 10, :str => 8, :dex => 6, :int => 4, :men => 2, :wit => 0}))
    assert_equal(10, character_modifier.stats.con, "The new character modifier's con should be 10")
    assert_equal(8, character_modifier.stats.str, "The new character modifier's str should be 8")
    assert_equal(6, character_modifier.stats.dex, "The new character modifier's dex should be 6")
    assert_equal(4, character_modifier.stats.int, "The new character modifier's int should be 4")
    assert_equal(2, character_modifier.stats.men, "The new character modifier's men should be 2")
    assert_equal(0, character_modifier.stats.wit, "The new character modifier's wit should be 0")
  end
end
