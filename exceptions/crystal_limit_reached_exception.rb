# frozen_string_literal: true

require_relative 'crystal_exception'

# This exception is thrown when an attempt is made to bind more than too many
# crystals to a character.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
class CrystalLimitReachedException < CrystalException
end
