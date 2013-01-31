require "motion-plot/version"
require 'bubble-wrap'
require 'motion-cocoapods'
require 'cocoapods'


Motion::Project::App.setup do |app|

  # BW.require File.expand_path('../motion-plot/**/*.rb', __FILE__)

  p File.join(File.dirname(__FILE__), 'motion-plot/**/*.rb')

  app.files.unshift(Dir.glob("./motion-plot/**/*.rb"))

  # Dir.glob(File.join(File.dirname(__FILE__), 'motion-plot/**/*.rb')).each do |file|
  #   p file
  #   app.files.unshift(file)
  # end

  app.frameworks << "QuartzCore"

  app.pods do
    pod "CorePlot"
  end
end