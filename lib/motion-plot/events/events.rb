module MotionPlot
  class Events
    CHART_TYPE_EVENT_MAPPINGS = {
      pie: {
        slice_selected: nil, # sliceWasSelectedAtRecordIndex
        plot_space: {
          touch_down: nil, # shouldHandlePointingDeviceDownEvent
          touch_up: nil, # shouldHandlePointingDeviceUpEvent (plotSpace:shouldHandlePointingDeviceUpEvent:atPoint:)
          dragged: nil, # shouldHandlePointingDeviceDraggedEvent
        }
      },
      bar: {
        bar_selected: nil, # barWasSelectedAtRecordIndex
        plot_space: {
          touch_down: nil, # shouldHandlePointingDeviceDownEvent
          touch_up: nil, # shouldHandlePointingDeviceUpEvent (plotSpace:shouldHandlePointingDeviceUpEvent:atPoint:)
          dragged: nil, # shouldHandlePointingDeviceDraggedEvent
        }
      },
      line: {
        symbol_selected: nil, # plotSymbolWasSelectedAtRecordIndex
        plot_space: {
          touch_down: nil, # shouldHandlePointingDeviceDownEvent
          touch_up: nil, # shouldHandlePointingDeviceUpEvent (plotSpace:shouldHandlePointingDeviceUpEvent:atPoint:)
          dragged: nil, # shouldHandlePointingDeviceDraggedEvent
        }
      }
    }

    attr_reader :subscriber

    def initialize(mappings={})
      @subscriber = mappings.delete(:subscriber)
      @subscribed = MAPPINGS.merge(mappings)
    end

    def bindings
      @subscribed
    end

    def delegate_event(event_key, withData: data)
      @subscriber.send(@subscribed.deep_find(event_key), data)
    end
  end
end