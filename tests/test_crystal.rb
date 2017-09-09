require "minitest/autorun"
require_relative "../character"
require_relative "../crystal"
require_relative "blank_race"

# Test suite for the Crystal class.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
class TestCrystal < Minitest::Test
  # Tests the class initializer
  #
  # * Tests that an error is thrown when no element is specified
  # * Tests than an error is thrown when something besied a symbol is given
  # * Tests than an error is thrown when an invalid element is given
  # * Tests that an element can be specified at creation and is later
  #   accesible with the `element` property.
  # * Tests that the specified level is retained and accesible.
  #
  # All level related tests are left to the test_level_setter function.
  #
  # @see test_level_setter
  def test_initializer
    assert_raises ArgumentError do
      Crystal.new                         # No element specified
    end

    assert_raises ArgumentError do
      Crystal.new("dark")                 # Not a Symbol
    end

    assert_raises ArgumentError do
      Crystal.new(:lightning)             # Not a valid element
    end

    crystal = Crystal.new(:dark)
    assert_equal(:dark, crystal.element, "The element specified at creation should be retained")
    assert_equal(1, crystal.level, "A crystal created without a level should be level 1")

    crystal = Crystal.new(:earth, 5)
    assert_equal(5, crystal.level, "The level specified during creation should be retained")
  end

  # Tests that the crystal element cannot be changed after creation.
  def test_inmutable_element
    crystal = Crystal.new(:fire)
    assert_raises NameError do
      crystal.element = :wind
    end
  end

  # Tests the level= method.
  #
  # * Tests that an error is raised if something besides an Integer is given
  # * Tests that an error is raied if a level outsied the admitted ranged is
  #   given.
  # * Tests that the level can be set.
  # * Tests that an error is raised if an attempt is made to set a level less
  #   than the current level.
  def test_level_setter
    crystal = Crystal.new(:water)

    assert_raises ArgumentError do
      crystal.level = "one"                 # Not an integer
    end

    assert_raises ArgumentError do
      crystal.level = 0                      # Less than one
    end

    assert_raises ArgumentError do
      crystal.level = Crystal::MAX_LEVEL + 1 # Greater than MAX_LEVEL
    end

    # Tests that the AP required to reach level 2 is initialized correctly.

    assert_equal(Crystal::BASE_AP, crystal.next_level, "The AP required to reach level 2 should be #{Crystal::BASE_AP}")

    # Tests that the crystal level can be changed and that the AP required to
    # reach the next level is correctly calculated.

    crystal.level = 2
    required_ap = (Crystal::BASE_AP * 1.5).to_i
    assert_equal(2, crystal.level, "Should be able to set the crystal's level")
    assert_equal(required_ap, crystal.next_level, "The AP required to reach level 3 should be #{required_ap}")

    # Tests that the crystal's level can be incremented and that the AP required
    # to reach the next level is properly calculated.

    required_ap = (crystal.next_level * 1.5).to_i
    crystal.level += 1
    assert_equal(3, crystal.level, 'Should be able to increment the crystal\'s level')
    assert_equal(required_ap, crystal.next_level, "The AP required to reach level 5 should be #{required_ap}")

    # Tests that the crystal's level can be set to any arbitrary level and that
    # the AP required to reach the next level is properly calculated.

    crystal.level = 7
    required_ap = Crystal::BASE_AP
    (crystal.level - 1).times { required_ap = (required_ap * 1.5).to_i }
    assert_equal(required_ap, crystal.next_level, "The AP required to reach level 8 should be #{required_ap}")

    assert_raises ArgumentError do
      crystal.level = 1                     # Less than current level
    end
  end

  # Tests the ap= method:
  #
  # * Tests that an error is raised is something besides an Integer is given
  # * Tests that an error is raised if the given number is less than 0
  # * Tests that the correct value is returned by the attr_reader after setting
  #   it,
  # * Tests that the AP can be incremented
  # * Tests that the AP can be decremented
  # * Tests that an error is raised if the AP is decremented below 0
  # * Tests that the crystal's level goes up when enough AP is given.
  # * Tests that the remaining AP is kept if the AP given is greater than the
  #   AP needed to reach the next level.
  # * Tests that the the crystal con go up multiple levels if enough AP is
  #   given.
  # * Tests that the crystal won't go over its max level if a lot of AP is
  #   given.
  def test_ap_setter
    crystal = Crystal.new(:wind)

    assert_raises ArgumentError do
      crystal.ap = "Black"
    end

    assert_raises ArgumentError do
      crystal.ap = -4
    end

    crystal.ap = 10
    assert_equal(10, crystal.ap, "The crystal's AP should be 10")

    crystal.ap += 10
    assert_equal(20, crystal.ap, "The crystal's AP should be 20")

    crystal.ap -= 5
    assert_equal(15, crystal.ap, "The crystal's AP should be 15")

    assert_raises ArgumentError do
      crystal.ap -= 20
    end

    crystal.ap = crystal.next_level
    assert_equal(2, crystal.level, "The crystal should have leveled UP")
    assert_equal(0, crystal.ap, "The crystal's AP should be 0")

    crystal.ap = crystal.next_level + 10
    assert_equal(3, crystal.level, "The crystal's level should be now 3")
    assert_equal(10, crystal.ap, "The crystal's AP should be 10")

    crystal.ap = crystal.next_level + (crystal.next_level * 1.5).to_i + 50
    assert_equal(5, crystal.level, "The crystal's level should be 5")
    assert_equal(50, crystal.ap, "The crystal's AP should be 50")

    crystal.ap = 10000
    assert_equal(Crystal::MAX_LEVEL, crystal.level, "The crystal's level should be #{Crystal::MAX_LEVEL}")
    assert_equal(crystal.next_level, crystal.ap, "The crystal's AP should be #{crystal.next_level}")
  end

  # Tests crystal binding.
  #
  # * Tests that a crystal is not bound to any character after creation.
  # * Tests that an error is raised if bind_to is given anything besides an
  #   instance of `Character`.
  # * Tests that the crystal can be bound to a character.
  # * Tests than an error is raised if an attempt is made to bind the crystal a
  #   second time.
  def test_binding
    character = Character.new(BLANK_RACE)
    crystal = Crystal.new(:light)

    assert_nil(crystal.bound_to, "The crystal should not be bound to any character yet")

    assert_raises ArgumentError do
      crystal.bind_to("Wizard")
    end

    crystal.bind_to(character)
    assert_equal(character, crystal.bound_to, "The crystal should be bound to the character")

    assert_raises CrystalAlreadyBoundException do
      crystal.bind_to(character)
    end
  end
end
