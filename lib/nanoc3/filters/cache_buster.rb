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

      # The Strategy is a way to deal with an input file. The Cache busting filter
      # will use a strategy to process all references. You may want to use different
      # strategies for different file types.
      #
      # @abstract
      class Strategy
        # The current site. We need a reference to that in a strategy,
        # so we can browse through all its items.
        #
        # This might very well have been just the site#items array, but for
        # future portability we might as well carry the entire site object
        # over.
        #
        # @return <Nanoc3::Site>
        attr_reader :site

        # The Nanoc item we are currently filtering.
        #
        # @return <Nanoc3::Item>
        attr_reader :current_item

        def initialize(site, current_item)
          @site, @current_item = site, current_item
        end

        # Abstract method that subclasses (actual strategies) should
        # implement.
        #
        # @abstract
        def apply
          raise Exception, 'Must be implemented in a subclass'
        end

      protected

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
            i.path.sub(/#{Nanoc3::Cachebuster::CACHEBUSTER_PREFIX}[a-zA-Z0-9]{9}(?=\.)/o, '') == path
          end

          # Raise an exception to indicate we should leave this reference alone
          unless matching_item
            raise Nanoc3::Cachebuster::NoSuchSourceFile, 'No source file found matching ' + input_path
          end

          # Make sure to keep or remove the first slash, as the input path
          # does.
          matching_item.path.tap do |p|
            p.sub!(/^\//, '') unless input_path =~ /^\//
          end
        end

        # Get the absolute path to a file, whereby absolute means relative to the root.
        #
        # We use the relative-to-root path to detect if our site contains an item
        # that will be output to that location.
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
          File.join(File.dirname(current_item[:content_filename]), path).sub(/^content/, '')
        end
      end

      # The Css strategy looks for CSS-style external references that use the
      # url() syntax. This will typically cover any @import statements and
      # references to images.
      class Css < Strategy
        REGEX = /
          url\(          # Start with the literal url(
          ('|"|)         # Then either a single, double or no quote at all
          (
            ([^'")]+)    # The file basename, and below the extension
            \.(#{Nanoc3::Cachebuster::FILETYPES_TO_FINGERPRINT.join('|')})
          )
          \1             # Repeat the same quote as at the start
          \)             # And cose the url()
        /ix

        def apply(m, quote, filename, basename, extension)
          m.sub(filename, output_filename(filename))
        end
      end

      # The Html strategy looks for HTML-style attributes in the item source code,
      # picking up the values of href and src attributes. This will typically cover
      # links, stylesheets, images and javascripts.
      class Html < Strategy
        REGEX = /
          (href|src)        # Look for either an href="" or src="" attribute
          =                 # ...followed by an =
          ("|'|)            # Then either a single, double or no quote at all
          (                 # Capture the entire reference
            [^'"]+          # Anything but something that would close the attribute
                            # And then the extension:
            (\.(?:#{Nanoc3::Cachebuster::FILETYPES_TO_FINGERPRINT.join('|')}))
          )
          \2                # Repeat the opening quote
        /ix

        def apply(m, attribute, quote, filename, extension)
          %Q{#{attribute}=#{quote}#{output_filename(filename)}#{quote}}
        end
      end
    end
  end
end

