# frozen_string_literal: true

require_relative 'party_error'

# This exception is raised when an attempt is made to add a character to a
# dispersed party.
class PartyHasDispersed < PartyError
  def initialize(msg = nil)
    super(msg || 'Party has dispersed')
  end
end
