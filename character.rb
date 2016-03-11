require_relative "exceptions/character_not_in_party_exception"

# Represents a Character.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class Character
  attr_accessor :party

  # Leaves the current party.
  #
  # @raise [CharacterNotInPartyException] If the character is not a party member.
  # @raise [CharacterNotFoundException] If the character tries to leave a party
  #   from which it is not a member. (Should never be raised under normal
  #   circunstances).
  def leave_party
    unless party
      raise CharacterNotInPartyException.new
    end

    party.remove!(self)
  end
end
