# frozen_string_literal: true

require_relative '../job'
require_relative 'support/character_modifier_behavior'

RSpec.describe Job do
  it_behaves_like 'a CharacterModifier'
end
