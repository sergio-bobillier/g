require_relative 'exceptions/character_already_in_party_exception'
require_relative 'exceptions/character_not_found_exception'
require_relative 'exceptions/party_has_dispersed_exception'
require_relative 'exceptions/party_full_exception'

# rubocop:disable Style/RedundantReturn

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
  # @param characters [Array<Character>] An array of Characters.
  def initialize(characters)
    unless characters.is_a?(Array)
      raise ArgumentError,
            'A party can only be created from an array of characters'
    end

    unless characters.length >= 2
      raise ArgumentError,
            'Parties should be compraised of at least two characters'
    end

    unless characters.length <= MAX_SIZE
      raise ArgumentError, "Party size cannot exceed #{MAX_SIZE} characters"
    end

    validate_characters(characters)

    characters.each { |character| character.party = self }
    @characters = characters.clone
    @leader = characters[0]
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
  # @raise [PartyHasDispersedException] If the party has dispersed.
  # @raise [PartyFullException] If the party is full.
  # @raise [CharacterAlreadyInPartyException] If the character is already in a
  #   party.
  def <<(character)
    raise PartyHasDispersedException if @dispersed

    unless character.is_a?(Character)
      raise ArgumentError, 'Only characters can be added to a party'
    end

    raise PartyFullException unless @characters.length < MAX_SIZE
    raise CharacterAlreadyInPartyException if character.party

    character.party = self
    @characters << character
    return self
  end

  # Removes the given charater from the party.
  #
  # @param character [Character] The character to be removed.
  # @return [Character|nil] The removed character or nil if the character was
  #   not a member of the party.
  def remove(character)
    removed_character = @characters.delete character
    removed_character.party = nil if removed_character

    if @characters.length == 1
      @characters[0].leave_party
      @dispersed = true
    end

    @leader = @characters[0] if removed_character == @leader && @characters.any?
    return removed_character
  end

  # Removes the given character from the party. If the character is not in the
  # party the function will raise a CharacterNotFoundException.
  #
  # @param character [Character] The character to be removed.
  # @return [Character] The removed character
  # @raise [CharacterNotFoundException] If the character is not a member of the
  #   party.
  def remove!(character)
    removed_character = remove(character)
    raise CharacterNotFoundException unless removed_character
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
      raise ArgumentError, '`character` must be an instance of Character'
    end

    unless @characters.include?(character)
      raise CharacterNotFoundException, 'The character is not a party member'
    end

    @leader = character
  end

  # @return [Boolean] True if the party has dispersed, false otherwise
  def dispersed?
    @dispersed == true
  end

  private

  # Validates that the given characters array contains only objects of the
  # Character class, that none of those characters are already in a party and
  # that there are no repeated characters in the array.
  #
  # @param [Array<Character>] The array of characters.
  # @raise [ArgumentError] If anything else but Characters is found in the
  #   array.
  # @raise [CharacterAlreadyInPartyException] If any of the characters is
  #   already in party or if there are duplicated elements in the array.
  def validate_characters(characters)
    characters.each do |character|
      unless character.is_a?(Character)
        raise ArgumentError, 'All array items must be characters'
      end

      raise CharacterAlreadyInPartyException if character.party
    end

    # rubocop:disable Style/GuardClause

    # Checks that no character is repeated in the array
    unless characters.length == characters.uniq.length
      raise CharacterAlreadyInPartyException
    end
  end
end
