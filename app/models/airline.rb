class Airline < ActiveRecord::Base
  audited

  ALLIANCES = { :staralliance => "Star Alliance", :oneworld => "oneworld", :skyteam => "Sky Team" }

  has_attached_file :logo,
    :styles => { :medium => "35x35>", :icon => "16x16>" },
    :default_url => "/images/:class/:attachment/:style/missing.png",
    :path => ":rails_root/public/system/:class/:attachment/:style/:iata_code.png",
    :url => "/system/:class/:attachment/:style/:iata_code.png"
  validates_attachment_content_type :logo, :content_type => ["image/jpeg", "image/gif", "image/png"]

  def to_param
    iata_code
  end

  def in_alliance?
    !alliance.blank?
  end

  private

  Paperclip.interpolates :iata_code do |attachment, style|
    attachment.instance.iata_code
  end
end
