class Birthday < ApplicationRecord
    validates :user_id, presence: true
    validates :birthday, presence: true
end
