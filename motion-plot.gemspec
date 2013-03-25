# -*- encoding: utf-8 -*-
require File.expand_path('../lib/motion-plot/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Amit Kumar"]
  gem.email         = ["toamitkumar@gmail.com"]
  gem.description   = "Create native iOS charts using simple JSON as you are used-to with Highcharts like JS library. This library is a wrapper on top of CorePlot"
  gem.summary       = "Create native iOS charts using simple JSON as you are used-to with Highcharts like JS library. This library is a wrapper on top of CorePlot"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split("\n").delete_if {|x| x.include? "examples"}
  # gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.name          = "motion-plot"
  gem.require_paths = ["lib"]

  gem.version       = MotionPlot::VERSION

  gem.add_dependency "bubble-wrap"
  gem.add_dependency 'motion-cocoapods', '>= 1.2.1'
  gem.add_development_dependency 'rake'
end
