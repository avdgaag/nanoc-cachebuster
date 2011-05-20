require 'nanoc3'

module Nanoc3
  module Cachebuster
    autoload :VERSION,  'cachebuster/version'

    FILETYPES_TO_FINGERPINT = %w[css js scss sass less coffee html htm png jpg jpeg gif]

    def self.should_apply_fingerprint_to_file?(item)
      FILETYPES_TO_FINGERPINT.include? item[:extension]
    end
  end

  require File.expand_path('../filters', __FILE__)
  require File.expand_path('../helpers', __FILE__)
end
