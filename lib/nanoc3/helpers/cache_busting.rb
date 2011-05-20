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

      # Get a unique fingerprint for a file's content. This currently uses
      # an MD5 hash of the file contents.
      #
      # @todo Also allow passing in an item rather than a path
      # @param <String> filename is the path to the file to fingerprint.
      # @return <String> file fingerprint
      def fingerprint(filename)
        Nanoc3::Cachebuster.fingerprint_file(filename)
      end
    end
  end
end
