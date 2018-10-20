# frozen_string_literal: true

require_relative '../crystal'

require 'byebug'

RSpec.shared_examples 'correctly calculates the AP required to reach level 2' do
  it 'correctly calculates the AP required to reach level 2' do
    required_ap = (described_class::BASE_AP * 1.5).to_i
    expect(subject.next_level).to eq required_ap
  end
end

RSpec.shared_examples 'the crystal levels up' do
  it 'causes the `Crystal` to level up' do
    expect { subject.ap = ap_value }.to change { subject.level }.by 1
  end
end

RSpec.describe Crystal do
  describe '#initialize' do
    context 'when no element is provided' do
      it 'raises an error' do
        message = 'wrong number of arguments (given 0, expected 1..2)'
        expect { described_class.new }.to raise_error ArgumentError, message
      end
    end

    context 'when the provided element is not a symbol' do
      it 'raises an error' do
        message = '`element` should be a Symbol. String given'
        expect { described_class.new('dark') }
          .to raise_error ArgumentError, message
      end
    end

    context 'when the provided element is not a known element' do
      it 'raises an error' do
        message = '`element` should be a valid element'
        expect { described_class.new(:lightning) }
          .to raise_error ArgumentError, message
      end
    end

    context 'when the crystal is created without specifying a level' do
      subject { described_class.new(:earth) }

      it('sets the level to 1') { expect(subject.level).to eq 1 }

      it('corrently sets the AP required to reach the next level') do
        expect(subject.next_level).to eq described_class::BASE_AP
      end
    end

    context 'when a level is specified on crystal creation' do
      subject { described_class.new(:earth, 5) }

      it('sets the crystal level to the given one') do
        expect(subject.level).to eq 5
      end

      it('corrently sets the AP required to reach the next level') do
        required_ap = described_class::BASE_AP
        4.times { required_ap = (required_ap * 1.5).to_i }

        expect(subject.next_level).to eq(required_ap)
      end
    end

    it 'should not bound the crystal to any character' do
      new_crystal = described_class.new(:light)
      expect(new_crystal.bound_to).to be_nil
    end
  end

  describe '#element' do
    subject { described_class.new(:dark) }

    it 'returns the element specified when the crystal was created' do
      expect(subject.element).to eq(:dark)
    end
  end

  it 'does not allow its element to be changed after creation' do
    expect { described_class.new(:dark).element = :fire }
      .to raise_error NameError
  end

  describe '#level=' do
    subject { described_class.new(:water) }

    context 'when the argument is not an integer' do
      it 'raises an error' do
        message = '`level` must be an Integer. `String` given'
        expect { subject.level = 'one' }.to raise_error ArgumentError, message
      end
    end

    context 'when the level is out of bounds' do
      let(:message) do
        "`level` must be between 1 and #{described_class::MAX_LEVEL}"
      end

      context 'when the given level is below 1' do
        it 'raises an error' do
          expect { subject.level = 0 }.to raise_error ArgumentError, message
        end
      end

      context 'when the given level is greater than the maximum allowed' do
        it 'raises an error' do
          expect { subject.level = described_class::MAX_LEVEL + 1 }
            .to raise_error ArgumentError, message
        end
      end
    end

    context 'when the level is set' do
      before { subject.level = 2 }
      include_examples 'correctly calculates the AP required to reach level 2'
    end

    context 'when the level is incremented' do
      before { subject.level += 1 }
      include_examples 'correctly calculates the AP required to reach level 2'
    end

    context 'when an attempt is made to lower the level' do
      before { subject.level = 7 }

      it 'raises an error' do
        message = '`level` must be greater or equal to 7'
        expect { subject.level = 4 }.to raise_error ArgumentError, message
      end
    end
  end

  describe '#ap=' do
    subject { described_class.new(:wind) }

    context 'when something besides an integer is given' do
      it 'raises an error' do
        message = '`ap` must be an integer. `String` given'
        expect { subject.ap = 'Black' }.to raise_error ArgumentError, message
      end
    end

    context 'when a negative value is given' do
      it 'raises an error' do
        message = '`ap` must be a positive integer'
        expect { subject.ap = -4 }.to raise_error ArgumentError, message
      end
    end

    context 'when AP is set directly' do
      before { subject.ap = 10 }
      it('sets the AP to the given value') { expect(subject.ap).to eq 10 }
    end

    context 'when AP is incremented' do
      before do
        subject.ap = 10
        subject.ap += 5
      end

      it('increases the AP by the given amount') { expect(subject.ap).to eq 15 }
    end

    context 'when AP is decreased' do
      before do
        subject.ap = 10
        subject.ap -= 5
      end

      it('reduces the AP by the given amount') { expect(subject.ap).to eq 5 }
    end

    context 'when an attempt is made to reduce the AP below 0' do
      before do
        subject.ap = 10
      end

      it 'raises an error' do
        message = '`ap` must be a positive integer'
        expect { subject.ap -= 20 }.to raise_error ArgumentError, message
      end
    end

    context 'when the AP is set to an amount equal to `next_level`' do
      before { subject.ap = 10 }

      let(:ap_value) { subject.next_level }

      include_examples 'the crystal levels up'

      it "causes the `Crystal`'s AP' to go back to zero" do
        expect { subject.ap = ap_value }.to change { subject.ap }.to 0
      end
    end

    context 'when the AP is set to an amount beyond `next_level`' do
      before { subject.ap = 20 }

      let(:ap_value) { subject.next_level + 10 }

      include_examples 'the crystal levels up'

      it "sets the `Crystal`'s AP to the excess beyond `next_level`" do
        expect { subject.ap = ap_value }.to change { subject.ap }.to 10
      end
    end

    context 'when AP is set to a value that would cause multiple level ups' do
      let(:ap_value) { subject.next_level * 5 }

      it 'causes the `Crystal` to level up multiple times' do
        expect { subject.ap = ap_value }
          .to change { subject.level }.to 4
      end

      it "sets the `Crystal`'s AP to the excess over the current level" do
        expect { subject.ap = ap_value }
          .to change { subject.ap }.to 13
      end
    end

    context 'when a very big AP amount is given' do
      let(:ap_amount) { 10_000 }

      let(:max_level_ap) do
        crystal = subject.dup
        crystal.level = described_class::MAX_LEVEL
        crystal.next_level
      end

      it "raises the `Crystal`'s level to the maximum" do
        expect { subject.ap = ap_amount }
          .to change { subject.level }.to described_class::MAX_LEVEL
      end

      it 'sets the amount of AP to `next_level`' do
        expect { subject.ap = ap_amount }
          .to change { subject.ap }.to max_level_ap
      end
    end
  end

  describe '#bind_to' do
    subject { described_class.new(:light) }

    context 'When something besides a `Character` is given' do
      it 'raises an error' do
        message = 'character should be an instance of `Character`'

        expect { subject.bind_to('Wizard') }
          .to raise_error ArgumentError, message
      end
    end

    context 'When a valid `Character` is given' do
      include_context 'Blank Race'

      let(:character) { Character.new(blank_race) }

      before { subject.bind_to(character) }

      it 'binds the `Crystal` to the character' do
        expect(subject.bound_to).to eq(character)
      end

      it 'raises an error is a second bound is attempted' do
        message = 'crystal already bound to a character'

        expect { subject.bind_to(character) }
          .to raise_error CrystalAlreadyBoundException, message
      end
    end
  end
end
