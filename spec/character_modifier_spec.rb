# frozen_string_literal: true

require_relative '../character_modifier'

RSpec.describe CharacterModifier do
  describe '#initialize' do
    context 'when no `stats` object is given' do
      it 'raises an exception' do
        message = 'wrong number of arguments (given 0, expected 1)'
        expect { described_class.new }.to raise_error ArgumentError, message
      end
    end

    context 'when something besides an `Stats` object is given' do
      it 'raises an exception' do
        message = '`stats` should be an instance of Stats'
        expect { described_class.new('Hello') }.to raise_error ArgumentError,
                                                               message
      end
    end

    context 'when a valid Stats object is given' do
      let(:stats) { Stats.new(con: 10, str: 8, dex: 6, int: 4, men: 2, wit: 0) }
      subject { described_class.new(stats) }

      it 'has the correct stats' do
        expect(subject.stats[:con]).to eq 10
        expect(subject.stats[:str]).to eq 8
        expect(subject.stats[:dex]).to eq 6
        expect(subject.stats[:int]).to eq 4
        expect(subject.stats[:men]).to eq 2
        expect(subject.stats[:wit]).to eq 0
      end
    end
  end
end
