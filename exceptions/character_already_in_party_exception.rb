# frozen_string_literal: true

require_relative 'party_exception'

# This exception is thrown when an attempt is made to add a character to a party
# and the character is already in the same (or other party).
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class CharacterAlreadyInPartyException < PartyException
  def initialize(msg = nil)
    super(msg || 'Character already in party')
  end
end
