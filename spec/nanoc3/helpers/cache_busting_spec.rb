describe Nanoc3::Helpers::CacheBusting do
  let(:subject) do
    o = Object.new
    o.extend Nanoc3::Helpers::CacheBusting
  end

  describe '#should_cachebust?' do
    %w{css js png jpg jpeg gif}.each do |extension|
      it { should be_cachebust({ :extension => extension }) }
    end
  end

  describe '#cachebusting_hash' do
    it 'should calculate a checksum of the source file' do
      File.should_receive(:read).with('foo').and_return('baz')
      Digest::MD5.should_receive(:hexdigest).with('baz').and_return('bar')
      subject.cachebusting_hash('foo').should == '-cbbar'
    end
  end
end
