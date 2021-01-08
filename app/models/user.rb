class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:twitter, :facebook]
  
  with_options presence: true do
    validates :nickname, format: { with: /\A[a-z\d]{4,16}+\z/i, message: 'が4文字以上の半角英数字ではありません' }
    validates :password, format: { with: /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]{8,100}+\z/i, message: 'は8文字以上の半角英数字ではありません' }
  end

  has_one :intro
  has_many :sns_credentials

  # メソッド定義時binding.pryでauthが取得できるか確認する
  def self.from_omniauth(auth)
    sns = SnsCredential.where(provider: auth.provider, uid: auth.uid).first_or_create

    # sns認証したことがあればアソシエーションで取得
    # なければemailでユーザー検索して取得orビルド(保存しない)
    user = User.where(email: auth.info.email).first_or_initialize(
      nickname: auth.info.name
         email: auth.info.email
    )
  end
end
