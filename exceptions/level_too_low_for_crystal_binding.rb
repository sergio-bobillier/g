# frozen_string_literal: true

require_relative 'crystal_error'

# This exception is raised when an attempt is made to bind a crystal to a
# character before it has reached the required level.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
class LevelTooLowForCrystalBinding < CrystalError
end
