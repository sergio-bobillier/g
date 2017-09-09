require_relative "elements"
require_relative "exceptions/crystal_already_bound_exception"

# Represents a Crystal. Crystals are the way characters adquire abilities.
# The crystals level up as they gain AP and "learn" abilities as they do. The
# character that has the crystal bound can use those abilities.
#
# The abilities the crystal can "learn" depend on the bound character's current
# job.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
class Crystal
  # Level cap
  MAX_LEVEL = 10

  # AP Required to reach level 2
  BASE_AP = 45

  # @return [Integer] The crystal's level.
  attr_reader :level

  # @return [Integer] The AP needed for the crystal to reach the next level.
  attr_reader :next_level

  # @return [Integer] The AP the crystal has earned in the current level.
  attr_reader :ap

  # @return [Symbol] The element of the crystal
  attr_reader :element

  # Creates a new crystal with the of the given element.
  #
  # @param element [Symbol] The element for the crystal.
  # @param level [Integer] The crystal's level
  # @return [Crystal] The new crystal instance.
  # @raise [ArgumentError] If the given element is not a `Symbol` or is not a
  #   valid, known element. If the given level is not an integer or is outside
  #   of the allowed level range.
  def initialize(element, level = 1)
    raise ArgumentError.new("`element` should be a Symbol. #{element.class} given") unless element.is_a?(Symbol)
    raise ArgumentError.new("`element` should be a valid element") unless ELEMENTS.include?(element)
    @element = element

    @level = 1
    @next_level = BASE_AP
    self.level = level
  end

  # Binds the crystal to the given character.
  #
  # @param character [Character] The character to bind the crystal to.
  # @raise [CrystalAlreadyBoundException] If the crystal is already bound to a
  #   character.
  # @raise [ArgumentError] If the given character is not an instance of
  #   `Character`
  def bind_to(character)
    raise CrystalAlreadyBoundException.new("crystal already bound to a character") if @character
    raise ArgumentError.new("character should be an instance of `Character`") unless character.is_a?(Character)
    @character = character
  end

  # Returns the character the crystal is bound to.
  #
  # @return [Character] The character the crystal is bound to.
  def bound_to
    return @character
  end

  # Sets the crystal's level.
  #
  # @param level [Integer] The crystal's level.
  # @raise [ArgumentError] If the given level is not an integer, is outside
  #   of the allowed level range or is less than the current level.
  def level=(level)
    return if level == @level

    raise ArgumentError.new("`level` must be an Integer. `#{level.class}` given") unless level.is_a?(Integer)
    raise ArgumentError.new("`level` must be between 1 and #{MAX_LEVEL}") if level < 1 || level > MAX_LEVEL
    raise ArgumentError.new("`level` must be greater or equal to #{@level}") if level < @level

    @level = level
    @ap = 0

    # Calculates the AP needed to reach the next level, should be 1.5 times the
    # AP needed to reach the current level.

    @next_level = BASE_AP
    (@level - 1).times { @next_level = (@next_level * 1.5).to_i }
  end

  # Sets the crystal's current AP.
  #
  # @param ap [Integer] The AP.
  # @raise [ArgumentError] If the given AP is not an integer or is less than 0.
  def ap=(ap)
    raise ArgumentError.new("`ap` must be an integer. `#{ap.class}` given") unless ap.is_a?(Integer)
    raise ArgumentError.new("`ap` must be a positive integer") unless ap >= 0

    if ap >= @next_level
      while ap >= @next_level && @level < MAX_LEVEL do
        ap -= @next_level
        self.level += 1
      end

      @ap = (ap > @next_level ? @next_level : ap)
    else
      @ap = ap
    end
  end
end
