# This module provides a function that can be plugged-in in a class's
# method_missing function to make the keys of the given hash appear as object's
# properties.
#
# @example
#   class Dog
#     include HashMethods
#
#     def initialize
#       @props = {:breed => null}
#     end
#
#     def method_missing(method, *args)
#       hash_method(@props, method, args) do |prop, value|
#         @props[prop] = value
#       end
#     end
#   end
#
#   dog = Dog.new
#   dog.breed = "Basset Hound"
#   puts dog.breed                  # => "Basset Hound"
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
module HashProperties
  # Checks if the specified method's name is one of the keys in the given hash
  # (a property) if that is the case the function yields the method's name and
  # the passed value (if any) to the given block (where class specific logic can
  # take place).
  #
  # @param hash [Hash] The that contains the properties
  # @param method [Symbol] The method name
  # @param args [Array] The arguments passed to the method.
  # @yield [method, value] The called method's name (as a symbol) and the value.
  # @raise [NameError] If the specified method is not found within the hash keys.
  def hash_properties(hash, method, args)
    setter = false
    method_name = method.to_s
    if method_name.end_with?("=")
      method = method_name[0..-2].to_sym
      setter = true
    end

    raise NameError.new("Undefined property '#{method}' for #{self.class}") unless hash.has_key?(method)
    return hash[method] unless setter

    return yield(method, args[0])
  end
end
