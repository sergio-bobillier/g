# frozen_string_literal: true

require_relative '../character_modifier'
require_relative 'support/character_modifier_behavior.rb'

RSpec.describe CharacterModifier do
  it_behaves_like 'a CharacterModifier'
end
