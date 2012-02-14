---
layout: default
title: nanoc-cachebuster
tagline: Simple cache busting for Nanoc projects
nav:
  - url: http://avdgaag.github.com/nanoc-cachebuster
    label: Homepage
  - url: http://github.com/avdgaag/nanoc-cachebuster/issues
    label: Issues
  - url: http://github.com/avdgaag/nanoc-cachebuster
    label: Source
  - url: http://rubydoc.info/gems/nanoc-cachebuster/0.1.0/frames
    label: Docs
---
With a static site generator like [Nanoc][], you no longer have to worry about back-end performance. But there are front-end gains to be made. the `nanoc-cachebuster` gems you make the most of client-side caching by allowing far-future expiration dates, while making it easy for you to deploy changes.
{: .leader }

## The problem

Client-side caching reduces the amount of data the client has to download. All the server has to do is tell the client that a requested file has not changed since the last time he downloaded it, using **far-future expiration** dates.

But setting a far-future expires header has a downside. When the client ‘permanently’ caches a file, you as the developer cannot push changes anymore. Since there is no way to tell the client that this time the file has changed, the only option is to use a different file altogether.

We could mimick using a different file by appending a query string to our URL. It sounds smart, but some proxies will actually not cache these supposedly dynamic files at all. So, we simply need to update the filename itself.

We could use version numbers, but that is too much of a hassle. I prefer including a hash of the file in its filename – so that every time the content changes, the filename changes. And when the filename changes, the URL changes, effectively flushing the client’s cache.

## Usage

### Installation

`nanoc-cachebuster` is a Ruby gem that extends [Nanoc][], so make sure you've got those set up and ready to go first. It should work fine with both Ruby 1.8 and Ruby 1.9. Simply install the gem from [rubygems.org][]:

{% highlight sh %}
$ gem install nanoc-cachebuster
{% endhighlight %}

### Load it in your project

To use `nanoc-cachebuster` in your static site project, it is probably best to `require` and `include` it in your `./lib/default.rb` file:

{% highlight ruby %}
require 'nanoc/cachebuster'
include Nanoc::Helpers::CacheBusting
{% endhighlight %}

### Usage in your `Rules` file

You can now use the `#cachebust?` and `#fingerprint` helper methods in your `Rules` file to determine whether to cachebust a file, and get its contents-based hash:

{% highlight ruby %}
route '/styles/' do
  item.identifier.chop + fingerprint(item[:filename]) + '.' + item[:extension]
end
{% endhighlight %}

This example will rewrite `styles.css` to something like `styles-cb18cc7a9df.css` in your output directory. You can still reference `styles.css` in your source files, though -- when you use the supplied filter it will be automatically rewritten to the output filename on compilation:

{% highlight ruby %}
compile '*' do
  filter :cache_buster
end
{% endhighlight %}

## Credits

* **Author**: Arjan van der Gaag (<arjan@arjanvandergaag.nl>)
* **License**: MIT license (same as Ruby)

If you have any ideas or improvements for this gem, do share them on Github.

## More information

* [Nanoc][]
* [My blog post on nanoc-cachebuster][1]

[Nanoc]: http://nanoc.stoneship.org
[rubygems.org]: http://rubygems.org
[1]: http://arjanvandergaag.nl/blog/nanoc-cachebuster.html

