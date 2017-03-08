require 'digest/md5'

class UserDecorator < Draper::Decorator
  delegate_all

  def image_tag(size = :square)
    h.image_tag image(size), alt: object.display_name, class: 'user-image'
  end

  # Return a URL for a user photo
  # Should move to decorator
  def image(size = :square)
    # this isn't the right way to do this. the image should be copied to user.image
    object.image.blank? &&
      (identity_with_image = self.identities.where('image IS NOT NULL').first) &&
      (object.image = identity_with_image.image)

    # If they don't have an image URL, use gravatar
    if object.image.blank?
      object.image = gravatar_url(size)
    else
      # For Facebook, we can ask for a specific size
      if object.image =~ /graph\.facebook\.com/
        object.image = "#{object.image}?type=#{size}"
      end

      if object.image =~ /googleusercontent\.com/
        sizes = { square: 50, small: 50, normal: 100, large: 200 }
        object.image.sub!(/sz=\d+/, "sz=#{sizes[size]}")
      end
    end

    object.image
  end

  def gravatar_url(size = :normal)
    hash = Digest::MD5.hexdigest(object.email.downcase)
    sizes = { square: 50, small: 50, normal: 100, large: 200 }
    "http://www.gravatar.com/avatar/#{hash}?s=#{sizes[size]}"
  end
end
