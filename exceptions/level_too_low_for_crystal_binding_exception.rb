# frozen_string_literal: true

require_relative 'crystal_exception'

# This exception is thrown when an attempt is made to bind a crystal to a
# character before it has reached the required level.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
class LevelTooLowForCrystalBindingException < CrystalException
end
