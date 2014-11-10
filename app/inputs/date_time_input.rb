class DateTimeInput < SimpleForm::Inputs::StringInput
  enable :placeholder, :min_max

  def input(wrapper_options = nil)
    if html5?
      input_html_options[:type] ||= input_type
    end

    formats = { date: "%Y-%m-%d", time: "%H:%M" }

    raw_value = object.send("#{attribute_name}")
    html_value = raw_value.strftime(formats[input_type.to_sym])

    input_html_options[:value] = html_value
    input_html_options['data-value'] = html_value

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    @builder.text_field(attribute_name, merged_input_options)
  end
end
