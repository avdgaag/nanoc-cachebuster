module Nanoc3::Filters
  autoload 'CacheBuster', 'nanoc3/filters/cache_buster'
  Nanoc3::Filter.register '::Nanoc3::Filters::CacheBuster', :cache_buster
end
