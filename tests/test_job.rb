require "minitest/autorun"

require_relative "../job"

# Tests suite for the Job class.
#
# Since the Job class is basically a CharacterModifier class all we need to test
# here is that the Job class can be instantiated because all the core tests are
# in the TestCharacterModifier tests suite.
#
# @see TestCharacterModifier
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class TestJob < Minitest::Unit::TestCase

  # Test that the Job class can be instantiated.
  def test_instantiation
    Job.new(Stats.new)
  end
end
