# config/initializers/user_optional_assocs.rb
Rails.application.config.to_prepare do
  conn = ActiveRecord::Base.connection

  # 改めて安全に関連を追加（テーブルがあるときだけ）
  if conn.data_source_exists?('improvements')
    User.has_many :improvements, dependent: :nullify
  end
  if conn.data_source_exists?('histories')
    User.has_many :histories,    dependent: :nullify
  end
  if conn.data_source_exists?('messages')
    User.has_many :messages,     dependent: :nullify
  end
  if conn.data_source_exists?('blogs')
    User.has_many :blogs,        dependent: :nullify
  end
end
