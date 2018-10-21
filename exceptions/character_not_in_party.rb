# frozen_string_literal: true

require_relative 'party_error'

# This exception is raised when the leave_party method is called on a character
# that is not currently a party member.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class CharacterNotInParty < PartyError
  def initialize(msg = nil)
    super(msg || 'Character not currently in party')
  end
end
