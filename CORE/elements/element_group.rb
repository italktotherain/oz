class ElementGroup

  def initialize(*elements)
    @elements = [elements].flatten
    @active = true
    @disabled = false
  end

  def deactivate
    @elements.each do |element|
      element.deactivate
    end
    @active = false
  end

  def activate
    @elements.each do |element|
      element.activate
    end
    @active = true
  end
  
  def activate_if(condition)
    condition ? activate : deactivate
  end

  def active?
    @active
  end

  def disable
    @elements.each do |element|
      element.disabled
    end
    @disabled = true
  end

  def enable
    @elements.each do |element|
      element.enable
    end
    @disabled = false
  end

  def disable_if(condition)
    condition ? disable : enable
  end

  def disabled?
    @disabled
  end
  
end
