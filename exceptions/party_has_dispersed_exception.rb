require_relative "party_exception"

# This exception is raised when an attempt is made to add a character to a
# dispersed party.
class PartyHasDispersedException < PartyException
  def initialize(msg = nil)
    super(msg || "Party has dispersed")
  end
end
