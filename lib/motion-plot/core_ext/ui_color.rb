class UIColor
  def to_cpt_color
    CPTColor.alloc.initWithCGColor(self.CGColor)
  end
end