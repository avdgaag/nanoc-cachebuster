module Nanoc3
  module Filters

    # The cache buster filter rewrites references to external files, so that the
    # filenames include a timestamp. This creates a unique filename that will
    # change whenever the file is changed.
    #
    # This allows you to use far-future expires headers to fully benefit from
    # client-side caching.
    #
    # We do not simply append a query string, as this might sometimes trigger
    # proxies to not cache the results.
    #
    # Note: this requires you to use .htaccess rewrites to point the
    # filenames-with-timestamps back into normal filenames.
    class CacheBuster < Nanoc3::Filter
      identifier :cache_buster

      def run(content, args = {})
        strategy = stylesheet? ? Css.new(site, item) : Html.new(site, item)
        content.gsub(strategy.class::REGEX) do |m|
          begin
            strategy.apply m, $1, $2, $3, $4
          rescue Nanoc3::Cachebuster::NoSuchSourceFile
            m
          end
        end
      end

    private

      # See if the current item is a stylesheet.
      #
      # Apart from regular .css-files, this method will consider any file
      # with an extension that is mapped to 'css' in the filter_extensions
      # setting in config.yaml to be a CSS file.
      #
      # @return <Bool>
      def stylesheet?
        @site.config[:filter_extensions].select do |k, v|
          v == 'css'
        end.flatten.uniq.map do |k|
          k.to_s
        end.include?(@item[:extension].to_s)
      end

      class Strategy
        attr_reader :site, :item

        def initialize(site, item)
          @site, @item = site, item
        end

        # Try to find the source path of a referenced file.
        #
        # This will use Nanoc's routing rules to try and find an item whose output
        # path matches the path given, which is a source reference. It returns
        # the path to the content file if a match is found.
        #
        # As an example, when we use the input file "assets/styles.scss" for our
        # stylesheet, then we refer to that file in our HTML as "assets/styles.css".
        # Given the output filename, this method will return the input filename.
        #
        # @raises NoSuchSourceFile when no match is found
        # @param <String> path is the reference to an asset file from another source
        #   file, such as '/assets/styles.css'
        # @return <String> the path to the content file for the referenced file,
        #   such as '/assets/styles.scss'
        def output_filename(input_path)
          path = absolutize(input_path)

          matching_item = site.items.find do |i|
            i.path.sub(/-cb[a-zA-Z0-9]{9}(?=\.)/, '') == path
          end

          raise Nanoc3::Cachebuster::NoSuchSourceFile, 'No source file found matching ' + input_path unless matching_item

          output_path = matching_item.path
          output_path.sub!(/^\//, '') unless input_path =~ /^\//
          output_path
        end

        # Get the absolute path to a file, whereby absolute means relative to the root.
        #
        # When we are trying to get to a source file via a referenced filename,
        # that filename may be absolute (relative to the site root) or relative to
        # the file itself. In the latter case, our file detection would miss it.
        # We therefore rewrite any reference not starting with a forward slash
        # to include the full path of the referring item.
        #
        # @example Using an absolute input path in 'assets/styles.css'
        #   absolutize('/assets/logo.png') # => '/assets/logo.png'
        # @example Using a relative input path in 'assets/styles.css'
        #   absolutize('logo.png') # => '/assets/logo.png'
        #
        # @param <String> path is the path of the file that is referred to in
        #   an input file, such as a stylesheet or HTML page.
        # @return <String> path to the same file as the input path but relative
        #   to the site root.
        def absolutize(path)
          return path if path =~ /^\//
          File.join(File.dirname(item[:content_filename]), path).sub(/^content/, '')
        end
      end

      class Css < Strategy
        REGEX = /url\(('|"|)(([^'")]+)\.(#{Nanoc3::Cachebuster::FILETYPES_TO_FINGERPRINT.join('|')}))\1\)/i

        def apply(m, quote, filename, basename, extension)
          m.sub(filename, output_filename(filename))
        end
      end

      class Html < Strategy
        REGEX = /(href|src)=("|'|)([^'"]+(\.(?:#{Nanoc3::Cachebuster::FILETYPES_TO_FINGERPRINT.join('|')})))\2/

        def apply(m, attribute, quote, filename, extension)
          %Q{#{attribute}=#{quote}#{output_filename(filename)}#{quote}}
        end
      end
    end
  end
end

