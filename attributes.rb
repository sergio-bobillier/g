require_relative "hash_properties"

# Models the attributes and stats of characters.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class Attributes
  include HashProperties

  # Character attributes with their types, bounds and other constraints. It Also
  # contains a lamda function to calculate the attribute value based on the
  # character stats and level.
  ATTRIBUTES = {
    :defense => {:min => 0, :type => Integer,
      :formula => lambda { |stats, level| (50*(stats.con.to_f/10)*(1+(0.2*level))).floor }
    },
    :total_health => {:min => 0, :type => Integer,
      :formula => lambda { |stats, level| ((stats.con-20)*100*(0.5*(level.to_f/4))+(stats.con.to_f/8)*(300*(0.3*(level.to_f/2)))+(150-level)).floor }
    },
    :attack => {:min => 0, :type => Integer,
      :formula => lambda { |stats, level| (40*(stats.str.to_f/9)*(1+(0.3*level.to_f))).floor }
    },
    :critical_damage => {:min => 0, :type => Float,
      :formula => lambda { |stats, level| (1+(level.to_f/50)+((stats.str.to_f/500)*level.to_f*0.05)).round(2) }
    },
    :critical_rate => {:min => 0, :max => 1, :type => Float,
      :formula => lambda { |stats, level| (((level.to_f/82*0.5)+stats.dex.to_f/400)*0.7).round(2) }
    },
    :evasion => {:min => 0, :max => 1, :type => Float,
      :formula => lambda { |stats, level| ((stats.dex.to_f/200)+(level.to_f/500)).round(2) }
    },
    :accuracy => {:min => 0, :max => 1, :type => Float,
      :formula => lambda { |stats, level| ((stats.dex.to_f/37)+(level/1000)).round(2) }
    },
    :speed => {:min => 0, :max => 70, :type => Integer,
      :formula => lambda { |stats, level| (20+((stats.dex-20)*2)+(level.to_f*0.1+stats.dex.to_f*0.02)).to_i }
    },
    :magic_power => {:min => 0, :type => Integer,
      :formula => lambda { |stats, level| (40*(stats.int.to_f/6)*(1+(0.3*level.to_f))).floor }
    },
    :magic_critical_damage => {:min => 0, :type => Float,
      :formula => lambda { |stats, level| (1+(level.to_f/55)+((stats.int.to_f/490)*level.to_f*0.06)).round(2) }
    },
    :magic_defense => {:min => 0, :type => Integer,
      :formula => lambda { |stats, level| (43*(stats.men.to_f/7)*(1+(0.28*level.to_f))).floor }
    },
    :total_mana => {:min => 0, :type => Integer,
      :formula => lambda { |stats, level| ((stats.men-20)*100*(0.5*(level.to_f/4))+(stats.men.to_f/8)*(300*(0.2*(level.to_f/5)))+(150-level)).floor }
    },
    :magic_critical_rate => {:min => 0, :max => 1, :type => Float,
      :formula => lambda { |stats, level| (((level.to_f/82*0.5)+stats.wit.to_f/400)*0.4).round(2) }
    },
    :magic_accuracy => {:min => 0, :max => 1, :type => Float,
      :formula => lambda { |stats, level| (((20+(stats.wit.to_f/3))/38)+(level.to_f/400)).round(2) }
    },
    :magic_evasion => {:min => 0, :max => 1, :type => Float,
      :formula => lambda { |stats, level| ((stats.wit.to_f/175)+(level.to_f/400)).round(2) }
    },
    :casting_speed => {:min => 0, :type => Integer,
      :formula => lambda { |stats, level| ((stats.wit.to_f*12.54)+((stats.wit.to_f-20)*0.65*level.to_f)+(3*level.to_f)).floor }
    },

    # Transient attributes
    :health => {:min => 0, :max => :total_health, :type => Integer},
    :mana => {:min => 0, :max => :total_mana, :type => Integer}
  }

  # Initializes the @attributes instance variable with the minimum value for
  # each of the character's attributes. Then, if a stats object is given
  # calculates values for each attribute based on the given stats.
  #
  # @param stats [Stats] A stats object used to calculate attribute values.
  # @param level [Integer] The character's level
  def initialize(stats = nil, level = 1)
    raise ArgumentError.new("Expecting Stats but got #{stats.class}") unless stats.is_a?(Stats) || stats.nil?
    raise ArgumentError.new("Expecting an Integer but got #{level.class}") unless level.is_a?(Integer)

    @attributes = {};
    ATTRIBUTES.each do |attribute, properties|
      @attributes[attribute] = properties[:min]
    end

    calculate_attributes(stats, level, true) if stats
  end

  # Called by Ruby when a non-existing method is invoked. The function calls the
  # hash_properties method to try and find a matching key in the attributes
  # array and calls the set_attribute method if it finds it.
  #
  # @param method [Symbol] The called method's name
  # @param args [Array] The parameters passed to the method.
  def method_missing(method, *args)
    hash_properties(@attributes, method, args) do |attribute, value|
      set_attribute(attribute, value)
    end
  end

  # Recalculate the attributes using the given stats object and level.
  #
  # @param stats [Stats] The stats object.
  # @param level [Integer] The level.
  # @param reset_transient_attributes [Boolean] If true transient attributes
  #   like health and mana will be reset to their maximum.
  def calculate_attributes(stats, level, reset_transient_attributes = false)
    @attributes.each do |attribute, value|
      next unless ATTRIBUTES[attribute][:formula]
      set_attribute(attribute, ATTRIBUTES[attribute][:formula].call(stats, level))
    end

    if reset_transient_attributes
      set_attribute(:health, @attributes[:total_health])
      set_attribute(:mana, @attributes[:total_mana])
    else
      if @attributes[:health] > @attributes[:total_health]
        @attributes[:health] = @attributes[:total_health]
      end
      if @attributes[:mana] > @attributes[:total_mana]
        @attributes[:mana] = @attributes[:total_mana]
      end
    end
  end

  private

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
      raise ArgumentError.new("Expected #{properties[:type]} but got #{value.class} instead")
    end

    # Minimum
    if properties[:min]
      min = (properties[:min].is_a?(Symbol) ? @attributes[properties[:min]] : properties[:min])
      value = min if value < min
    end

    # Maximum
    if properties[:max]
      max = (properties[:max].is_a?(Symbol) ? @attributes[properties[:max]] : properties[:max])
      value = max if value > max
    end

    @attributes[attribute] = value

    # Adjust transient attributes if their totals decrease.
    if attribute == :total_health || attribute == :total_mana
      transient = attribute.to_s[6..-1].to_sym                 # Remove "total_"
      if @attributes[transient] > @attributes[attribute]
        @attributes[transient] = @attributes[attribute]
      end
    end
  end
end
