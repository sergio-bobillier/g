require_relative "crystal_exception"

# This exception is thrown when an attempt is made to bind two crystals with
# the same element to a character.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
class SameElementCrystalAlreadyBoundException < CrystalException
end
