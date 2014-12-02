# Represents an OAuth identity. This allows a user to authenticate
# with one or more OAuth accounts and not have separate user records
class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, scope: :provider

  def self.find_for_oauth(auth)
    find_or_create_by(uid: auth.uid, provider: auth.provider) do |ident|
      # save the profile image with the identity so the user can pick
      # which identity's profile image they want to use
      ident.image = auth.info.image
    end
  end
end
