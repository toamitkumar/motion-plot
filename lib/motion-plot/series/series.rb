class Series

  attr_accessor :name, :data, :color

  def initialize(args)
    args.each_pair {|key, value|
      send("#{key}=", value) if(respond_to?("#{key}="))
    }
  end

end