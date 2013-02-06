require "motion-plot/version"
require 'bubble-wrap'
require 'motion-cocoapods'
require 'cocoapods'


Motion::Project::App.setup do |app|

  Dir.glob(File.join(File.dirname(__FILE__), 'motion-plot/**/*.rb')).each do |file|
    app.files.unshift(file)
  end

  app.files.unshift(File.join(File.dirname(__FILE__), 'motion-plot/chart/base.rb'))

  app.frameworks << "QuartzCore"

  app.pods do
    pod "CorePlot"
  end
end