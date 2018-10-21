# frozen_string_literal: true

require_relative('crystal_error')

# This exception is raised when an attempt is made to bind an already bound
# crystal.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
class CrystalAlreadyBound < CrystalError
end
