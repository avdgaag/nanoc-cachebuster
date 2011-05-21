require 'nanoc3'
require 'digest'

module Nanoc3
  module Cachebuster
    autoload :VERSION,  'cachebuster/version'

    # List of file extensions that the routing system should regard
    # as needing a fingerprint. These are input file extensions, so
    # we also include the extensions used by popular preprocessors.
    FILETYPES_TO_FINGERPRINT = %w[css js scss sass less coffee html htm png jpg jpeg gif]

    # List of file extensions that should be considered css. This is used
    # to determine what filtering strategy to use when none is explicitly
    # set.
    FILETYPES_CONSIDERED_CSS = %w[css js scss sass less]

    # Value prepended to the file fingerprint, to identify it as a cache buster.
    CACHEBUSTER_PREFIX = '-cb'

    # Custom exception that might be raised by the rewriting strategies when
    # there can be no source file found for the reference that it found that
    # might need rewriting.
    #
    # This exception should never bubble up from the filter.
    NoSuchSourceFile = Class.new(Exception)

    # Custom exception that will be raised when trying to use a filtering
    # strategy that does not exist. This will bubble up to the end user.
    NoSuchStrategy = Class.new(Exception)

    def self.should_apply_fingerprint_to_file?(item)
      FILETYPES_TO_FINGERPRINT.include? item[:extension]
    end

    def self.fingerprint_file(filename, length = 8)
      CACHEBUSTER_PREFIX + Digest::MD5.hexdigest(File.read(filename))[0..length.to_i]
    end
  end

  require File.expand_path('../filters', __FILE__)
  require File.expand_path('../helpers', __FILE__)
end
