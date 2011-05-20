require 'nanoc3'

module Nanoc3
  module Cachebuster
    autoload :VERSION,  'cachebuster/version'
  end

  require File.expand_path('../filters', __FILE__)
  require File.expand_path('../helpers', __FILE__)
end
