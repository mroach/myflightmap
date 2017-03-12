RSpec::Matchers.define :have_friendly_id do
  module_to_find = FriendlyId::Model

  match do |actual|
    actual.class.included_modules.include? module_to_find
  end

  failure_message do |actual|
    "expected that #{actual.model_name.name} would include #{module_to_find}"
  end
end
