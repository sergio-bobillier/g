require "minitest/autorun"
require_relative "../stats"

class TestStats < Minitest::Unit::TestCase
  # Checks that the class initializer works properly under various
  # circumstances
  def test_initializer
    # Non-existing stat
    assert_raises ArgumentError do
      Stats.new(:ukn => 10)
    end

    # Non integer value
    assert_raises ArgumentError do
      Stats.new(:wit => "hello")
    end

    # Default values
    stats = Stats.new
    assert_equal(20, stats.int, "Intelligence should be at 20 after initialization")
    assert_equal(20, stats.str, "Strength should be at 20 after initialization")

    # Overriding values for certain stats
    stats = Stats.new({:men => 10, :dex => 5})
    assert_equal(20, stats.int, "Intelligence should be at 20 after initialization")
    assert_equal(20, stats.str, "Strength should be at 20 after initialization")
    assert_equal(10, stats.men, "Mental Strength should be at 20 after initialization")
    assert_equal(5, stats.dex, "Dexterity should be at 20 after initialization")
  end

  # Tests that the stat class's getters and setters work and that values are not
  # allowed to get out of bounds.
  def test_setters
    stats = Stats.new

    assert_raises ArgumentError do
      stats.con = "hello"              # Non integer value
    end

    stats.con = 10
    assert_equal(10, stats.con, "Constitution should be at 10")

    stats.dex = -1
    assert_equal(0, stats.dex, "Dexterity should be at 0")

    stats.wit = Stats::MAX_STATS + 1
    assert_equal(Stats::MAX_STATS, stats.wit, "Wisdom should be at #{Stats::MAX_STATS}")

    orig = stats.str
    stats.str += 5
    stats.str -= 2
    assert_equal(orig + 3, stats.str, "Stats should be mutable")
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
    assert_equal(25, stats.str, "Strength should be at 25")
    assert_equal(30, stats.int, "Intelligence should be at 25")
    assert_equal(28, stats.men, "Mental Strength should be 28")
    assert_equal(20, stats.wit, "Wisdom should be 20")
    assert_equal(40, stats.dex, "Dexterity should be 20")

    stats = Stats.new
    stats2 = Stats.new(:men => 5, :wit => 5, :int => 5, :str => 0)
    stats3 = Stats.new(:men => 2, :wit => 0, :int => -5, :str => 10)

    stats << stats2 << stats3
    assert_equal(27, stats.men, "Mental Strength should be 25")
    assert_equal(25, stats.wit, "Wisdom should be 25")
    assert_equal(25, stats.int, "Intelligence should be 25")
    assert_equal(30, stats.str, "Strength should be 30")
  end
end
