require 'spec_helper'
require 'ostruct'

class MockItem
  attr_reader :path, :content

  def self.generated_css_file
    new '/styles-cb123456789.css', 'example content', { :extension => 'css' }
  end

  def self.css_file(content = 'example content')
    new '/styles-cb123456789.css', content, { :extension => 'css', :content_filename => 'content/styles.css' }
  end

  def self.css_file_in_folder(folder_name = 'assets')
    new "/#{folder_name}/styles-cb123456789.css", 'example content', { :extension => 'css', :content_filename => "content/#{folder_name}/styles.css" }
  end

  def self.html_file(content = 'example content')
    new '/output_file.html', content, { :extension => 'html', :content_filename => 'content/input_file.html' }
  end

  def self.html_file_in_folder(folder_name = 'baz', content = 'example content')
    new "/#{folder_name}/output_file.html", content, { :extension => 'html', :content_filename => "content/#{folder_name}/input_file.html" }
  end

  def self.image_file(input = '/foo.png', output = '/foo-cb123456789.png')
    new output, 'hello, world', { :extension => 'png', :content_filename => input }
  end

  def self.image_file_routed_somewhere_else
    image_file '/foo.png', '/folder/foo-cb123456789.png'
  end

  def self.image_file_unfiltered
    image_file '/foo.png', '/foo.png'
  end

  def initialize(path, content, attributes = {})
    @path, @content, @attributes = path, content, attributes
  end

  def identifier
    File.basename(@path)
  end

  def [](k)
    @attributes[k]
  end
end

describe Nanoc::Filters::CacheBuster do
  before(:each) do
    Digest::MD5.stub!(:hexdigest).and_return('123456789')
  end

  let(:subject) { Nanoc::Filters::CacheBuster.new context }
  let(:content) { item.content }
  let(:item)    { MockItem.css_file }
  let(:target)  { MockItem.image_file }
  let(:items)   { [item, target] }
  let(:site)    { OpenStruct.new({ :items => items }) }
  let(:context) do
    {
        :site    => site,
        :item    => item,
        :content => content,
        :items   => items
    }
  end

  describe 'filter interface' do
    it { should be_kind_of(Nanoc::Filter) }
    it { should respond_to(:run) }

    it 'should accept a string and an options Hash' do
      lambda { subject.run('foo', {}) }.should_not raise_error(ArgumentError)
    end
  end

  def self.it_should_filter(replacements = {})
    replacements.each do |original, busted|
      it 'should add cache buster to reference' do
        context[:content] = original
        subject.run(original).should == busted
      end
    end
  end

  def self.it_should_not_filter(str)
    it 'should not change the reference' do
      context[:content] = str
      subject.run(str).should == str
    end
  end

  describe 'filtering CSS' do
    let(:item) { MockItem.css_file }

    describe 'when the file exists' do
      before(:each) do
        File.stub!(:read).with(File.join(Dir.pwd, 'content', 'foo.png')).and_return(context[:content])
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
    end

    describe 'when using an absolute path' do
      let(:target) { MockItem.image_file '/foo.png', '/images/foo-cb123456789.png' }

      before(:each) do
        File.stub!(:read).with(File.join(Dir.pwd, 'content', 'foo.png')).and_return(context[:content])
      end

      it_should_filter %Q{background: url("/images/foo.png");} => %Q{background: url("/images/foo-cb123456789.png");}
    end

    describe 'when using a relative path' do
      let(:item) { MockItem.css_file_in_folder }
      let(:target) { MockItem.image_file '/images/foo.png', '/images/foo-cb123456789.png' }

      before(:each) do
        File.stub!(:read).with(File.join(Dir.pwd, 'content', 'images', 'foo.png')).and_return(context[:content])
      end

      it_should_filter %Q{background: url("../images/foo.png");} => %Q{background: url("../images/foo-cb123456789.png");}
    end

    describe 'when the file does not exist' do
      let(:target) { MockItem.image_file_routed_somewhere_else }

      it_should_not_filter %Q{background: url(foo.png);}
    end

    describe 'when the file is not cache busted' do
      let(:target) { MockItem.image_file_unfiltered }

      it_should_not_filter %Q{background: url(foo.png);}
    end

    describe 'when the current item has no content path' do
      let(:target) { MockItem.image_file '/foo.png', '/../images/foo-cb123456789.png' }
      let(:item) { MockItem.generated_css_file }

      it_should_filter %Q{background: url("../images/foo.png");} => %Q{background: url("../images/foo-cb123456789.png");}
    end
  end

  describe 'filtering HTML' do
    describe 'on the href attribute' do
      let(:item) { MockItem.html_file '<link href="foo.png">' }

      describe 'when the file exists' do
        before(:each) do
          File.stub!(:read).with(File.join(Dir.pwd, 'content', 'foo.png')).and_return(context[:content])
        end

        describe 'without quotes' do
          it_should_filter %Q{<link href=foo.png>} => %Q{<link href=foo-cb123456789.png>}
        end

        describe 'with single quotes' do
          it_should_filter %Q{<link href='foo.png'>} => %Q{<link href='foo-cb123456789.png'>}
        end

        describe 'with double quotes' do
          it_should_filter %Q{<link href="foo.png">} => %Q{<link href="foo-cb123456789.png">}
        end
      end

      describe 'when using an absolute path' do
        let(:target) { MockItem.image_file '/foo.png', '/images/foo-cb123456789.png' }

        before(:each) do
          File.stub!(:read).with(File.join(Dir.pwd, 'content', 'foo.png')).and_return(context[:content])
        end

        it_should_filter %Q{<link href="/images/foo.png">} => %Q{<link href="/images/foo-cb123456789.png">}
      end

      describe 'when using a relative path' do
        let(:item) { MockItem.html_file_in_folder }
        let(:target) { MockItem.image_file '/foo.png', '/images/foo-cb123456789.png' }

        before(:each) do
          File.stub!(:read).with(File.join(Dir.pwd, 'content', 'foo.png')).and_return(context[:content])
        end

        it_should_filter %Q{<link href="../images/foo.png">} => %Q{<link href="../images/foo-cb123456789.png">}
      end

      describe 'when the file does not exist' do
        let(:target) { MockItem.image_file_routed_somewhere_else }

        it_should_not_filter '<link href="foo.png">'
      end

      describe 'when the file is not cache busted' do
        let(:target) { MockItem.image_file_unfiltered }

        it_should_not_filter '<link href="foo.png">'
      end
    end

    describe 'on the src attribute' do
      let(:item) { MockItem.html_file '<img src="foo.png">' }

      describe 'when the file exists' do
        before(:each) do
          File.stub!(:read).with(File.join(Dir.pwd, 'content', 'foo.png')).and_return(context[:content])
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
      end

      describe 'when using an absolute path' do
        let(:target) { MockItem.image_file '/foo.png', '/images/foo-cb123456789.png' }

        before(:each) do
          File.stub!(:read).with(File.join(Dir.pwd, 'content', 'foo.png')).and_return(context[:content])
        end

        it_should_filter %Q{<img src="/images/foo.png">} => %Q{<img src="/images/foo-cb123456789.png">}
      end

      describe 'when using a relative path' do
        let(:item) { MockItem.html_file_in_folder }
        let(:target) { MockItem.image_file '/foo.png', '/images/foo-cb123456789.png' }

        before(:each) do
          File.stub!(:read).with(File.join(Dir.pwd, 'content', 'foo.png')).and_return(context[:content])
        end

        it_should_filter %Q{<img src="../images/foo.png">} => %Q{<img src="../images/foo-cb123456789.png">}
      end

      describe 'when the file does not exist' do
        let(:target) { MockItem.image_file_routed_somewhere_else }

        it_should_not_filter '<img src="foo.png">'
      end

      describe 'when the file is not cache busted' do
        let(:target) { MockItem.image_file_unfiltered }

        it_should_not_filter '<img src="foo.png">'
      end
    end
  end
end
