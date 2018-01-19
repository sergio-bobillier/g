require_relative '../job'

# This module contains constants with all the available jobs. Usually these
# would be loaded from a database but since this a conceptual game I want to
# keep it as simple as possible.
#
# @author Sergio Bobillier C. <sergio.bobillier@gmail.com>
module Jobs
  WIZARD = Job.new(Stats.new(con: 0, str: 0, dex: 0, int: 5, men: 1, wit: 3))
  KNIGHT = Job.new(Stats.new(con: 5, str: 2, dex: 0, int: 0, men: 2, wit: 0))
  PRIEST = Job.new(Stats.new(con: 0, str: 0, dex: 0, int: 0, men: 3, wit: 3))
  ROGUE = Job.new(Stats.new(con: 0, str: 2, dex: 5, int: 0, men: 0, wit: 0))
  ARCHER = Job.new(Stats.new(con: 0, str: 2, dex: 3, int: 0, men: 0, wit: 0))
  MONK = Job.new(Stats.new(con: 3, str: 3, dex: 1, int: 0, men: 1, wit: 0))
end
