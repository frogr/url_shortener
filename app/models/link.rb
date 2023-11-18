class Link < ApplicationRecord
  extend FriendlyId
  friendly_id :link_id, use: :slugged

  paginates_per 12
  belongs_to :user, optional: true
  has_many :events, class_name: 'Ahoy::Event', as: :subject

  def click_count
    Ahoy::Event.where(name: "Link clicked")
              .where("properties::json -> 'link_id' ->> 'id' = ?", id.to_s)
              .count
  end

  def shortened_url
    ENV["ROOT_URL"] + self.link_id
  end

  def full_url
    url = self.url
    url = "https://#{url}" unless url.start_with?('http://', 'https://')
    url 
  end
end
