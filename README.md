A simple Ruby gem that enhances Nanoc with cache-busting capabilities.

**warning**: this gem is outdated and no longer actively maintained. Proceed with caution.

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

```ruby
require 'nanoc/cachebuster'
```

Usage
=====

This gem provides a simple helper method you can use to rewrite the output
filename of your static assets to include a content-based fingerprint.
A simple filter will look up the output filename you have generated, and
replace any references to the regularly-named file to the rewritten one.

So, when you include a stylesheet:

```html
<link rel="stylesheet" href="styles.css">
```

And you rewrite the output of the file to include a fingerprint:

```ruby
# in your ./lib/default.rb
include Nanoc::Helpers::CacheBusting
# in ./Rules
route '/styles/' do
  fp = fingerprint(item[:filename])
  item.identifier.chop + fp + '.css'
end
```

The filter will change your HTML on compilation to:

```html
<link rel="stylesheet" href="styles-cb7a4bb98ef.css">
```

You get simple, content-based cachebusters for free. All that is left for you
to do is set some far-future expires header in your server configuration.

Development
===========

Development happens in the `develop` branch, with stable code being merged to `master` to be released.

Changes
-------

See HISTORY.md for the full changelog.

Dependencies
------------

nanoc-cachebuster obviously depends on Nanoc, but has no further dependencies.
To test it you will need Rspec.

Credits
=======

* **Author**: Arjan van der Gaag <arjan@arjanvandergaag.nl>
* **License**: MIT License (same as Ruby, see LICENSE)
* **With contributions from**: John Nishinaga
