A simple Ruby gem that enhances Nanoc with cache-busting capabilities.

I am currently extracting these features from another project, so it is still very much a work-in-progress.

Description
===========

Your website should use far-future expires headers on static assets, to make
the best use of client-side caching. But when a file is cached, updates won't
get picked up. Cache busting is the practice of making the filename of a
cached asset unique to its content, so it can be cached without having to
worry about future changes.

This gem adds a filter and some helper methods to Nanoc, the static site
generator, to simplify the process of making asset filenames unique. It helps
you output fingerprinted filenames, and refer to them from your source files.

More information
----------------


Find out more about Nanoc by Denis Defreyne at http://nanoc.stoneship.org.

Installation
============

As an extension to Nanoc, you need to have that installed and working before
you can add this gem. When your Nanoc project is up and running, simply
install this gem:

    $ gem install nanoc-cachebuster

Then load it via your project Gemfile or in `./lib/default.rb`:

    require 'nanoc3/cachebuster'

Usage
=====

This gem provides a Nanoc filter you can use to rewrite references to static
assets in your source files. These will be picked up automatically.

So, when you include a stylesheet:

    <link rel="stylesheet" href="styles.css">

This filter will change that on compilation to:

    <link rel="stylesheet" href="styles-cb7a4bb98ef.css">

The adjusted filename changes every time the file itself changes, so you don't
want to code that by hand in your Rules file. Instead, use the helper methods
provided. First, include the helpers in your ./lib/default.rb:

    include Nanoc3::Helpers::Cachebusting

Then you can use `#should_cachebust?` and `#cachebusting_hash` in your routing
rules to determine whether an item needs cachebusting, and get the fingerprint
for it. So you can do something like:

    route 'styles' do
      if should_cachebust? item
        item.identifier.chop + cachebusting_hash(item[:filename]) +
          '.' + item[:extension]
      else
        item.identifier.chop + '.' + item[:extension]
      end
    end

Development
===========

Changes
-------

See HISTORY.md for the full changelog.

To do
-----

* There is some magic going on here in detecting file references, and
  inferring the source item filename from that reference. This should be
  cleaned up and tested.
* There should also be one single method of determining the output filename
  both in the reference rewriter and the Rules file, so no mismatch can occur.
* Finally, the filter should be refactored in something more maintainable.

Dependencies
------------

nanoc-cachebuster obviously depends on Nanoc, but has no further dependencies.

Credits
=======

* **Author**: Arjan van der Gaag <arjan@arjanvandergaag.nl>
* **License**: MIT License (same as Ruby, see LICENSE)
