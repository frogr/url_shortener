class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  after_initialize :init

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :links
  has_many :blips
  has_many :events, class_name: 'Ahoy::Event', as: :subject
  has_many :visits, class_name: "Ahoy::Visit"

  def admin?
    self.role == "admin"
  end

  def user?
    self.role == "user"
  end

  def promote_to_admin
    self.update(role: "admin")
  end

  def demote_to_user
    self.update(role: "user")
  end

  def change_role(new_role)
    self.update(role: new_role)
  end

  def init
    self.role ||= "user"
  end
end
