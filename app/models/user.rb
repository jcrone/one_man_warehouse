class User < ApplicationRecord

  has_person_name
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates_format_of :email, with: /\@westcoastski\.com/, message: 'Your email is not Authorized ask Rachel'


end
