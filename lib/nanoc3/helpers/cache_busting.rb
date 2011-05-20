module Nanoc3
  module Helpers
    module CacheBusting

      # Test if we want to filter the output filename for a given item.
      # This is logic used in the Rules file, but doesn't belong there.
      #
      # @example Determining whether to rewrite an output filename
      #   # in your Rules file
      #   route '/assets/*' do
      #     hash = cachebust?(item) ? cachebusting_hash(item) : ''
      #     item.identifier + hash + '.' + item[:extension]
      #   end
      #
      # @param <Item> item is the item to test
      # @return <Boolean>
      def cachebust?(item)
        Nanoc3::Cachebuster.should_apply_fingerprint_to_file?(item)
      end

      def cachebusting_hash(filename)
        Nanoc3::Filters::CacheBuster.hash(filename)
      end
    end
  end
end
