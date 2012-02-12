module Nanoc::Filters
  autoload 'CacheBuster', 'nanoc/filters/cache_buster'
  Nanoc::Filter.register '::Nanoc::Filters::CacheBuster', :cache_buster
end
