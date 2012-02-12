describe Nanoc::Helpers::CacheBusting do
  let(:subject) do
    o = Object.new
    o.extend Nanoc::Helpers::CacheBusting
  end

  describe '#should_cachebust?' do
    %w{png jpg jpeg gif css js scss sass less coffee html htm}.each do |extension|
      it "should add fingerprint to #{extension} files" do
        subject.cachebust?({ :extension => extension }).should be_true
      end
    end
  end

  describe '#fingerprint' do
    it 'should calculate a checksum of the source file' do
      File.should_receive(:read).with('foo').and_return('baz')
      Digest::MD5.should_receive(:hexdigest).with('baz').and_return('bar')
      subject.fingerprint('foo').should == '-cbbar'
    end
  end
end
