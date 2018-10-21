# frozen_string_literal: true

require_relative 'party_error'

# This exception is raised when an attempt is made to add a character to a party
# and the character is already in the same (or other party).
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class CharacterAlreadyInParty < PartyError
  def initialize(msg = nil)
    super(msg || 'Character already in party')
  end
end
