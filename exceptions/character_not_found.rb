# frozen_string_literal: true

require_relative 'party_error'

# This exception is raised then an attempt is made to remove a character from a
# party of which it is not a member.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class CharacterNotFound < PartyError
  def initialize(msg = nil)
    super(msg || 'Character not in party')
  end
end
