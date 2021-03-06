# frozen_string_literal: true

require_relative 'stats'

# This is the base class for the classes that modify the basic stats of
# characters such as a Race or a Job.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class CharacterModifier
  # @return [Stats] The stats object associated with the modifier.
  attr_reader :stats

  # Initializes the @stats object.
  def initialize(stats)
    unless stats.is_a?(Stats)
      raise ArgumentError, '`stats` should be an instance of Stats'
    end

    @stats = stats
  end
end
