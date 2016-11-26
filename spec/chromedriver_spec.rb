require "spec_helper"

describe Webdrivers::Chromedriver do

  let(:chromedriver) { Webdrivers::Chromedriver }

  it 'downloads' do
    chromedriver.download
    file = "#{ENV['GEM_HOME']}/bin/chromedriver"
    expect(File.exist?(file)).to eq true
  end

  it 'deletes' do
    begin
      chromedriver.download
      chromedriver.reset
      file = "#{ENV['GEM_HOME']}/bin/chromedriver"
      expect(File.exist?(file)).to eq false
    ensure
      system %w[bundle install]
    end
  end

  it { expect(chromedriver.newest_version.to_f).to be >= 2.25 }

  it { expect(chromedriver.downloads.size).to be >= 26 }

  context "on a linux platform" do
    before { allow(chromedriver).to receive(:platform) { "linux32" } }

    it { expect(chromedriver.file_name).to match(/chromedriver$/) }

    it { expect(chromedriver.binary_path).to match '.webdrivers/linux32/chromedriver' }

    it { expect(chromedriver.download_url('2.24')).to match("2.24/chromedriver_linux32.zip") }
  end

  context "on a windows platform" do
    before { allow(chromedriver).to receive(:platform) { "win" } }

    it { expect(chromedriver.file_name).to match(/chromedriver\.exe$/) }

    it { expect(chromedriver.binary_path).to match '.webdrivers/win/chromedriver' }

    it { expect(chromedriver.download_url('2.24')).to match("2.24/chromedriver_win32.zip") }
  end
end
