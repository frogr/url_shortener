class Blip < ApplicationRecord
  before_create :generate_unique_url
  belongs_to :user

  private

  def generate_unique_url
    loop do
      self.unique_url = SecureRandom.hex(10)
      break unless self.class.exists?(unique_url: unique_url)
    end
  end
end
