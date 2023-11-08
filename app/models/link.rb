class Link < ApplicationRecord
  extend FriendlyId
  friendly_id :link_id, use: :slugged
end
