require "minitest/autorun"
require_relative "../character"
require_relative "../party"

# Tests the Party class.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class TestParty < Minitest::Test

  # A race with no particular attributes (needed for character creation).
  BLANK_RACE = Race.new(Stats.new({:con => 0, :str => 0, :dex => 0, :int => 0, :men => 0, :wit => 0}))

  # Tests that the class constructor raises an error when invalid objects
  # are used to build it.
  def test_exception_raised_when_invalid_object
    assert_raises ArgumentError do
      Party.new("Hello")        # Not a Characters array
    end

    # Not all array elements are characters
    assert_raises ArgumentError do
      Party.new([Character.new, Character.new, "hello"])
    end
  end

  # Tests than an exception is raised if the party is created with an array of
  # a single character.
  def test_exception_raised_if_array_of_one_element
    assert_raises ArgumentError do
      Party.new([Character.new])
    end
  end

  # Tests that a party can be created from a characters array
  def test_party_can_be_created_with_characters_array
    party = Party.new([Character.new(BLANK_RACE), Character.new(BLANK_RACE), Character.new(BLANK_RACE)])
    assert_equal(3, party.length, "Should be able to create a party from a characters array")
  end

  # Test that an exception is raised if a party is created with a character that
  # belongs to another party.
  def test_exception_if_character_already_in_party
    character = Character.new(BLANK_RACE)
    Party.new([character, Character.new(BLANK_RACE)])

    assert_raises CharacterAlreadyInParty do
      Party.new([Character.new(BLANK_RACE), character, Character.new(BLANK_RACE)])
    end
  end

  # Tests that an exception is raised if the characters array contains
  # duplicates.
  def test_exception_if_repeated_character
    character = Character.new(BLANK_RACE)

    assert_raises CharacterAlreadyInParty do
      Party.new([Character.new(BLANK_RACE), character, character, Character.new(BLANK_RACE)])
    end
  end

  # Tests that an exception is raised if a party is created with a characters
  # array which size exceeds the party's max allowed size.
  def test_exception_raised_when_creating_a_too_big_party
    assert_raises ArgumentError do
      characters = []
      (Party::MAX_SIZE + 1).times { characters << Character.new }
      Party.new(characters)
    end
  end

  # Tests that the array returned by the characters property of the party is a
  # clone or copy and not the internal array and that no characters can be added
  # directly to the party.
  def test_array_copy_is_returned
    party = Party.new([Character.new(BLANK_RACE), Character.new(BLANK_RACE)])

    length = party.length
    characters = party.characters
    assert_equal(length, characters.length, "The returned array length should be the same size as the party size")

    characters << Character.new(BLANK_RACE)
    refute_equal(characters.length, party.length, "Should not be able to add characters to the party directly")
  end

  # Tests that an exception is raised when a non character object is added to a
  # party.
  def test_exception_if_invalid_object_added
    party = Party.new([Character.new(BLANK_RACE), Character.new(BLANK_RACE)])

    assert_raises ArgumentError do
      party << "Hello"
    end
  end

  # Tests than an exception is raised when an attempt is made to add a character
  # to a full party.
  def test_exception_if_party_full
    characters = []
    (Party::MAX_SIZE).times { characters << Character.new(BLANK_RACE) }
    party = Party.new(characters)

    assert_raises PartyFull do
      party << Character.new(BLANK_RACE)
    end
  end

  # Tests than an exception is raised if an attempt is made to add a character
  # that is already in a party to another party.
  def test_exception_if_character_already_in_party_when_added
    character = Character.new(BLANK_RACE)
    Party.new([character, Character.new(BLANK_RACE)])
    party2 = Party.new([Character.new(BLANK_RACE), Character.new(BLANK_RACE)])

    assert_raises CharacterAlreadyInParty do
      party2 << character
    end
  end

  # Tests that relations are created between the characters and theirs parties
  # when parties are created or characters are added to the parties later.
  def test_relationships_created
    characters = [Character.new(BLANK_RACE), Character.new(BLANK_RACE), Character.new(BLANK_RACE)]
    party = Party.new(characters)

    characters.each do |chara|
      assert_equal(party, chara.party, "Characters should be related with their party")
    end

    character = Character.new(BLANK_RACE)
    party << character
    assert_equal(party, character.party, "Character must be related with it's party")
  end

  # Tests that relationships are broken when a character is removed from a party
  # or when it leaves the party
  def test_relationships_broken
    character1 = Character.new(BLANK_RACE)
    character2 = Character.new(BLANK_RACE)
    character3 = Character.new(BLANK_RACE)
    character4 = Character.new(BLANK_RACE)
    party = Party.new([character1, character2, character3, character4])

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
    party = Party.new([Character.new(BLANK_RACE), Character.new(BLANK_RACE)])
    character = Character.new(BLANK_RACE)

    party.remove(character)

    assert_raises CharacterNotFound do
      party.remove!(character)
    end
  end

  # Tests that the include? method is returning the expected value.
  def test_include
    character1 = Character.new(BLANK_RACE)
    character2 = Character.new(BLANK_RACE)
    party = Party.new([character1, Character.new(BLANK_RACE)])
    assert(party.include?(character1), "Party should include the character")
    refute(party.include?(character2), "Party should not include the character")
  end

  # Tests that the the party leader is set when the party is created.
  def test_leader_when_creating
    character = Character.new(BLANK_RACE)
    party = Party.new([character, Character.new(BLANK_RACE), Character.new(BLANK_RACE)])
    assert_equal(character, party.leader, "The first character in the array should be appointed party leader")
  end

  # Tests the leader= method.
  def test_leader_change
    assert_raises ArgumentError do
      party = Party.new([Character.new, Character.new])
      party.leader = "Hello"        # Not a Character instance
    end

    character1 = Character.new(BLANK_RACE)
    character2 = Character.new(BLANK_RACE)
    party = Party.new([character1, character2])

    assert_raises CharacterNotFound do
      party.leader = Character.new(BLANK_RACE)      # Not a member of the party.
    end

    assert_equal(character1, party.leader, "`character1` should've been the party leader here")

    party.leader = character2
    assert_equal(character2, party.leader, "`character2` should have been promoted to party leader")
  end

  # Tests that a new party leader is appointed if the current party leader is
  # removed from party and that the party leader is unchanged when another
  # character is removed.
  def test_leader_set_on_remove
    character1 = Character.new(BLANK_RACE)
    character2 = Character.new(BLANK_RACE)
    character3 = Character.new(BLANK_RACE)
    party = Party.new([character1, character2, character3])

    party.remove(character1)
    assert_equal(character2, party.leader, "`character2` should have been appointed party leader when `character1` was removed")

    party << character1
    assert_equal(character2, party.leader, "`character2` should be the party leader here")

    party.remove(character1)
    assert_equal(character2, party.leader, "`character2` should still be the party leader")
  end

  # Tests that the party disperses if all but one character leaves
  def test_party_disperses_if_all_removed
    character1 = Character.new(BLANK_RACE)
    character2 = Character.new(BLANK_RACE)

    party = Party.new([character1, character2])
    party.remove(character1)

    assert_equal(true, party.dispersed?, "Party should have been dispersed")
    assert_nil(character1.party, "`character1` should not be in party")
    assert_nil(character2.party, "`character2` should not be in party")

    party = Party.new([character1, character2])
    character1.leave_party

    assert_equal(true, party.dispersed?, "Party should have been dispersed")
    assert_nil(character1.party, "`character1` should not be in party")
    assert_nil(character2.party, "`character2` should not be in party")
  end

  # Tests that an exception is raised when an attempt is made to add a character
  # to a dispersed party.
  def test_exception_when_add_to_dispersed_party
    character1 = Character.new(BLANK_RACE)
    character2 = Character.new(BLANK_RACE)

    party = Party.new([character1, character2])
    party.remove(character1)

    assert_raises PartyHasDispersed do
      party << character1
    end
  end
end
