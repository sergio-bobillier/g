require "minitest/autorun"

require_relative "../race"

# Tests the Race class.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class TestRace < Minitest::Unit::TestCase

  # Tests that the initializer method can create a race without en element,
  # that it can create a race with an element and a rece with two (or more)
  # elements.
  #
  # NOTE: The invalid element tests are done in the test_element_setter
  # test case since is in the element setter where the validation occurrs.
  #
  # @see test_element_setter
  def test_initializer
    race = Race.new(Stats.new)
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
