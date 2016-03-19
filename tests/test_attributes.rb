require "minitest/autorun"
require_relative "../attributes"

class TestAttributes < Minitest::Unit::TestCase

  # Tests the class initializer. Checks that if no Stats object is given then
  # all attributes are initialized to their minimum value. Also checks that the
  # initializer raises exceptions for invalid parameters.
  def test_initializer
    attributes = Attributes.new
    assert_equal(Attributes::ATTRIBUTES[:casting_speed][:min], attributes.casting_speed, "All attributes should start at their minimum value when no `stats` object is given")
    assert_equal(Attributes::ATTRIBUTES[:attack][:min], attributes.attack, "All attributes should start at their minimum value when no `stats` object is given")

    assert_raises ArgumentError do
      attributes = Attributes.new("hello")
    end

    assert_raises ArgumentError do
      attributes = Attributes.new(Stats.new, "hello")
    end
  end

  # Tests attribute setting and retrieving and verifies that attributes values
  # outside bounds are adjusted to the boundary value.
  def test_attributes
    attributes = Attributes.new

    assert_raises NameError do
      attributes.missingno                  # Undefined property
    end

    attributes.total_health = 100
    assert_equal(100, attributes.total_health, "Should be able to set attributes directly")

    attributes.total_health += 100
    assert_equal(200, attributes.total_health, "Should be able to mutate attribute values")

    assert_raises ArgumentError do
      attributes.health = "hello"           # Not the expected type
    end

    # Within bounds
    attributes.mana = 0
    assert_equal(0, attributes.mana, "0 should be within bounds")

    # Out of bounds
    attributes.mana = -1
    assert_equal(0, attributes.mana, "-1 is out of bounds, should be adjusted")

    # Within bounds
    attributes.health = 200
    assert_equal(200, attributes.health, "200 should be within bounds")

    # Out of bounds
    attributes.health = 300
    assert_equal(200, attributes.health, "300 is out of bounds, should be adjusted" )
  end

  # Test each of the attributes calculation formulas
  def test_formulas
    attributes = Attributes.new(Stats.new)

    assert_equal(120, attributes.defense, "defense should be 120")
    assert_equal(261, attributes.total_health, "total_health should be 261")
    assert_equal(115, attributes.attack, "attack should be equal to 115")
    assert_equal(1.02, attributes.critical_damage, "critical_damage should be equal to 1.02")
    assert_equal(0.04, attributes.critical_rate, "critical_rate should be equal to 0.04")
    assert_equal(0.1, attributes.evasion, "evasion should be equal to 0.1")
    assert_equal(0.54, attributes.accuracy, "accuracy should be equal to 0.54")
    assert_equal(20, attributes.speed, "speed should be equal to 20")
    assert_equal(173, attributes.magic_power, "magic_power should be equal to 173")
    assert_equal(1.02, attributes.magic_critical_damage, "magic_critical_damage should be equal to 1.02")
    assert_equal(157, attributes.magic_defense, "magic_defense should be equal to 157")
    assert_equal(179, attributes.total_mana, "total_mana should be equal to 179")
    assert_equal(0.02, attributes.magic_critical_rate, "magic_critial_rate should be equal to 0.02")
    assert_equal(0.7, attributes.magic_accuracy, "magic_accuracy should be equal to 0.7")
    assert_equal(0.12, attributes.magic_evasion, "magic_evasion should be equal to 0.12")
    assert_equal(253, attributes.casting_speed, "casting_speed should be equal to 253")
  end

  # Tests that transient attributes are reset when reset_transient_attributes is
  # set to true.
  def test_transient_rest
    stats = Stats.new
    attributes = Attributes.new(stats)
    assert_equal(attributes.total_health, attributes.health, "health should be equal to total_health")
    assert_equal(attributes.total_mana, attributes.mana, "mana should be equal to total_mana")

    attributes.calculate_attributes(stats, 2, true)
    assert_equal(attributes.total_health, attributes.health, "health should be equal to total_health")
    assert_equal(attributes.total_mana, attributes.mana, "mana should be equal to total_mana")
  end

  # Tests that the transient attributes are NOT reset when
  # reset_transient_attributes is omitted.
  def test_no_transient_reset
    stats = Stats.new
    attributes = Attributes.new(stats)
    health = attributes.health
    mana = attributes.mana

    attributes.calculate_attributes(stats, 2)
    assert_equal(health, attributes.health, "transient attributes should NOT have changed")
    assert_equal(mana, attributes.mana, "transient_attributes should NOT have changed")
  end

  # Tests that transient attributes are adjusted when their respective totals
  # decrease.
  def test_transient_adjustment
    stats = Stats.new
    attributes = Attributes.new(stats)
    attributes.total_health -= 10
    attributes.total_mana -= 10

    assert_equal(attributes.total_health, attributes.health, "health should be equal to total_health. Transient attributes should be adjusted when their total decreases.")
    assert_equal(attributes.total_mana, attributes.mana, "mana should be equal to total_mana. Transient attributes should be adjusted when their total decreases.")

    attributes.calculate_attributes(stats, 2, true)
    attributes.calculate_attributes(stats, 1)

    assert_equal(attributes.total_health, attributes.health, "health should be equal to total_health. Transient attributes should be adjusted when their total decreases.")
    assert_equal(attributes.total_mana, attributes.mana, "mana should be equal to total_mana. Transient attributes should be adjusted when their total decreases.")
  end
end
