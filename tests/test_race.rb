require "minitest/autorun"

require_relative "../race"

# Tests the Race class.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class TestRace < Minitest::Unit::TestCase

  # Tests that the initializer method doesn't allow the creation of an invalid
  # race. It also tests that the stats and element attributes are set correctly
  # in the newly created race.
  def test_initializer
    assert_raises ArgumentError do
      Race.new                           # No stats argument
    end

    assert_raises ArgumentError do
      Race.new("hello")                  # Invalid stats argument
    end

    race = Race.new(Stats.new({:con => 10, :str => 8, :dex => 6, :int => 4, :men => 2, :wit => 0}))
    assert_equal(10, race.stats.con, "The new race's con should be 10")
    assert_equal(8, race.stats.str, "The new race's str should be 8")
    assert_equal(6, race.stats.dex, "The new race's dex should be 6")
    assert_equal(4, race.stats.int, "The new race's int should be 4")
    assert_equal(2, race.stats.men, "The new race's men should be 2")
    assert_equal(0, race.stats.wit, "The new race's wit should be 0")
    assert_nil(race.element, "The new race should have no element")

    race = Race.new(Stats.new, :water)
    assert_equal(:water, race.element, "The new race's element should be water")

    race = Race.new(Stats.new, [:wind, :dark])
    assert_equal([:wind, :dark], race.elements, "The new race's elements should be wind and dark")
  end

  # Test that the race element (or elements) can be accessed or set using
  # `element` or `elements`
  def test_aliases
    race = Race.new(Stats.new)

    race.element = :dark
    assert_equal(:dark, race.element, "Should be able to use `elements` or `element`")

    elements = [:wind, :fire]
    race.elements = elements
    assert_equal(elements, race.elements, "Should be able to use `elements` or `element`")
  end

  # Tests that the element setter raises exceptions when invalid values are
  # given and that it accepts the valid ones.
  def test_element_setter
    race = Race.new(Stats.new)

    race.element = nil
    assert_nil(race.element, "Should be able to make a race non-elemental")

    assert_raises ArgumentError do
      race.element = "hello"             # Not an element nor array
    end

    assert_raises ArgumentError do
      race.element = [:water, nil]       # Not a Symbol in the array
    end

    assert_raises ArgumentError do
      race.element = :thunder            # Not a valid element
    end

    assert_raises ArgumentError do
      race.element = [:fire, :holy]      # Not a valid element in the array
    end

    assert_raises ArgumentError do
      race.element = [:wind, :wind]      # Repeated element
    end

    race.element = :earth
    assert_equal(:earth, race.element, "Should be able to set a single element")

    elements = [:wind, :water]
    race.elements = elements
    assert_equal(elements, race.elements, "Should be able to set multiple elements as an array")
  end
end
