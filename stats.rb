# Models the character's basic stats.
#
# - con - Constitution: Influences physical defense, resistance to physical
#         debuffs and health
# - str - Strength: Influences physical attack, physical debuff landing rate
#         and critical damage
# - dex - Dexterity: Influences crital rate, evasion, accuracy and speed
# - int - Intelligence: Influences magic power, magical critical damage and
#         magical debuff landing rate.
# - men - Mental Strength: Influences magical defense, resistance to magic
#         debuffs, and mana
# - wit - Wisdom: Influences magical critical rate, magical accuracy, magical
#         evasion and casting speed.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class Stats
  # The maximum value that character stats (str, con, etc) can get.
  MAX_STATS = 50

  # The default value for all stats
  DEFAULT_VALUE = 20

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

    if stats
      stats.each do |stat, value|
        raise ArgumentError.new("Unrecognized stat #{stat}") unless @stats.has_key?(stat)
        set_stat(stat, value)
      end
    end
  end

  # Called by Ruby then the called method cannot be found. Checks if the method
  # name matches one of the stats and sets or returns that stat's value.
  #
  # @param method [Symbol] The called method name.
  # @param args [Array] The method parameters.
  def method_missing(method, *args)
    set_stat = false
    method_name = method.to_s
    if method_name.end_with?("=")
      method = method_name[0..-2].to_sym
      set_stat = true
    end

    super unless @stats.has_key?(method)

    return set_stat(method, args[0]) if set_stat
    return @stats[method]
  end

  # Adds the stat values of the given object to the stat values of the receiver.
  #
  # @param stats [Stats] The stat object whose values should be added.
  # @param [Stats] The receiver object (so multiple Stats object can be added)
  def <<(stats)
    raise ArgumentError.new("Stats expected but got #{stats.class}") unless stats.is_a?(Stats)

    @stats.each do |stat, value|
      set_stat(stat, value + stats.send(stat))
    end

    return self
  end

  private

  # Sets a stat's value. If the value is less than zero then the stat will be
  # set to zero. If the value is greater than MAX_STATS then the stat will be
  # set to MAX_STATS.
  #
  # @param stat [Symbol] The stat to set.
  # @param value [Integer] The value.
  def set_stat(stat, value)
    raise ArgumentError.new("Integer expected but #{value.class} received") unless value.is_a?(Integer)
    value = MAX_STATS if value > MAX_STATS
    value = 0 if value < 0
    @stats[stat] = value
  end
end
