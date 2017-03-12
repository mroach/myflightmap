# Helper for dealing security in tests. Usually for bypassing it.
module Security
  # Avoids having to create an user and person every time we want to "skip"
  # authentication
  # This code is horrendous and could probably be greatly simplified
  def sign_in_stubbed(user = stubbed_user)
    if request.nil?
      sign_in_stubbed_request user
    else
      sign_in_stubbed_controller user
    end
  end

  def stubbed_user(role = :admin)
    user = double('user')
    allow(user).to receive(:to_key).and_return([1])
    allow(user).to receive(:authenticatable_salt).and_return('')
    allow(user).to receive(:roles_name).and_return [role.to_s]
    allow(user).to receive(:has_role?).with(role.to_sym).and_return(true)
    allow(user).to receive(:any_role?) { |*v| v.flatten.include?(role) }
    allow(user).to receive(:person).and_return double('person')
    user
  end

  private

  def sign_in_stubbed_request(user)
    # This is for integration tests where the request object isn't available
    # and we have to stub the methods Warden needs to pass authentication
    sign_in user, scope: :user
  end

  def sign_in_stubbed_controller(user)
    # This is for controller tests
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end

RSpec.configure do |c|
  c.include Security
end
