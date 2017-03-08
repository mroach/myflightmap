module Formattable
  extend ActiveSupport::Concern

  DEFAULTS = {
    :default_format => 'NO FORMAT?'
  }

  included do
    class_attribute :formattable_settings
  end

  module ClassMethods
    def formattable(default_format, settings = {})
      self.formattable_settings = DEFAULTS.merge(settings)
      self.formattable_settings[:default_format] = default_format
    end
  end

  def to_s(format_string = nil)
    if self.formattable_settings.nil?
      super()
    else
      format_string ||= self.formattable_settings[:default_format]

      # inject the attributes into the format string
      # collapse repeating whitespace and strip leading and trailing whitespace
      # this is likely to happen when values were nil
      (format_string % self.attributes.symbolize_keys).sub(/[ ]{2,}/, ' ').strip
    end
  end
end
