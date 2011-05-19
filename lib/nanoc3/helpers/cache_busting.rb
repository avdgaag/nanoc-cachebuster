module Nanoc3
  module Helpers
    module CacheBusting
      def should_cachebust?(item)
        Nanoc3::Filters::CacheBuster.should_filter? item
      end

      def cachebusting_hash(filename)
        Nanoc3::Filters::CacheBuster.hash(filename)
      end
    end
  end
end