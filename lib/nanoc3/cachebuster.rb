require 'nanoc3'
require 'digest'

module Nanoc3
  module Cachebuster
    autoload :VERSION,  'cachebuster/version'

    # List of file extensions that the routing system should regard
    # as needing a fingerprint. These are input file extensions, so
    # we also include the extensions used by popular preprocessors.
    FILETYPES_TO_FINGERPINT = %w[css js scss sass less coffee html htm png jpg jpeg gif]

    # Value prepended to the file fingerprint, to identify it as a cache buster.
    CACHEBUSTER_PREFIX = '-cb'

    def self.should_apply_fingerprint_to_file?(item)
      FILETYPES_TO_FINGERPINT.include? item[:extension]
    end

    def self.fingerprint_file(filename, length = 8)
      CACHEBUSTER_PREFIX + Digest::MD5.hexdigest(File.read(filename))[0..length.to_i]
    end
  end

  require File.expand_path('../filters', __FILE__)
  require File.expand_path('../helpers', __FILE__)
end
