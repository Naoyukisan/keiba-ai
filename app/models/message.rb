# app/models/message.rb
class Message < ApplicationRecord
  # ユーザー削除時に user_id が NULL になる方針のため optional: true にする
  belongs_to :user, optional: true

  # （他の関連があればここに）
end
