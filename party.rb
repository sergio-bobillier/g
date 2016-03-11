require_relative "exceptions/character_already_in_party_exception"
require_relative "exceptions/character_not_found_exception"
require_relative "exceptions/party_full_exception"

# Represents a Characters party.
#
# @author Sergio Bobillier <sergio.bobillier@gmail.com>
class Party
  # Maximum size for party
  MAX_SIZE = 8

  # Creates a new party.
  #
  # @param characters [Character|Array<Character>] An Character or an array of
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
      else
        if characters.party
          raise CharacterAlreadyInPartyException.new
        end

        characters.party = self
        @characters = [characters]
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
    return nil
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
end
