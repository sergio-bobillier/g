require "minitest/autorun"
require_relative "../character"
require_relative "../party"

# Tests the Party class.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class TestParty < Minitest::Unit::TestCase

  # Tests that the class constructor raises an exception when invalid objects
  # are used to build it.
  def test_exception_raised_when_invalid_object
    assert_raises ArgumentError do
      party = Party.new("Hello")        # Not a Character nor an Array
    end

    # Not all array elements are characters
    assert_raises ArgumentError do
      party = Party.new(Character.new, Character.new, "hello")
    end
  end

  # Tests that a party can be created with 1 single character
  def test_party_can_be_created_with_one_character
    party = Party.new(Character.new)
    assert_equal(party.length, 1, "Should be able to create a party from a single character")
  end

  # Tests that a party can be created with from a characters array
  def test_party_can_be_created_with_characters_array
    party = Party.new([Character.new, Character.new, Character.new])
    assert_equal(party.length, 3, "Should be able to create a party from a characters array")
  end

  # Test that an aception is thrown if a party is created with a character that
  # belongs to another party.
  def test_exception_if_character_already_in_party
    character = Character.new
    party1 = Party.new(character)

    assert_raises CharacterAlreadyInPartyException do
      party2 = Party.new(character)
    end

    assert_raises CharacterAlreadyInPartyException do
      party2 = Party.new([Character.new, character, Character.new])
    end
  end

  # Tests that an exception is raised if the characters array contains
  # duplicates.
  def test_exception_if_repeated_character
    character = Character.new

    assert_raises CharacterAlreadyInPartyException do
      party = Party.new([Character.new, character, character, Character.new])
    end
  end

  # Tests that an exception is raised if a party is created with a characters
  # array which size exceeds the party's max allowed size.
  def test_exception_raised_when_creating_a_too_big_party
    assert_raises ArgumentError do
      characters = []
      (Party::MAX_SIZE + 1).times { characters << Character.new }
      party = Party.new(characters)
    end
  end

  # Tests that the array returned by the characters property of the party is a
  # clone or copy and not the internal array and that no characters can be added
  # directly to the party.
  def test_array_copy_is_returned
    party = Party.new([Character.new, Character.new])

    length = party.length
    characters = party.characters
    assert_equal(characters.length, length, "The returned array length should be the same size as the party size")

    characters << Character.new
    refute_equal(characters.length, party.length, "Should not be able to add characters to the party directly")
  end

  # Tests that an exception is raised when a non character object is added to a
  # party.
  def test_exception_if_invalid_object_added
    party = Party.new

    assert_raises ArgumentError do
      party << "Hello"
    end
  end

  def test_exception_if_party_full
    characters = []
    (Party::MAX_SIZE).times { characters << Character.new }
    party = Party.new(characters)

    assert_raises PartyFullException do
      party << Character.new
    end
  end

  def test_exception_if_character_already_in_party_when_added
    character = Character.new
    party1 = Party.new(character)
    party2 = Party.new

    assert_raises CharacterAlreadyInPartyException do
      party2 << character
    end
  end

  # Tests that relations are created between the characters and theirs parties
  # when parties are created or characters are added to the parties later.
  def test_relationships_created
    character = Character.new
    party = Party.new(character)
    assert_equal(character.party, party, "Character should be related with it's party")

    characters = [Character.new, Character.new, Character.new]
    party = Party.new(characters)

    characters.each do |character|
      assert_equal(character.party, party, "Characters should be related with their party")
    end

    character = Character.new
    party << character
    assert_equal(character.party, party, "Character must be related with it's party")
  end

  # Tests that relationships are broken when a character is removed from a party
  # or when it leaves the party
  def test_relationships_broken
    character1 = Character.new
    character2 = Character.new
    character3 = Character.new
    party = Party.new([character1, character2, character3])

    party.remove(character1)
    assert_nil(character1.party, "Relationships should be broken when characters are removed from parties")

    party.remove!(character2)
    assert_nil(character2.party, "Relationships should be broken when characters are removed from parties")

    character3.leave_party
    assert_nil(character3.party, "Relationships should be broken when characters leave their parties")
  end

  # Tests that the remove method doesn't raise an exception if a character that
  # is not member of the party is removed and that the remove! (bang) method
  # does
  def test_remove_without_and_with_exception
    party = Party.new
    character = Character.new

    party.remove(character)

    assert_raises CharacterNotFoundException do
      party.remove!(character)
    end
  end

  # Tests that the include? method is returning the expected value.
  def test_include
    character1 = Character.new
    character2 = Character.new
    party = Party.new(character1)
    assert(party.include?(character1), "Party should include the character")
    refute(party.include?(character2), "Party should not include the character")
  end
end
