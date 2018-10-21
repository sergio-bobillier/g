# frozen_string_literal: true

require_relative 'party_error'

# This exception is raised when you try to add a character to a party that has
# already reached the maximum number of allowed characters.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class PartyFull < PartyError
  def initialize(msg = nil)
    super(msg || 'Party full')
  end
end
