require_relative 'character_modifier'

# This class models a character Job. A Job, sometimes referred to as a Class
# determines the main role the character plays in a party (as a nuker, a healer,
# a defensive warrior, support, etc.) This class contains a Stats object which
# determines the bonuses the character gains by playing a particular Job.
#
# NOTE: Originally this class was intended to be named "Class" but that would
# monkey patch Ruby's Class class so let's avoid doing that for now ;)
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class Job < CharacterModifier
end
