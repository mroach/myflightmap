class Airline < ActiveRecord::Base
  include Formattable
  audited

  ALLIANCES = { :staralliance => "Star Alliance", :oneworld => "oneworld", :skyteam => "Sky Team" }

  has_attached_file :logo,
    :styles => { large: "96x96>", medium: "48x48>", icon: "16x16>" },
    :default_url => "/images/:class/:attachment/:style/missing.png",
    :path => ":rails_root/public/system/:class/:attachment/:style/:iata_code.png",
    :url => "/system/:class/:attachment/:style/:iata_code.png"
  validates_attachment_content_type :logo, :content_type => ["image/jpeg", "image/gif", "image/png"]

  formattable "%{iata_code}: %{name}"

  def to_param
    iata_code
  end

  def in_alliance?
    !alliance.blank?
  end

  def has_logo?
    !logo.nil?
  end

  private

  Paperclip.interpolates :iata_code do |attachment, style|
    attachment.instance.iata_code.downcase
  end
end
