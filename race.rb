require_relative "character_modifier"
require_relative "elements"

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

  alias_method :elements, :element

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
    unless element.nil?
      unless element.is_a?(Symbol) || element.is_a?(Array)
        raise ArgumentError.new("`element` should be a Symbol or an Array of Symbols")
      end

      if element.is_a?(Array)
        if element.length != element.uniq.length
          raise ArgumentError.new("Elements in the array should be unique")
        end

        element.each do |elm|
          raise ArgumentError.new("All elements of the array should be Symbols") unless elm.is_a?(Symbol)
          raise ArgumentError.new("Unknown element '#{elm}'") unless ELEMENTS.include?(elm)
        end
      else
        raise ArgumentError.new("Unknown element '#{element}'") unless ELEMENTS.include?(element)
      end
    end

    @element = element
  end

  alias_method :elements=, :element=
end
