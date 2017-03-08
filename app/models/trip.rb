class Trip < ActiveRecord::Base
  extend FriendlyId
  include Formattable
  audited

  has_many :flights
  belongs_to :user
  validates_presence_of :user_id, :name

  default_scope { order('begin_date ASC') }

  friendly_id :name, use: [:slugged, :scoped], scope: :user

  formattable '%{name}: %{begin_date} - %{end_date}'

  def self.belonging_to(user_id)
    where('user_id = ?', user_id)
  end

  def self.recent
    reorder('begin_date DESC')
  end

  def self.completed
    where('end_dateb < ?', Time.now.utc)
  end

  def self.future
    where('begin_date > ?', Time.now.utc)
  end

  def private?
    !self.is_public?
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
