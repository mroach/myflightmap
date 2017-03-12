include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do |config|
  # By default, we're creating Audit::SecurityEvent logs (config/initializers/warden.rb)
  # every time someone logs-in and logs-out. Don't do this in the test environment
  # 1) Unnecessary database writes
  # 2) Mock/stubbed User objects violate foreign key constraints
  config.before(:suite) do
    ENV['AUDIT_SECURITY_EVENTS'] = 'false'
  end

  # If a test is specifcally using a persisted User and wants to test logging
  # then provide the ability to do that by appending metadata to the example
  #
  # Example (right out of the omniauth callbacks controller spec):
  #
  # it 'creates a logged security event', audit_security_events: true do
  #   user.find_or_create_identity! oauth
  #   expect {
  #     visit "/users/auth/#{provider}"
  #   }.to change(Audit::SecurityEvent, :count).by(1)
  # end
  config.around(:example, audit_security_events: true) do |example|
    previous_status = ENV.fetch('AUDIT_SECURITY_EVENTS', 'false')
    ENV['AUDIT_SECURITY_EVENTS'] = 'true'
    example.run
    ENV['AUDIT_SECURITY_EVENTS'] = previous_status
  end
end
