# Models the character's basic stats.
#
# - con - Constitution: Influences physical defense, resistance to physical
#   debuffs and health
# - str - Strength: Influences physical attack, physical debuff landing rate
#   and critical damage
# - dex - Dexterity: Influences crital rate, evasion, accuracy and speed
# - int - Intelligence: Influences magic power, magical critical damage and
#   magical debuff landing rate.
# - men - Mental Strength: Influences magical defense, resistance to magic
#   debuffs, and mana
# - wit - Wisdom: Influences magical critical rate, magical accuracy, magical
#   evasion and casting speed.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class Stats

  # The maximum value that character stats (str, con, etc) can get.
  MAX_STATS = 50

  # The default value for all stats
  DEFAULT_VALUE = 20

  # An array of listeners that will be executed when a stat changes. The
  # listeners should respond to the call method. When listeners are called they
  # receive three parameters: the stat being changed, the current value and the
  # new value. No listeners will be called if no change occurs (current value
  # equals new value)
  #
  # @return [Array<#call>] The array of listeners.
  attr_reader :change_listeners

  # Class constructor. Initializes all stats to a default value
  def initialize(stats = nil)
    raise ArgumentError.new("`stats` should be Hash") unless stats.nil? || stats.is_a?(Hash)

    @stats = {
      :con => DEFAULT_VALUE,
      :str => DEFAULT_VALUE,
      :dex => DEFAULT_VALUE,
      :int => DEFAULT_VALUE,
      :men => DEFAULT_VALUE,
      :wit => DEFAULT_VALUE
    }

    @change_listeners = []

    if stats
      stats.each do |stat, value|
        validate_stat(stat)
        set_stat(stat, value)
      end
    end
  end

  # Returns the value of the given stat.
  #
  # @param stat [Symbol] The stat's name
  # @return [Integer] The value of the stat.
  # @raise [ArgumentError] If the stat's name is not a symbol or is not a valid
  #   stat name.
  def [](stat)
    validate_stat(stat)
    @stats[stat]
  end

  # Sets the given stat's value.
  #
  # @param stat [Symbol] The stat's name
  # @param value [Integer] The new value for the stat.
  # @raise [ArgumentError] If the stat's name is not a symbol or is not a valid
  #   stat name or the given value is not an integer.
  def []=(stat, value)
    validate_stat(stat)
    set_stat(stat, value)
  end

  # Adds the stat values of the given object to the stat values of the receiver.
  #
  # @param stats [Stats] The stat object whose values should be added.
  # @return [Stats] The receiver object (so multiple Stats object can be added)
  def <<(stats)
    raise ArgumentError.new("Stats expected but got #{stats.class}") unless stats.is_a?(Stats)

    @stats.each do |stat, value|
      set_stat(stat, value + stats[stat])
    end

    return self
  end

  # Returns a new instance of Stats whose values are the sum of the receiver
  # values and the stats values.
  #
  # @param stats [Stats] The stats object whose values should be added.
  # @return [Stats] A new instance of Stats.
  def +(stats)
    raise ArgumentError.new("Stats expected but got #{stats.class} instead") unless stats.is_a?(Stats)
    derive(stats)
  end

  # @return [Stats] A clone of the receiver object.
  def clone
    derive
  end

  private

  # Validates that the given stat name is valid.
  #
  # @param stat [Stat] The stat's name.
  # @raise [ArgumentError] If the stat's name is not a symbol or is not a valid
  #   stat name.
  def validate_stat(stat)
    raise ArgumentError.new("Stat names should be symbols, got #{stat.class} instead") unless stat.is_a?(Symbol)
    raise ArgumentError.new("Unrecognized stat #{stat}") unless @stats.has_key?(stat)
  end

  # Sets a stat's value. If the value is less than zero then the stat will be
  # set to zero. If the value is greater than MAX_STATS then the stat will be
  # set to MAX_STATS.
  #
  # @param stat [Symbol] The stat to set.
  # @param value [Integer] The value.
  # @raise [ArgumentError] If the value is not an integer.
  def set_stat(stat, value)
    raise ArgumentError.new("Integer expected but #{value.class} received") unless value.is_a?(Integer)
    value = MAX_STATS if value > MAX_STATS
    value = 0 if value < 0

    oldValue = @stats[stat]
    @stats[stat] = value

    unless oldValue == value
      @change_listeners.each do |listener|
        next unless listener.respond_to?(:call)
        listener.call(:stat, @stats[:stat], value)
      end
    end

    return value
  end

  # Creates a new Stats object from the receiver and optionally adds the values
  # of the given `Stats` object to the newly created object.
  #
  # @param stats [Stats] An optional Stats object whose values should be added
  #   to the newly created object.
  # @return [Stats] A new `Stats` object derived from the receiver.
  def derive(stats = nil)
    new_stats = Stats.new

    @stats.each do |stat, value|
      addition = (stats ? stats[stat] : 0)
      new_stats[stat] = value + addition
    end

    return new_stats
  end
end
