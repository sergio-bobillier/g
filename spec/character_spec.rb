# frozen_string_literal: true

require_relative '../character'
require_relative '../party'
require_relative 'support/races'
require_relative 'support/jobs'
require_relative 'support/crystals'

RSpec.shared_context 'Default character' do
  subject { described_class.new(blank_race) }
end

RSpec.shared_context 'Character and party' do
  subject { described_class.new(blank_race) }
  let(:other_character) { described_class.new(blank_race) }
end

RSpec.shared_context 'With a Crystal already bound' do
  before { subject.bind_crystal(water_crystal) }
end

RSpec.shared_examples 'Level out of bounds' do |level|
  it 'raises an error' do
    error = ArgumentError
    message = "`level` must be between 1 and #{described_class::MAX_LEVEL}"

    expect do
      described_class.new(blank_race, level)
    end.to raise_error(error, message)
  end
end

RSpec.shared_examples 'level and next_level' do |level, next_level|
  it "is in level #{level} and next_level should be#{next_level}" do
    expect(subject.level).to eq(level)
    expect(subject.next_level).to eq(next_level)
  end
end

RSpec.shared_examples '0 experience' do
  it { expect(subject.experience).to eq 0 }
end

RSpec.shared_examples 'next_level value' do |next_level|
  it { expect(subject.next_level).to eq next_level }
end

RSpec.shared_examples "alters the stats' values" do |stats_values|
  it "alters the stats' values" do
    [:con, :str, :dex, :int, :men, :wit].each do |stat|
      expect(subject.stats[stat]).to eq(stats_values[stat])
    end
  end
end

RSpec.shared_examples "alters the attributes' values" do |attribute_values|
  it "alters the attributes' values" do
    attribute_values.each do |attribute, value|
      expect(subject.attributes[attribute]).to eq(value)
    end
  end
end

RSpec.describe Character do
  include_context 'Blank Race'

  let(:another_character) { described_class.new(blank_race) }

  describe '#initialize' do
    context 'When no race is given' do
      it 'raises an error' do
        expect { described_class.new }.to raise_error ArgumentError
      end
    end

    context 'When an invalid race is given' do
      it 'raises an error' do
        error = ArgumentError
        message = 'race should be an instance of `Race`'
        expect { described_class.new('h') }.to raise_error(error, message)
      end
    end

    context 'when a specific race is given' do
      include_context 'Basic Race'
      subject { described_class.new(basic_race) }

      include_examples "alters the stats' values",
                       con: 25, str: 25, dex: 25, int: 25, men: 25, wit: 25

      include_examples "alters the attributes' values",
                       defense: 150,
                       attack: 144,
                       critical_rate: 0.05,
                       attack_speed: 130,
                       magic_power: 216,
                       magic_defense: 196,
                       magic_critical_rate: 0.03
    end

    context 'when no level is given' do
      include_context 'Default character'
      include_examples 'level and next_level', 1, described_class::BASE_EXP
    end

    context 'when the given level is not an integer' do
      it 'raises an error' do
        error = ArgumentError
        message = '`level` must be an Integer'

        expect do
          described_class.new(blank_race, 'h')
        end.to raise_error(error, message)
      end
    end

    context 'when the given level is less than 1' do
      include_examples 'Level out of bounds', 0
    end

    context 'when the given level is greater than MAX_LEVEL' do
      include_examples 'Level out of bounds', described_class::MAX_LEVEL + 1
    end

    context 'when an specified level is given' do
      subject { described_class.new(blank_race, 5) }
      include_examples 'level and next_level', 5, 505
    end

    context 'when the maximum level is given' do
      subject { described_class.new(blank_race, described_class::MAX_LEVEL) }
      include_examples 'level and next_level', described_class::MAX_LEVEL,
                       42_329_445_661
    end

    context 'when an invalid job is given' do
      it 'raises an error' do
        message = '`job` muest be an instance of Job or `nil`'
        expect { described_class.new(blank_race, 1, 'hello') }
          .to raise_error ArgumentError, message
      end
    end

    context 'when a job is given' do
      include_context 'Basic Race'
      include_context 'Basic Job'

      subject { described_class.new(basic_race, 1, basic_job) }

      include_examples "alters the stats' values",
                       con: 30, str: 30, dex: 30, int: 30, men: 30, wit: 30

      include_examples "alters the attributes' values",
                       total_health: 442,
                       critical_damage: 1.02,
                       critical_rate: 0.06,
                       attack_speed: 158,
                       magic_power: 260,
                       magic_defense: 235,
                       magic_evasion: 0.17
    end

    it 'triggers the attributes calculation' do
      expect_any_instance_of(Attributes).to receive(:calculate_attributes)
      described_class.new(blank_race)
    end
  end

  describe '#leave_party' do
    include_context 'Default character'

    context 'when the character is not a member of a party' do
      it 'raises an error' do
        error = CharacterNotInParty
        message = 'Character not currently in party'

        expect { subject.leave_party }.to raise_error(error, message)
      end
    end

    context 'when the character is not a member of the party assigned to it' do
      include_context 'Character and party'
      let(:party) { Party.new [other_character, another_character] }

      before do
        subject.party = party
      end

      it 'raises an error' do
        error = CharacterNotFound
        message = 'Character not in party'

        expect { subject.leave_party }.to raise_error(error, message)
      end
    end

    context 'when the character is a party member' do
      include_context 'Character and party'

      before do
        Party.new [subject, other_character]
      end

      it 'withdraws the character from the party' do
        expect(subject.party).not_to be_nil
        expect { subject.leave_party }.to change(subject, :party).to(nil)
      end
    end
  end

  describe '#experience' do
    include_context 'Default character'

    context 'when the character is created' do
      include_examples '0 experience'
    end

    context 'when the character level is set' do
      before do
        subject.experience += 10
        subject.level = 2
      end

      include_examples '0 experience'
    end
  end

  describe 'experience=' do
    include_context 'Default character'

    context 'when the parameter is not an integer' do
      it 'raises an error' do
        message = '`experience` should be an integer'

        expect do
          subject.experience = 'Hello'
        end.to raise_error ArgumentError, message
      end
    end

    context 'when the argument is less than `next_level`' do
      it 'does not change the level' do
        exp = described_class::BASE_EXP / 10
        expect { subject.experience = exp }.not_to change(subject, :level)
      end
    end

    context 'when the argument is greater than `next_level`' do
      before do
        subject.experience = subject.next_level - 10
      end

      it "increases the character's level and adds the remaining" do
        expect { subject.experience += 20 }
          .to change(subject, :level).by(1)
          .and change(subject, :experience).to(10)
      end
    end

    context 'when the argument is negative and the level is greater than 1' do
      before do
        subject.level = 2
        subject.experience = 10
      end

      it "decreses the character's level and substracts the remaining" do
        expect { subject.experience -= 20 }.to change(subject, :level).by(-1)
          .and change(subject, :experience).to(described_class::BASE_EXP - 10)
      end
    end

    context 'when the argument is negative and big' do
      before do
        subject.level = 3
        subject.experience = 110
      end

      it "decreases the character's level but never below level 1" do
        exp = subject.next_level * 4
        expect { subject.experience -= exp }.to change(subject, :level).to(1)
          .and change(subject, :experience).to(0)
      end
    end

    context 'when the argument is big enough to increase multiple levels' do
      it "increses the character's level and adds the remining" do
        expect { subject.experience += 5000 }.to change(subject, :level).to(9)
          .and change(subject, :experience).to(89)
      end
    end

    context 'when the argument is a big negative number' do
      before { subject.level = 10 }

      it "decreases the character's level and substracts the remaining" do
        expect { subject.experience -= 5000 }.to change(subject, :level).to(7)
          .and change(subject, :experience).to(390)
      end
    end

    context 'when the argument is really big' do
      before { subject.level = described_class::MAX_LEVEL - 1 }

      it "increases the characters's level but never past the level cap" do
        exp = subject.next_level * 4
        level_cap = described_class::MAX_LEVEL
        next_level = (subject.next_level * 1.5).floor

        expect { subject.experience += exp }
          .to change(subject, :level).to(level_cap)
          .and change(subject, :experience).to(next_level)
      end
    end

    it 'triggers the attributes recalculation when the level changes' do
      subject.level = 2
      expect_any_instance_of(Attributes).to receive(:calculate_attributes)
      subject.experience = subject.next_level + 1
    end
  end

  describe '#next_level' do
    include_context 'Default character'

    context 'when the character is created' do
      include_examples 'next_level value', described_class::BASE_EXP
    end

    context 'when the character level is set' do
      before { subject.level = 10 }
      include_examples 'next_level value', 3829
    end

    context 'when the character level is decreased' do
      before do
        subject.level = 10
        subject.level = 6
      end

      include_examples 'next_level value', 757
    end
  end

  describe '#stats' do
    include_context 'Default character'

    context 'when the character is created' do
      it 'returns a `Stats` object' do
        expect(subject.stats).to be_a Stats
      end
    end

    it 'allows individual stats to be changed' do
      expect { subject.stats[:wit] += 5 }
        .to change { subject.stats[:wit] }.by(5)
    end

    it 'triggers the attributes recalculation when the stats change' do
      subject.level = 2
      expect_any_instance_of(Attributes).to receive(:calculate_attributes)
      subject.stats[:con] += 2
    end
  end

  describe '#stats=' do
    include_context 'Default character'

    it 'does not allow direct assignment' do
      expect { subject.stats = nil }.to raise_error NameError
    end
  end

  describe '#attributes' do
    include_context 'Default character'

    context 'when the character is created' do
      it 'returns an `Attributes` object' do
        expect(subject.attributes).to be_an Attributes
      end
    end

    it 'allows individual attributes to be changed' do
      expect { subject.attributes[:attack_speed] += 10 }
        .to change { subject.attributes[:attack_speed] }.by(10)
    end
  end

  describe '#attributes=' do
    include_context 'Default character'

    it 'does not allow direct assignment' do
      expect { subject.attributes = nil }.to raise_error NameError
    end
  end

  describe '#level=' do
    include_examples 'Default character'

    # Call subject so that the class is instantiated before
    # expect_any_instance_of is called, otherwise the test will fail because
    # calculate_attributes will be called twice.
    before { subject }

    it 'triggers the attributes calculation on level change' do
      expect_any_instance_of(Attributes).to receive(:calculate_attributes)
      subject.level = 10
    end
  end

  describe '#race' do
    subject { described_class.new(blank_race) }

    it 'returns the race the character was created with' do
      expect(subject.race).to eq(blank_race)
    end
  end

  describe '#race=' do
    include_examples 'Default character'

    it 'does not allow the race to be changed after charater creation' do
      expect { subject.race = Races::DARK_ELF }.to raise_error NameError
    end
  end

  describe '#job' do
    context 'when no job is given on character creation' do
      subject { described_class.new(blank_race, 1) }

      it 'returns `nil`' do
        expect(subject.job).to be_nil
      end
    end
  end

  describe '#job=' do
    include_context 'Basic Job'

    subject { described_class.new(blank_race) }

    context 'when something besides a job is given as argument' do
      it 'raises an error' do
        expect { subject.job = 'hello' }.to raise_error ArgumentError
      end
    end

    context 'when a valid job is given' do
      it "changes the character's job to the given one" do
        expect { subject.job = basic_job }.to change(subject, :job)
          .to(basic_job)
      end
    end

    context 'when a job is set or changed' do
      it 're-calculates the character attributes' do
        expect { subject.job = basic_job }
          .to change { subject.attributes[:total_health] }.to(352)
          .and change { subject.attributes[:critical_rate] }.to(0.05)
          .and change { subject.attributes[:attack_speed] }.to(130)
          .and change { subject.attributes[:magic_power] }.to(216)
          .and change { subject.attributes[:magic_defense] }.to(196)
          .and change { subject.attributes[:magic_evasion] }.to(0.15)
      end

      it 'should NOT reset transient attributes' do
        expect { subject.job = basic_job }
          .not_to(change { subject.attributes[:health] })
      end
    end

    context 'when the job is set to `nil`' do
      subject { described_class.new(blank_race, 1, basic_job) }

      it 'removes the job' do
        expect { subject.job = nil }.to change(subject, :job).to nil
      end

      it 'triggers the attribute re-calculation' do
        expect { subject.job = nil }
          .to change { subject.attributes[:total_health] }.to(261)
          .and change { subject.attributes[:critical_rate] }.to(0.04)
          .and change { subject.attributes[:attack_speed] }.to(102)
          .and change { subject.attributes[:magic_power] }.to(173)
          .and change { subject.attributes[:magic_defense] }.to(157)
          .and change { subject.attributes[:magic_evasion] }.to(0.12)
      end
    end
  end

  describe '#crystals' do
    subject { described_class.new(blank_race) }

    context 'when the character is created' do
      it 'returns an empty array' do
        expect(subject.crystals).to be_an Array
        expect(subject.crystals).to be_empty
      end
    end

    it 'returns a copy of the crystal array' do
      crystals = subject.crystals
      expect { crystals << 'Crystal' }.not_to(change { subject.crystals.size })
    end
  end

  describe '#bind_crystal' do
    include_context 'Crystals'

    subject { described_class.new(blank_race) }

    it 'binds the crystal to the character' do
      expect { subject.bind_crystal(water_crystal) }
        .to change { subject.crystals.length }.to(1)
        .and change { subject.crystals[0] }.to(water_crystal)
        .and change { water_crystal.bound_to }.to(subject)
    end

    context 'at level 1' do
      include_context 'With a Crystal already bound'

      context 'when an attempt is made to bind another crystal' do
        it 'raises an error' do
          expect { subject.bind_crystal(fire_crystal) }
            .to raise_error(LevelTooLowForCrystalBinding)
        end
      end
    end

    context 'at a higher level' do
      subject { described_class.new(blank_race, Character::MAX_LEVEL) }

      include_context 'With a Crystal already bound'

      context 'when an attempt is made to' do
        context 'bind the same crystal' do
          it 'raises an error' do
            expect { subject.bind_crystal(water_crystal) }
              .to raise_error(CrystalAlreadyBound)
          end
        end

        context 'bind a crystal with the same element' do
          it 'raises an error' do
            expect { subject.bind_crystal(ice_crystal) }
              .to raise_error(SameElementCrystalAlreadyBound)
          end
        end

        context 'bind more than three crystals' do
          before do
            subject.bind_crystal(fire_crystal)
            subject.bind_crystal(earth_crystal)
          end

          it 'raises an error' do
            expect { subject.bind_crystal(wind_crystal) }
              .to raise_error(CrystalLimitReached)
          end
        end

        context 'bind the same crystal to another character' do
          it 'raises an error' do
            expect { another_character.bind_crystal(water_crystal) }
              .to raise_error(CrystalAlreadyBound)
          end
        end
      end
    end
  end
end
