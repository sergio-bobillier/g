RSpec.shared_context 'Crystals' do
  let(:water_crystal) { Crystal.new(:water) }
  let(:ice_crystal) { Crystal.new(:water) }
  let(:fire_crystal) { Crystal.new(:fire) }
  let(:earth_crystal) { Crystal.new(:earth) }
  let(:wind_crystal) { Crystal.new(:wind) }
end
