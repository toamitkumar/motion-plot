# Motion::Plot

Create native iOS charts using simple JSON as you are used-to with Highcharts like JS library. 
This library is a wrapper on top of [CorePlot](https://code.google.com/p/core-plot/), the iOS plotting framework to build native chart using CoreAnimation, Core Data and Cocoa Bindings

## Installation

1. Add this line to your application's Gemfile:

    `gem 'motion-plot'`

  Then execute:

    `$ bundle`

  Or install it yourself as:

    `$ gem install motion-plot`

  And add `require 'motion-plot'` to your `Gemfile`

2. Run '`pod setup`' to install core-plot as a pod

## Usage

  1. Create a UIView (with whatever frame size you wish)
  2. Build a JSON structure with the details of the chart (look at examples for more)
  3. Initialize the chart type with this JSON (it returns back an instance of `CPTGraphHostingView`)
  4. Add the view returned to your view

  Look at the `examples` directory for detail usage options.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
