module Nanoc
  module Filters
    class CacheBuster < Nanoc::Filter
      identifier :cache_buster

      def run(content, options = {})
        kind = options[:strategy] || (stylesheet? ? :css : :html)
        strategy = Nanoc::Cachebuster::Strategy.for(kind , site, item)
        content.gsub(strategy.class::REGEX) do |m|
          begin
            strategy.apply m, $1, $2, $3, $4
          rescue Nanoc::Cachebuster::NoSuchSourceFile
            m
          end
        end
      end

    private

      # See if the current item is a stylesheet.
      #
      # This is a simple check for filetypes, but you can override what strategy to use
      # with the filter options. This provides a default.
      #
      # @see Nanoc::Cachebuster::FILETYPES_CONSIDERED_CSS
      # @return <Bool>
      def stylesheet?
        Nanoc::Cachebuster::FILETYPES_CONSIDERED_CSS.include?(item[:extension].to_s)
      end
    end
  end
end

