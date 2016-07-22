require "minitest/autorun"
require_relative "../stats"

class TestStats < Minitest::Test
  # Checks that the class initializer works properly under various
  # circumstances
  def test_initializer
    # Non-existing stat
    assert_raises ArgumentError do
      Stats.new(:ukn => 10)
    end

    # Not a symbol
    assert_raises ArgumentError do
      Stats.new("con" => 12)
    end

    # Non integer value
    assert_raises ArgumentError do
      Stats.new(:wit => "hello")
    end

    # Default values
    stats = Stats.new
    assert_equal(20, stats[:int], "Intelligence should be at 20 after initialization")
    assert_equal(20, stats[:str], "Strength should be at 20 after initialization")

    # Overriding values for certain stats
    stats = Stats.new({:men => 10, :dex => 5})
    assert_equal(20, stats[:int], "Intelligence should be at 20 after initialization")
    assert_equal(20, stats[:str], "Strength should be at 20 after initialization")
    assert_equal(10, stats[:men], "Mental Strength should be at 20 after initialization")
    assert_equal(5, stats[:dex], "Dexterity should be at 20 after initialization")
  end

  # Tests that the stat class's getters and setters work and that values are not
  # allowed to get out of bounds.
  def test_setters
    stats = Stats.new

    assert_raises ArgumentError do
      stats[:con] = "hello"              # Non integer value
    end

    stats[:con] = 10
    assert_equal(10, stats[:con], "Constitution should be at 10")

    stats[:dex] = -1
    assert_equal(0, stats[:dex], "Dexterity should be at 0")

    stats[:wit] = Stats::MAX_STATS + 1
    assert_equal(Stats::MAX_STATS, stats[:wit], "Wisdom should be at #{Stats::MAX_STATS}")

    orig = stats[:str]
    stats[:str] += 5
    stats[:str] -= 2
    assert_equal(orig + 3, stats[:str], "Stats should be mutable")
  end

  # Test that one or more Stats objects can be added to another Stats object and
  # that the resulting values are correctly calculated.
  def test_merge
    stats = Stats.new

    assert_raises ArgumentError do
      stats << "Hello"                  # Not a Stats instance.
    end

    stats2 = Stats.new({:str => 5, :int => 10, :men => 8, :wit => 0})

    stats << stats2
    assert_equal(25, stats[:str], "Strength should be at 25")
    assert_equal(30, stats[:int], "Intelligence should be at 25")
    assert_equal(28, stats[:men], "Mental Strength should be 28")
    assert_equal(20, stats[:wit], "Wisdom should be 20")
    assert_equal(40, stats[:dex], "Dexterity should be 20")

    stats = Stats.new
    stats2 = Stats.new(:men => 5, :wit => 5, :int => 5, :str => 0)
    stats3 = Stats.new(:men => 2, :wit => 0, :int => -5, :str => 10)

    stats << stats2 << stats3
    assert_equal(27, stats[:men], "Mental Strength should be 25")
    assert_equal(25, stats[:wit], "Wisdom should be 25")
    assert_equal(25, stats[:int], "Intelligence should be 25")
    assert_equal(30, stats[:str], "Strength should be 30")
  end

  # Tests that the "+" method in the stats class create a new instance of Stats
  # whose values are the sum of the values of the operands.
  def test_addition
    s1 = {:con => 1, :str => 2, :dex => 3, :int => 5, :men => 7, :wit => 11}
    s2 = {:con => 1, :str => 1, :dex => 2, :int => 3, :men => 5, :wit => 8}

    stats1 = Stats.new(s1)
    stats2 = Stats.new(s2)
    stats3 = stats1 + stats2
    stats4 = stats1 + stats1

    refute_equal(stats1, stats3, "The result should be a new instance of Stats")
    refute_equal(stats2, stats3, "The result should be a new instance of Stats")

    s1.each do |stat, value|
      assert_equal(s1[stat], stats1[stat], "Original stats should not be modified")
      assert_equal(s2[stat], stats2[stat], "Original stats should not be modified")

      expected = s1[stat] + s2[stat]
      assert_equal(expected, stats3[stat], "The sum for #{stat} should give #{expected}")

      expected = s1[stat] * 2
      assert_equal(expected, stats4[stat], "The sum for #{stat} when added to itself should be #{expected}")
    end
  end

  # Tests the following:
  #
  # * That listeners get called when a stat changes.
  # * That nothing is raised even is something besides a Proc is added to the
  #   listeners array
  # * That listeners are not called if the stat value doesn't change.
  # * That listeners are called AFTER the value has been set.
  def test_listeners
      called = false

      stats = Stats.new
      stats.change_listeners << lambda { |stat, currentValue, newValue| called = true }
      stats[:str] += 2

      assert_equal(true, called, "Listener should have been called")

      stats = Stats.new
      stats.change_listeners << "hello"
      stats[:men] += 10

      stats = Stats.new
      stats.change_listeners << lambda { |stat, currentValue, newValue|
        raise Exception.new("Listeners should not be called if the value doesn't change")
      }

      stats[:wit] = 20

      stats = Stats.new
      stats.change_listeners << lambda { |stat, currentValue, newValue|
        assert_equal(30, stats[:con], "Listeners should be called AFTER the value has been set")
      }

      stats[:con] = 30
  end
end
