# frozen_string_literal: true

require_relative 'crystal_error'

# This exception is raised when an attempt is made to bind more than too many
# crystals to a character.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
class CrystalLimitReached < CrystalError
end
