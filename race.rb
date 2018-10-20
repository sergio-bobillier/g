# frozen_string_literal: true

require_relative 'character_modifier'
require_relative 'elements'

# This class models a character race. A race contains a Stats object, this
# object has the stats bonuses that should be given to a character of that
# particular race. It also says for what elements a character of that race
# receives bonus attack and AP gain.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class Race < CharacterModifier
  # @return [Symbol|Array<Symbol>] The element or elements for which a Character
  #   of this race should receive bonuses on attack and AP gain.
  attr_reader :element

  alias elements element

  # Sets the race element (if given).
  def initialize(stats, element = nil)
    super(stats)
    self.element = element if element
  end

  # Sets the race's element (or elements). A race's element determines what
  # elemental bonuses a character of the race will receive (when attacking or
  # during AP gain).
  #
  # @param element [Symbol] The race's element.
  def element=(element)
    unless element.is_a?(Symbol) || element.is_a?(Array) || element.nil?
      raise ArgumentError, '`element` should be a Symbol or an Array of Symbols'
    end

    if element.is_a?(Array)
      validate_elements(element)
    else
      validate_element(element) unless element.nil?
    end

    @element = element
  end

  alias elements= element=

  private

  # Validates that no element is duplicated in the given array, that the array
  # is compraised only of Symbols and that each of those Symbols is actually a
  # valid element.
  #
  # @param elements [Array<Symbol>] The elements array.
  # @raise [ArgumentError] If there is a duplicated element in the array, if
  #   any of the elements in the array is not a Symbol or any of the elements is
  #   unknown.
  def validate_elements(elements)
    if elements.length != elements.uniq.length
      raise ArgumentError, 'Elements in the array should be unique'
    end

    elements.each do |element|
      unless element.is_a?(Symbol)
        raise ArgumentError, 'All elements of the array should be Symbols'
      end

      validate_element(element)
    end
  end

  # Checks that the given element is valid.
  #
  # @param element [Symbol] The element.
  # @raise [ArgumentError] If the element is unknown.
  def validate_element(element)
    return if ELEMENTS.include?(element)

    raise ArgumentError, "Unknown element '#{element}'"
  end
end
