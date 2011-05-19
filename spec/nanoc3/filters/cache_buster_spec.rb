require 'ostruct'

describe Nanoc3::Filters::CacheBuster do
  before(:each) do
    @item = { :extension => 'css', :content_filename => 'styles.css' }
    @context = {
      :site    => OpenStruct.new,
      :item    => @item,
      :config  => { :filter_extensions => { :scss => 'css' }},
      :content => 'example content',
      :items   => [@item]
    }
    @context[:site].config    = @context[:config]
    @context[:site].items     = @context[:items]
    Digest::MD5.stub!(:hexdigest).and_return('123456789')
  end

  let(:subject) { Nanoc3::Filters::CacheBuster.new @context }

  describe 'filter interface' do
    it { should be_kind_of(Nanoc3::Filter) }
    it { should respond_to(:run) }

    it 'should accept a string and an options Hash' do
      lambda { subject.run('foo', {}) }.should_not raise_error(ArgumentError)
    end
  end

  def self.it_should_filter(replacements = {})
    replacements.each do |original, busted|
      it 'should add cache buster to reference' do
        @context[:content] = original
        subject.run(original).should == busted
      end
    end
  end

  def self.it_should_not_filter(str)
    it 'should not change the reference' do
      @context[:content] = str
      subject.run(str).should == str
    end
  end

  describe 'filtering CSS' do
    before(:each) do
      @item[:extension]  = 'css'
      @item.stub!(:path).and_return('./foo-cb123456789.png')
      File.stub!(:read).with(File.join(Dir.pwd, 'content', 'styles.css')).and_return(@context[:content])
    end

    describe 'without quotes' do
      it_should_filter %Q{background: url(foo.png);} => 'background: url(foo-cb123456789.png);'
    end

    describe 'with single quotes' do
      it_should_filter %Q{background: url('foo.png');} => %Q{background: url('foo-cb123456789.png');}
    end

    describe 'with double quotes' do
      it_should_filter %Q{background: url("foo.png");} => %Q{background: url("foo-cb123456789.png");}
    end

    describe 'when the file does not exist' do
      before(:each) do
        @item.stub!(:path).and_return('bar.png')
      end

      it_should_not_filter %Q{background: url(foo.png);}
    end

    describe 'when the file is not cache busted' do
      before(:each) do
        @item.stub!(:path).and_return('foo.png')
      end

      it_should_not_filter %Q{background: url(foo.png);}
    end
  end

  describe 'filtering HTML' do
    before(:each) do
      @item[:content_filename] = 'page.html'
      @item[:extension] = 'html'
    end

    describe 'on the src attribute' do
      before(:each) do
        @context[:content] = '<img src="foo.png">'
        @item.stub!(:path).and_return('./foo-cb123456789.png')
        File.stub!(:read).with(File.join(Dir.pwd, 'content', 'page.html')).and_return(@context[:content])
      end

      describe 'without quotes' do
        it_should_filter %Q{<img src=foo.png>} => %Q{<img src=foo-cb123456789.png>}
      end

      describe 'with single quotes' do
        it_should_filter %Q{<img src='foo.png'>} => %Q{<img src='foo-cb123456789.png'>}
      end

      describe 'with double quotes' do
        it_should_filter %Q{<img src="foo.png">} => %Q{<img src="foo-cb123456789.png">}
      end

      describe 'when the file does not exist' do
        before(:each) do
          @item.stub!(:path).and_return('bar.png')
        end

        it_should_not_filter '<img src="foo.png">'
      end

      describe 'when the file is not cache busted' do
        before(:each) do
          @item.stub!(:path).and_return('foo.png')
        end

        it_should_not_filter '<img src="foo.png">'
      end
    end
  end
end
