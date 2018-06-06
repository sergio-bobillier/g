RSpec.shared_context 'Blank Race' do
  let(:blank_race) do
    Race.new(Stats.new(con: 0, str: 0, dex: 0, int: 0, men: 0, wit: 0))
  end
end

RSpec.shared_context 'Basic Race' do
  let(:basic_race) do
    Race.new(Stats.new(con: 5, str: 5, dex: 5, int: 5, men: 5, wit: 5))
  end
end
