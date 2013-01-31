# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require "bundler/gem_tasks"
require "bundler/setup"
Bundler.require :default

$:.unshift("./lib/")
require './lib/motion-plot'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MotionPlot'


  app.frameworks << "QuartzCore"

  app.pods do
    pod "CorePlot"
  end

end