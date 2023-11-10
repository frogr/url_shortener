class Link < ApplicationRecord
  extend FriendlyId
  friendly_id :link_id, use: :slugged

  paginates_per 25
  belongs_to :user, optional: true
  has_many :events, class_name: 'Ahoy::Event', as: :subject

  def click_count
    Ahoy::Event.where(name: "Link clicked").where("json_extract(properties, '$.link_id.id') = ?", id).count
  end
end
