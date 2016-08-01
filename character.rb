require_relative "attributes"
require_relative "exceptions/character_not_in_party_exception"
require_relative "exceptions/crystal_already_bound_exception"
require_relative "exceptions/crystal_limit_reached_exception"
require_relative "exceptions/level_too_low_for_crystal_binding_exception"
require_relative "exceptions/same_element_crystal_already_bound_exception"
require_relative "crystal"
require_relative "job"
require_relative "race"
require_relative "stats"

# Represents a Character.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class Character
  # Level cap
  MAX_LEVEL = 50

  # Experience needed to reach level 2. The experience needed for level up is
  # calculated using this figure as a base.
  BASE_EXP = 100

  # The maximum number of crystals a character can have.
  MAX_CRYSTALS = 3

  # @return [Party] The party the character belongs to.
  attr_accessor :party

  # @return [Integer] The character's level
  attr_reader :level

  # @return [Integer] The experience needed to reach the next level
  attr_reader :next_level

  # @return [Integer] The experience gained in the current level
  attr_reader :experience

  # @return [Stats] The character's basic stats
  attr_reader :stats

  # @return [Attributes] The character's attributes
  attr_reader :attributes

  # @return [Race] The character's race.
  attr_reader :race

  # @return [Job] The character's current job.
  attr_reader :job

  # Creates a new character with the supplied race, level and job
  #
  # @param race [Race] The character's race.
  # @param level [Integer] The character's level.
  # @param job [Job] The character's job.
  # @return [Character] The new Character instance.
  # @raise [ArgumentError] If `race` is not an instance of `Race`, `level` is
  #   not an Integer or is outside the valid range or `job` is not an instance
  #   of `Job`
  def initialize(race, level = 1, job = nil)
    raise ArgumentError.new("race should be an instance of `Race`") unless race.is_a?(Race)

    @race = race

    @base_stats = Stats.new
    @base_stats << @race.stats
    self.job = job

    # Attributes needs to be recalculated when stats change.
    @stats.change_listeners << lambda { |stat, currentValue, newValue|
      recalculate_attributes
    }

    @attributes = Attributes.new
    @crystals = []

    # NOTE: Setting the level should be the last thing in the initializer
    self.level = level
  end

  # Sets the character's level.
  #
  # @param level [Integer] The character's level.
  # @raise [ArgumentError] If `level` is not an integer or ir is less than one
  #   or greater than MAX_LEVEL.
  def level=(level)
    raise ArgumentError.new("`level` must be an Integer") unless level.is_a?(Integer)
    raise ArgumentError.new("`level` must be between 1 and #{MAX_LEVEL}") unless level >= 1 && level <= MAX_LEVEL

    @level = level
    @experience = 0

    # Calculates the experience needed to reach the next level. Should be 1.5
    # times the experience needed to reach the current level.

    experience = BASE_EXP

    if @level >= 2
      (@level-1).times { experience = (experience * 1.5).floor }
    end

    @next_level = experience

    unless @dont_recalculate
      recalculate_attributes(true)
    end
  end

  # Sets the character's experience in the current level. If the experience set
  # is greater than the experience needed to level up then the character will
  # level up and the remaining experience will be awarded for the next level. If
  # the experience is negative then the character will level down and the
  # remaining experience will be substracted from the previous level.
  #
  # @param experience [Integer] The experience.
  # @raise [ArgumentError] If the experience is not an integer.
  def experience=(experience)
    raise ArgumentError.new("`experience` should be an integer") unless experience.is_a?(Integer)
    return if experience == 0

    if experience > 0
      if experience < @next_level
        @experience = experience
      else

        @dont_recalculate = true

        while experience >= @next_level && @level < MAX_LEVEL do
          experience -= @next_level
          self.level += 1
        end

        recalculate_attributes(true)
        @dont_recalculate = false

        if experience > @next_level
          @experience = @next_level
        else
          @experience = experience
        end
      end
    else
      if @level == 1
        @experience = 0           # Character cannot go below level 1
        return                    # so bail out.
      end

      experience = @experience + experience.abs

      @dont_recalculate = true

      while experience >= @experience
        experience -= @experience
        self.level -= 1
        @experience = @next_level

        break if @level == 1      # Don't allow the charater to go below level 1
      end

      recalculate_attributes(true)
      @dont_recalculate = false

      if experience > @experience
        @experience = 0
      else
        @experience -= experience
      end
    end
  end

  # Leaves the current party.
  #
  # @raise [CharacterNotInPartyException] If the character is not a party member.
  # @raise [CharacterNotFoundException] If the character tries to leave a party
  #   from which it is not a member. (Should never be raised under normal
  #   circunstances).
  def leave_party
    unless party
      raise CharacterNotInPartyException.new
    end

    party.remove!(self)
  end

  # Sets the character's current job.
  #
  # @param job [Job] The character's current job.
  # @raise [ArgumentError] If `job` is not an instance of `Job` or `nil`
  def job=(job)
    unless job.is_a?(Job) || job.nil?
      raise ArgumentError.new("`job` muest be an instance of Job or `nil`")
    end

    @job = job
    @stats = (job ? @base_stats + job.stats : @base_stats.clone)
    recalculate_attributes if @level
  end

  # Returns an array with the crystals that are currently bound to the
  # character.
  #
  # @return [Array] The bound crystals array.
  def crystals
    return @crystals.clone
  end

  # Binds the given crystal to the character.
  #
  # @param [Crystal] The crystal to bind.
  # @raise [ArgumentError] If the given value is not an instance of `Crystal`.
  # @raise [CrystalLimitReachedException] If the crystal limit has been reached.
  # @raise [LevelTooLowForCrystalBindingException] If the character's level is
  #   not high enough to bind another crystal.
  # @raise [CrystalAlreadyBoundException] If an attempt is made to bind the same
  #   crystal twice.
  # @raise [CrystalAlreadyBoundException] If the crystal has already been bound
  #   to a character.
  def bind_crystal(crystal)
    raise ArgumentError.new unless crystal.is_a?(Crystal)
    raise CrystalLimitReachedException.new if @crystals.length >= MAX_CRYSTALS

    # The first crystal can be bound as soon as the character is created, that
    # is, when character is at level 1. The second crystal can only be bound
    # after the character has reached 1 * (MAX_LEVEL/MAX_CRYSTALS), normally
    # that would be 1 * (50 / 3) = 16. The third crystal can only be bound
    # after the character has reached 2 * (MAX_LEVEL/MAX_CRSTALS), i.e. 2 *
    # (50 / 3) = 32 and so on. Note that, if MAX_LEVEL or MAX_CRYSTALS change
    # these values will change too.
    min_level = @crystals.length * (MAX_LEVEL / MAX_CRYSTALS)
    raise LevelTooLowForCrystalBindingException.new if self.level < min_level

    # Do not allow the same crystal to be bound twice
    raise CrystalAlreadyBoundException.new if @crystals.include?(crystal)

    # Do not allow two crystals with the same element to be bound.

    @crystals.each do |bound_crystal|
      raise SameElementCrystalAlreadyBoundException.new if bound_crystal.element == crystal.element
    end

    crystal.bind_to(self)
    @crystals << crystal
  end

  private

  # Recalculates the character attributes with the current level and ststs.
  #
  # @param reset_transient_attributes [Boolean] If true transient attributes
  #   like health and mana will be reset to their maximum.
  def recalculate_attributes(reset_transient_attributes = false)
    # Recalculate the character attributes for this level
    @attributes.calculate_attributes(@stats, @level, reset_transient_attributes)
  end
end
