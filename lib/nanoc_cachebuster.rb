module NanocCachebuster
  autoload :VERSION,  'nanoc_cachebuster/version'
end

require File.expand_path('../nanoc3/filters', __FILE__)
require File.expand_path('../nanoc3/helpers', __FILE__)
