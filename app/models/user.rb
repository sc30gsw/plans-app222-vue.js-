class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[twitter facebook]

  with_options presence: true do
    validates :nickname, format: { with: /\A[a-z\d]{4,16}+\z/i, message: 'が4文字以上の半角英数字ではありません' }
    validates :password, format: { with: /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]{8,100}+\z/i, message: 'は8文字以上の半角英数字ではありません' }
  end

  has_one :intro
  has_many :sns_credentials
  has_many :notes
  has_one_attached :image
  has_many :comments
  has_many :commented_notes, through: :comments, source: :note
  has_many :favorites, dependent: :destroy
  has_many :favorited_notes, through: :favorites, source: :note
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverse_of_relationships, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverse_of_relationships, source: :user

  # SNS認証ログイン
  def self.from_omniauth(auth)
    sns = SnsCredential.where(provider: auth.provider, uid: auth.uid).first_or_create
    user = User.where(email: auth.info.email).first_or_initialize(
      nickname: auth.info.name,
      email: auth.info.email
    )
    if user.persisted?
      sns.user = user
      sns.save
    end
    { user: user, sns: sns }
  end

  # ゲストログイン
  def self.guest
    find_or_create_by!(email: 'guest@example.com', nickname: 'guest') do |user|
      user.password = 'guest4040'
    end
  end

  
end
