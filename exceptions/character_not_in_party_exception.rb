# This exception is raised when the leave_party method is called on a character
# that is not currently a party member.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class CharacterNotInPartyException < RuntimeError
  def initialize(msg = nil)
    super(msg || 'Character not currently in party')
  end
end
