module MotionPlot
  class BaseDelegate

    def initialize(source)
      @delegated_to = source
    end

    def numberOfRecordsForPlot(plot)
      @delegated_to.series[plot.identifier].data.size
    end

  end
end