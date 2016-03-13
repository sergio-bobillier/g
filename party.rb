require_relative "exceptions/character_already_in_party_exception"
require_relative "exceptions/character_not_found_exception"
require_relative "exceptions/party_full_exception"

# Represents a Characters party.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class Party
  # Maximum size for party
  MAX_SIZE = 8

  # @return [Character] The current party leader
  attr_reader :leader

  # Creates a new party.
  #
  # @param characters [Character|Array<Character>] A Character or an array of
  #   Characters from wich to build the party.
  def initialize(characters = nil)
    if characters
      unless characters.is_a?(Array) || characters.is_a?(Character)
        raise ArgumentError.new("A party can only be created from an array of characters or an individual character")
      end

      if characters.is_a?(Array)
        unless characters.length <= MAX_SIZE
          raise ArgumentError.new("Party size cannot exceed #{MAX_SIZE} characters")
        end

        # Check that the array is comprised of characters and that none of them
        # is already in another party.
        characters.each do |character|
          raise ArgumentError.new("All array items must be characters") unless character.is_a?(Character)
          raise CharacterAlreadyInPartyException.new if character.party
        end

        # Checks that no character is repeated in the array
        unless characters.length == characters.uniq.length
          raise CharacterAlreadyInPartyException.new
        end

        characters.each { |character| character.party = self }
        @characters = characters.clone
        @leader = characters[0]
      else
        if characters.party
          raise CharacterAlreadyInPartyException.new
        end

        characters.party = self
        @characters = [characters]
        @leader = characters
      end
    else
      @characters = []
    end
  end

  # @return [Array] A copy of the party's caracters array.
  def characters
    @characters.clone
  end

  # @return [Integer] The size of the party.
  def length
    @characters.length
  end

  # @return [Boolean] True if the party is empty, false otherwise
  def empty?
    @characters.empty?
  end

  # Adds a character to the party.
  #
  # @param character [Character] The character
  # @raise [ArgumentError] If the given object is not a Character.
  # @raise [PartyFullException] If the party is full.
  # @raise [CharacterAlreadyInPartyException] If the character is already in a
  #   party.
  def <<(character)
    unless character.is_a?(Character)
      raise ArgumentError.new("Only characters can be added to a party")
    end

    unless length < MAX_SIZE
      raise PartyFullException.new
    end

    if character.party
      raise CharacterAlreadyInPartyException.new
    end

    character.party = self
    @characters << character
    @leader = character if @characters.length == 1
    return self
  end

  # Removes the given charater from the party.
  #
  # @param character [Character] The character to be removed.
  # @return [Character|nil] The removed character or nil if the character was
  #   not a member of the party.
  def remove(character)
    removed_character = @characters.delete character
    if removed_character
      removed_character.party = nil
    end

    if removed_character == @leader
      if @characters.length > 0
        @leader = @characters[0]
      else
        @leader = nil
      end
    end

    return removed_character
  end

  # Removes the given character from the party. If the character is not in the
  # party the function will throw a CharacterNotFoundException.
  #
  # @param character [Character] The character to be removed.
  # @return [Character] The removed character
  # @raise [CharacterNotFoundException] If the character is not a member of the
  #   party.
  def remove!(character)
    removed_character = remove(character)
    unless removed_character
      raise CharacterNotFoundException.new
    end

    return removed_character
  end

  # @return [Boolean] True if the given character is a member of the party,
  #   false otherwise.
  def include?(character)
    @characters.include?(character)
  end

  # Sets the party leader.
  #
  # @param character [Character] The character to be appointed as party leader.
  def leader=(character)
    unless character.is_a?(Character)
      raise ArgumentError.new("`character` must be an instance of Character")
    end

    unless @characters.include?(character)
      raise CharacterNotFoundException.new("The character is not a party member")
    end

    @leader = character
  end
end
