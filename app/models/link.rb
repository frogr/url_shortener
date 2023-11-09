class Link < ApplicationRecord
  extend FriendlyId
  friendly_id :link_id, use: :slugged

  belongs_to :user, optional: true
end
