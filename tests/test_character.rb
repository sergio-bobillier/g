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
end
