class Trip < ActiveRecord::Base
  extend FriendlyId
  include Formattable
  audited

  has_many :flights
  belongs_to :user

  default_scope { order('begin_date ASC') }

  friendly_id :name, use: [:slugged, :scoped], scope: :user

  formattable "%{name}: %{begin_date} - %{end_date}"

  # See if the flight is visible to the current user
  def is_visible_to?(user_id)
    self.user_id == user_id || self.is_public?
  end

  def self.belonging_to(user_id)
    where("user_id = ?", user_id)
  end

  def self.visible_to(user_id)
    where("user_id = ? OR is_public = ?", user_id, true)
  end

  def self.visible
    where("is_public = ?", true)
  end

  def refresh_dates!
    begin_date = flights.minimum(:depart_date)
    end_date = flights.maximum(:arrive_date)
    logger.debug "Trip #{name} (#{user.username}) is #{begin_date} to #{end_date}"
    update(begin_date: begin_date, end_date: end_date)
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
