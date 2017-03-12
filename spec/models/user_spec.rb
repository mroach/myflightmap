require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many :trips }
    it { is_expected.to have_many :flights }
    it { is_expected.to have_many :identities }
  end

  describe do
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of :email }
  end
end
