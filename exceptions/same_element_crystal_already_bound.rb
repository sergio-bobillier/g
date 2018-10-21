# frozen_string_literal: true

require_relative 'crystal_error'

# This exception is raised when an attempt is made to bind two crystals with
# the same element to a character.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
class SameElementCrystalAlreadyBound < CrystalError
end
