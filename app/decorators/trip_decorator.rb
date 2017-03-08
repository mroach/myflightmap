class TripDecorator < Draper::Decorator
  delegate_all

  def css_classes
    [private_css_class]
  end

  def private_css_class
    'private' if object.private?
  end
end
