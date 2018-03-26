require_relative '../attributes'

RSpec.describe Attributes do
  describe '#initialize' do
    context 'when no `stats` object is given' do
      subject { described_class.new }

      it 'initializes all attributes to their minimum' do
        Attributes::ATTRIBUTES.keys.each do |attr|
          expect(subject[attr]).to eq Attributes::ATTRIBUTES[attr][:min]
        end
      end
    end

    context 'when an empty `Stats` object is given' do
      subject { described_class.new(Stats.new) }

      it 'sets the transient attributes to their maximum' do
        expect(subject[:health]).to eq subject[:total_health]
        expect(subject[:mana]).to eq subject[:total_mana]
      end
    end

    context 'when invalid parameters are given' do
      subject { described_class }

      it 'raises an exception' do
        msg = 'Expecting `stats` to be an instance of `Stats` but got String'
        expect { subject.new('hello') }.to raise_error ArgumentError, msg

        msg = 'Expecting `level` to be an Integer but got String'
        expect { subject.new(Stats.new, 'hello') }
          .to raise_error ArgumentError, msg
      end
    end
  end

  describe '#[]' do
    subject { described_class.new }

    it 'raises an error if an unknown attribute is given' do
      message = 'Unrecognized attribute missingno'
      expect { subject[:missingno] }.to raise_error ArgumentError, message
    end
  end

  describe '#[]=' do
    subject { described_class.new }

    it 'raises an error if an unknown attribute is given' do
      message = 'Unrecognized attribute missingno'
      expect { subject[:missingno] = 100 }.to raise_error ArgumentError, message
    end

    it 'raises an error if an unsupported type is provied' do
      message = 'Expected Integer but got String instead'
      expect { subject[:health] = 'hello' }
        .to raise_error ArgumentError, message
    end

    context 'when the given value is within bounds' do
      it 'sets the value for the given attribute' do
        expect { subject[:total_health] = 100 }
          .to change { subject[:total_health] }.to(100)
      end

      it 'can increment the value for the given attribute' do
        expect { subject[:total_health] += 100 }
          .to change { subject[:total_health] }.by(100)
      end
    end

    context 'when the given value is out of bounds' do
      before { subject[:evasion] = 0.6 }

      it 'adjusts the value to the lowest bound' do
        expect { subject[:evasion] = -1.0 }
          .to change { subject[:evasion] }.to(0.0)
      end

      it 'adjusts the value to the upper bound' do
        expect { subject[:evasion] = 2.0 }
          .to change { subject[:evasion] }.to(1.0)
      end
    end
  end

  describe 'formulas' do
    context 'for an empty `Stats` object' do
      subject { described_class.new(Stats.new) }

      it { expect(subject[:defense]).to eq 120 }
      it { expect(subject[:total_health]).to eq 261 }
      it { expect(subject[:critical_damage]).to eq 1.02 }
      it { expect(subject[:critical_rate]).to eq 0.04 }
      it { expect(subject[:attack_speed]).to eq 102 }
      it { expect(subject[:evasion]).to eq 0.1 }
      it { expect(subject[:accuracy]).to eq 0.54 }
      it { expect(subject[:speed]).to eq 20 }
      it { expect(subject[:magic_power]).to eq 173 }
      it { expect(subject[:magic_critical_damage]).to eq 1.02 }
      it { expect(subject[:magic_defense]).to eq 157 }
      it { expect(subject[:total_mana]).to eq 179 }
      it { expect(subject[:magic_critical_rate]).to eq 0.02 }
      it { expect(subject[:magic_accuracy]).to eq 0.7 }
      it { expect(subject[:magic_evasion]).to eq 0.12 }
      it { expect(subject[:casting_speed]).to eq 253 }
    end
  end

  describe '#calculate_attributes' do
    let(:stats) { Stats.new }
    subject { described_class.new(stats) }

    context 'when `reset_transient_attributes` is `false`' do
      it 'does not reset the transient attributes' do
        expect { subject.calculate_attributes(stats, 2) }
          .to change { subject[:health] }.by(0)
                                         .and change { subject[:mana] }.by(0)
      end
    end

    context 'when `reset_transient_attributes` os `true`' do
      it 'resets the transient attributes' do
        expect { subject.calculate_attributes(stats, 2, true) }
          .to change { subject[:health] }.to(373)
                                         .and change { subject[:mana] }.to(208)
      end
    end

    context 'When `level` is 2' do
      before { subject.calculate_attributes(stats, 2) }

      it { expect(subject[:total_mana]).to eq 208 }
      it { expect(subject[:attack_speed]).to eq 105 }
      it { expect(subject[:magic_critical_rate]).to eq 0.02 }
    end

    context 'When `level` is 5' do
      before { subject.calculate_attributes(stats, 5) }

      it { expect(subject[:total_mana]).to eq 295 }
      it { expect(subject[:attack_speed]).to eq 113 }
      it { expect(subject[:magic_critical_rate]).to eq 0.03 }
    end

    context 'When `level` is 10' do
      before { subject.calculate_attributes(stats, 10) }

      it { expect(subject[:total_mana]).to eq 440 }
      it { expect(subject[:attack_speed]).to eq 127 }
      it { expect(subject[:magic_critical_rate]).to eq 0.04 }
    end
  end

  describe 'transient adjustment' do
    let(:stats) { Stats.new }
    subject { described_class.new(stats) }

    it 'adjusts the transient attributes when their totals change' do
      expect { subject[:total_health] -= 10 }
        .to change { subject[:health] }.by(-10)
      expect { subject[:total_mana] -= 10 }.to change { subject[:mana] }.by(-10)
    end

    it 'adjusts the transient attributes when the level decrease' do
      subject.calculate_attributes(stats, 2, true)

      expect { subject.calculate_attributes(stats, 1) }
        .to change { subject[:health] }.to(261)
                                       .and change { subject[:mana] }.to(179)
    end
  end
end
