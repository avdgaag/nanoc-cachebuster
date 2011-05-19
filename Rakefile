$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'nanoc_cachebuster/version'

def sh(s)
  puts 'Dummy operation:', s
end

task :build do
  sh 'gem build nanoc_cachebuster.gemspec'
end

task :tag do
  sh "git tag -a #{NanocCachebuster::VERSION}"
end

task :push do
  sh 'git push origin master'
  sh 'git push --tags'
end

task :log do
  changes = `git log --oneline $(git describe --abbrev=0 2>/dev/null)..HEAD`
  abort 'Nothing to do' if changes.empty?

  changes.gsub!(/^\w+/, '*')
  path = File.expand_path('../HISTORY.md', __FILE__)

  original_content = File.read(path)
  addition = "# #{NanocCachebuster::VERSION}\n\n#{changes}"
  puts addition

  File.open(path, 'w') do |f|
    f.write "#{addition}\n#{original_content}"
  end
end

desc 'Tag the code, push upstream, build and push the gem'
task :release => [:build, :tag, :push] do
  sh "gem push nanoc_cachebuster-#{NanocCachebuster::VERSION}"
end

desc 'Print current version number'
task :version do
  puts NanocCachebuster::VERSION
end

class Version
  def initialize(version_string)
    @major, @minor, @patch = version_string.split('.').map { |s| s.to_i }
  end

  def bump(part)
    case part
    when :major then @major, @minor, @patch = @major + 1, 0, 0
    when :minor then @minor, @patch = @minor + 1, 0
    when :patch then @patch += 1
    end
    self
  end

  def to_s
    [@major, @minor, @patch].join('.')
  end

  def write
    file = File.expand_path('../lib/nanoc_cachebuster/version.rb', __FILE__)
    original_contents = File.read(file)
    File.open(file, 'w') do |f|
      f.write original_contents.gsub(/VERSION = ('|")\d+\.\d+\.\d+\1/, "VERSION = '#{to_s}'")
    end
    puts to_s
    to_s
  end
end

namespace :version do
  namespace :bump do
    desc 'Bump a major version'
    task :major do
      Version.new(NanocCachebuster::VERSION).bump(:major).write
    end

    desc 'Bump a minor version'
    task :minor do
      Version.new(NanocCachebuster::VERSION).bump(:minor).write
    end

    desc 'Bump a patch version'
    task :patch do
      Version.new(NanocCachebuster::VERSION).bump(:patch).write
    end
  end
end