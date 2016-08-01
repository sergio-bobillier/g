require_relative("crystal_exception")

# This exception is raised when an attempt is made to bind an already bound
# crystal.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
class CrystalAlreadyBoundException < CrystalException
end
