RSpec::Matchers.define :contain_substring do |x|
  match { |actual| actual.include?(x) }
end

describe Fastlane::Actions::MaestroAction do
  describe '#run' do
    it 'Installs the maestro samples' do

      result = Fastlane::FastFile.new.parse("lane :test do
        maestro(command: 'download_samples')
      end").runner.execute(:test)

      path = File.directory?('samples')
      expect(path).not_to be_falsey
    end
  end
end
