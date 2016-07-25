# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'nanoc/cachebuster/version'

Gem::Specification.new do |s|
  s.name        = 'nanoc-cachebuster'
  s.version     = Nanoc::Cachebuster::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Arjan van der Gaag']
  s.email       = ['arjan@arjanvandergaag.nl']
  s.homepage    = 'https://github.com/avdgaag/nanoc-cachebuster'
  s.summary     = %q{Adds filters and helpers for cache busting to Nanoc}
  s.description = <<-EOS
Your website should use far-future expires headers on static assets, to make
the best use of client-side caching. But when a file is cached, updates won't
get picked up. Cache busting is the practice of making the filename of a
cached asset unique to its content, so it can be cached without having to
worry about future changes.

This gem adds a filter and some helper methods to Nanoc, the static site
generator, to simplify the process of making asset filenames unique. It helps
you output fingerprinted filenames, and refer to them from your source files.

It works on images, javascripts and stylesheets. It is extracted from the
nanoc-template project at http://github.com/avdgaag/nanoc-template.
EOS

  s.rubyforge_project = 'nanoc-cachebuster'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  
  s.add_runtime_dependency 'nanoc', '>= 3.3.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
