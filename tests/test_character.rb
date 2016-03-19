require "minitest/autorun"
require_relative "../character"
require_relative "../party"

class TestCharacter < Minitest::Unit::TestCase

  # Tests that an exception is throw if leave_party is called without joining
  # a party first.
  def test_exception_if_leave_without_joining
    character = Character.new
    assert_raises CharacterNotInPartyException do
      character.leave_party
    end
  end

  # Tests that no exception is thrown if the character joins a party before
  # calling leave_party
  def test_not_exception_if_leave_after_joining
    character = Character.new
    party = Party.new(character)
    character.leave_party

    party << character
    character.leave_party
  end

  # Tests that an exception is raised when a character tries to leave a party
  # it does not belongs to.
  def test_exception_on_irregular_situation
    assert_raises CharacterNotFoundException do
      character = Character.new
      party = Party.new
      character.party = party
      character.leave_party
    end
  end

  # Tests that a character can be created with a specific level and that the
  # experience needed to reach the next level is properly calculated.
  def test_creation_with_level
    assert_raises ArgumentError do
      Character.new("hello")                 # Not an integer
    end

    assert_raises ArgumentError do
      Character.new(0)                      # Less than 1
    end

    assert_raises ArgumentError do
      Character.new(Character::MAX_LEVEL+1)  # Above MAX_LEVEL
    end

    character = Character.new
    assert_equal(1, character.level, "Character's level on creation should be 1")
    assert_equal(Character::BASE_EXP, character.next_level, "Needed experience in level 1 should be equal to `BASE_EXP`")

    character = Character.new(5)
    assert_equal(5, character.level, "Character's level should be 5")
    assert_equal(505, character.next_level, "Needed experience in level 5 should be equal to 505")

    character = Character.new(Character::MAX_LEVEL)
    assert_equal(Character::MAX_LEVEL, character.level, "Character's level should be #{Character::MAX_LEVEL}")
  end

  # Tests that the experience needed for the next level is properly calculated
  # when character's level is set.
  def test_experience_calculated_when_level_set
    character = Character.new(2)
    assert_equal(0, character.experience, "Experience should be set to 0 when character level is set")
    assert_equal(150, character.next_level, "Experience needed to reach level 3 should be 150")

    character.level = 1
    assert_equal(0, character.experience, "Experience should be set to 0 when character level is set")
    assert_equal(100, character.next_level, "Experience needed to reach level 2 should be 100")

    character.level = 10
    assert_equal(0, character.experience, "Experience should be set to 0 when character level is set")
    assert_equal(3829, character.next_level, "Experience needed to reach level 11 should be 3829")

    character.level = 6
    assert_equal(0, character.experience, "Experience should be set to 0 when character level is set")
    assert_equal(757, character.next_level, "Experience needed to reach level 7 should be 757")
  end

  # Tests various scenarios regarding experience loose and gain. Tests that the
  # character's level and experience values are adjusted properly according to
  # the experience change performed.
  def test_set_experience
    character = Character.new

    assert_raises ArgumentError do
      character.experience = "Hello"                # Not an integer
    end

    exp = Character::BASE_EXP / 10

    # Set experience (less than next_level)
    character.experience = exp
    assert_equal(exp, character.experience, "Character's experience should be #{exp}")

    # Increase experience (less than next_level)
    character.experience += exp
    assert_equal(exp*2, character.experience, "Character's experience should be #{exp*2}")

    # Set experience (more than next level)
    character.experience = Character::BASE_EXP + exp
    assert_equal(2, character.level, "Character's level should be 2")
    assert_equal(exp, character.experience, "Character's experience should be #{exp}")

    # Decrease experience (enough to level down)
    character.experience -= exp*2
    assert_equal(1, character.level, "Character's level should be 1")
    assert_equal(exp*9, character.experience, "Character's experience should be #{exp*9}")

    # Increase experience (enough to level up)
    character.experience += exp*2
    assert_equal(2, character.level, "Character's level should be 2")
    assert_equal(exp, character.experience, "Character's experience should be #{exp}")

    # Gain a lot of experience
    character.level = 1
    character.experience += 5000
    assert_equal(9, character.level, "Character's level should be 9")
    assert_equal(89, character.experience, "Character's experience should be 89")

    # Loose a lot of experience
    character.level = 10
    character.experience -= 5000
    assert_equal(7, character.level, "Character's level should drop to 7")
    assert_equal(390, character.experience, "Character's experience should be 390")

    # Loose enough experience to go below level 1 (should stay at level 1)
    character.level = 2
    exp = character.next_level * 4
    character.experience = -exp
    assert_equal(1, character.level, "Character's level should be 1")
    assert_equal(0, character.experience, "Character's experience should be 0")

    # Trying to go over the level cap
    character.level = Character::MAX_LEVEL
    character.experience = character.next_level * 2
    assert_equal(Character::MAX_LEVEL, character.level, "Character's level should be #{Character::MAX_LEVEL}")
    assert_equal(character.next_level, character.experience, "Character's experience should be #{character.next_level}")

    # Trying to go over the level cap
    character.level = Character::MAX_LEVEL-1
    character.experience = character.next_level * 4
    assert_equal(Character::MAX_LEVEL, character.level, "Character's level should be #{Character::MAX_LEVEL}")
    assert_equal(character.next_level, character.experience, "Character's experience should be #{character.next_level}")
  end

  # Tests that an instance of the Stats class is created with the character,
  # that said class is accessible (but not mutable) and that the stats
  # themselves mutable.
  def test_character_stats
    character = Character.new
    assert_kind_of(Stats, character.stats, "Character stats should be created with it")

    assert_raises NoMethodError do
      character.stats = nil
    end

    original_value = character.stats.wit
    character.stats.wit = original_value + 5
    assert_equal(original_value + 5, character.stats.wit, "Character's stats should be mutable")
  end

  # Tests that an instance of the Attributes class is created with the caracter,
  # that said class is accessible (but not mutable) and that the attributes
  # themselves are mutable.
  def test_character_attributes
    character = Character.new
    assert_kind_of(Attributes, character.attributes, "Character attributes should be created with it")

    assert_raises NoMethodError do
      character.attributes = nil
    end

    original_value = character.attributes.casting_speed
    character.attributes.casting_speed = original_value + 100
    assert_equal(original_value + 100, character.attributes.casting_speed, "Character attributes should be mutable")
  end

  # Tests that character attributes are calculated when the character is
  # created.
  def test_attributes_calculated
    character = Character.new
    attributes = Attributes.new(character.stats, character.level)
    assert_equal(attributes.critical_rate, character.attributes.critical_rate, "Character attributes should be calculated when the character is created")
  end

  # Tests that the character attributes are re-calculated when the character's
  # level changes directly or by means of experience gain.
  def test_attributes_on_level_change
    character = Character.new
    attributes = Attributes.new(character.stats, character.level)
    assert_equal(attributes.attack, character.attributes.attack, "Character attributes should be calculated when the character is created")
    assert_equal(attributes.health, character.attributes.total_health, "Transient attributes should be reset when level changes")

    character.level = 6
    attributes = Attributes.new(character.stats, character.level)
    assert_equal(attributes.attack, character.attributes.attack, "Character attributes should be re-calculated when the character level is set")
    assert_equal(attributes.health, character.attributes.total_health, "Transient attributes should be reset when level changes")

    character.level += 1
    attributes = Attributes.new(character.stats, character.level)
    assert_equal(attributes.attack, character.attributes.attack, "Character attributes should be re-calculated when the character level is mutated")
    assert_equal(attributes.health, character.attributes.total_health, "Transient attributes should be reset when level changes")

    character.experience += character.next_level * 2
    attributes = Attributes.new(character.stats, character.level)
    assert_equal(attributes.attack, character.attributes.attack, "Character attributes should be re-calculated when the character levels up by experience gain")
    assert_equal(attributes.health, character.attributes.total_health, "Transient attributes should be reset when level changes")
  end
end
