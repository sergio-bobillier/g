require_relative "party_exception"

# This exception is thrown when you try to add a character to a party that has
# already reached the maximum number of allowed characters.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class PartyFullException < PartyException
  def initialize(msg = nil)
    super(msg || "Party full")
  end
end
