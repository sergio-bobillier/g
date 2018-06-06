RSpec.shared_context 'Basic Job' do
  let(:basic_job) do
    Job.new(Stats.new(con: 5, str: 5, dex: 5, int: 5, men: 5, wit: 5))
  end
end
