# frozen_string_literal: true

require_relative 'stats'

# rubocop:disable Metrics/ClassLength

# Models the attributes and stats of characters.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class Attributes
  # Character attributes with their types, bounds and other constraints. It Also
  # contains a lamda function to calculate the attribute value based on the
  # character stats and level.
  ATTRIBUTES = {
    defense: { min: 0, type: Integer,
               formula: lambda { |stats, level|
                 (50 * (stats[:con].to_f / 10) *
                 (1 + (0.2 * level))).floor
               } },

    total_health: { min: 0, type: Integer,
                    formula: lambda { |stats, level|
                      ((stats[:con] - 20) * 100 *
                      (0.5 * (level.to_f / 4)) +
                      (stats[:con].to_f / 8) *
                      (300 * (0.3 * (level.to_f / 2))) +
                      (150 - level)).floor
                    } },

    attack: { min: 0, type: Integer,
              formula: lambda { |stats, level|
                (40 * (stats[:str].to_f / 9) *
                (1 + (0.3 * level.to_f))).floor
              } },

    critical_damage: { min: 0, type: Float,
                       formula: lambda { |stats, level|
                         (1 + (level.to_f / 50) +
                         ((stats[:str].to_f / 500) *
                         level.to_f * 0.05)).round(2)
                       } },

    critical_rate: { min: 0, max: 1, type: Float,
                     formula: lambda { |stats, level|
                       (((level.to_f / 82 * 0.5) +
                       stats[:dex].to_f / 400) * 0.7).round(2)
                     } },

    attack_speed: { min: 0, type: Integer,
                    formula: lambda { |stats, level|
                      ((stats[:dex] * 5) +
                      ((stats[:dex] - 15) * level.to_f * 0.55)).floor
                    } },

    evasion: { min: 0, max: 1, type: Float,
               formula: lambda { |stats, level|
                 ((stats[:dex].to_f / 200) + (level.to_f / 500)).round(2)
               } },

    accuracy: { min: 0, max: 1, type: Float,
                formula: lambda { |stats, level|
                  ((stats[:dex].to_f / 37) + (level / 1000)).round(2)
                } },

    speed: { min: 0, max: 70, type: Integer,
             formula: lambda { |stats, level|
               (20 + ((stats[:dex] - 20) * 2) +
               (level.to_f * 0.1 + stats[:dex].to_f * 0.02)).to_i
             } },

    magic_power: { min: 0, type: Integer,
                   formula: lambda { |stats, level|
                     (40 * (stats[:int].to_f / 6) *
                     (1 + (0.3 * level.to_f))).floor
                   } },

    magic_critical_damage: { min: 0, type: Float,
                             formula: lambda { |stats, level|
                               (1 + (level.to_f / 55) +
                               ((stats[:int].to_f / 490) *
                               level.to_f * 0.06)).round(2)
                             } },

    magic_defense: { min: 0, type: Integer,
                     formula: lambda { |stats, level|
                       (43 * (stats[:men].to_f / 7) *
                       (1 + (0.28 * level.to_f))).floor
                     } },

    total_mana: { min: 0, type: Integer,
                  formula: lambda { |stats, level|
                    ((stats[:men] - 20) * 100 * (0.5 * (level.to_f / 4)) +
                    (stats[:men].to_f / 8) * (300 * (0.2 * (level.to_f / 5))) +
                    (150 - level)).floor
                  } },

    magic_critical_rate: { min: 0, max: 1, type: Float,
                           formula: lambda { |stats, level|
                             (((level.to_f / 82 * 0.5) +
                             stats[:wit].to_f / 400) * 0.4).round(2)
                           } },

    magic_accuracy: { min: 0, max: 1, type: Float,
                      formula: lambda { |stats, level|
                        (((20 + (stats[:wit].to_f / 3)) / 38) +
                        (level.to_f / 400)).round(2)
                      } },

    magic_evasion: { min: 0, max: 1, type: Float,
                     formula: lambda { |stats, level|
                       ((stats[:wit].to_f / 175) +
                       (level.to_f / 400)).round(2)
                     } },

    casting_speed: { min: 0, type: Integer,
                     formula: lambda { |stats, level|
                       ((stats[:wit].to_f * 12.54) +
                       ((stats[:wit].to_f - 20) * 0.65 * level.to_f) +
                       (3 * level.to_f)).floor
                     } },

    # Transient attributes
    health: { min: 0, max: :total_health, type: Integer },
    mana: { min: 0, max: :total_mana, type: Integer }
  }.freeze

  # Initializes the @attributes instance variable with the minimum value for
  # each of the character's attributes. Then, if a stats object is given
  # calculates values for each attribute based on the given stats.
  #
  # @param stats [Stats] A stats object used to calculate attribute values.
  # @param level [Integer] The character's level
  def initialize(stats = nil, level = 1)
    unless stats.is_a?(Stats) || stats.nil?
      raise ArgumentError, 'Expecting `stats` to be an instance of `Stats` '\
                           "but got #{stats.class}"
    end

    unless level.is_a?(Integer)
      raise ArgumentError, 'Expecting `level` to be an Integer but got '\
                           "#{level.class}"
    end

    @attributes = {}
    ATTRIBUTES.each do |attribute, properties|
      @attributes[attribute] = properties[:min]
    end

    calculate_attributes(stats, level, true) if stats
  end

  # Returns the value of the given attribute.
  #
  # @param attribute [Symbol] The attribute's name
  # @return The attribute's value.
  # @raise [ArgumentError] If the given attribute name is not a symbol or is not
  #   the name of a known attribute.
  def [](attribute)
    validate_attribute(attribute)
    @attributes[attribute]
  end

  # Sets the value of the given attribute.
  #
  # @param attribute [Symbol] The attribute's name
  # @param value The attribute's value.
  # @raise [ArgumentError] If the given attribute name is not a symbol or is not
  #   the name of a known attribute or the type of the value parameter is
  #   unacceptable.
  def []=(attribute, value)
    validate_attribute(attribute)
    set_attribute(attribute, value)
  end

  # Recalculate the attributes using the given stats object and level.
  #
  # @param stats [Stats] The stats object.
  # @param level [Integer] The level.
  # @param reset_transient_attributes [Boolean] If true transient attributes
  #   like health and mana will be reset to their maximum.
  def calculate_attributes(stats, level, reset_transient_attributes = false)
    @attributes.keys.each do |attribute|
      next unless ATTRIBUTES[attribute][:formula]

      set_attribute(attribute,
                    ATTRIBUTES[attribute][:formula].call(stats, level))
    end

    return unless reset_transient_attributes

    set_attribute(:health, @attributes[:total_health])
    set_attribute(:mana, @attributes[:total_mana])
  end

  private

  # rubocop:disable Style/GuardClause

  # Validates that the given attribute name is a Symbol and the name of a known
  # attribute.
  #
  # @param attribute [Symbol] The name of the attribute.
  # @raise [ArgumentError] If the given attribute name is not a symbol or is not
  #   the name of a known attribute.
  def validate_attribute(attribute)
    unless attribute.is_a?(Symbol)
      raise ArgumentError,
            "Attribute name expected to be a Symbol, #{attribute.class} given "\
            'instead'
    end

    unless ATTRIBUTES.key?(attribute)
      raise ArgumentError, "Unrecognized attribute #{attribute}"
    end
  end

  # rubocop:enable Style/GuardClause

  # Sets the specified attribute to the given value.
  #
  # @param attribute [Symbol] The attribute to set.
  # @param value The value for the attribute.
  # @return The set value may differ from the value parameter if it was out of
  #   bounds.
  # @raise [ArgumentError] If the type of the value parameter is unacceptable.
  def set_attribute(attribute, value)
    properties = ATTRIBUTES[attribute]

    # Type validation
    if properties[:type] && !value.is_a?(properties[:type])
      raise ArgumentError,
            "Expected #{properties[:type]} but got #{value.class} instead"
    end

    value = validate_limits(properties, value)
    @attributes[attribute] = value

    # Adjust transient attributes if their totals decrease.
    return unless [:total_health, :total_mana].include? attribute

    update_transient_attribute(attribute)
  end

  def update_transient_attribute(attribute)
    transient = attribute.to_s[6..-1].to_sym # Remove "total_"
    return if @attributes[transient] < @attributes[attribute]

    @attributes[transient] = @attributes[attribute]
  end

  # Validates that the given value is within the limits for the attribute.
  #
  # @param properties [Hash] The attribute's properties.
  # @param value The value for the attribute.
  # @return The same value if it was within the limits or the adjusted value if
  #   was not.
  def validate_limits(properties, value)
    # Minimum
    if properties[:min]
      min = limit_value properties, :min
      value = min if value < min
    end

    # Maximum
    if properties[:max]
      max = limit_value properties, :max
      value = max if value > max
    end

    value
  end

  # Returns the specified limit value for the attribute.
  #
  # @param properties [Hash] The attribute's properties.
  # @param limit [Symbol] The limit value to get, either `:min` or `:max`
  # @return The limit value.
  def limit_value(properties, limit)
    attr_limit = properties[limit]
    attr_limit.is_a?(Symbol) ? @attributes[attr_limit] : attr_limit
  end
end

# rubocop:enable Metrics/ClassLength
